function fingertip = fingertip_adjust(y_array, fingertip)
    %----------------------------------------------------------------------
    %  *_________________                  _________*________ 
    %  |                |                 |                 |
    %  |                |                 |                 |
    %  |                |                 |                 |
    %  |                |                 |                 |
    %  |                |     ======>     |                 |
    %  \                \                 \                 \
    %   \                \                 \                 \
    %    \                \                 \                 \
    %     \                \                 \                 \
    %  *: fingertip
    %----------------------------------------------------------------------
    for i = 1 : size(fingertip, 1)
        start = 1;
        x_pos = find(y_array(fingertip(i)) == y_array);
        if(x_pos(end) - x_pos(1) + 1 == size(x_pos, 2))
            fingertip(i) = round(mean(x_pos([1, end])));
        else
            x_pos_dif = x_pos(2: end) - x_pos(1: end - 1);
            while(1)
                ind = start -1 + find(x_pos_dif(start : end) ~= 1, 1, 'first');
                if(~isempty(ind) && sum(x_pos(start : ind) == fingertip(i)))
                    fingertip(i) = round(mean(x_pos([start, ind])));
                    break;
                elseif(isempty(ind))
                    fingertip(i) = round(mean(x_pos([start, end])));
                    break;
                else
                    start = ind + 1;
                end
            end
        end
    end
end