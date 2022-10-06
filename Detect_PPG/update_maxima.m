function [Range_max_input, ...
            maxx, ...
            T_start_point_index, ...
            Range_Maxima_Error_count, ...
            Max_Val] ...
                                = update_maxima(signal, ...
                                        Index_window_start_point, ...
                                        Index_window_end_point, ...
                                        Range_max_input, ...
                                        Percent_change_maxima, ...
                                        Range_Maxima_Error_count, ...
                                        Array_Max_last_few_beats)
                                    
    [Max_Val, maxx_Win]  	 	= max(signal);
    maxx                        = Index_window_start_point + maxx_Win - 1; 
    T_start_point_index         = Index_window_end_point; 

    %fprintf('Samples_per_beat = %6d\t', Samples_beat);
    if Range_max_input(1) <= Max_Val && Max_Val <= Range_max_input(2)        
        Range_max_input             = find_new_range_of_max(Array_Max_last_few_beats, Max_Val, Percent_change_maxima);
        Range_Maxima_Error_count    = 0;        
    else
        maxx                        = [];
        Max_Val                     = [];
        Range_Maxima_Error_count    = Range_Maxima_Error_count + 1;
    end
    
    % If range error is happening continusouly for N times, 
    % Skip the Range requirement
    if Range_Maxima_Error_count == 10
        Range_Maxima_Error_count    = 0;
        Range_max_input             = find_new_range_of_max(Array_Max_last_few_beats, Max_Val, Percent_change_maxima);   
    end
end
function Range_max_input = find_new_range_of_max(Array_Max_last_few_beats, Max_Val, Percent_change_maxima)
          
        
    % Find the mean of the maxima of the past few beats 
    Mean_Amp                    = mean(Array_Max_last_few_beats, 'omitnan');  

    if isnan(Mean_Amp)
        Mean_Amp                = Max_Val;	
    end

    Range_max_input             = Mean_Amp * [100 - Percent_change_maxima, 100 + Percent_change_maxima]/100;
end