function start = increment_starting_point(...
                    start, ...
                    detections, ...
                    Index_Detections_Window, ...
                    Fs, ... 
                    Delta_T)

    Max_Detections  = detections(:, 1);
                
    % Update the starting point of the display window
    if isempty(Max_Detections(Index_Detections_Window))  
        start    = start + floor(Fs * Delta_T);
    else
        Det     = Max_Detections(Index_Detections_Window);
        if length(Det) == 1
           start   = start + floor(Fs * 5); 
        else
           start   = max(Max_Detections(Index_Detections_Window)) ; 
        end

        if start > floor(Fs * 1/4)
            start = start - floor(Fs * 1/4);
        end
        
    end

end
