function edge_map=edge_finder(binary_map,row,colum)
    %-------------------------------------------------------------------------
    % find the edge pixels of the hand gestures, stored in edge_map(row * col)
    %-------------------------------------------------------------------------
    edge_map = zeros(size(binary_map));
    edge_direction = zeros(size(binary_map));
    for i = 1 : row
        j = 1;
        while(true)
            if(j == colum + 1)
                break;
            elseif(i ~= 1 && j ~= 1 && i ~= row && j ~= colum)
                if(xor(binary_map(i, j), binary_map(i, j + 1)))
                    if(edge_map(i, j + binary_map(i, j + 1)) == 1 && (edge_direction(i, j + binary_map(i, j + 1)) == 1 || edge_direction(i, j + binary_map(i, j + 1)) == 3))%可以去除想101图中的孤立的竖线
                        edge_map(i, j + binary_map(i, j + 1)) = 0;
                        edge_direction(i, j + binary_map(i, j + 1)) = 0;
                        binary_map(i, j + binary_map(i, j + 1)) = 0;
                        continue;
                    else
                        edge_map(i, j + binary_map(i, j + 1)) = 1;
                        edge_direction(i, j + binary_map(i, j + 1)) = edge_direction(i, j + binary_map(i, j + 1)) + 1;
                    end
                end
                if(xor(binary_map(i, j), binary_map(i + 1, j)))
                    if(edge_map(i + binary_map(i + 1, j), j) == 1 && (edge_direction(i + binary_map(i + 1, j), j) == 2 || edge_direction(i + binary_map(i + 1, j), j) == 3))
                        edge_map(i + binary_map(i + 1, j), j) = 0;
                        binary_map(i + binary_map(i + 1, j), j) = 0;
                        if(binary_map(i + binary_map(i + 1, j), j - 1))
                            j = j - 1;
                        end
                        edge_direction(i + binary_map(i + 1, j), j) = 0;
                        continue;
                    else
                        edge_map(i + binary_map(i + 1, j), j) = 1;
                        edge_direction(i + binary_map(i + 1, j), j) = edge_direction(i + binary_map(i + 1, j), j) + 2;
                    end
                end
            else
                if(binary_map(i, j))
                   edge_map(i, j) = 1;
                end
            end
            j = j + 1;
        end
    end
    edge_pixel = zeros(1, 2);
    n = 1;
    for j = 2 : colum - 1
        if(edge_map(row, j) > 0)
            if(sum([edge_map(row, j - 1), edge_map(row - 1, j), edge_map(row, j + 1)]) == 3)
                edge_pixel(n) = j;
                n = n + 1;
            end
        end
    end
    if(find(edge_pixel, 1, 'last') == 2)
        edge_map(row, edge_pixel(1) - 1) = 0;
        edge_map(row, edge_pixel(2) + 1) = 0;
    elseif(find(edge_pixel, 1, 'last') == 1)
        if(sum(edge_map(row, 1 : edge_pixel(1) - 1)) > sum(edge_map(row, edge_pixel(1) + 1 : end)))
            edge_map(row, edge_pixel(1) + 1 : end) = 0;
        else
            edge_map(row, 1 : edge_pixel(1) - 1) = 0;
        end
    end
    
    edge_pixel = zeros(1, 2);
    n = 1;
    for i = 2 : row - 1
        if(edge_map(i, colum) > 0)
            if(sum([edge_map(i - 1, colum), edge_map(i, colum - 1), edge_map(i + 1, colum)]) == 3)
                edge_pixel(n) = i;
                n = n + 1;
            end
        end
    end
    if(find(edge_pixel, 1, 'last') == 2)
        edge_map(1 : edge_pixel(1) - 1, colum) = 0;
        edge_map(edge_pixel(2) + 1, colum) = 0;
    elseif(find(edge_pixel, 1, 'last') == 1)
        if(sum(edge_map(1 : edge_pixel(1) - 1, colum)) > sum(edge_map(edge_pixel(1) + 1 : end, colum)))
            edge_map(edge_pixel(1) + 1 : end, colum) = 0;
        else
            edge_map(1 : edge_pixel(1) - 1, colum) = 0;
        end
    end
end