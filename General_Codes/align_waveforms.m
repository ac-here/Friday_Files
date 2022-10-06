% Author: Anand Chandrasekhar

% This function align all the waveforms. Here, we use 
% cross-correlation to get the signals algined. While shifting the
% signals, Nan values are used appended to tailend/begining of the waveform
% depending on the required delay.

% Input:    Input_X         X axis of the signal. Assume to be uniformly
%                           sampled. 
%           Input_Y:        2D array with signals as column vectors
%           plot_data       This is a boolean number
%                           = True: Plot the results
%                           = False(Default): Do not Plot the results                           
% Ouput:    Ouput_signals:  Output_Y: Aligned output
%                           Output_X: X axis of output

% Use this example code to test it
% y   = circshift(0.84.^(0:10)', 5);
% ya  = [zeros(9, 1); y; zeros(1, 1)];
% yb  = [zeros(8, 1); y; zeros(2, 1)];
% yc  = [zeros(7, 1); y; zeros(3, 1)];
% yd  = [zeros(6, 1); y; zeros(4, 1)];
% ye  = [zeros(5, 1); y; zeros(5, 1)];
% yf  = [zeros(4, 1); y; zeros(6, 1)];
% Y   = [ya yb yc yd ye];
% X   = (1:size(Y, 1))';
% close; clc;
% [X1, Y1] = align_waveforms(X, Y, true);
function Output_Y = align_waveforms(Input_Y, plot_data)

%     % We are using some code in Friday files
%     Loc_Friday_Files = '../../Friday_Files';
%     addpath(genpath(Loc_Friday_Files));
    
    % Default value of plot_data is false.
    if ~exist('plot_data', 'var')
        plot_data = false;
    end
    
    if size(Input_Y, 2) == 1
        %fprintf('Size of Input_signals should be more than 1. No allignment performed. Returning the input\t');
        Output_Y = Input_Y;
        return;
    end
    
    % Normalize all the waveforms using Min_Max normalization
    [Input_Y, Min_val, Max_val] = perform_Min_Max_Normalization(Input_Y);
    
    % Find a reference signal.
    % Here a column vector with minimum Nan terms is considered as the reference
    % signal
    [~, col_index]  = min(sum(isnan(Input_Y)));
    y_ref        	= Input_Y(:, col_index);
    
    % Interpolate the reference signal to remove any possible nan
    Interpolate_N   = size(y_ref, 1);
    y_ref_interp    = interpolate_me(y_ref, Interpolate_N);  
    
    Input_X         = repmat((1:Interpolate_N)', [1, size(Input_Y, 2)]);
    Shifted_X    	= nan(Interpolate_N, size(Input_Y, 2));
    
    delay           = nan(size(Input_Y, 2), 1);
    
    % Compute the delay between the waveform and the reference signal
    % Once the delay is comuted, shift the X axis
    for i = 1:size(Input_Y, 2)
        Y               = interpolate_me(Input_Y(:, i), Interpolate_N);
        [c,lags]        = xcorr(y_ref_interp, Y);
        delay(i, 1)  	= mean(lags(abs(c) == max(abs(c))));
        Shifted_X(:, i) = Input_X(:, i) + delay(i, 1);
    end
    
    % Range for X axis
    Range_X     = linspace(min(min(Shifted_X)), max(max(Shifted_X)), Interpolate_N)';
    
    % Initialize the output
    Output_Y    = nan(length(Range_X), size(Input_Y, 2));
    
    % Interpolate the input signals based on the Range_X
    for i = 1:size(Shifted_X, 2)
        Output_Y(:, i) = interp1(Shifted_X(:, i), Input_Y(:, i), Range_X);
    end
    
    % Compute the X axis of the shifted signal
    Output_X = linspace(Input_X(1, 1), Input_X(end, 1), size(Output_Y, 1))';
        
    % Undo Min Max Nomalization
    Output_Y = Output_Y .* (Max_val - Min_val) + Min_val;
    
    if plot_data
        subplot(1, 2, 1); plot(Input_X, Input_Y, '-o'); pbaspect([1 1 1]);
        xlabel('Sample Num'); ylabel('Before'); 
        title('Input Waveform before alignment');
        set(gca, 'FontSize', 20);
        subplot(1, 2, 2); 
        plot(Output_X, Output_Y, '-o'); pbaspect([1 1 1]); 
        xlabel('Sample Num'); ylabel('After'); 
        title('Output Waveform after alignment');
        set(gca, 'FontSize', 20);
    end
    
end