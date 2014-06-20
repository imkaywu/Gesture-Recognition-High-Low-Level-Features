function [degree, norm_distance] = trans_graph1(x_array, y_array, x_center, y_center, norm_on_off)
    %----------------------------------------------------------------------
    % transform the original gesture into the time-series curve
    %----------------------------------------------------------------------
    length = find(x_array, 1, 'last');
    radius = atan2(y_array(1 : length) - y_center, x_array(1 : length) - x_center);
    degree = radius ./ pi * 180;
    degree(degree > 0) = 360 - degree(degree > 0);    % -180~+180=>0~360
    degree(degree < 0) = abs(degree(degree < 0));
    degree = degree - degree(1);
    degree(degree > 0) = 360 - degree(degree > 0);
    degree(degree < 0) = -degree(degree < 0);
    degree = degree / 360;

    x_distance = x_array - x_center;
    y_distance = y_array - y_center;
    distance = zeros(length, 1);
    for i = 1 : length
        distance(i) = norm([x_distance(i), y_distance(i)]);
    end
    if(strcmp(norm_on_off, 'norm_on'))
        min_distance = min(distance);
    elseif(strcmp(norm_on_off, 'norm_off'))
        min_distance = 1;
    end
    norm_distance = distance ./ min_distance;
end
