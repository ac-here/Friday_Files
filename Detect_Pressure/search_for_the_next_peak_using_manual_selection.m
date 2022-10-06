function [Index_window, ...
            ABORT_FlAG] = search_for_the_next_peak_using_manual_selection(...
                                time, signal, ...
                                T_start_point_index, ...
                                MAXIMA_LOCATED_FLAG, ...
                                Index_window)
    
    % Initialize the abort flag
    ABORT_FlAG = false;
                            
    if ~MAXIMA_LOCATED_FLAG
        beep
        [X_start, Samples_beat, ...
            ABORT_FlAG]             = locate_number_of_samples(time, signal, time(T_start_point_index));
        
        if ~ABORT_FlAG
            Index_window            = (X_start:X_start + Samples_beat)';
        end
    end
end