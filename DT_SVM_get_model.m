

function [percent_correct,qofo_c,qofo_i] = DT_SVM_get_model(test_nums_all)

    model_nums = "";
    MAD_slopes_con = [];
    EDA_avgs_con = [];
    port_avgs_con = [];
    HR_avgs_con = [];
    times = [];
    classes_con = [];

    
    time_end = 0;
    % concatenate training data from all desired trials
    for i = 1:size(test_nums_all,2)
        test_nums = test_nums_all{i};
        model_num = test_nums(1);
        model_nums = model_nums + model_num;
        
        % leave control data: 0
        % subtract off control: 1
        % remove control data: 2
        control = 1; 
        
        % only a single trial
        single = 1;
        
        % include heart rate
        HR = 1;
        
        % load data from files and put in proper form
        [MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,phys_states,end_times,classes,end_time_control] = DT_get_data(test_nums,HR,single);
        
        % make sure all data is the same length
        data_length = min([size(MAD_slopes_all,2), size(EDA_avgs_all,2),size(port_avgs_all,2)]);
        if HR
            data_length = min([size(MAD_slopes_all,2), size(EDA_avgs_all,2),size(port_avgs_all,2),size(HR_avgs_all,2)]);
        end
        MAD_slopes_all = MAD_slopes_all(1:data_length);
        MAD_slopes_times = MAD_slopes_times(1:data_length);
        EDA_avgs_all = EDA_avgs_all(1:data_length);
        EDA_avgs_times = EDA_avgs_times(1:data_length);
        port_avgs_all = port_avgs_all(1:data_length);
        port_avgs_times = port_avgs_times(1:data_length);
        classes = classes(1:data_length);
        if HR
            HR_avgs_all = HR_avgs_all(1:data_length);
            HR_avgs_times = HR_avgs_times(1:data_length);
        end
        
        % deal with resting control period
        if control == 1
            % subtracting off resting control averages from all data
            [MAD_slopes_all,EDA_avgs_all,port_avgs_all,HR_avgs_all,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes] = DT_control_avgs(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes);
        elseif control == 2
            % remove resting control period data
            [MAD_slopes_all,EDA_avgs_all,port_avgs_all,HR_avgs_all,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes] = DT_remove_control(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes);
        end
        
        % concatenate data
        MAD_slopes_con = [MAD_slopes_con,MAD_slopes_all];
        EDA_avgs_con = [EDA_avgs_con,EDA_avgs_all];
        port_avgs_con = [port_avgs_con,port_avgs_all];
        HR_avgs_con = [HR_avgs_con,HR_avgs_all];
        times = [times,EDA_avgs_times + time_end];
        classes_con = [classes_con,classes];

        time_end_opts = [MAD_slopes_times(end),EDA_avgs_times(end),port_avgs_times(end),HR_avgs_times(end)];
        time_end = time_end + max(time_end_opts);
    end
    
    % put all data for training in matrix (data)
    all_data = [port_avgs_con;EDA_avgs_con;MAD_slopes_con;HR_avgs_con;times;classes_con]';
    
    num_rested = 0;
    num_fatigued = 0;
    for i = 1:size(all_data,1)
        if all_data(i,6) == 1
            num_rested = num_rested + 1;
        else
            num_fatigued = num_fatigued + 1;
        end
    end
% % get all transitions between physiological states
%     transitions = []; 
%     flag = 1;
%     for i = 1:size(classes_con,2)
%         if flag ~= classes_con(i)
%             transitions = [transitions, times(i)];
%             if flag == 1
%                 flag = 2;
%             else
%                 flag = 1;
%             end
%         end
%     end
% 
%     save('transition_all.mat','transitions');
    num_points = size(all_data,1);
    
    % split data into testing and training
    randomized = all_data(randperm(num_points),:);
    
    end_i = floor(num_points * 0.6);
    training = randomized(1:end_i,:);
    testing = randomized(end_i+1:end,:);

    save('DT_testing_data',"testing");
    save('DT_training_data',"training");

    data = training(:,1:4);
    classes = training(:,6);
% 
%     rng('default');
    scale = '';

    % get SVM Model
    SVMModel_1 = fitcsvm(data,classes,'KernelFunction','rbf',...
        'Standardize',true,'ClassNames',{'1','2'});

    SVMModel = fitPosterior(SVMModel_1);

    [label,score_2] = predict(SVMModel,data);
    score = zeros(size(score_2,1),1);



    preds = zeros(size(label));
    for i = 1:size(label,1)
        preds(i) = str2double(label{i});
    end

    for i = 1:size(score_2)
        score(i) = score_2(i,preds(i));
    end
    
    % store quality-of-output metrics for correctly and incorrectly labeled
    % physiological states 
    qofo_c = [];
    qofo_i = [];
    for i = 1:size(score,1)
        x1 = score(i);
        % quality-of-output distribution
        qofo = 0.2055*atan(15*(x1-0.89))+0.789;
        if classes(i) == preds(i)
            qofo_c = [qofo_c;qofo];
        else
            qofo_i = [qofo_i;qofo];
        end
    end
    
    percent_correct = sum(preds == classes)/size(classes,1);
    
    % save model to .mat file
    save(strcat('SVM_test_',model_nums,'_model_',string(control),'_pemh',scale,'.mat'),'SVMModel');

end
