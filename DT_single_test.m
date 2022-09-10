function [MAV_avgs,MAV_time,EDA_avgs,EDA_avgs_time,port_avgs,port_avgs_time,HR_avgs,HR_avgs_time,phys_indicators,end_time,class,end_time_cn] = DT_single_test(test_num,HR,single)
   
% store times that physiological state switched based on human
    % self-labels
    phys_indicators = [];
    % store start and stop of assembly task periods
    ss_times = [];

    %% get EMG data
    EMG_data_1 = readlines(strcat('EMG_data_board_test_',test_num,'.txt'));
    EMG_time = [];
    EMG = [];
    
    EMG_data_1 = EMG_data_1(~cellfun('isempty',EMG_data_1));
    
    % sort EMG data from physiological state labels and start and stop
    % times
    j = 1; 
    EMG_data = [];
    while j < size(EMG_data_1,1)
        data = char(EMG_data_1(j));
        if strcmp(data(1),'t')
            j = j + 1;
            while str2double(EMG_data_1(j)) > 0
                j = j + 1;
            end
            ss_times = [ss_times, [0;str2double(EMG_data_1(j))/(-1000)]];
        elseif strcmp(data(1),'l') 
            j = j + 1;
            while str2double(EMG_data_1(j)) > 0
                j = j + 1;
            end
            ss_times = [ss_times,[1;str2double(EMG_data_1(j))/(-1000)]];
        elseif strcmp(data(1),'n')
            j = j + 1;
            while str2double(EMG_data_1(j)) > 0
                j = j + 1;
            end
            phys_indicators = [phys_indicators, [1;str2double(EMG_data_1(j))/(-1000)]];
        elseif strcmp(data(1),'h')
            j = j + 1;
            while str2double(EMG_data_1(j)) > 0
                j = j + 1;
            end
            phys_indicators = [phys_indicators, [2;str2double(EMG_data_1(j))/(-1000)]];
        else
            EMG_data = [EMG_data;str2double(data)];
        end
        j = j + 1;
    end

    % parse EMG time from data points and average EMG values between time
    % values (indicated by being negative)
    j = 1;
    while j < size(EMG_data,1)
        if EMG_data(j) < 0
            sum1 = 0;
            count = 0;
            i = j + 1;
            while EMG_data(i) >= 0 && i < size(EMG_data,1)
                if mod(EMG_data(i),1) ~= 0 && EMG_data(i) < 2
                    sum1 = sum1 + EMG_data(i);
                    count = count + 1;
                end
                i = i + 1;
            end
            if count > 0
                EMG = [EMG; sum1/count]; % average EMG values between time points
                EMG_time = [EMG_time; EMG_data(j)/(-1000)]; % save time in seconds
            end
            j = i;
            
        else
            j = j + 1;
        end
    end
    
    first_EMG_val = EMG(1);
    for i = 0:EMG_time(1)
        EMG_time = [i;EMG_time];
        EMG = [first_EMG_val;EMG];
    end
    end_time = EMG_time(end);
      
    low = EMG;
    
    % Mean absolute value for EMG data
    step = 30;
    p = 1;
    EMG_time2 = [];
    MAD_EMG = [];
    
    while p < size(low,1)
        if p + step <= size(low,1)
            EMG_time2 = [EMG_time2;EMG_time(p+step)];
            MAD_EMG = [MAD_EMG;mean(low(p:p+step))];
        else
            EMG_time2 = [EMG_time2;EMG_time(end)];
            MAD_EMG = [MAD_EMG;mean(low(p:end))];
        end
        p = p + step;
    end

    % get average mean absolute value over 20 second intervals
    MAV_avgs = [];
    MAV_time = [];
    step_size = 20;
    i_start = 1;
    i_end = i_start;
    while i_start <= size(EMG_time2,1)
        while (EMG_time2(i_end) - EMG_time2(i_start) < step_size) && (i_end < size(EMG_time2,1))
            i_end = i_end + 1;
        end
        if i_start ~= i_end
            MAV_avgs = [MAV_avgs,mean(MAD_EMG(i_start:i_end))];
            MAV_time = [MAV_time,EMG_time2(i_start)];
            i_start = i_end;
        else
            i_start = i_start + 1;
        end
    end

    
    if single
        MAD_start_time = 1;
        count = 0;
        j = 1;
        % get time when resting control period is over
        while j < size(ss_times,2)
            if ss_times(1,j) == 1
                count = count + 1;
                if count == 3
                    MAD_start_time = ss_times(2,j);
                    break;
                end
            end
            j = j + 1;
        end
        end_time_cn = MAD_start_time;
    else
        end_time_cn = end_time;
    end
    
    %% EDA sensor data
    % load tags from E4 data
    E4_sample_rate = 4;
    tags = readmatrix(strcat('tags_',test_num,'.csv'));
    % load EDA data
    EDA = readmatrix(strcat('EDA_',test_num,'.csv'));
    time_EDA = (1:size(EDA))./E4_sample_rate;
    
    % tags used to align data at starting time (start_time)
    if ~isempty(tags)
        tags = tags - tags(1);
        start_time = tags(2);
        [val_start,start_i] = min(abs(time_EDA-start_time));  
        end_i = length(EDA);
    else
        start_i = 1;
        end_i = length(EDA);
    end
    
    start_E4 = start_i;
    EDA = EDA(start_E4:end);
    EDA_time = time_EDA(start_E4:end) - start_time;

    % average EDA data over 20 second intervals
    EDA_step = step_size * E4_sample_rate;
    i = 1;
    EDA_avgs_time = [];
    EDA_avgs = [];
    while i <= size(EDA_time,2) - EDA_step
        EDA_avgs_time = [EDA_avgs_time, EDA_time(i)];
        EDA_avgs = [EDA_avgs, mean(EDA(i:i+EDA_step))];
        i = i + EDA_step;
    end 
    
    %% PortaMon data
    % 10Hz sampling rate
    portamon_sampling_rate = 10;
    % load muscle deoxygenation data
    load(strcat('Portamon_board_test_',test_num,'0.mat'));
    % load amount of time PortaMon is collecting data before trial starts
    load(strcat('PortaMon_board_test_',test_num,'_time.mat'));
    portamon_time = b;

    % get correct start time for PortaMon data
    portamon_start = portamon_time*portamon_sampling_rate;
    portamon_end = end_i * portamon_sampling_rate + portamon_time*portamon_sampling_rate;
    t = nirs_data.time(portamon_start:min(portamon_end,size(nirs_data.dxyvals,1))) - nirs_data.time(portamon_start);
    port_data = nirs_data.dxyvals(portamon_start:min(portamon_end,size(nirs_data.dxyvals,1)),1);
    
    % average PortaMon data over 20 second intervals
    port_step = step_size * portamon_sampling_rate; % 20 seconds of data
    i = 1;
    port_avgs_time = [];
    port_avgs = [];
    count = 1;
    curr_state = phys_indicators(1,count);
    if count + 1 <= size(phys_indicators,2)
        state_time = phys_indicators(2,count+1);
    else
        state_time = end_time + port_step;
    end
    % store human-labeles physiological states in classes
    class = [];
    while i < size(t,1) - port_step
        port_avgs_time = [port_avgs_time, t(i)];
        port_avgs = [port_avgs, mean(port_data(i:i+port_step))];
        if (t(i) + t(floor(port_step/2))) > state_time
            if count + 1 <= size(phys_indicators,2)
                count = count + 1;
                curr_state = phys_indicators(1,count);
                if count + 1 <= size(phys_indicators,2)
                    state_time = phys_indicators(2,count+1);
                else
                    state_time = end_time + port_step;
                end
            end
        end
        class = [class,curr_state];
        i = i + port_step;
    end


    %% Heart rate from Polar Beat Sensor
    HR_avgs_time = [];
    HR_avgs = [];
    if HR
        % load heart rate data
        HRP = readmatrix(strcat('HR_board_test_',test_num,'.csv'));
        HR_sampling_rate = 1;
        HRP = HRP(:,3);
        HRPTime = 0:length(HRP)-1;
          
        % average heart rate data over 180 second sliding window
        HR_step = 180 * HR_sampling_rate;
        HR_avgs3 = [];
        for i = 1:size(HRPTime,2)
            if i < HR_step
                HR_avgs3 = [HR_avgs3, mean(HRP(1:i))];
            else
                HR_avgs3 = [HR_avgs3, mean(HRP(i-HR_step+1:i))];
            end
        end
    
        % average averaged heart rate data so array length agrees with data
        % from other sensors
        HR_step = step_size * HR_sampling_rate;
        i = 1;
        while i < size(HRPTime,2) - HR_step
            HR_avgs_time = [HR_avgs_time, HRPTime(i)];
            HR_avgs = [HR_avgs, mean(HR_avgs3(i:i+HR_step))];
            i = i + HR_step;
        end
    end
   
end

