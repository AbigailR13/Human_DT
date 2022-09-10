
% get the averages for the resting control periods and
% subtract them from the all data
function [MAD_new,EDA_new,port_new,HR_new,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes] = DT_control_avgs(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes)
    [MAD_new,EDA_new,port_new,HR_new,MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,classes,index] = DT_remove_control(MAD_slopes_all,MAD_slopes_times,EDA_avgs_all,EDA_avgs_times,port_avgs_all,port_avgs_times,HR_avgs_all,HR_avgs_times,end_time_control,HR,classes);
    MAD_con = mean(MAD_slopes_all(1:index)); 
    EDA_con = mean(EDA_new(1:index));
    port_con = mean(port_avgs_all(1:index));
    MAD_new = MAD_new - MAD_con;
    EDA_new = EDA_new - EDA_con;
    port_new = port_new - port_con;
    if HR
        HR_con = mean(HR_avgs_all(1:index));
        HR_new = HR_new - HR_con;
    end
end