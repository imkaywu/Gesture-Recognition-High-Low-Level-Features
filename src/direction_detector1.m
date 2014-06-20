function direction_angle=direction_detector1(x_array,y_array)
    %----------------------------------------------------------------------
    % find the orientation of the hand gestures using orientation histogram
    % of the contour pixels
    %----------------------------------------------------------------------
    direction=zeros(1, 17);
    for i = 1 : size(x_array, 1);
        index1 = i;
        if(i < size(x_array, 1) - 2)
            index2 = i + 3;
        elseif(i < size(x_array, 1) - 1)
            index2 = 1;
        elseif(i < size(x_array, 1))
            index2 = 2;
        else
            index2 = 3;
        end
        if(x_array(index2) ~= x_array(index1))
            k = (y_array(index2) - y_array(index1)) / (x_array(index2) - x_array(index1));
            switch k
                case 0
                    if(x_array(index2) > x_array(index1))
                        direction(1) = direction(1) + 1;
                    else
                        direction(17) = direction(17) + 1;
                    end
                case -1/3
                    direction(2) = direction(2) + 1;
                case -1/2
                    direction(3) = direction(3) + 1;
                case -2/3
                    direction(4) = direction(4) + 1;
                case -1
                    direction(5) = direction(5) + 1;
                case -3/2
                    direction(6) = direction(6) + 1;
                case -2
                    direction(7) = direction(7) + 1;
                case -3
                    direction(8) = direction(8) + 1;
                    
                case 3
                    direction(10) = direction(10) + 1;
                case 2
                    direction(11) = direction(11) + 1;
                case 3/2
                    direction(12) = direction(12) + 1;
                case 1
                    direction(13) = direction(13) + 1;
                case 2/3
                    direction(14) = direction(14) + 1;
                case 1/2
                    direction(15) = direction(15) + 1;
                case 1/3
                    direction(16) = direction(16) + 1;
            end
        else
            direction(9) = direction(9) + 1;
        end
    end

    %solution 2
    angle = -[atan2(0, 1), atan2(-1, 3), atan2(-1, 2), atan2(-2, 3), atan2(-1, 1), atan2(-3, 2), atan2(-2, 1), atan2(-3, 1), atan2(-1, -0), atan2(-3, -1), atan2(-2, -1), atan2(-3, -2), atan2(-1, -1), atan2(-2, -3), atan2(-1, -2), atan2(-1, -3)] / pi * 180;
    direction_temp = zeros(1, 15);
    direction([1, 17]) = [];
    angle(1) = [];
    [a, index] = max(direction);
    for i = 1 : 15
        direction_temp(i) = i - index;
    end
    direction = direction / sum(direction);%ÂË²¨Ç°ÂË²¨ºó?
    direction = direction .* direction_temp;
    direction = sum(direction);
    index = find(direction_temp == 0);
    direction_fix = fix(direction);
    if(direction < 0)
        direction_angle = angle(index + direction_fix) - abs(direction - direction_fix) * (angle(index + direction_fix) - angle(index + direction_fix - 1));
    else
        direction_angle = abs(direction - direction_fix) * (angle(index + direction_fix + 1) - angle(index + direction_fix)) + angle(index + direction_fix);
    end
end