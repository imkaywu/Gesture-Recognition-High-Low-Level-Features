function [x_center, y_center]=center_finder(edge_map, binary_map, x_array, y_array)
    %----------------------------------------------------------------------
    % calculate the center of the hand gesture
    %  - solution 1: average of the x-coordinate, y-coordiante
    %  - solution 2: distance transform
    %   * dist_trans: function used to calculate DT
    %----------------------------------------------------------------------
    %% ----find the center point, solution 1---- %%
    % [y_binary, x_binary] = ind2sub(size(binary_map), find(binary_map));
    % x_center = round(mean(x_binary));
    % y_center = round(mean(y_binary));
    %% ----find the center point, solution 2---- %%
    max_distance = 0;
    dist_trans_map = bwdist(edge_map);    % MATLAB's function for distance transform
    % dist_trans_map1 = dist_trans(edge_map);    % distance transform the author implemented
    dist_trans_map(binary_map == 0) = 0;
    x_left = min(x_array(x_array ~= 0));
    x_right = max(x_array);
    y_up = min(y_array(y_array ~= 0));
    y_bottom = max(y_array);
    for i = x_left : x_right
        for j = y_up : y_bottom
            if(dist_trans_map(j, i) > max_distance)
                x_center = i;
                y_center = j;
                max_distance = dist_trans_map(j, i);
            end
        end
    end
end