% Author Anand Chandrasekhar
% This function detects the features of a BP signal. The algorithm detects 
% features of BP  signal like the minima and maxima of a beat . The
% location of the detections are saved into an array in the following
% format output = [maxima_locations minima locations]

% Input:        time                        Time vector
%               signal                      Pressure Signal  
%               Allowed_threshold_signal    Min max of the signal
%                                           [30 180] in mmHg            

%Output         detections          [Peak Foot]
           
function detections = find_max_min_Pressure_Waveform(...
                                        time, ...
                                        signal, ...
                                        Allowed_threshold_signal)
                                    
    
    % Start parallel pooling if not enabled
    if isempty(gcp('nocreate')), parpool; end
                                    
   	% Start computing time;
    tic
                                          
    % Initialize all the variables
    maxima              = [];
    detections          = [];
        
    % Ensure the starting point of time  is 0s
    time                = time - time(1);
    
    % plot the data online when every beat is detected
    plot_data_online    = false;

    % Try iterating new starting point. Allow the number of iterations
    iterations_num      = 5;
    
    % Sampling Rate
    Fs          = 1/(time(2) - time(1));
    
    % Use this variable to decide how to locate the first maxima
    % IF this variable is set to false, first maxima will be located via
    % FFT based algorithm. If FFT fails to locate maxima, user need to
    % manually loctae the maxima
    Locate_Maxima_Manually = false;

    % Duaration for computing FFT in seconds
    % The algorithm takes this much data for computing a 1024 point FFT
    duration_for_computing_FFT = 10;

    % Percentage of maxima change allowed in the next beat
    % This variable decides how much change in SP is allowed between
    % adjacent beats
    Percent_change_maxima = 15;
    
    % Allowed threshold of the signal
    % The BP waveform should be within these ranges.
    if ~exist('Allowed_threshold_signal', 'var')
        Allowed_threshold_signal = [30 180];        
    end
    
    % Initialize Abort flag
    ABORT_FlAG = false;

    % Make column vectors
    time = time(:);
    signal = signal(:);

    % Decide the starting point
    % Start point should be in units of seconds. The code will detect
    % features from beats from the start_point
    start_point = 0;

    % Compute the number of samples in a beat.
    if length(signal) < floor(10*Fs)
        detections = [];
        fprintf('Very less data. Abort\t');
        return;
    else
        fprintf('%3.3f Hours of data loaded\t', (max(time) - min(time))/60/60);
    end

    % This code helps to locate the first maxima.
    % There are two ways to locate it.
    % Option 1: Manual detections
    % Option 2: Detections using FFT. If detections using FFT fails,
    % algorithm resort to manual detections. 
    
    if Locate_Maxima_Manually
        % Locate the number of samples in a beat
        [X_start, Samples_beat, ...
            ABORT_FlAG]         = locate_number_of_samples(time, signal, start_point);
        if ~ABORT_FlAG
            Index_window            = (X_start:X_start + Samples_beat)';
        else
            return;
        end
        
    else
        [MAXIMA_LOCATED_FLAG, ...
            Index_window] = search_for_the_next_peak_using_fft(...
                                time, signal, ...
                                1, ...
                                false, ...
                                [], ...
                                duration_for_computing_FFT, ...
                                Allowed_threshold_signal, ...
                                Fs);
                            
        % If FFT fails to locate the first maxima, manually locate it
        if ~MAXIMA_LOCATED_FLAG
            [X_start, Samples_beat] = locate_number_of_samples(time, signal, start_point);
            Index_window            = (X_start:X_start + Samples_beat)';
        end
        
    end
    
    % Locate the first maxima
    [Max_Val, maxx_Win]     = max(signal(Index_window));
    maxx                    = Index_window(1) + maxx_Win - 1;
    maxima                  = [maxima; maxx];
    TO_added             	= time(maxx);
    Range_max_input         = Max_Val* [100 - Percent_change_maxima, 100 + Percent_change_maxima]/100;
        
    % This variables decides when to stop the maxima computation
    Max_Time                    = max(time);
    Range_Maxima_Error_count    = 0;
    
    % Use this array to store amplitude of SP for the last 10 seconds
    Array_Max_last_few_beats_Y = Max_Val;
    Array_Max_last_few_beats_X = time(maxx);
    
    % Find all maxima locations
    % Data for the last 10s will be not be calculated
    while TO_added < (Max_Time - 10)    
                       
        [Range_max_input, ...
            Maxx_return, ...
            T_start_point_index, ...
            Range_Maxima_Error_count, ...
            Max_Val] ...
                                = update_maxima(signal(Index_window), ...
                                            Index_window(1), ...
                                            Index_window(end), ...
                                            Range_max_input, ...
                                            Percent_change_maxima, ...
                                            Range_Maxima_Error_count, ...
                                            Array_Max_last_few_beats_Y); 
        
        if ~isempty(Maxx_return)
            TO_added                    = time(Maxx_return);
            Array_Max_last_few_beats_Y  = [Array_Max_last_few_beats_Y; Max_Val];
            Array_Max_last_few_beats_X  = [Array_Max_last_few_beats_X; TO_added]; 
            if TO_added > (Array_Max_last_few_beats_X(1) + 10)
                Array_Max_last_few_beats_Y(1) = [];
                Array_Max_last_few_beats_X(1) = [];
            end
        end
        
        % Update the maxima array with the new maxx
        maxima = [maxima; Maxx_return];
    
        if plot_data_online
            figure(2); 
            Index_plot = (time(maxima(end))-10) <= time & time <= (time(maxima(end))+10);
            T_plot = time(Index_plot);
            plot(T_plot, signal(Index_plot), '-k'); hold on; 
            plot(time(Index_window), signal(Index_window), '-b', 'LineWidth', 2);
            plot(time(maxima(end)), signal(maxima(end)), 'or');
            xlim([T_plot(1) T_plot(end)]);            
        end

        % This code fragment try to locate index window of the next beat 
        % without using FFT or manual intervention. 
        
        [Index_window, ~, MAXIMA_LOCATED_FLAG] ...
                                = itratively_search_for_next_peak(...
                                        iterations_num, ...
                                        Fs, ...
                                        signal, ...
                                        T_start_point_index, ...
                                        Range_max_input);    

        % Use FFT based Max detection
        % This code is activated when the Previous methods fail.
        [MAXIMA_LOCATED_FLAG, ...
            Index_window]   = search_for_the_next_peak_using_fft(...
                                time, signal, ...
                                T_start_point_index, ...
                                MAXIMA_LOCATED_FLAG, ...
                                Index_window, ...
                                duration_for_computing_FFT, ...
                                Allowed_threshold_signal, ...
                                Fs);
                                               
        % Use this code to detect the next index window by manual selection
        [Index_window, ...
            ABORT_FlAG]     = search_for_the_next_peak_using_manual_selection(...
                                time, signal, ...
                                T_start_point_index, ...
                                MAXIMA_LOCATED_FLAG, ...
                                Index_window); 
                                    
        if ABORT_FlAG
            break;
        end
        
    end
    
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
                
        if minn_Win == 1 || ...
                minn_Win == length(Index_window)
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

    fprintf('Time Elaspsed = %3.2f mts \t', toc/60);
end
