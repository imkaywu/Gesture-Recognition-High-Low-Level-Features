function dt = dist_trans(mat)
    %-------------------------------------------------
    % an implementation of distance transform
    %-------------------------------------------------
    index0 = (mat == 0);
    index1 = (mat == 1);
    mat(index0) = 1;
    mat(index1) = 0;
    
    [y_index, x_index] = find(mat == 0);
    x_min = min(x_index);
    x_max = max(x_index);
    y_min = min(y_index);
    y_max = max(y_index);
    for n = 1 : 10
    for i = y_min : y_max
        for j = x_min : x_max
            if(mat(i, j) > 0)
                if((i == 1) && (j == 1));
                elseif(i == 1)
                    mat(i, j) = mat(i, j - 1) + 1;
                elseif(j == 1)
                    mat(i, j) = min([mat(i - 1, j), mat(i - 1, j + 1)]) + 1;
                elseif(j == x_max)
                    mat(i, j) = min([mat(i, j - 1), mat(i - 1, j - 1), mat(i - 1, j)]) + 1;
                else
                    mat(i, j) = min([mat(i, j - 1),mat(i - 1, j - 1), mat(i - 1, j), mat(i - 1, j + 1)]) + 1;
                end
            end
        end
    end
    
    for i = y_max : -1 : y_min
        for j = x_max : -1 : x_min
            if(mat(i, j) > 0)
                if((i == y_max) && (j == x_max));
                elseif(i == y_max)
                    mat(i, j) = min([mat(i, j), mat(i, j + 1) + 1]);
                elseif(j == x_max)
                    mat(i, j) = min([mat(i, j), mat(i + 1, j) + 1, mat(i + 1, j - 1) + 1]);
                elseif(j == 1)
                    mat(i, j) = min([mat(i, j), mat(i, j + 1) + 1, mat(i + 1, j + 1) + 1, mat(i + 1, j) + 1]);
                else
                    mat(i, j) = min([mat(i, j), mat(i, j + 1) + 1, mat(i + 1, j + 1) + 1, mat(i + 1, j) + 1, mat(i + 1, j - 1) + 1]);
                end
            end
        end
    end
    end
    dt = mat;
end