% Author:       Anand Chandrasekhar
% This function perform a high pass filer on the input signsl
% Input:        input   (Signal)
%               time    (units in seconds)
%               N       (Order of the filter: May use 5)
%               FPass   (Cut-OFF frequency of filter: May use 0.7)
%               Apass   (Filter Parameter: May assume 0.01)
%               Astop   (Filter Parameter: May assume 100)
function output = high_pass_filter(Input, Time, N, Fpass, Apass, Astop) 

    % Customary Input Checking
    if  nargin ~= 6 || ...              % Check if all the arguments are available
        isempty(Time) || ...            % Check if Time is not empty
        isempty(Input) || ...           % Check if ECG is not empty
        length(Input) ~= length(Input)  % Check if #ECG == #Time
        output = [];                    % Set the output to empty []
        fprintf('Error in the input files\n')
        return;
    end
    
    % Samplig Rate of the signal
    Fs = length(Time) / (max(Time) - min(Time));
    
    % Create Filter object
    d = designfilt( 'highpassiir', ...
                      'FilterOrder', N, ...
                      'PassbandFrequency', Fpass, ...
                      'PassbandRipple', Apass, ...
                      'StopbandAttenuation', Astop, ...
                      'SampleRate', Fs);
    
	script_to_filter_the_signal;
end
