% Author Anand Chandrasekhar
% This function detects the features of a PPG signal. The algorithm detects 
% features of PPG singal like the minima and maxima.
% Input:        time                Time vector
%               signal              PPG Signal
%               ID_file             Unique ID of the file  
%               Type_of_valley      The location of the valley may be
%                                   minima location of the beat or may be
%                                   identified via tangent algorithm.
%                                   = 'Minima' for Minimum of beat
%                                   = 'Tangent' for tangent algorithm 

%Output         Valley_Locations    Minimum or Tangent point of the beat
%               Maxima_Locations    Maxima Location of the beat
           
function detections = find_max_min_PPG(...
                                        time, ...
                                        signal, ...
                                        ID_file)
                                          
    % Initialize all the variables
    maxima              = [];
        
    % Units of seconds
    % This is to create the vincity of the feature
    Local_Win_Th        = 0.1;

    % Ensure the starting point of time  is 0s
    time                = time - time(1);

    % plot the data online
    plot_data_online    = false;

    % Try iterating new starting point. Allow the number of iterations
    iterations_num      = 5;
    
    % Sampling Rate
    Fs          = 1/(time(2) - time(1));

    % Duaration for computing FFT in seconds
    duration_for_computing_FFT = 10;

    % Percentage of maxima change allowed in the next beat
    Percent_change_maxima = 15;
    
    % Allowed threshold of the signal
    Allowed_threshold_signal = [40 150];

    % Make column vectors
    time = time(:);
    signal = signal(:);

    % Create a temporary ID file
    if ~exist('ID_file', 'var') 
        ID_file = randi([1 1000],1,1);
    end

    % Save the current_ID_file
    current_ID_file = ID_file;

    % load previously saved detections
    if isfile('temporary_maxima_file.mat')
        load('temporary_maxima_file.mat', 'maxima', 'ID_file');
        loaded_ID_file = ID_file;  
    else
        loaded_ID_file = [];
    end

    clear ID_file

    % Decide the starting point
    if current_ID_file == loaded_ID_file
        start_point = time(max(maxima));
        ptr         = length(maxima) +1;
        % Use this variable to mention when did the 
        % last temporary_maxima_file got saved
        previous_saved_time_stamp = start_point;
    else
        start_point = 0;
        ptr         = 1;
        previous_saved_time_stamp = 0;
    end

    % Save the maxima after every interval mentioned in this variable
    save_me_after_every_interval_in_miutes = 30;

    % Compute the number of samples in a beat.
    if length(signal) < floor(10*Fs)
        detections = [];
        fprintf('Very less data. Abort\n');
        return;
    end

    % Locate the number of samples in a beat
    [X_start, Samples_beat] = locate_number_of_samples(time, signal, start_point);
    Index_window            = (X_start:X_start + Samples_beat)';
    [~, maxx_Win]  	        = max(signal(Index_window));
    maxx                    = Index_window(1) + maxx_Win - 1;
    Range_max_input         = signal(maxx) * [100 - Percent_change_maxima, 100 + Percent_change_maxima]/100;
    
    % Error Checking
    if length(signal) < 2*Samples_beat
        fprintf('Length of signal is very minimal in find_max_min_PPG.m');
        return;
    end
    
    % This variables decides when to stop the maxima computation
    Stop_Flag                   = false;
    Range_Maxima_Error_count    = 0;
    
    % Start computing time;
    tic

    % Find all maxima locations
    while(~Stop_Flag)    
               
        [Range_max_input, ...
            maxima, ...
            T_start_point_index, ...
            Range_Maxima_Error_count] ...
                                = update_maxima(time, signal, ...
                                            Index_window, Range_max_input, ...
                                            maxima, Percent_change_maxima, ...
                                            Range_Maxima_Error_count);                            
        
    
        if plot_data_online
            figure(2); 
            Index_plot = (time(maxima(end))-10) <= time & time <= (time(maxima(end))+10);
            T_plot = time(Index_plot);
            plot(T_plot, signal(Index_plot), '-k'); hold on; 
            plot(time(Index_window), signal(Index_window), '-b', 'LineWidth', 2);
            plot(time(maxima(end)), signal(maxima(end)), 'or');
            xlim([T_plot(1) T_plot(end)]);            
        end

        % This code fragment try to locate maxima without using FFT or
        % manual intervention
        [Index_window, ~, MAXIMA_LOCATED_FLAG] ...
                                = itratively_search_for_next_peak(...
                                        iterations_num, ...
                                        Fs, ...
                                        time, ...
                                        signal, ...
                                        T_start_point_index, ...
                                        Range_max_input);
                                    
        if plot_data_online && MAXIMA_LOCATED_FLAG
            fprintf('Time detected via Algo 1 @ [%3.4f]\n', time(maxima(end))/60/60);
        end    

        % Use FFT based Max detection
        % This code is activated when the Previous methods fail.
        [MAXIMA_LOCATED_FLAG, ...
            Index_window] = search_for_the_next_peak_using_fft(...
                                time, signal, ...
                                T_start_point_index, ...
                                MAXIMA_LOCATED_FLAG, ...
                                Index_window, ...
                                duration_for_computing_FFT, ...
                                Allowed_threshold_signal);
                            
        if plot_data_online && MAXIMA_LOCATED_FLAG
            fprintf('Time detected via Algo 2 @ [%3.4f]\n', time(maxima(end))/60/60);
        end                              
                            
        % Use this code to detect the next index window by manual selection
        Index_window = search_for_the_next_peak_using_manual_selection(...
                                        time, signal, ...
                                        T_start_point_index, ...
                                        MAXIMA_LOCATED_FLAG, ...
                                        Index_window);      
        
        % Save the detections every 30 minutes in the local directory.
        T_current = time(maxima(end));
        if (T_current - previous_saved_time_stamp) >= save_me_after_every_interval_in_miutes*60
            Time_elaspsed = toc;
            ID_file = current_ID_file;
            save('temporary_maxima_file.mat', 'maxima', 'ID_file');
            previous_saved_time_stamp = T_current;
            fprintf('File saved. Time completed = [%3.2f/%3.2f] Hours. Time Taken = %3.1f\n', ...
                            T_current/60/60, max(time)/60/60, Time_elaspsed);
            tic
        end
        
        if time(Index_window(end)) > (max(time) - 60)
            Stop_Flag = true;
        end        
        %
    end

    % Delete the temporary file
    delete('temporary_maxima_file.mat');

    % Remove wrong detections of maxima
    maxima(isnan(maxima)) = [];  

    % Remove repeated values
    maxima = unique(maxima);

    maxima = sort(maxima);
    
    % Locate the minima points
    minima = nan(length(maxima), 1);

    for i = 1:length(maxima)
        window_start 	= floor(maxima(i) - 0.5*Fs);
        window_end    	= maxima(i)-1;        
        
        if(window_end > length(signal))
            window_end = length(signal);
        end
        
        if(window_start < 1) 
            window_start = 1;
        end
        
        Index_window    = window_start:window_end;        
        [~, minn_Win] 	= min(signal(Index_window));
        minn            = Index_window(1) + minn_Win - 1;
                
        if minn_Win == 1 || minn_Win == length(Index_window)
            minima(i, 1)	= nan;
        else
            minima(i, 1)	= minn;
        end
    end 
    
    % Remove wrong detections of minima and maxima
    Minima_is_nan_index         = isnan(minima);
    maxima(Minima_is_nan_index) = [];
    minima(Minima_is_nan_index) = [];   
    
    % Remove any repeated beats
    [~, unique_index]           = unique(minima);
    minima                      = minima(unique_index);
    maxima                      = maxima(unique_index);
    [~, unique_index]           = unique(maxima);
    minima                      = minima(unique_index);
    maxima                      = maxima(unique_index);
    
    detections                  = [maxima minima];
    
    detections = update_peak_minima_locations(signal, detections, Fs, Allowed_threshold_signal);
    
%     plot(time, signal);hold on;
%     plot(time(detections(:, 1)), signal(detections(:, 1)),'or');
%     plot(time(detections(:, 2)), signal(detections(:, 2)),'*b');
end
