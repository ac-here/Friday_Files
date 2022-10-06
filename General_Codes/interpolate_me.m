% Author:       Anand Chandrasekhar

% This function linearly interoplates the Input based on "N_interpolation"
% This interpolation replaces Nan with an interpolated value. If the Nan
% values are comming at the end or begining of the signal, last or first 
% non-Nan values are respectively used to replace the nan elements. 

% Input:        Input               One dimensional signal
%               N_interpolation     Factor of linear interpolation.
%                                   =   Number of samples to be present
%                                       in the interpolates signal
%               method              = 'linear' (default)
%                                   = 'pchip'
%                                   look here for more info
%                                   [https://www.mathworks.com/help/matlab/ref/interp1.html#btwp6lt-1-method]    
% Output:       interpolated_sig    Final interpolated signal

% How to use this function:
% time      = (0:0.01:1)';
% Input     = sin (2 * pi * 1 * t);
% Output    = interpolate_me(Input, 40);
function interpolated_sig = interpolate_me(Input, N_interpolation, method)
    
    % Convert the signal into a column vector
    Input = Input(:);
    
    if ~exist('method', 'var')
        method = 'linear';
    end
    
    % Interpolate the signal based on "N_interpolation"
	% and save into "stack_input"
	x_axis              = (1:length(Input))';
    
    % X_axis is linearly increasing. Interpolate the X_axis
	New_x_axis       	= linspace(1, length(Input), N_interpolation)';
    
    %Find index of non-Nan locations
    Index_nan           = isnan(Input);
    
    % x_axis without nan
    x_axis_noNan        = x_axis(~Index_nan);
    
    % Input without nan
    Input_noNan         = Input(~Index_nan);
    
    % Interpolate the signal
	interpolated_sig	= interp1(x_axis_noNan, Input_noNan, New_x_axis, method); 
    
    %Find index of non-Nan locations
    Index_nan           = isnan(interpolated_sig);
    
    % Replace Nan values in the begining of the signal
    for i = 1:length(interpolated_sig)
        if isnan(interpolated_sig(i))
            interpolated_sig(i) = interpolated_sig(find(~Index_nan(i:end), 1)+ i - 1);
        else
            break
        end
    end
    
    % Replace Nan values in the end of the signal
    for i = length(interpolated_sig):-1:1
        if isnan(interpolated_sig(i))
            interpolated_sig(i) = interpolated_sig(find(~Index_nan(end-i+1:end), 1, 'last' ) + length(interpolated_sig) - i);
        else
            break
        end
    end
end