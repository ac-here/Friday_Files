% Author: Anand Chandrasekhar
% This function calculates the beat to beat parameters from an input
% waveform. For instance, you may input BP waveform to calculate the beat
% to beat SP, DP, MAP, PP and other parameters.

% Input     : time          - Time Vector
%           : Input         - BP waveform
%           : foot_location - Index of the foot  
%           : Method        - Which method to use for exponential fitting.
%                           See the list of differnt methods in the function
%                           find_exponential_fit_main.m
%           : number_beats_ensampled_vector - 
%                           Use this variable to select
%                           how many variables to use 
%                           while averaging the waveforms.
%           : str_to_print  - strings to print after computation
%           : plot_data     - True or False
%           : Threshold_MAP_std
%                           - While averaging waveforms, minimum threshold 
%                           standard deviation.
%           : range_Tau     - Allowed range for time constant for
%                           exponential fitting.
%           : modify_Index  - True or False.
%                           True: Use the entire Tail of BP waveofor for
%                           fiting the exponential equation.
%           : percent_tail_range 
%                           - While searching for region for exponential
%                           fit, mention the range for tail to be used for
%                           searching. [50:-1:20]
%           : Allowed_difference_between_time_stamp
%                           - Allowed time differnece between two vectors
%                           in the ensampled average vector.
%           : Minimum_points_required_to_fit_EXP
%                           - if the exponential data has less than the 
%                           value in the variable, you get an error.

% Output    : SP            Systolic BP values
%           : DP            Diastolic BP values
%           : MAP           Mean Arterial Pressure
%           : PP            Pulse Pressure
%           : Time Axis     Time stamp for all beats in an ensampled vector
%           : Tau_struct    Values of Tau and the corresponding BP values
%           : Pinf          Values for the Asymptode value of pressure.
%           : Mean Tau      MEan value of decay time constant
%           : Error Message Error in computations.

function [SP, DP, MAP, PP, HR_BPM, ....
            Time_axis, ...
            Tau_struct, ...
            Pinf, ...
            Mean_Tau, ...
            Error_Message] ...
                = find_beat_to_beat_parameters_of_the_wave(...
                    time, Input, ...
                    foot_location, ...
                    Method, ...
                    number_beats_ensampled_vector, ...
                    str_to_print, ...
                    plot_data, ...
                    Threshold_MAP_std, ...
                    range_Tau, ...
                    modify_Index, ...
                    percent_tail_range, ...
                    Allowed_difference_between_time_stamp, ...
                    Minimum_points_required_to_fit_EXP)

    % Make this variable false to stop printing data
    print_me = false;

    % Make this variable true to skip exponential fitting
    Skip_exponential_fitting = true;

    % Initialize the variables
    N                   = length(foot_location);
    MAP                 = nan(1, 1);
    SP                  = nan(1, 1);
    DP                  = nan(1, 1);
    PP                  = nan(1, 1);
    HR_BPM              = nan(1, 1);
    Mean_Tau            = nan(1, 1);
    Tau_struct          = struct();
    Pinf                = nan(1, 1);
    Error_Message{1, 1} = '';
    
    % Interpolate the beats
    interpolation_factor = 100; 
    
    % Ensampled mean of beats will be saved here
    Mean_beat   = nan(interpolation_factor, 1); 
    
    % Use this variable to set the window length for calculating the
    % estimated value for sampeles per beat
    Window_for_samples_per_beat = 20;    
    
    % Average Samples per beat
    beat_to_beat_samples        = diff(foot_location);
    
    % Initialize a value for the number of samples per beat
    Samples_per_previous_beat   = calculate_samples_per_beat(beat_to_beat_samples, 1, Window_for_samples_per_beat);
    
    % Plot the results
    if ~exist('plot_data', 'var')
        plot_data   = false;
    end
    
    if ~exist('str_to_print', 'var')
        str_to_print = '---';
    end
    
    % Threshold standard deviation for MAP [ Units: mmHg ]
    if ~exist('Threshold_MAP_std', 'var')
        Threshold_MAP_std = 2;   
    end
    
    % Allowed range for Tau
    if ~exist('range_Tau', 'var')
        range_Tau   = [0 1];
    end
    
    % Make this variable true, if you want to fit the exponential to the
    % end of the beat.
    if ~exist('modify_Index', 'var')
        modify_Index    = true;
    end
    
    % fit exponential has lots of methods. Select which method to use
    if ~exist('Method', 'var')
        Method = 10;
    end
    
    % fitting algorithm estimates values from the tail of the BP waveform.
    % Select a possible range of th tail for fitting.
    if ~exist('percent_tail_range', 'var')
        percent_tail_range = (60:-1:20);    
    end
    
    % While taking ensampled average, use this variable to determine what
    % is the allowed time differnence in seconds between beats in the ensampled vector.
    if ~exist('Allowed_difference_between_time_stamp', 'var')
        Allowed_difference_between_time_stamp = 100;
    end
    
    % Set this variable to appropriate number of beats that are allowed in
    % an ensamppled vector
    if ~exist('number_beats_ensampled_vector', 'var')
        number_beats_ensampled_vector = 30;
    end

    % Set this variable to a value to decide the minimum of data required
    % to fit an exponential
    if ~exist('Minimum_points_required_to_fit_EXP', 'var')
        Minimum_points_required_to_fit_EXP = 10;
    end
    
    % Set the varibale to trigger an error warning to abort ensample
    % averaging.
    Minimum_required_waves_in_ensample = number_beats_ensampled_vector/2;
    
    % Use this varibale to save the time axis of various vectors in the
    % ensmapled vector
    Time_axis = nan(1, number_beats_ensampled_vector);
    
    % Use this counter to updated the saved ensampled wave
    Wave_Counter            = 1;
    
    % Initilize the vectors for getting ensampled data
    [Ensample_cntr, ...
        Ensample_beats, ...
        Ensample_Delta_time, ...
        T_axis_for_ensampled_vector] = ...
                Initialize_ensample_data (...
                        number_beats_ensampled_vector, ...
                        interpolation_factor);
    
    for beat_i = 1: N - 1
        
        try
        
        if print_me    
            fprintf('%s Beat ID [%5d/%5d] \t', str_to_print, beat_i, N);        
        end
            
        % Index of the beat
        Index       = foot_location(beat_i):foot_location(beat_i+1);
        
        % Time vector
        time_beat   = time(Index); 
        
        % Delta Time
        Delta_T     = max(time_beat) - min(time_beat);
        
        % BP wave vector
        BP_beat     = Input(Index);
        
        % Number of samples per beat
        Samples_in_current_beat    = Index(end) - Index(1);
        
        % Calculate the estimate for the samples in a beat
        Estimate_Samples_in_beat    = calculate_samples_per_beat(...
                                        beat_to_beat_samples, ...
                                        beat_i, ...
                                        Window_for_samples_per_beat); 
        
        % Check if BP beat is detected properly
        if Samples_in_current_beat > Estimate_Samples_in_beat * 120/100 
            if print_me 
                fprintf('Excess number of BP beats selected\n');
            end
            Samples_per_previous_beat    = Estimate_Samples_in_beat;
            continue; 
        end 
        
        % Check if BP beat is detected properly
        if Samples_in_current_beat < Estimate_Samples_in_beat * 50/100 
            if print_me 
                fprintf('Entire BP beats not selected\n');
            end
            Samples_per_previous_beat    = Estimate_Samples_in_beat;
            continue; 
        end 
        
        % Check if the quality of the signals are good
        Error_beat = check_quality_beats(time_beat, BP_beat, ...
                                    Samples_per_previous_beat, ...
                                    [1/4, 3/2], ...
                                    50);        
                        
        if ~isempty(Error_beat)
            if print_me 
                fprintf('%s\n', Error_Message{Wave_Counter, 1});
            end
            Samples_per_previous_beat   = Estimate_Samples_in_beat;            
            continue; 
        end    
        
        BP_beat         = interpolate_me(BP_beat, interpolation_factor);
        
        % Time stamp for the current beat 
        Current_time_stamp      = time_beat(1);
        
        % Initialize the Previous time stamps
        if Ensample_cntr == 1
            Previous_time_stamp = Current_time_stamp;
            if print_me 
                fprintf('Std_MAP = %3s mmHg \t', '---');
            end
            Std_within_limits   = true;
        else
            % Check if the std(MAP) of vectors in the ensmapled vectors is less
            % than the threshold            
            std_MAP = std(mean(Ensample_beats, 1, "omitnan"), 'omitnan');
            if print_me 
                fprintf('Std_MAP = %2.1f mmHg \t', std_MAP);
            end
            Std_within_limits = std_MAP < Threshold_MAP_std;
        end
        
        Time_stamp_within_limits = (Current_time_stamp - Previous_time_stamp)< Allowed_difference_between_time_stamp;     

        if Ensample_cntr <= number_beats_ensampled_vector && Time_stamp_within_limits && Std_within_limits
           [T_axis_for_ensampled_vector, ...
            Ensample_beats, ...
            Ensample_cntr, ...
            Previous_time_stamp, ...
            Ensample_Delta_time] = Update_ensampled(...
                                        Ensample_cntr, ...
                                        Ensample_beats, ...
                                        Current_time_stamp, ...
                                        BP_beat, ...
                                        T_axis_for_ensampled_vector, ...
                                        Delta_T, ...
                                        Ensample_Delta_time, ...
                                        print_me);            
            
        else
            if isempty(Ensample_beats)
                
                Mean_beat(:, Wave_Counter)      = nan(interpolation_factor, 1); 
            	Error_Message{Wave_Counter, 1}  = 'Empty Ensampled Vector';
                if print_me 
                    fprintf('Error = [%s] \t', Error_Message{Wave_Counter, 1});
                end
                
            elseif Ensample_cntr < Minimum_required_waves_in_ensample 
                
                Mean_beat(:, Wave_Counter)      = nan(interpolation_factor, 1); 
                Error_Message{Wave_Counter, 1}  = sprintf('Only %d waves in the ensampled vector', Ensample_cntr);
                if print_me 
                    fprintf('Error = [%s] \t', Error_Message{Wave_Counter, 1});
                end
                
            else                               
                % Compute the mean of the ensampled beat
                Mean_beat(:, Wave_Counter) ...
                                    = median(Ensample_beats, 2, 'omitnan');   
                Y_beat              = Mean_beat(:, Wave_Counter);
                
                HR_time             = mean(Ensample_Delta_time, 'omitnan');
                New_Fs              = interpolation_factor/HR_time;
                T_beat              = (0:1/New_Fs:(interpolation_factor-1)/New_Fs)' + mean(T_axis_for_ensampled_vector, 'omitnan');  
                
                Time_axis(Wave_Counter, :) 	= T_axis_for_ensampled_vector;
                MAP(Wave_Counter, 1)        = mean(Y_beat, "omitnan");
                SP(Wave_Counter, 1)         = max(Y_beat);
                DP(Wave_Counter, 1)         = min(Y_beat);
                PP(Wave_Counter, 1)         = SP(Wave_Counter, 1) - DP(Wave_Counter, 1);
                HR_BPM(Wave_Counter, 1)     = 1/HR_time * 60;  
                                
                if ~Skip_exponential_fitting
                [Error_Message{Wave_Counter, 1},...
                    Tau_struct(Wave_Counter, 1).Tau, ...
                    Pinf(Wave_Counter, 1), ...
                    Tau_struct(Wave_Counter, 1).Idx_sel, ...
                    Tau_struct(Wave_Counter, 1).BP_sel]...
                                        = find_exponential_fit_main(...
                                            T_beat, Y_beat, ...
                                            plot_data, ...
                                            range_Tau, ... 
                                            '', ...
                                            modify_Index, ...
                                            Method, ...
                                            percent_tail_range, ...
                                            Minimum_points_required_to_fit_EXP); 
                else
                    Error_Message{Wave_Counter, 1}          = '';
                    Tau_struct(Wave_Counter, 1).Tau         = nan;
                    Pinf(Wave_Counter, 1)                   = nan;
                    Tau_struct(Wave_Counter, 1).Idx_sel     = nan;
                    Tau_struct(Wave_Counter, 1).BP_sel      = nan;
                end
                                        
                % Compute the mean Tau
                Mean_Tau(Wave_Counter, 1) = median(Tau_struct(Wave_Counter, 1).Tau, 'omitnan');
                      
                if print_me 
                    fprintf('Processed. Tau = %1.2f, Error = [%s]\t', ...
                                                    Mean_Tau(Wave_Counter, 1), ...
                                                    Error_Message{Wave_Counter, 1});
                end
                Wave_Counter                    = Wave_Counter + 1; 
                
            end
            [Ensample_cntr, ...
                Ensample_beats, ...
                Ensample_Delta_time, ...
                T_axis_for_ensampled_vector] ...
                                = Initialize_ensample_data (...
                                    number_beats_ensampled_vector, ...
                                    interpolation_factor);
            
            % Load the present beat
            [T_axis_for_ensampled_vector, ...
            Ensample_beats, ...
            Ensample_cntr, ...
            Previous_time_stamp, ...
            Ensample_Delta_time] = Update_ensampled(...
                                        Ensample_cntr, ...
                                        Ensample_beats, ...
                                        Current_time_stamp, ...
                                        BP_beat, ...
                                        T_axis_for_ensampled_vector, ...
                                        Delta_T, ...
                                        Ensample_Delta_time, print_me);
        end
        
        catch ME
            if print_me
                fprintf('Processed. Error = [%s]\t', ME.message);
            end
            [Ensample_cntr, ...
                Ensample_beats, ...
                Ensample_Delta_time, ...
                T_axis_for_ensampled_vector] ...
                                = Initialize_ensample_data (...
                                    number_beats_ensampled_vector, ...
                                    interpolation_factor);
        end
        if print_me
            fprintf('\n');
        end
    end  
    
    if size(Time_axis, 1) == (length(SP) + 1),...
        Time_axis = Time_axis(1:end-1, :);
    end
    
end
function [T_axis_for_ensampled_vector, ...
            Ensample_beats, ...
            Ensample_cntr, ...
            Previous_time_stamp, ...
            Ensample_Delta_time] = ...
                Update_ensampled(...
                    Ensample_cntr, ...
                    Ensample_beats, ...
                    Current_time_stamp, ...
                    BP_beat, ...
                    T_axis_for_ensampled_vector, ...
                    Delta_T, ...
                    Ensample_Delta_time, print_me)
    
    if print_me
        fprintf('Added to ensampled set [%2d]\t', Ensample_cntr); 
    end
    
    if Ensample_cntr == 1
        T_axis_for_ensampled_vector(1, :) = nan;
    end
    
    % Save timestamp   
    T_axis_for_ensampled_vector(1, Ensample_cntr) ...
                                    = Current_time_stamp;

    % Load the BP beat into the 
    Ensample_beats(:, Ensample_cntr)= BP_beat;
    
    % Load the Delta time for each beat
    Ensample_Delta_time(Ensample_cntr, 1) = Delta_T;

    % Update the counter
    Ensample_cntr                   = Ensample_cntr + 1; 

    % Save the time stamp for analysis on the next beat 
    Previous_time_stamp             = Current_time_stamp;
end
function [Ensample_cntr, ...
            Ensample_beats, ...
            Ensample_Delta_time, ...
            T_axis_for_ensampled_vector] = ...
                Initialize_ensample_data (...
                        number_beats_ensampled_vector, ...
                        interpolation_factor)
    Ensample_beats              = nan(interpolation_factor, number_beats_ensampled_vector);
    Ensample_Delta_time         = nan(number_beats_ensampled_vector, 1);
    Ensample_cntr               = 1;
    T_axis_for_ensampled_vector = nan(1, number_beats_ensampled_vector);
end
function mean_value = calculate_samples_per_beat(beat_to_beat_samples, beat_i, delta_i)

    % Select the index to the used for averaging
    Index_to_sel = floor(beat_i-delta_i:beat_i+delta_i);
    
    % Remove unvalid index
    Index_to_sel(Index_to_sel <= 0 | Index_to_sel> length(beat_to_beat_samples)) = [];
    
    % Calculate the average value of the index
    mean_value = floor(median(beat_to_beat_samples(Index_to_sel), 'omitnan'));
end