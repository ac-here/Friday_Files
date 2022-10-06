% Author: Anand Chandrasekhar
% This function segments the waveform into multiple beats and stack them
% via linear interpolation
% Input:        Input_signal        Time Domain Signal to stack 
%                                   into multiple beats
%               Input_index         Index locations to break the signal
%                                   Example: R wave locations
%               N_interpolation     Interpolation factor
%                                   X = [1 2 3 4 5 6];
%                                   New_X = linspace(1, 6, 100)';;
%                                   Here, Interpolation factor = 100;        
% Ouput:        stack_Y             Stacked 2D array of mutlple beats
%               stack_X             X axis of the stacked 2D beats
function [stack_X, stack_Y] ...
                            = interpolate_and_stack_signals(...
                                    X_axis_input, ...
                                    Y_axis_input, ...
                                    Input_index, ...
                                    N_interpolation)
    Error = false;
    if nargin ~= 4
       fprintf('Length of signals does not match. Error in interpolate_and_stack_signals.m\n');   
       Error = true;
    end
                                
    % Error chaecking
    if length(X_axis_input) ~= length(Y_axis_input)
        fprintf('Length of signals does not match. Error in interpolate_and_stack_signals.m\n');
        Error = true;
    end
    
    % Error chaecking
    if ~exist('N_interpolation', 'var')
        fprintf('Define a factor for interpolation. Error in interpolate_and_stack_signals.m\n');
        Error = true;
    end
    
    % Error chaecking
    if ~exist('Input_index', 'var')
        fprintf('Define Input_index. Error in interpolate_and_stack_signals.m\n');
        Error = true;
    elseif any(Input_index<0) || ...
            any(Input_index>length(X_axis_input)) || ...
            any(isnan(Input_index))
        fprintf('Input_index has some error. Error in interpolate_and_stack_signals.m\n');
        Error = true;
    end
    
    if Error
        stack_X = [];
        stack_Y = [];
        return;
    end
    
    % Make all the input into column vectors
    X_axis_input    = X_axis_input(:);
    Y_axis_input    = Y_axis_input(:);
    Input_index     = Input_index(:);    
    
    % Stacked Input
    stack_Y     = nan(N_interpolation, length(Input_index)-1);
	stack_X     = nan(N_interpolation, length(Input_index)-1);                       
    
    for i = 1: size(Input_index, 1)-1

        % Load the index
        Index_to_fetch      = Input_index(i):Input_index(i+1); 
        
        if any(Index_to_fetch > length(Y_axis_input)) ||...
                any(Index_to_fetch < 1), continue; end
        
        X                   = X_axis_input(Index_to_fetch);
        Y                   = Y_axis_input(Index_to_fetch);
                
        % Interpolate the X axis
        stack_X(:, i)       = interpolate_me(X, N_interpolation);
        
        % Interpolate the Y axis
        stack_Y(:, i)       = interp1(X, Y, stack_X(:, i));   
                
    end
    
    % Remove columns with nan
    Col_Index_to_remove = all(isnan(stack_Y), 1);
    stack_X(: ,Col_Index_to_remove) = [];
    stack_Y(: ,Col_Index_to_remove) = [];
   	%plot(stack_Y)
end