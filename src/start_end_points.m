function [start_index, end_index] = start_end_points(x_array, y_array, x_center, y_center, direction_angle, start_degree, end_degree)
    %----------------------------------------------------------------------
    % find the index of the start and end contour point. the contour points
    % between the two points contribute most to the hand orientation
    %
    % vairable:
    %  - start_degree, end_degree: 边缘上的起、终点和中心连线和手势方向夹角
    %----------------------------------------------------------------------
    flag1 = 1;
    flag2 = 1;
    direction_angle1 = atan2((y_array - y_center), (x_array - x_center)) / pi * 180;
    direction_angle1(direction_angle1 > 0) = 360 - direction_angle1(direction_angle1 > 0);    % -180~+180=>0~360
    direction_angle1(direction_angle1 < 0) = -direction_angle1(direction_angle1 < 0);
    direction_angle2 = direction_angle1;
    if(direction_angle < 90)
        direction_angle1 = direction_angle + 360 - end_degree - direction_angle1;   %end point,-90+360
    else
        direction_angle1 = direction_angle1 - direction_angle + end_degree;
    end
    direction_angle2 = direction_angle2 - direction_angle - start_degree;    %start point
    
    while(true)
        [a, end_index] = min(abs(direction_angle1));
        [a, start_index] = min(abs(direction_angle2));
        
%         hold on;
%         plot(x_center, y_center, 'ro');
%         plot(x_array([start_index, end_index]), y_array([start_index, end_index]), 'ro');
%         plot(x_array([start_index, end_index]), y_array([start_index, end_index]));
%         row = 640;
%         y_line = 1 : row;
%         x_line(1 : y_center) = x_center + round((y_center - (1 : y_center)) ./ tand(direction_angle));
%         x_line(y_center + 1 : row) = x_center - round(((y_center + 1 : row) - y_center) ./ tand(direction_angle));
%         plot(x_line, y_line, 'r');
        
        if(x_array(end_index) > x_center)   %abs(y_center-y_array(end_index)<1.5*abs(y_center-y_array(start_index))is for gesture2 image13,14, is contradictory to gesture6 image12
            flag1 = 0;
        else
            direction_angle1(end_index) = 360;
        end
        if(x_array(start_index) < x_center)
            flag2 = 0;
        else
            direction_angle2(start_index) = 360;
        end
        if(~(flag1 || flag2))
            break;
        end
    end
end