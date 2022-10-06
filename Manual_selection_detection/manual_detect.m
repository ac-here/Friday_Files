% Author: Anand Chandrasekhar

% This function helps to detect features of Physiological waveforms
% This function helps users to remove error in detections manually.
% It does not do any FANCY algorithms. 

% Input:    Time            Time as a column vector
%           Input_Signal    Phyiological signal like ECG or PPG
%           detections      If it is ECG, detectons hold locations of
%                           R-wave
%                           If it is PPG, detections hold locations of 
%                           maximum or minimum of the beat.
%                           detections should be loaded as a column vector.
%                           If there are multiple dections in one beat, for-example 
%                           minimum and maximum of a PPG beat, you may use
%                           the following format:
%                           detections(:, 1) = ppg_maximum_detection
%                           detections(:, 2) = ppg_minimum_detection
%           Window_Frame    Span of time to be displayed in one plot
%                           Unit of seconds. 
%                           = 10 means Input_Signal for a span of 
%                           10 s will be plotted.
%           signal_type     At present, only these signals are allowed.
%                           1. ECG
%                           2. PPG (Not tested)
% Output    detections      Detection of the waveform
%           Error_Message   Information on any error message

% How to use this function  
% INSTRUCTIONS
%       1. Wait for the program to load the window_frame(10s) of the signal.
%       2. You can scroll through the signals using "L/R Arrow" keys.
%       3. If you need to modify features in a beat:
%           a.  To add features in a beat, select the beat using 
%               LEFT mouse click and press "SPACE" or "RETURN". 
%                   (i).    Press "SPACE", the defualt algorithm  
%                           will run on that specific beat to detect 
%                           the features.
%                   (ii).   Press "RETURN" to select the point of click.
%                           This feature is only available for ECG signals.
%           b.  To remove features in a beat, select the beat using
%               LEFT mouse click and press "DELETE".
%       4. Press Middle Mouse button to zoom on a plot.
%          To Stop Zooming, press "ENTER". 
%       5. To select a region of beats, Press "LEFT Click", "Escape", "2 LEft Clicks"
%       6. To select an amplitude threshold for selecting beats, Press "LEFT Click", "x", "1 LEft Clicks"
%           All foot detections below the amplitude threshold will be
%           removed.
%       7. To select an amplitude threshold for selecting beats, Press "LEFT Click", "z", "1 LEft Clicks"
%           All foot detections above the amplitude threshold will be
%           removed. 
%       8. If you want to discontinue the manual detection, follow these 
%          options.
%           a.  RIGHT mouse click at any point of time.
%           b.  Scroll to the end of the data using RIGHT Arrow Key

function [detections, Error_Message] ...
                    = manual_detect(Time, Input_Signal, ...
                                    detections, Window_Frame, ...
                                    signal_type)   

    % Customary Input Checking
    if  nargin ~= 5 || ...                      % Check if all the arguments are available
        isempty(Time) || ...                    % Check if Time is not empty
        isempty(Input_Signal) || ...            % Check if Signal is not empty
        length(Input_Signal) ~= length(Time)    % Check if #Signal == #Time
        fprintf('Error in the input files\n')
        return;
    end
    
    Error_Message = '';
    
    % Force all figures;
    close all;
    
    % If detections are empty, run basic algorithm to detect
    detections = default_detections(Time, Input_Signal, signal_type, detections);

    % Starting index of the data
    start       = 1;
    
    % Sampling rate of the signal
    Fs          = 1/mean(diff(Time)); 
    
    % If length of window frame is larger than the 
    % recorded data
    if Window_Frame * Fs > length(Input_Signal)
        Window_Frame =  2;     
    end
    
    % if length of ECG is very small, return without computation
    if length(Input_Signal) < Fs
        Error_Message = 'Length of Input signal is too short';
        fprintf('%s\n', Error_Message);
        return
    end
    
    %fprintf('Use LEFT mouse click to indicate R Peaks and Press SPACE to confirm\n');
    %fprintf('Use LEFT mouse click to indicate R Peaks and Press "ENTER" to confirm\n');
    %fprintf('Use LEFT mouse click to indicate R Peaks and Press "DELETE" to remove\n');
    %fprintf('Use arrow keys to scroll\n');
    
    % Window length to display [Units of seconds]
    Delta_T         = Window_Frame;
    
    % Number of samples in a beat
    Samples_per_beat= mean(diff(detections(:, 1)));
    
    % Approximate width of the R peak [Units of seconds]
    switch signal_type
        case 'ECG'
            %Half_beat       = floor(Fs/4); % 4
            Half_beat       = floor(Samples_per_beat/4); % 4
        case 'PPG'
            %Half_beat       = floor(Fs/2);
            Half_beat       = floor(Samples_per_beat/2); % 4
        otherwise
    end
    
    
    % This flag decides when to stop processing
    Stop_Flag       = false;
    
    % Length of the input signal
    Len_Input       = length(Input_Signal);
       
    % Try Catch block is to give an option to save the indentified peaks
    try    
        while(true)

            % Update the stop point of the display window
            stop                    = update_stop(...
                                            start, ...
                                            Fs, Delta_T, ...
                                            Len_Input);

            % If length of displayed window is less than 1s, 
            % Re-intialize the start and stop variabels to display
            % the last window properly
            if stop-start < Fs
                stop    = Len_Input;
                start   = stop - Delta_T*Fs;
            end
            
            % Plot the signals and detection withtin the interval [start stop]
            Index_Detections_Window = plot_signals(...
                                        Time, Input_Signal, ...
                                        start, stop, ...
                                        detections, signal_type);          
            
            % Wait for the mouse click. Click on the beat of interest
            [loc, ~, button]        = ginput(1);
            
            % check if middle bouse button clicked for Zooming
            if button == 2
                zoom on; 
                pause(); 
                [loc, ~, button]  	= ginput(1);
                xlim([Time(start) Time(stop)])
            end
            
            [~, Index_Location] 	= min(abs(Time - loc));
            Index_Signal_ROI        = Index_Location-Half_beat:Index_Location+Half_beat;
            Index_Signal_ROI(Index_Signal_ROI<=0)           = 1;
            Index_Signal_ROI(Index_Signal_ROI>=Len_Input)   = Len_Input;
            [~, ...
              Index_Detections_ROI] = intersect(detections(:, 1), Index_Signal_ROI);
            
            switch button 
                case 29 % Pressed Right Arrow
                        % Update the starting point of the display window
                      	start = increment_starting_point(start, ...
                                                    detections, ...
                                                    Index_Detections_Window, ...
                                                 	Fs, Delta_T);
                        hold off; 
                        
                case 28 % Pressed left Arrow
                        % Update the starting point of the display window
                      	start = decrement_starting_point(start, ...
                                                    Delta_T, ...
                                                    Fs);
                        hold off; 
                        
                case 3  % Pressed Right Mouse Click
                        Stop_Flag = true; 
                        
                case 1  % Pressed Left Mouse Click
                        if Stop_Flag, hold off; end
                        
                        % Select or delete the point
                        detections ...
                                = make_deletion_or_selection(...
                                    Time, Input_Signal, ...
                                    Index_Signal_ROI, ...
                                    Index_Detections_ROI, ...
                                    detections, signal_type, ...
                                    Index_Location); 
                        
                otherwise
                       fprintf('[-----]: Invaid Button Try L/R Mouse Click, Arrow Keys to scroll, SPACE/DELETE to confirm/remove features\n');
            end
            
            % Initialize the Stop_Flag to prevent the next iteration
            if stop == length(Input_Signal) && ...
                    button ~= 1 &&  button ~= 28
                Stop_Flag = true;
            end  
            
            % If length of displayed window is less than 1s or if Stop Flag is
            % true, end the loop
            if Stop_Flag
                break; 
            end
            
        end  
    catch ME
        Error_Message = ME.message;
        fprintf('%s\n', Error_Message);
    end
    
    % Removing any peaks detected outside the range of the input signal
    detections(any(detections>Len_Input, 2), :)     = [];
    detections(any(detections<1, 2), :)             = [];
        
    fprintf('Data is saved. Return to the main function\t');
    close;
end