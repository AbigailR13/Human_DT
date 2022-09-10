
% returns index of end time for the resting control periods
function [MAD_new,EDA_new,port_new,HR_new,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes,index] = DT_remove_control(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes)
    [index] = DT_get_control_index(MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,end_time_control,HR);
    MAD_new = MAD_slopes_all;
    EDA_new = EDA_avgs_all;
    port_new = port_avgs_all;
    port_avgs_times = port_avgs_times;
    EDA_avgs_times = EDA_avgs_times;
    MAD_slopes_times = MAD_slopes_times;
    classes = classes;
    HR_new = [];
    if HR
        HR_new = HR_avgs_all;
        HR_avgs_times = HR_avgs_times;
    end
end