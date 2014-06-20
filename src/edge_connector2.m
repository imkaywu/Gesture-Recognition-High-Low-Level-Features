function [x_array, y_array]=edge_connector2(edge_map, row, colum)
    %----------------------------------------------------------------------
    % connect the contour pixels using 8-neighbor connectivity, the 
    % coordinates are stored individually in x_array, y_array
    %----------------------------------------------------------------------
    edge_map(row + 1, :) = 0;
    edge_map(:, colum + 1) = 0;
    % [y_origin, x_origin] = ind2sub(size(edge_map), min(find(edge_map)));
    [y_index, x_index] = find(edge_map == 1);
    [y_present, index] = max(y_index); % the start is the bottom left pixel
    x_present = min(x_index(index));
    x_array = zeros(sum(sum(edge_map)), 1);
    y_array = zeros(sum(sum(edge_map)), 1);
    x_array(1) = x_present;
    y_array(1) = y_present;
    i = 1;
    first_time = 1;
    while(1)
%         if(x_present == 233 && y_present == 198)
%         end
        x_present = x_array(i);
        y_present = y_array(i);
        if(first_time)
            i = i + 1;
            [x_array(i), y_array(i)] = first_detect(edge_map, x_present, y_present);
            first_time = ~first_time;
        else
            if((x_present > 1 && x_present < max(x_index) && sum(edge_map(y_present, [x_present - 1, x_present + 1])) > 0) || (x_present > 1 && edge_map(y_present, x_present - 1) == 1) || (x_present < max(x_index) && edge_map(y_present, x_present + 1) == 1))
                i = i + 1;
                y_array(i) = y_present;
                if(x_present > 1 && x_present < max(x_index) && sum(edge_map(y_present, [x_present - 1, x_present + 1])) == 2)
                    if(x_present - min(x_index) > max(x_index) - x_present)
                        x_array(i) = x_present - 1;
                    else
                        x_array(i) = x_present + 1;
                    end
                elseif(x_present > 1 && edge_map(y_present, x_present - 1) == 1)
                    x_array(i) = x_present - 1;
                else
                    x_array(i) = x_present + 1;
                end
            elseif((y_present > 1 && y_present < max(y_index) && sum(edge_map([y_present - 1 , y_present + 1], x_present)) > 0) || (y_present > 1 && edge_map(y_present - 1, x_present) == 1) || (y_present < max(y_index) && edge_map(y_present + 1, x_present) == 1))
                i = i + 1;
                x_array(i) = x_present;
                if(y_present > 1 && y_present < max(y_index) && sum(edge_map([y_present - 1 , y_present + 1], x_present)) == 2)
                    if(y_present - min(y_index) > max(y_index) - y_present)
                        y_array(i) = y_present - 1;
                    else
                        y_array(i) = y_present + 1;
                    end
                elseif(y_present > 1 && edge_map(y_present - 1, x_present) == 1)
                    y_array(i) = y_present - 1;
                else
                    y_array(i) = y_present + 1;
                end
            elseif(sum(edge_map([y_present - 1, y_present + 1], x_present - 1)) > 0)
                i = i + 1;
                x_array(i) = x_present - 1;
                if(sum(edge_map([y_present - 1, y_present + 1], x_present - 1)) == 2)
                    if(y_present - min(y_index) > max(y_index) - y_present)
                        y_array(i) = y_present - 1;
                    else
                        y_array(i) = y_present + 1;
                    end
                elseif(edge_map(y_present - 1, x_present - 1))
                    y_array(i) = y_present - 1;
                else
                    y_array(i) = y_present + 1;
                end
            elseif(sum(edge_map([y_present - 1, y_present + 1], x_present + 1)) > 0)
                i = i + 1;
                x_array(i) = x_present + 1;
                if(sum(edge_map([y_present - 1, y_present + 1], x_present + 1)) == 2)
                    if(y_present - min(y_index) > max(y_index) - y_present)
                        y_array(i) = y_present - 1;
                    else
                        y_array(i) = y_present + 1;
                    end
                elseif(edge_map(y_present - 1, x_present + 1) == 1)
                    y_array(i) = y_present - 1;
                else
                    y_array(i) = y_present + 1;
                end
            else
                edge_map(y_present, x_present) = 0;
                dist = norm([x_present - x_array(1), y_present - y_array(1)]);
                if(dist == 1 || dist == sqrt(2))%size(x_array(x_array > 0), 1) > 0.95 * sum_point
                    break;
                else
                    i = i - 1;
                    continue;
                end
            end
        end
%         hold on;
%         plot(x_present, y_present, 'r.');
        edge_map(y_present, x_present) = 0;
    end
    
    x_array(x_array == 0) = [];
    y_array(y_array == 0) = [];
end

function [x, y] = first_detect(edge_map, x_present, y_present)
    y = y_present - 1;
    if(edge_map(y_present - 1, x_present) == 1)
        x = x_present;
    elseif(edge_map(y_present - 1, x_present - 1) == 1)
        x = x_present - 1;
    elseif(edge_map(y_present - 1, x_present + 1) == 1)
        x = x_present + 1;
    end 
end

% not used now
function direction = choose_direction(edge_map, x_present, y_present) 
    n = 1;
    while(1)
    end
end