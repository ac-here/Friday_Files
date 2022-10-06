% Author: Anand Chandrasekhar
% Use the right and left arrow to scroll the window.
% Use the mouse pointed to locate the beats.
function [X_start, ...
            Samples_beat, ...
            ABORT_FlAG] = locate_number_of_samples(time, signal, T_start)

    % Initialize a timer 
    t               = timer;
    t.StartDelay    = 1 * 60;
    t.TimerFcn      = 'TIMER_RUNNING = false; close;';
    TIMER_RUNNING   = true;
    start(t); % Start the timer

    %Initialize variables for error
    Continue_operation = true;
    
    % Set this flag if you want to stop computation
    ABORT_FlAG      = false;

    while Continue_operation

        Continue_operation = false;

        figure(1);
    
        % Initializations
        X_start         = nan;
        Samples_beat    = nan;
    
        % Length of time in seconds for plotting data
        Delta_window_to_plot = 10;
        
        % If flag is true, beats are identified
        COMPLETE_FLAG = false;
    
        % Time for shiting window frame
        shift_plot  = Delta_window_to_plot/2;
    
        % Interval to plot to locating a beat
        Interval    = [T_start T_start+Delta_window_to_plot];
    
        % Samples per second in Hz
        Fs          = 1/(time(2) - time(1));
    
        if length(signal) ~= length(time)
            Continue_operation = false;
            COMPLETE_FLAG = true;
            break;
        end
    
        if length(signal) <= Fs*Delta_window_to_plot
            Continue_operation = false;
            COMPLETE_FLAG = true;
             break;
        end
    
        try
                
            while ~COMPLETE_FLAG
    
                continue_looking_for_button_press = true;
        
                while continue_looking_for_button_press
    
                    Index_to_plot = Interval(1) <=  time & time < Interval(2);

                    if ~any(Index_to_plot)
                        Interval(1)     = min(time(time>=Interval(2)));
                        Interval(2)     = Interval(1) + Delta_window_to_plot;
                        Index_to_plot   = Interval(1) <=  time & time < Interval(2);
                    end

                    Y_plot = signal(Index_to_plot);
                    plot(time(Index_to_plot), Y_plot, '--k'); 
                    title('Arrows to scroll. Enter to confirm the region');
            
                    % Wait for the press of button
                    % Right arrow - shift right the plot window by shift_plot
                    % left arrow - shift left the plot window by shift_plot 
                    waitforbuttonpress;
                    
                    currkey = get(gcf, 'CurrentKey');        
                    continue_looking_for_button_press = true;
    
                    switch currkey
                        case 'rightarrow'
                            Interval = [Interval(1) + shift_plot Interval(1) + shift_plot + Delta_window_to_plot];                
                        case 'leftarrow'
                            Interval = [Interval(2) - shift_plot - Delta_window_to_plot Interval(2) - shift_plot];
                        case 'return' % This is left mose click
          
                            continue_mouse_selection = true;
                            while continue_mouse_selection
                                try
                                    plot(time(Index_to_plot), Y_plot, '-k'); hold on;
                                    title('Left mouse click to select. Right mouse click to scroll');
                                    [T0(1), ~, btn(1)]         = ginput(1);
                                    if btn(1) == 1                                    
                                        plot([T0(1) T0(1)], [min(Y_plot) max(Y_plot)], '-b', 'LineWidth', 3);                                    
                                        title('Left mouse click to select. Right mouse click to scroll');
                                        [T0(2), ~, btn(2)]     = ginput(1);                                    
                                        if btn(2) == 1   
    
                                            plot([T0(2) T0(2)], [min(Y_plot) max(Y_plot)], '-r', 'LineWidth', 3);
                                            continue_mouse_selection = false;
                                            COMPLETE_FLAG       = true; 
                                            X_start             = floor(interp1(time, (1:length(time))', T0(1)));
                                            Samples_beat        = floor((T0(2) - T0(1)) * Fs);
                                            continue_looking_for_button_press = false;                                            
                                            title('Thank you');
                                            figure(1); hold off;
                                        else
                                            continue_mouse_selection = false; 
                                            figure(1); hold off;
                                        end
                                    else
                                        continue_mouse_selection = false;
                                        figure(1); hold off;
                                    end
                                catch 
                                   
                                end
                            end
                        otherwise
                            continue_looking_for_button_press = true;
                             hold off;
                    end
    
                end
            
                if Interval(1) < 0
                    Interval = [0 Delta_window_to_plot];
                elseif Interval(2) > max(time)
                    Interval = [max(time)-Delta_window_to_plot max(time)];
                end
        
            end
        catch 
            if ~TIMER_RUNNING
                X_start             = nan;
                Samples_beat        = nan;
                Continue_operation 	= true;
            else
                ABORT_FlAG          = true;
                X_start             = nan;
                Samples_beat        = nan;
                Continue_operation 	= false;
            end
        end
    end
    
    stop(t); % Start the timer    
    delete(t); % delete the timer
end