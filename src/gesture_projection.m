%--------------------------------------------------------------------------
% 平面投影，输入是手势深度图
% project the hand gesture into a center plane(decided by Z_std)
%--------------------------------------------------------------------------
function binary_map = gesture_projection(image, disparity, Z_std)
    [y_dim, x_dim] = size(image);
    x_center = x_dim / 2;
    y_center = y_dim / 2;
    [y, x] = find(image > 0);
    
    B = 0.0935;
    f = 533;
    Z = zeros(size(image));
%     x_pos = zeros(size(image));
%     y_pos = zeros(size(image));
    for row = min(y) : max(y)
        ind = row == y;
        col = x(ind);
        if(isempty(col))
            continue;
        end
        if(col(end) - col(1) + 1 == size(col, 1))
            d = disparity(row - min(y) + 1, 1);
            Z(row, col(1) : col(end)) = B * f / d;
%             x_pos(row, col(1) : col(end)) = col(1) : col(end);
%             y_pos(row, col(1) : col(end)) = row * ones(size(col, 1), 1);
        else
            col_sp = split_vector(col);
            for i = 1 : size(col_sp, 1)
                d = disparity(row - min(y) + 1, i);
                Z(row, col_sp(i, 1) : col_sp(i, 2)) = B * f / d;
%                 x_pos(row, col_sp(i, 1) : col_sp(i, 2)) = col_sp(i, 1) : col_sp(i, 2);
%                 y_pos(row, col_sp(i, 1) : col_sp(i, 2)) = row * ones(col_sp(i, 2) - col_sp(i, 1) + 1, 1);
            end
        end
    end
    Z = Z(image > 0);
    X = -(x - x_center) .* Z / f;
    Y = -(y - y_center) .* Z / f;
    x = round(-X * f / Z_std + x_center);
    y = round(-Y * f / Z_std + y_center);
    
%     X = -(x_pos - x_center) .* Z / f;
%     Y = -(y_pos - y_center) .* Z / f;
%     x = round(-X * f / Z_std + x_center);
%     y = round(-Y * f / Z_std + y_center);
%     x(image == 0) = 0;
%     y(image == 0) = 0;
%     x = x(image ~= 0);
%     y = y(image ~= 0);
    [row, col] = size(image);
    if(min(y) <= 0)
        row = size(image, 1) - min(y) + 1;
        y = y - min(y) + 1;
    elseif(max(y) > row)
        row = max(y);
    end
    if(min(x) <= 0)
        col = size(image, 2) - min(x) + 1;
        x = x - min(x) + 1;
    elseif(max(x) > col)
        col = max(x);
    end
    binary_map = zeros(row, col);
    for i = 1 : size(x, 1)
        binary_map(y(i), x(i)) = 1;
    end
    se=strel('disk',4);
    binary_map = imdilate(binary_map, se);
    se=strel('disk',5);
    binary_map = imerode(binary_map, se);
    
%     figure;
%     image = B * f ./ Z;
%     image(image == inf) = 0;
%     imshow(image);
%     title('after projection');
end

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