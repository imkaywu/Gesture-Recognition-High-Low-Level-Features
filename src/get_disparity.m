function disparity = get_disparity(image)
    %----------------------------------------------------------------------
    % assign each pixel a disparity value which is equal to that of the
    % central pixel. apply a linear polyfit to smooth the disparity
    %----------------------------------------------------------------------
    [y, x] = find(image > 0);
    disparity = zeros(max(y) - min(y) + 1, 5);
    for row = min(y) : max(y)
        ind = row == y;
        col = x(ind);
        if(isempty(col))
            continue;
        end
        
        if(col(end) - col(1) + 1 == size(col, 1))
            disparity(row - min(y) + 1, 1) = image(row, round(mean(col([1, end]))));
        else
            col_sp = split_vector(col);
            for i = 1 : size(col_sp, 1)
                disparity(row - min(y) + 1, i) = image(row, round(mean(col_sp(i, :))));
            end
        end
    end
    
    index = [];
    for n = 2 : 5   % size(disparity, 2) is at most 5 because of 5 fingers, and disparity(, 2 : 5) could be 0
        if(sum(disparity(:, n)) == 0)
            index = [index, n];
        end
    end
    disparity(:, index) = [];
    
    for n = 2 : size(disparity, 2)
        disparity(disparity(:, n) == 0, n) = disparity(disparity(:, n) == 0, 1);
    end
%     figure
%     subplot(211);
%     plot(disparity);
%     disparity = smooth_disp(disparity, 21);% odd number
    for i = 1 : size(disparity, 2)
        p = polyfit(1 : size(disparity(:, i)), disparity(:, i)', 1);
        disparity(:, i) = polyval(p, 1 : size(disparity(:, i)));
    end
%     subplot(212);
%     plot(disparity);
end

%--------------------------------------------------------------------------
% split a vector into several continous vectors
% {1, 2, 3, 4, 10, 11, 12, 13} => {1, 2, 3, 4}, {10, 11, 12, 13}
%--------------------------------------------------------------------------
function index = split_vector(col)
    col_dif = col(2 : end) - col(1 : end - 1);
    num = sum(col_dif > 1) + 1;
    index = zeros(num, 2);
    start = 1;
    for i = 1 : num - 1
        ind = start + find(col_dif(start : end) > 1, 1) - 1;
        index(i, :) = col([start, ind]);
        start = ind + 1;
    end
    index(num, :) = [col(start), col(end)];
end

% served to smooth disparity, not used
function disp_temp = smooth_disp(disparity, n)
    disp_temp = disparity;
    for i = (n + 1) / 2 : size(disparity, 1) - (n - 1) / 2
        disparity(i);
        disp_temp(i, :) = mean(disparity(i - (n - 1) / 2 : i + (n - 1) / 2, :), 1);
    end
    for i = 1 : (n - 1) / 2
%         disp_temp(i, :) = mean(disparity(i : i + (n - 1) / 2, :), 1);
        disp_temp(i, :) = disp_temp((n + 1) / 2, :);
    end
    for i = size(disparity, 1) - (n - 3) / 2 : size(disparity, 1)
%         disp_temp(i, :) = mean(disparity(i - (n - 1) / 2 : i, :), 1);
        disp_temp(i, :) = disp_temp(size(disparity, 1) - (n - 1) / 2, :);
    end
%     for i = 1 : (n - 1) / 2
%         disp_temp(i, :) = mean(disparity([1 : i + (n - 1) / 2, i + size(disparity, 1) - (n - 1) / 2 : size(disparity, 1)], :), 1);
%     end
%     for i = size(disparity, 1) - (n - 3) / 2 : size(disparity, 1)
%         disp_temp(i, :) = mean(disparity([i : size(disparity, 1), 1 : (n + 3) / 2 - size(disparity, 1) + i], :), 1);
%     end
end