% Author: Anand Chandrasekhar
% This code iterativey search for next peak. 
% This function does not use FFT
function [Index_window, Er_Msg, MAXIMA_LOCATED_FLAG] ...
                        = itratively_search_for_next_peak(...
                                iterations_num, ...
                                Fs, ...
                                signal, ...
                                T_start_point_index, ...
                                Range_max_input)
    Index_window = [];
    
    % search time for the next peak
    search_time_in_seconds = 3;
                                
    for iteration_index = 1:iterations_num
        
        % Index to crop
        Index_crop = T_start_point_index: ...
                    floor(T_start_point_index + search_time_in_seconds*Fs);
                
        % Signal subset cropped based on timw windows
        signal_subset = signal(Index_crop);

        % Locate the width of the signal for which maxima need to be
        % calculated. 
        [Idx_Width, Condition, ...
            Er_Msg]     = find_index_to_search(signal_subset);
        
        % Initialize the flag for maxima location detection
        MAXIMA_LOCATED_FLAG = false;       
        
        % Extract Index for locating the maxima
        % Extract maxima only if all conditions are met
        if all(Condition)

            % Find the Index window to get maxima of the signal
            Index_window    = Idx_Width(1):Idx_Width(2);

            % Find the maxima
            [Max_Val, maxx_Win]  	= max(signal_subset(Index_window)); 
            
            % Maxima is considered good based on conditions discussed
            % below. If Maxima is not good, shift the start point to get
            % ready to find the next maxima
            if ~isempty(maxx_Win)
                if maxx_Win ~= 1 && ...
                        maxx_Win ~= length(Index_window) && ...
                        Range_max_input(1) <= Max_Val && ...
                        Max_Val <= Range_max_input(2)
                    MAXIMA_LOCATED_FLAG = true;
                else
                    % Clear the index window
                    Er_Msg = [Er_Msg; {'Maxima not within the range'}];
                    MAXIMA_LOCATED_FLAG = false;
                end
            end
        end

        % Confirm if the maxima is located
        if MAXIMA_LOCATED_FLAG
            
            break;
            
        else
            % Shift the starting point to the end of the index window
            T_start_point_index = T_start_point_index + Idx_Width(2);
            Er_Msg = [Er_Msg; {sprintf('Maxima not located in Iternation %d/%d', iteration_index, iterations_num)}];
        end
    end
    
    % Shift the Index window to the absolute index
	Index_window = Index_window + T_start_point_index - 1;
    
end