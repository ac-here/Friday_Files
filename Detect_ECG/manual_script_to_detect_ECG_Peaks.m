% Author:   Anand Chandrasekhar

% This function assist manual detection of ECG peaks.
% Input:    Time            In units of seconds
%           ECG
%           Peak_Index      Locations of R wave
%                           These locations are output of find_R_Wave_ECG.m
%           Window_Frame    How much window_frame to display
%                           In units of seconds
% Output:   Peak_Index      Updated ECG peaks

% For INSTRUCTIONS on how to use the visualiztion tool, check
% Manual_selection_detection/manual_detect.m in the Friday_Files

function Peak_Index = manual_script_to_detect_ECG_Peaks(...
                        Time, ECG, ...
                        Peak_Index, ...
                        Window_Frame)

    
    % Customary Input Checking
    if  nargin ~= 4 || ...          % Check if all the arguments are available
        isempty(Time) || ...      	% Check if Time is not empty
        isempty(ECG) || ...         % Check if ECG is not empty
        length(ECG) ~= length(Time) % Check if #ECG == #Time
        fprintf('Error in the input files\n')
        return;
    end  
    
    Peak_Index = manual_detect(Time, ECG, Peak_Index, Window_Frame, 'ECG');
    
end