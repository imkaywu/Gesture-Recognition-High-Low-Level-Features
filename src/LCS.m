function [dist_smp , dist_smp1 , dist_smp2 ] = LCS(x , y , start_index , end_index , min_dist, w , num)
%     size = end_index - start_index + 1;
%     u = zeros(size , 1);
%     v = zeros(size , 1);
%     for i = start_index : end_index
%         u(i - start_index + 1) = x(i) * (y(i - (w - 1) / 2) - y(i + (w - 1) / 2))...
%             + y(i) * (x(i + (w - 1) / 2) - x(i - (w - 1) / 2))...
%             + (y(i + (w - 1) / 2)) * (x(i - (w - 1) / 2))...
%             - (y(i - (w - 1) / 2)) * (x(i + (w - 1) / 2));
%         v(i - start_index + 1) = sqrt((y(i - (w - 1) / 2) - y(i + (w - 1) / 2))^2 + (x(i - (w - 1) / 2) - x(i + (w - 1) / 2))^2);
%     end
%     distance = abs(u ./ v);

    % P-点坐标　Q1, Q2线上两点坐标
    size = end_index - start_index + 1;
    dist_smp = zeros(num , 1);
    distance = zeros(size , 1);
    for i = start_index : end_index
        if(i <= (w - 1) / 2)
            w = 2 * start_index - 1;
        elseif(i + (w - 1) / 2 > length(x))
            w = 2 * (length(x) - i) + 1;
        end
        P = [x(i) , y(i)];
        Q1 = [x(i - (w - 1) / 2) , y(i - (w - 1) / 2)];
        Q2 = [x(i + (w - 1) / 2) , y(i + (w - 1) / 2)];
        distance(i - start_index + 1) = abs(det([Q2 - Q1 ; P - Q1])) / norm(Q2 - Q1);
    end
    % dist_tmp是采样值
    num_smp = linspace(1 , size , num);
    for i = 1 : num
        num_left = floor(num_smp(i));
        num_right = ceil(num_smp(i));
        dist_left = distance(num_left);
        dist_right = distance(num_right);
        if(dist_left < dist_right)
            dist_temp = dist_left;
            num_temp = num_left;
        elseif(dist_left > dist_right)
            dist_temp = dist_right;
            num_temp = num_right;
        else
            dist_smp(i) = dist_left;
            continue;
        end
        dist_smp(i) = (num_smp(i) - num_temp) / (num_right - num_left) * (dist_right - dist_left) + dist_temp;
    end
    dist_smp = dist_smp / min_dist;
    dist_smp1 = (dist_smp - mean(dist_smp)) / std(dist_smp);
    dist_smp2 = (dist_smp - min(dist_smp)) / (max(dist_smp) - min(dist_smp));
    dist_smp = dist_smp / std(dist_smp);
end