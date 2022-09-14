

function DT_SVM_get_model(test_nums_all)

    model_nums = "";
    MAD_slopes_con = [];
    EDA_avgs_con = [];
    port_avgs_con = [];
    HR_avgs_con = [];
    classes_con = [];
    
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
        classes_con = [classes_con,classes];
    end
    
    % put all data for training in matrix (data)
    data = [port_avgs_con;EDA_avgs_con;MAD_slopes_con;HR_avgs_con]';
    
    
    rng('default');
    scale = '';

    % get SVM Model
    SVMModel_1 = fitcsvm(data,classes_con','KernelFunction','rbf',...
        'Standardize',true,'ClassNames',{'1','2'});

    SVMModel = fitPosterior(SVMModel_1);
    
    % save model to .mat file
    save(strcat('SVM_test_',model_nums,'_model_',string(control),'_pemh',scale,'.mat'),'SVMModel');
    
end
