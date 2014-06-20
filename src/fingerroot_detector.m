function [fingerroot, finger_direction] = fingerroot_detector(x_array, y_array, fingertip, fingerroot_init)
    %------------------------------------------------------------------------
    % calculate the accurate positions of fingerroots using the ratio between 
    % the area of the finger and that of the external rectangle
    %
    % function:
    %  - direction_detector3: use the positions of fingertip and fingerroots
    %                         to determine the direction of finger
    %  - fingerroot_update: update the positions of fingerroots using the
    %                       newly detected direction
    %------------------------------------------------------------------------
    fingertip_length = size(fingertip, 1);
    fingerroot = zeros(1, 2 * fingertip_length);
    finger_direction = zeros(1, fingertip_length);
    for i = 1 : fingertip_length
        P = [y_array(fingertip(i)), x_array(fingertip(i))];
        fingerroot_start = fingerroot_init(i, 1);
        fingerroot_end = fingerroot_init(i, 2);
        while(true)
            direction_angle = direction_detector3(x_array, y_array, fingertip(i), [fingerroot_start, fingerroot_end]);
            [fingerroot_start, fingerroot_end] = fingerroot_update(x_array, y_array, fingertip(i), [fingerroot_start, fingerroot_end], direction_angle);
            %calculate the area of the external rectangle
            Q = [P(1) + 10, P(2) - 10 / tand(direction_angle)];
            n = 1;
            dist = zeros(1, fingerroot_end - fingerroot_start + 1);
            for j = fingerroot_start : fingerroot_end
                dist(n) = abs(det([P - Q; [y_array(j), x_array(j)] - Q])) / norm(P - Q);
                n = n + 1;
            end
            fingerroot1 = [y_array(fingerroot_start), x_array(fingerroot_start)];
            fingerroot2 = [y_array(fingerroot_end), x_array(fingerroot_end)];
            length = max(dist(1 : fingertip(i) - fingerroot_start + 1)) + max(dist(fingertip(i) - fingerroot_start + 1 : fingerroot_end - fingerroot_start + 1));
            height = abs(det([fingerroot2 - fingerroot1; P - fingerroot1])) / norm(fingerroot2 - fingerroot1);
            area = length * height;
            %calculate the area of the finger
            finger_area = 0;
            finger_top = min(y_array(fingerroot_start : fingerroot_end));
            up = min(y_array([fingerroot_start, fingerroot_end]));
            low = max(y_array([fingerroot_start, fingerroot_end]));
            for j = finger_top : 1 : low
                if(j <= up)
                    x = x_array(fingerroot_start + find(j == y_array(fingerroot_start : fingerroot_end)) - 1);
                    finger_area = finger_area + max(x) - min(x) + 1;
                else
                    if(up == y_array(fingerroot_end))
                        x = x_array(fingerroot_end) + (x_array(fingerroot_end) - x_array(fingerroot_start)) / (up - low) * (j - up);
                        finger_area = finger_area + x - min(x_array(fingerroot_start + find(j == y_array(fingerroot_start : fingerroot_end)) - 1)) + 1;
                    else
                        x = x_array(fingerroot_start) + (x_array(fingerroot_start) - x_array(fingerroot_end)) / (up - low) * (j - up);
                        finger_area = finger_area + max(x_array(fingerroot_start + find(j == y_array(fingerroot_start : fingerroot_end)) - 1)) - x + 1;
                    end
                end
            end
%             imshow(edge_map);
%             hold on;
%             x_line1 = zeros(1, row);
%             y_line = 1 : row;
%             x_line1(1 : y_array(fingertip(i))) = x_array(fingertip(i)) + round((y_array(fingertip(i)) - (1 : y_array(fingertip(i)))) ./ tand(direction_angle));
%             x_line1(y_array(fingertip(i)) + 1 : row) = x_array(fingertip(i)) - round(((y_array(fingertip(i)) + 1 : row) - y_array(fingertip(i))) ./ tand(direction_angle));
%             plot(x_line1, y_line);
%             plot([x_array(fingerroot_start), x_array(fingerroot_end)], [y_array(fingerroot_start), y_array(fingerroot_end)], 'ro');
%             plot([x_array(fingerroot_start), x_array(fingerroot_end)], [y_array(fingerroot_start), y_array(fingerroot_end)], 'r-');
            
            area_percent = finger_area / area;
            if(area_percent > 0.65 || (fingerroot_start > fingertip(i) || fingerroot_end < fingertip(i)))
                fingerroot([2 * i - 1, 2 * i]) = [fingerroot_start, fingerroot_end];
                finger_direction(i) = direction_angle;
                break;
            end
        end
    end
end