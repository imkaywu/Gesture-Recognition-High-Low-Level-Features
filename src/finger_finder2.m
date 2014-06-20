function [fingertip, fingerroot] = finger_finder2(degree, norm_distance)
    %----------------------------------------------------------------------
    % find the fingertips and their corresponding roots of fingers
    % 
    % variable:
    %  - fingertip: n * 1 (n: fingertip number)
    %  - fingerroot: n * 2 (n: fingertip number)
    %----------------------------------------------------------------------
    j = 1;
    firstTime = 1;
    finger_edge = 1;
    length = size(degree, 1);
    fingertip = zeros(5, 1);
    fingertip_remain = zeros(5, 1);
    fingervalley = zeros(6, 1);
    fingerroot = zeros(5, 2);
    fingerroot_remain = zeros(5, 2);
    min_distance = norm_distance(1);
    max_distance = norm_distance(1);
    
    % detect all the highest and lowest points as fingertips and fingervalleys
    for i = 1 : length
        if(norm_distance(i) < min_distance)
            min_distance = norm_distance(i);
            max_distance = norm_distance(i);
            if(min_distance < norm_distance(finger_edge))
                finger_edge = i;
            end
        elseif(norm_distance(i) < max_distance)
            fingertip(j) = i - 1;
            fingervalley(j) = finger_edge;
            j = j + 1;
            firstTime = ~firstTime;
            min_distance = norm_distance(i);
            max_distance = norm_distance(i);
        elseif(norm_distance(i) > max_distance)
            if(firstTime)
                finger_edge = i - 1;
                firstTime = ~firstTime;
            end
            max_distance = norm_distance(i);
        end
    end
    
    % eliminate invalid fingertips and fingervalleys
    j = 1;
    fingertip_length = find(fingertip, 1, 'last');
    fingervalley(fingertip_length + 1) = size(degree, 1);
    for i = 1 : fingertip_length
        index_left = i;
        index_right = i + 1;
%         if(i == 7)
%         end
        if(sum(fingertip_remain) == 0 || max(norm_distance(fingertip(fingertip_remain(1 : find(fingertip_remain, 1, 'last'))))) < norm_distance(fingertip(i)))
            fv_left_all = fingervalley(1 : index_left);
        else
            [ft_highest, ft_highest_index] = max(norm_distance(fingertip(fingertip_remain(1 : find(fingertip_remain, 1, 'last')))));
            ft_highest_index = fingertip_remain(ft_highest_index);
            fv_left_all = fingervalley(ft_highest_index + 1 : index_left);
        end
        fv_right_all = fingervalley(index_right : fingertip_length + 1);
%         fv_left_all(norm_distance(fv_left_all) > 1.85) = [];
%         fv_right_all(norm_distance(fv_right_all) > 1.85) = [];
        fv_left_index = (norm_distance(fingertip(i)) - norm_distance(fv_left_all)) ./ norm_distance(fv_left_all) > 0.49;
        fv_right_index = (norm_distance(fingertip(i)) - norm_distance(fv_right_all)) ./ norm_distance(fv_right_all) > 0.49;
        fv_left_all = fv_left_all(fv_left_index);
        fv_right_all = fv_right_all(fv_right_index);
        
        if(sum(fv_left_index) ~= 0 && size(fv_left_all, 1) > 1)
            optim_func_left = (norm_distance(fingertip(i)) - norm_distance(fv_left_all)) ./ norm_distance(fv_left_all) - 2.5 * (degree(fingertip(i)) - degree(fv_left_all)) ./ degree(fv_left_all);
            [maxVal, maxInd] = max(optim_func_left);
            fv_left_all = fv_left_all(maxInd);
        end

        if(sum(fv_right_index) ~= 0 && size(fv_right_index, 1) > 1)
            optim_func_right = (norm_distance(fingertip(i)) - norm_distance(fv_right_index)) ./ norm_distance(fv_right_index) - 2.5 * (degree(fv_right_index) - degree(fingertip(i))) ./ degree(fv_right_index);
            [maxVal, maxInd] = max(optim_func_right);
            fv_right_all = fv_right_all(maxInd);
        end
        
        if(sum(fv_left_index) == 0 || sum(fv_right_index) == 0)
            continue;
        else
            fingertip_remain(j) = i;
            fingerroot_remain(j, :) = [fv_left_all, fv_right_all];
            j = j + 1;
        end
    end
    index = find(fingertip_remain == 0);
    fingertip_remain(index) = [];
    fingertip_remain = fingertip(fingertip_remain);
    fingerroot_remain(index, :) = [];
    
    % choose one fingertip among >= 2 fingertips that have overlapped fingervalleys, an example: 
    % {fingertip: 100, fingervalley: (50, 150)}, {fingertip: 200, fingervalley: (120, 250)}
    n = 1;
    fingertip_remove = zeros(1,size(fingertip_remain,1));
    for i = 1 : size(fingertip_remain, 1) - 1
        for j = i + 1 : size(fingertip_remain, 1)
            if(fingerroot_remain(i, 1) >= fingerroot_remain(j, 1) || fingerroot_remain(i, 2) > fingerroot_remain(j, 1))    % between the two numbers
                if(sum((norm_distance(fingertip_remain(i)) - norm_distance(fingerroot_remain(i, :))) ./ norm_distance(fingerroot_remain(i, :))) > sum((norm_distance(fingertip_remain(j)) - norm_distance(fingerroot_remain(j, :))) ./ norm_distance(fingerroot_remain(j, :))))
                    fingertip_remove(n) = j;
                else
                    fingertip_remove(n) = i;
                end
                n = n + 1;
            end
        end
    end
    fingertip_remove(fingertip_remove == 0) = [];
    fingertip_remove = unique(fingertip_remove);
    fingertip_remain(fingertip_remove) = [];
%     fingertip_remain = unique(fingertip_remain);
    fingerroot_remain(fingertip_remove, :) = [];
    
    % choose the fingertip among >= 2 fingertips that have the same fingervalleys, an example:
    % {fingertip: 100, fingervalley: (50, 150)}, {fingertip: 120, fingervalley: (80, 150)}
    fingervalley_cato = zeros(size(fingertip_remain, 1));
    flag=zeros(1, size(fingertip_remain, 1));
    for i = 1 : size(fingertip_remain, 1) - 1
        for j = i + 1 : size(fingertip_remain, 1)
            if(sum(fingerroot_remain(i, :) == fingerroot_remain(j, :)) && flag(j) == 0)
                fingervalley_cato(i, [2 * (j - i) - 1, 2 * (j - i)]) = [i, j];
                flag([i, j]) = 1;
            end
        end
    end
    
    n = 1;
    fingertip = zeros(5, 1);
    if(size(fingertip_remain, 1) ~= 1 && sum(sum(fingervalley_cato)) ~= 0)
        for i = 1 : size(fingervalley_cato, 1)
            fingervalley_cato_temp = fingervalley_cato(i, :);
            if(sum(fingervalley_cato_temp) ~= 0)
                fingertip_index = unique(fingervalley_cato_temp(fingervalley_cato_temp ~= 0));
                optim_func = zeros(size(fingertip_index, 2), 1);
                for j = 1 : size(fingertip_index, 2)
                    optim_func(j) = norm_distance(fingertip_remain(fingertip_index(j))) - mean(norm_distance(fingerroot_remain(fingertip_index(j), :)));
                end
                [~, fingertip_pos] = max(optim_func);
                fingertip_pos = fingertip_index(fingertip_pos);
                fingertip(n) = fingertip_remain(fingertip_pos);
                fingerroot(n, :) = fingerroot_remain(fingertip_pos, :);
                n = n + 1;
            elseif(flag(i) == 0)
                fingertip(n) = fingertip_remain(i);
                fingerroot(n, :) = fingerroot_remain(i, :);
                n = n + 1;
            end
        end
    else
        fingertip = fingertip_remain;
        fingerroot = fingerroot_remain;
    end
    
    finger_remove = fingertip == 0;
    fingertip(finger_remove) = [];
    fingerroot(finger_remove, :) = [];
    [fingertip, ft_index] = sort(fingertip);
    fingerroot = fingerroot(ft_index, :);
    
    % used to solve noise peak in gesture4 image7
    if(find(fingertip, 1, 'last') > 1 && (degree(fingerroot(1, 2)) - degree(fingerroot(1, 1))) / (norm_distance(fingertip(1)) - mean(norm_distance(fingerroot(1, :)))) > 0.3)
        fingertip(1) = [];
        fingerroot(1, :) = [];
    end
    
%     figure;
%     plot(degree, norm_distance);
%     hold on;
%     plot(degree(fingertip), norm_distance(fingertip), 'r^');
%     plot(degree(fingerroot), norm_distance(fingerroot), 'ro');
end