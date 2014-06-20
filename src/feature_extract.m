function [distance_sample, dist_smp, dist_smp1, dist_smp2] = feature_extract(x_array, y_array, x_center, y_center, start_index, end_index, interv, num)
    %% Sampled contour points
    [degree, norm_distance] = trans_graph1(x_array(start_index : end_index), y_array(start_index : end_index), x_center, y_center, 'norm_on');

    degree_start = degree(1);
    degree_end = degree(end);
    degree_sample = linspace(degree_start, degree_end, interv+1);
    distance_sample = zeros(1, interv + 1);
    for i = 1 : interv + 1
        degree_interv = (degree_end - degree_start) / interv;
        while(~exist('index', 'var') || ~size(index, 1))
            index = find(abs(degree_sample(i) - degree) < degree_interv);
            degree_interv = 1.1 * degree_interv;
        end
        if(index(end) - index(1) + 1 > size(index, 1))
            index_temp = index(2 : end) - index(1 : end-1);
            index_temp = find(index_temp > 1) + 1;
            index_interv = zeros(size(index_temp, 1) + 1, 2);
            index_interv(1, 1) = index(1);
            index_interv(2 : end, 1) = index(index_temp);
            index_interv(1 : end - 1, 2) = index(index_temp - 1);
            index_interv(end, 2) = index(end);
            distance = 0;
            for j = 1 : size(index_interv, 1)
                if(mean(norm_distance(index_interv(j, 1) : index_interv(j, 2))) > distance)
                    distance = mean(norm_distance(index_interv(j, 1) : index_interv(j, 2)));
                end
            end
            distance_sample(i) = distance;
        else
            distance_sample(i) = mean(norm_distance(index));
        end
        clear index;
    end
%     figure;
%     plot(degree, norm_distance);
%     hold on;
%     stem(degree_sample, distance_sample);
%     hold off;
    %% LCS
    w = 67;
    dist = [x_array(start_index : end_index) - x_center, y_array(start_index : end_index) - y_center];
    min_dist = min(sqrt(sum(dist.^2, 2)));
    [dist_smp, dist_smp1, dist_smp2] = LCS(x_array, y_array, start_index, end_index, min_dist, w, num);
end