% one-versus-one
function [ accuracy_train , accuracy_test ,false_post, wrong_gesture, fal_pos_gesture ] = main_svm_classifier_v4
    tic;
    train_pct = 0.7;
    count = 5;
    accuracy_train = zeros( 13 );
    accuracy_test = zeros( 13 );
    false_post = zeros( 13 , 1 );
    wrong_gesture = [];
    fal_pos_gesture = [];
    for i = 1 : count
        [ accuracy_train_temp , accuracy_test_temp , false_post_temp, wrong_gesture_temp, fal_pos_gesture_temp ] = svm_classifier(train_pct);
        accuracy_train = accuracy_train + accuracy_train_temp;
        accuracy_test = accuracy_test + accuracy_test_temp;
        false_post = false_post + false_post_temp;
        wrong_gesture = [wrong_gesture, wrong_gesture_temp];
        fal_pos_gesture = [fal_pos_gesture, fal_pos_gesture_temp];
    end
    accuracy_train = accuracy_train / count;
    accuracy_test = accuracy_test / count;
    false_post = false_post / count;
    max_len = 0;
    for i = 1 : size(wrong_gesture, 1)
        len = size(wrong_gesture(i, wrong_gesture(i, :) > 0), 2);
        wrong_gesture(i, 1 : len) = wrong_gesture(i, wrong_gesture(i, :) > 0);
        wrong_gesture(i, len + 1 : end) = 0;
        if(len > max_len)
            max_len = len;
        end
    end
    wrong_gesture(:, max_len + 1 : end) = [];
    fal_pos_gesture(:, max_len + 1 : end) = [];
%     cd '..\data\Train data\accuracy';
    cd '..\data\projection\accuracy';
%     cd '..\data\dist_smp(50)\accuracy';
    save( strcat('accuracy_train',num2str(train_pct),'.mat'),'accuracy_train');
    save( strcat('accuracy_test',num2str(train_pct),'.mat'),'accuracy_test');
    save( strcat('false_positive',num2str(train_pct),'.mat'),'false_post');
    toc;
end
function [ accuracy_train , accuracy_test , false_post, wrong_gesture, fal_pos_gesture ] = svm_classifier(train_pct)
    %% Read in data and choose the training set
%     str = '..\data\Test data\gesture';
    str = '..\data\projection\distance_sample_map(100)\';
%     str = '..\data\projection\dist_smp(50)\normalized_min_max\';
    
    [gesture_data, gesture_num] = read_in_data(str);
    %x_all = x_all / 100;
    [train_set, test_set,train_label, test_label, test_index] = data_select(gesture_data, gesture_num, train_pct, 'random_on');   %gesture_distance_map, gesture_dist_smp
    %% Training
    cd 'E:\Program Files\MATLAB\R2010b\toolbox\libsvm-3.17\matlab';
    [ bestc , bestg ] = SVMcg( train_label, train_set );%(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)
    cmd = [ '-c ' , num2str(bestc) , ' -g ' , num2str(bestg) ];
    cd 'E:\Program Files\MATLAB\R2010b\toolbox\libsvm-3.17\matlab';
    model = svmtrain( train_label , train_set , cmd );
    %% Test
    gesture_type = size(gesture_num, 1);
    accuracy_train = zeros( gesture_type );
    accuracy_test = zeros( gesture_type );
    wrong_gesture = zeros(gesture_type, 1);
    fal_pos_gesture = zeros(gesture_type, 1);
    % Predict the training set
    cd 'E:\Program Files\MATLAB\R2010b\toolbox\libsvm-3.17\matlab';
    [ predict_label , accuracy_rate , prob_estimates ] = svmpredict( train_label , train_set , model , '-q' );
    cd 'G:\Projects\Hand Gesture\Kay''s code';
    for i = 1 : size( train_label , 1 )
        accuracy_train( predict_label( i ) , train_label( i ) ) = accuracy_train( predict_label( i ) , train_label( i ) ) + 1;
    end
    for i = 1 : gesture_type
        accuracy_train( : , i ) = accuracy_train( : , i ) / sum( accuracy_train( : , i ) );
    end
    
    % Predict the test set
    cd 'E:\Program Files\MATLAB\R2010b\toolbox\libsvm-3.17\matlab';
    [ predict_label , accuracy_rate , prob_estimates ] = svmpredict( test_label , test_set , model , '-q' );
    cd 'G:\Projects\Hand Gesture\Kay''s code';
    for i = 1 : size( test_label , 1 )
        accuracy_test( predict_label( i ) , test_label( i ) ) = accuracy_test( predict_label( i ) , test_label( i ) ) + 1;
        if(predict_label(i) ~= test_label(i))
            wrong_gesture(test_label( i ), end + 1) = test_index(i) - sum(gesture_num(1 : test_label( i ) - 1));
            fal_pos_gesture(test_label( i ), end + 1) = predict_label(i) + 1;
        end
    end
    % False positive
    false_post = zeros( gesture_type , 1 );
    for i = 1 : gesture_type
        false_post( i ) = ( sum( accuracy_test( i , : ) ) - accuracy_test( i , i ) ) / sum( accuracy_test( i , : ) );
    end
    % True positive
    for i = 1 : gesture_type
        accuracy_test( : , i ) = accuracy_test( : , i ) / sum( accuracy_test( : , i ) );
    end
end
%% Read in the data of each type of gesture
function [gesture_data, gesture_num] = read_in_data(str)
    load(strcat(str, 'gesture_distance_map'));
%     load(strcat(str, 'gesture_dist_smp'));
    gesture_data = distance_sample_map;    %distance_sample_map, distance_LCS_map
    load(strcat(str, 'gesture_num'));
    gesture_num = gesture_num(2 : end);
end
%% Select the training set and test set
function [train_set, test_set,train_label, test_label, test_index] = data_select( gesture_data , gesture_num , percent , CW_random )
    train_num = round(gesture_num * percent);
    test_num = gesture_num - train_num;
    train_index = [];
    test_index = [];
    for i = 1 : size(gesture_num, 1)
        if strcmp( CW_random , 'random_on' )
            index = randperm(gesture_num(i))';
            train_index = [train_index; sum(gesture_num(1 : i - 1)) + index(1 : train_num(i))];
            test_index = [test_index; sum(gesture_num(1 : i - 1)) + index(train_num(i) + 1 : end)];
        else
            train_index = [train_set; sum(gesture_num(1 : i - 1)) + (1 : train_num(i))'];
            test_index = [test_index; sum(gesture_num(1 : i - 1)) + (train_num(i) + 1 : gesture_num(i))'];
        end
    end
    train_set = gesture_data(train_index, :);
    test_set = gesture_data(test_index, :);
    
    train_label = zeros(sum(train_num), 1);
    test_label = zeros(sum(test_num), 1);
    for i = 1 : size(gesture_num, 1)
        train_label(sum(train_num(1 : i - 1)) + 1 : sum(train_num(1 : i - 1)) + train_num(i)) = i;
        test_label(sum(test_num(1 : i - 1)) + 1 : sum(test_num(1 : i - 1)) + test_num(i)) = i;
    end
end