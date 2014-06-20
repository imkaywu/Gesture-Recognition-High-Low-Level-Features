%--------------------------------------------------------------------------
% Detect the high-level(sampled contour points) and low-level feature(LCS)
% function:
%  - load_gesture: load the '.m' files of each gesture image
%  - blob_detector: detect the main blob in the image, eliminate noise
%  - get_disparity: assign each pixel a disparity value
%  - gesture_projection: project hand gesture to a certain plane
%  - edge_finder: find edge pixels, stored in a row * col matrix
%  - edge_connector2: connect the edge pixels using 8-neighbor connectivity
%  - center_finder: find the center of hand using distance transform
%  - direction_detector1: find the orientation of hand gestures
%  - start_end_points: find the index of the start and end contour point.
%  - trans_graph1: transform the original image into a time-series curve
%  - finger_finder2: find fingertips (highest) and fingervalleys (lowest)
%  - fingertip_adjust: adjust the position(s) of fingertip(s)
%  - fingerroot_detector: find the accurate positions of fingerroots
%  - feature_extract: extract features
%--------------------------------------------------------------------------
clear;
clc;
[gesture, image_num, ~] = load_gesture;
num = 50;   % num of LCS feature
interv=100;    % interv + 1: num of sampled contour points
distance_sample_map = zeros(sum(image_num(2 : end)), interv + 1);
distance_LCS_map = zeros(sum(image_num(2 : end)), num);
distance_LCS_map1 = zeros(sum(image_num(2 : end)), num);
distance_LCS_map2 = zeros(sum(image_num(2 : end)), num);
for image_index = 25 : size(gesture, 2)
    i_name = gesture{image_index};
    load(['..\hand\', i_name, '.mat']);
    if(exist('dis1_d2_e2', 'var'))
        image = dis1_d2_e2;
    elseif(exist('dis2_d2_e2', 'var'))
        image = dis2_d2_e2;
    end
    binary_map = zeros(size(image));
    binary_map(image > 0) = 1;
    %% Detect the main blob
    binary_map = blob_detector(binary_map);
    image(binary_map ~= 1) = 0;% eliminate background noise
    disparity = get_disparity(image);
    binary_map = gesture_projection(image, disparity, 0.35);
    binary_map = blob_detector(binary_map);
    %% Find the edge points
    [row, colum] = size(binary_map);
    edge_map = edge_finder(binary_map, row, colum);
%     figure;
%     imshow(edge_map);
%     title(['Gesture ', num2str(gesture_type), ' Total: ', num2str(size(gesture, 1)), ', No. ', num2str(image_index)]);
    %% Connect the edge points
    [x_array, y_array] = edge_connector2(edge_map, row, colum);
    %% Find the center point
    y_up = min(y_array);
    y_bottom = max(y_array);
    while(1)
        [x_center, y_center] = center_finder(edge_map, binary_map, x_array, y_array);
        if(y_center - y_up < 3.5 * (y_bottom - y_center))   % the centroid may locate at the arm
            break;
        end
        edge_map(y_center, x_center) = 1;
        y_bottom = y_center;
    end
    %% Detect the hand direction
    hand_direction = direction_detector1(x_array, y_array);
    %% Find the start and end points
    start_degree = 120;
    while(1)
        [start_index, end_index] = start_end_points(x_array, y_array, x_center, y_center, hand_direction, start_degree, 90);
        if(norm(x_array(start_index) - x_center, y_array(start_index) - y_center) > 2 * norm(x_array(end_index) - x_center, y_array(end_index) - y_center))
            start_degree = start_degree - 10;
            continue;
        elseif(start_index < end_index)
            break;
        end
        start_degree = start_degree - 10;
    end
    %% Transfer to time-series curve
    [degree, norm_distance] = trans_graph1(x_array(start_index : end_index), y_array(start_index : end_index), x_center, y_center, 'norm_on');
    %% Find the region of fingers
    if(max(norm_distance) < 1.653)
        fprintf('Image %d is recognized as fist, max_dist = %f.\n', image_index, max(norm_distance));
%         imshow(edge_map);
%         text(400, 30, '\color{white}\fontsize{35}Gesture 1');
%         hold on;
%         plot(x_center, y_center, 'ro');
%         plot(x_array([start_index, end_index]), y_array([start_index, end_index]), 'ro');
        if(exist('dis1_d2_e2', 'var'))
            clear dis1_d2_e2;
        elseif(exist('dis2_d2_e2', 'var'))
            clear dis2_d2_e2;
        end
        continue;
    else
        [fingertip, fingerroot] = finger_finder2(degree, norm_distance);    % fingerroot are not accurate, therefore fingerroot_detector is needed
        fingerroot = start_index + fingerroot - 1;
        fingertip = start_index + fingertip - 1;
    end
    %% Adjust the positions of fingertips
    fingertip = fingertip_adjust(y_array, fingertip);
    %% Find the accurate positions of fingerroots
    [fingerroot, finger_direction] = fingerroot_detector(x_array, y_array, fingertip, fingerroot);
    %% Detect the hand direction again
    hand_direction = mean(finger_direction);
    [start_index, end_index] = start_end_points(x_array, y_array, x_center, y_center, hand_direction, 90, 90);
    %% Extract features
    [distance_sample, dist_smp, dist_smp1 , dist_smp2] = feature_extract(x_array, y_array, x_center, y_center, start_index, end_index, interv, num);
    distance_sample_map(image_index - image_num(1), :) = distance_sample;
    distance_LCS_map(image_index - image_num(1), :) = dist_smp';
    distance_LCS_map1(image_index - image_num(1), :) = dist_smp1';
    distance_LCS_map2(image_index - image_num(1), :) = dist_smp2';
    %%
    if(exist('dis1_d2_e2','var'))
        clear dis1_d2_e2;
    elseif(exist('dis2_d2_e2','var'))
        clear dis2_d2_e2;
    end
end
%% Store data
save('..\data\projection\distance_sample_map(100)\gesture_distance_map.mat', 'distance_sample_map');
save('..\data\projection\dist_smp(50)\normalized_std\gesture_dist_smp.mat', 'distance_LCS_map');
distance_LCS_map = distance_LCS_map1;
save('..\data\projection\dist_smp(50)\normalized_std_mean\gesture_dist_smp.mat', 'distance_LCS_map');
distance_LCS_map = distance_LCS_map2;
save('..\data\projection\dist_smp(50)\normalized_min_max\gesture_dist_smp.mat', 'distance_LCS_map');
save('..\data\projection\distance_sample_map(100)\gesture_num.mat', 'gesture_num');