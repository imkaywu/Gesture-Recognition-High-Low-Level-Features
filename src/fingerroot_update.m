function [fingeredge_start, fingeredge_end] = fingerroot_update(x_array, y_array, fingertip, fingerroot, direction_angle)
    %----------------------------------------------------------------------
    % update the positions of fingerroots using the newly detected finger
    % direction
    %----------------------------------------------------------------------
    for i = 1 : 2
        if(i == 1)    %左边的点
            edge_degree = atan2(y_array(fingertip : fingerroot(2)) - y_array(fingerroot(1)), x_array(fingertip : fingerroot(2)) - x_array(fingerroot(1))) / pi * 180;
            edge_degree(edge_degree > 0) = 360 - edge_degree(edge_degree > 0);
            edge_degree(edge_degree < 0) = -edge_degree(edge_degree < 0);
            edge_degree(edge_degree > 180) = edge_degree(edge_degree > 180) - 360;
        else    %右边的点
            edge_degree1 = atan2(y_array(fingerroot(1) : fingertip(1)) - y_array(fingerroot(2)), x_array(fingerroot(1) : fingertip(1)) - x_array(fingerroot(2))) / pi * 180;
            edge_degree1(edge_degree1 > 0) = 360 - edge_degree1(edge_degree1 > 0);
            edge_degree1(edge_degree1 < 0) = -edge_degree1(edge_degree1 < 0);
        end
        if(i == 2)
            [a, index1] = min(abs(edge_degree - direction_angle + 90));%开始选左边为起点
            [a, index2] = min(abs(edge_degree1 - direction_angle - 90));%开始选右边为终点
            if(fingertip + index1 - 1 < fingerroot(2) && index2 == 1)
                fingeredge_start = fingerroot(1);
                fingeredge_end = fingertip + index1 - 1;
            elseif(index2 > 1 && fingertip + index1 - 1 == fingerroot(2))
                fingeredge_start = fingerroot(1) + index2 - 1;
                fingeredge_end = fingerroot(2);
            else
                fingeredge_start = fingerroot(1) + 1;
                fingeredge_end = fingerroot(2) - 1;
            end
%             if(min(edge_degree) <= 0 && max(edge_degree1) <= 180)%选左边
%                 [a, index1] = min(abs(edge_degree - direction(index) / 2 + 90));
%                 fingeredge_start = fingerroot(1);
%                 fingeredge_end = start_index + fingertip + index1 - 2;
%             else
%                 [a, index1] = min(abs(edge_degree1 - direction(index) / 2 - 90));%选右边
%                 fingeredge_start = fingerroot(1) + index1 - 1;
%                 fingeredge_end = fingerroot(2);
%             end
        end
    end
end