function Index_Detections_Window = plot_signals(Time, Input_Signal, ...
                                                    start, stop, ...
                                                    detections, ...
                                                    signal_type)

    % Select the window index for the Time and Input_Signal 
    Index_Signal_Window            = (start: stop)';

    % Select the window index for detections
    Index_Detections_Window = find( ...
                        ( ...
                        (Time(detections(:, 1)) >= Time(start))...
                        & ...
                        (Time(detections(:, 1)) <= Time(stop)) ...
                        )== 1);

    figure(1);
    
    % Plot the signals with detections. Set appropriate limits
    plot(Time(Index_Signal_Window), ...
                    Input_Signal(Index_Signal_Window), '-k'); hold on;
                
    switch signal_type
        case 'ECG'
            % Locate the R wave
            Max_Detections  = detections(:, 1);            
            plot(Time(Max_Detections(Index_Detections_Window)), ...
                    Input_Signal(Max_Detections(Index_Detections_Window)), 'ob'); 
            ylim([-3 3]);
                        
        case 'PPG'
            % Locate the Maxima and Minima points
            Max_Detections  = detections(:, 1);
            Min_Detections  = detections(:, 2); 
            plot(Time(Max_Detections(Index_Detections_Window)), ...
                    Input_Signal(Max_Detections(Index_Detections_Window)), '*r'); 
            plot(Time(Min_Detections(Index_Detections_Window)), ...
                    Input_Signal(Min_Detections(Index_Detections_Window)), '*b');
        
        otherwise
            close; 
            fprintf('Error in selected signal_type = %s\n', signal_type)
            return;
    end
    
    title_message = 'L/R Arrow || L/R mouse || SPACE/DELETE/RETURN';
    title(sprintf('[%2.1f%% %2.1f%%] \n%s', ...
                        (start-1)/length(Input_Signal) * 100, ...
                        stop/length(Input_Signal) * 100, ...
                        title_message));
                    
end