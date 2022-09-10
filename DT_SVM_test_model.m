

function [percent_correct,preds,classes,score] = DT_SVM_test_model(test_nums,control,model_num,mdl_control,scale)
    
    % include HR
    HR = 1;
    % single trial
    single = 1;

    % get data for current trial
    [MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,phys_states,end_times,classes,end_time_control] = DT_get_data(test_nums,HR,single);
    
    % make sure all data arrays are same length
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
    
    if control == 1
        % subtracting off control averages from all data in trial
        [MAD_slopes_all,EDA_avgs_all,port_avgs_all,HR_avgs_all,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes] = DT_control_avgs(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes);
    elseif control == 2
        % remove resting control period data
        [MAD_slopes_all,EDA_avgs_all,port_avgs_all,HR_avgs_all,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes] = DT_remove_control(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes);
    end
    
    % put data in matrix 
    data = [port_avgs_all;EDA_avgs_all;MAD_slopes_all;HR_avgs_all]';

    % load SVM model
    load(strcat('SVM_test_',model_num,'_model_',mdl_control,'_pemh',scale,'.mat'));
    
    % predict states and get scores
    [label,score] = predict(SVMModel,data);
    
    % make labels doubles
    preds = zeros(size(label));
    for i = 1:size(label)
        preds(i) = str2double(label{i});
    end
    
    % get num correctly labeled states
    num_correct = sum(preds == classes');
    total = size(preds,1);
    % get percent correctly labeled states
    percent_correct = (num_correct)/total;

end
