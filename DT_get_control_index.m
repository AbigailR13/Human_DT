
% returns index of end time for the resting control periods
function [index] = DT_get_control_index(MAD_slopes_times,EDA_avgs_times,port_avgs_times,HR_avgs_times,end_time_control,HR)
    index = 1;
    for i = 1:size(MAD_slopes_times,2)
        if MAD_slopes_times(i) >= end_time_control && EDA_avgs_times(i) >= end_time_control ...
                && port_avgs_times(i) >= end_time_control
            if HR
                if HR_avgs_times(i) >= end_time_control
                    index = i;
                    break;
                end
            else
                index = i;
                break;
            end
        end
    end
end