% Author:   Anand Chandrasekhar
% This function takes a time domain biomedical signal like Tonometric 
% waveform or a PPG waveform, and split the signals into differnt beats to 
% make a represenative aka ensampled-averaged beat. At present, we use
% R-Waves of an ECG signal to perform the beat splitting. After splitting
% and stacking beats, we align the waveforms using cro--coreelation. Also,
% the program has a feature to allow users to visualize the beats and 
% decide to remove any beat based on the morphology/shape. 

% How to use this function 
% Here, A figure pops up with all beats plotted on the same X axis.
% To select the beats with a Left Mouse Click, and then press "DELETE". 
% Close the figure after removing all the necessary beats.

% Requirements:
% Clone this repository https://github.mit.edu/anandc/Friday_Files

% Input:    Y                   Time domain signal like PPG or Pressure Waveform
%           X                   Time Vector
%           R_wave_loc          Index for R wave locations
%           N_interpolation     Each beat will be interpolated to a value
%                               give here. This is necessary to perform an
%                               ensampled average of beats. 
%           manual_removal      This is a boolean input
%                               = true:     User can select which data to
%                                           remove. (Default value)
%                               = false:    User has no option to remove 
%                                           data

% Output:   New_X               New Time vector 
%           New_Y               New Ensampled averaged beat   
%           stack_input_aft_rem 2D array of signals after user removed noisy 
%                               data
function [New_X, New_Y, ...
            stack_input_aft_rem] ...
                                = compute_ensampled_average_using_R_wave( ...
                                            Y, ...
                                            X, ...
                                            R_wave_loc, ...
                                            N_interpolation, ...
                                            manual_removal)
    
    % Setting a default value for manual removal 
    if ~exist('manual_removal', 'var')
        manual_removal = true;
    end
    
    if length(R_wave_loc) <= 1
        fprintf('Skipping Ensample averaging due to less information \n');
        New_X               = nan(N_interpolation, 1);
        New_Y               = nan(N_interpolation, 1);
        stack_input_aft_rem = nan(N_interpolation, size(Y, 2));
        return;
    end
    
                                        
    % This script will interpolate and stack all signals
    [stack_X, stack_Y]          = interpolate_and_stack_signals(...
                                            X, ...
                                            Y, ...
                                            R_wave_loc, ...
                                            N_interpolation);

    % Use the following code to align the stacked beats. This algorithm uses 
    % cross-corelation to align beats. While aligning, we use nan is shift
    % the waveforms
    Output_Y                    = align_waveforms( ...
                                            stack_Y, ...
                                            false);
    stack_Y                     = Output_Y;
    
    try
        
        switch manual_removal
            case true
                % This scrips removes data from plots based on user inputs
                % User clicks on the plot and remove it by pressing "DELETE"
                %stack_input_aft_rem     = remove_data_from_plot(stack_Y, true);  
                stack_input_aft_rem     = remove_data_from_plot(...
                                            stack_Y, ...
                                            50, ...
                                            true);
                
                % close the figure
                delete(gcf);
                fprintf('Status:\n')
                fprintf('Total input # beats = %5d\n', size(stack_Y, 2));
                fprintf('Total noisy # beats = %5d\n', size(stack_Y, 2) - size(stack_input_aft_rem, 2));
            otherwise                
                stack_input_aft_rem     = stack_Y;   
        end
             
        % Compute ensampled average 
        New_Y                   = compute_mean_based_on_Nan(stack_input_aft_rem, 50);
        X1                      = stack_X - repmat(stack_X(1, :), [size(stack_X, 1), 1]);
        New_X                   = mean(X1, 2);        
        
    catch ME
        New_Y                   = [];
        New_X                   = [];
        stack_input_aft_rem     = [];
        fprintf('%s\n', ME.message);
    end
    
    
end