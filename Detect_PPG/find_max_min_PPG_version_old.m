% Author Anand Chandrasekhar
% This function detects the features of a PPG signal. The algorithm detects 
% features of PPG singal like the minima and maxima.
% Input:        time                Time vector
%               signal              PPG Signal
%               Type_of_valley      The location of the valley may be
%                                   minima location of the beat or may be
%                                   identified via tangent algorithm.
%                                   = 'Minima' for Minimum of beat
%                                   = 'Tangent' for tangent algorithm 
%               Samples_beat        Number of samples in a cycle.
%               intermediate_Samples_detection
%                                   True: Find number of samples
%                                   intermitently
%                                   False: Use the first number of samples

%Output         Valley_Locations    Minimum or Tangent point of the beat
%               Maxima_Locations    Maxima Location of the beat
           
function detections = find_max_min_PPG_version_old(...
                                        time, ...
                                        signal, ...
                                        Type_of_valley, ...
                                        Samples_beat, ...
                                        intermediate_Samples_detection)
                                          
    % Initialize all the variables
    maxima              = [];
    Samples_beat_saved  = [];
        
    % Units of seconds
    % This is to create the vincity of the feature
    Local_Win_Th    = 0.1;

    % Ensure the starting point of time  is 0s
    time                = time - time(1);
    
    % Sampling Rate
    Fs          = 1/(time(2) - time(1));

    if ~exist('intermediate_Samples_detection', 'var')
        intermediate_Samples_detection = false;
    end
    
    if ~exist('Samples_beat', 'var') 
        % Compute the number of samples in a beat.
        if length(signal) < floor(10*Fs)
            detections = [];
            fprintf('Very less data. Abort\n');
            return;
        end
        [X_start, Samples_beat] = locate_number_of_samples(time, signal, 0);       
    end
    
    % Error Checking
    if length(signal) < 2*Samples_beat
        fprintf('Length of signal is very minimal in find_max_min_PPG.m');
        return;
    end
    
    %Extract the first Maxima and update the pointer
    [~,maxx]                    = max(signal(X_start:X_start + Samples_beat));
    ptr                         = 1;
    maxima(ptr, 1)              = maxx; 
    Samples_beat_saved(ptr, 1)  = Samples_beat;

    ptr                         = length(maxima) + 1;
    Stop_Flag                   = false;
    
    % Find all maxima locations
    while(~Stop_Flag)    

        window_start 	= floor(maxx + 1/4*Samples_beat);
        window_end    	= floor(maxx + 5/4*Samples_beat);        
        
        if(window_end > length(signal))
            window_end = length(signal);
            Stop_Flag = true;
        end
        
        if(window_start < 1) 
            window_start = 1;
        end
        
        Index_window    = window_start:window_end;       
        [~, maxx_Win]  	= max(signal(Index_window));
        if ~isempty(maxx_Win)
            maxx            = Index_window(1) + maxx_Win - 1;
        else
            maxima(ptr, 1)	= nan;
            maxx            = Index_window(end);
            ptr          	= ptr + 1;
            continue;
        end

        if(maxx_Win == 1 || maxx_Win == length(Index_window))     

            [X_start, Samples_beat]     = locate_number_of_samples(time, signal, time(Index_window(1)));
            [~,maxx]                    = max(signal(X_start:X_start + Samples_beat));
            maxima(ptr, 1)	            = maxx; 
            Samples_beat_saved(ptr, 1)  = Samples_beat;
            ptr          	            = ptr + 1; 

        else
            local_point                 = find_local_minima_maxima(...
                                            signal, ...
                                            maxx, ...
                                            Local_Win_Th, ...
                                            Fs, ...
                                            'Max');
            maxima(ptr, 1)	            = local_point;

            if ptr > 5
                avg_samples_beat = mean(Samples_beat_saved(ptr-5:ptr), 'omitnan');
                if isnan(avg_samples_beat)
                    plot(signal(maxima(ptr, 1):maxima(ptr, 1)+floor(25*Fs)));
                    title('Locate the start and end point of a SINGLE beat');
                    set(gca, 'FontSize', 10);            
                    [x, ~, ~]           = ginput(2);close;
                    avg_samples_beat    = abs(floor(x(2) - x(1))); 
                end
                Samples_beat_saved(ptr, 1) = avg_samples_beat;
            else
                Samples_beat_saved(ptr, 1) = Samples_beat_saved(1, 1);
            end

            ptr          	= ptr + 1; 
        end
                
    end

    % Remove wrong detections of maxima
    maxima(isnan(maxima)) = [];  
    
    % Locate the minima points
    minima = nan(length(maxima), 1);
    for i = 1:length(maxima)
        window_start 	= floor(maxima(i) - 0.5*Samples_beat);
        window_end    	= maxima(i);        
        
        if(window_end > length(signal))
            window_end = length(signal);
        end
        
        if(window_start < 1) 
            window_start = 1;
        end
        
        Index_window    = window_start:window_end;        
        [~, minn_Win] 	= min(signal(Index_window));
        minn            = Index_window(1) + minn_Win - 1;
        
        local_point     = find_local_minima_maxima(...
                                    signal, ...
                                    minn, ...
                                    Local_Win_Th, ...
                                    Fs, ...
                                    'Min');
        
        if minn_Win == 1 || minn_Win == length(Index_window) || minn > maxima(i)
            minima(i, 1)	= nan;
        else
            minima(i, 1)	= local_point;
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
    
%     plot(time, signal);hold on;
%     plot(time(detections(:, 1)), signal(detections(:, 1)),'or');
%     plot(time(detections(:, 2)), signal(detections(:, 2)),'*b');
end