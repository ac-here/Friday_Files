function [Stop_Flag, Index_window] = location_index_length(Len_signal, window_start, window_end)

    Stop_Flag = false;
    
    Sample_beat = window_end - window_start;

    if(window_end > Len_signal - 10*Sample_beat)
        window_end = Len_signal;
        Stop_Flag = true;
    end
    
    if(window_start < 1) 
        window_start = 1;
    end

    Index_window    = window_start:window_end; 
end