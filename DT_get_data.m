
function [MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,phys_states,end_times,classes,end_time_control] = DT_get_data(test_nums,HR,single)
    % arrays to store data from all testing trials
    MAD_slopes_all = [];
    EDA_avgs_all = [];
    port_avgs_all = [];
    MAD_slopes_times = [];
    EDA_avgs_times = [];
    port_avgs_times = [];
    HR_avgs_all = [];
    HR_avgs_times = [];
    phys_states = [];
    end_times = [];
    classes = [];
    is_first = 1;
    end_time_control = 0;
    % loop through all trials
    for test_i = 1:size(test_nums,2)
       test_num = test_nums(test_i);
       % get data from current trial
       [MAD_slopes,MAD_slopes_time,EDA_avgs,EDA_avgs_time,port_avgs,port_avgs_time,HR_avgs,HR_avgs_time,phys_indicators,end_time,class,end_time_cn] = DT_single_test(test_num,HR,single);
       % store data from each trial
       MAD_slopes_all = [MAD_slopes_all,MAD_slopes];
       EDA_avgs_all = [EDA_avgs_all,EDA_avgs];
       port_avgs_all = [port_avgs_all,port_avgs];
       MAD_slopes_times = [MAD_slopes_times,MAD_slopes_time];
       EDA_avgs_times = [EDA_avgs_times,EDA_avgs_time];
       port_avgs_times = [port_avgs_times,port_avgs_time];
       HR_avgs_all = [HR_avgs_all,HR_avgs];
       HR_avgs_times = [HR_avgs_times,HR_avgs_time];
       phys_states{test_i} = phys_indicators;
       end_times = [end_times,end_time];
       classes = [classes,class];
       % store time of end of resting control period
       if is_first
           end_time_control = end_time_cn;
           is_first = 0;
       end
    end
end
