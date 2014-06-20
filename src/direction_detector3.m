function direction_angle=direction_detector3(x_array,y_array,fingertip,fingerroots)
    direction_angle=0;
    for i=1:2
        if(i==1)
            direction_temp=atan2(y_array(fingertip)-y_array(fingerroots(1)),x_array(fingertip)-x_array(fingerroots(1)))/pi*180;
        else
            direction_temp=atan2(y_array(fingertip)-y_array(fingerroots(2)),x_array(fingertip)-x_array(fingerroots(2)))/pi*180;
        end
        direction_temp=(direction_temp<=0)*abs(direction_temp)+(direction_temp>0)*(360-direction_temp);
        direction_temp=(direction_temp>270)*(direction_temp-360)+(direction_temp<270)*direction_temp;
        direction_angle=direction_angle+direction_temp;
    end
    direction_angle=direction_angle/2;
end