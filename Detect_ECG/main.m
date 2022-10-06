% This function is a wrapper for ECG_peak_detect.m

% Following authors developed ECG_peak_detect.m 
% Author(s):    Jonathan Moeyersons         (Jonathan.Moeyersons@esat.kuleuven.be)
%               Sabine Van Huffel           (Sabine.Vanhuffel@esat.kuleuven.be)
%               Carolina Varon              (Carolina.Varon@esat.kuleuven.be)
%               Moeyersons, J., Amoni, M., Van Huffel, S., Willems, R., 
%               & Varon, C. (2020). R-DECO: An open-source Matlab based graphical 
%               user interface for the detection and correction of R-peaks 
%               (version 1.0.0). PhysioNet. https://doi.org/10.13026/x6j7-sp58.

% Following Authors implmented the Pan tomkins Algorithm
% Author:       Hooman Sedghamiz            (Implemented Pan tomkins)

% Following authors created a wrapper for all ECG detections presented here 
% Author:       Anand Chandrasekhar         (Created a simple wrapper function)   

% Requirements:
% Clone this repository https://github.mit.edu/anandc/Friday_Files

% In addition to ECG peat detection, there is a visualiztion tool that you
% may use to manully remove detcted peaks (check manual_script_to_detect_ECG_Peaks.m). 
% How to use this visualiztion tool is described here:
% The visulization tool loads a window(Window_Frame) of ECG with the detected R Peaks
%       If any R peaks are not detected, 
%           Left Click the mouse on the R Wave
%           Confirm the peak by pressing, "Space"
%       If any R peaks are wrongly detected, 
%           Left Click the mouse on the "wrongly detected" R Wave
%           Delete the peak by pressing "delete"
%       If you want to discontinue the manual detection
%           Right Click the mouse.
%       If you want to slide to the next window of signals,
%           Press "Right Arrow"
%       If you want to slide to the previous window of signals,
%           Press "Left Arrow"
%       You may close the figure anytime. Data will be saved
%       If you identified an ROI without R peaks,
%           Press "Delete"

% We have attached a sample ECG to test our code.
% Run this script to explore the features of ECG detection

%clear the screen
clc; close all; clear

% Use the following code to add the Friday files to the search path
Loc_Friday_Files = '../../Friday_Files/';
addpath(genpath(Loc_Friday_Files));

% Load the ECG files
load('sample_ECG.mat', 'ECG', 'time');

% Locate the ECG R waves
R_wave_index = find_R_Wave_ECG(time, ECG, 1);

% plot the results;
% plot(time, ECG, '-k'); hold on; 
% plot(time(R_wave_index(1).detections), ECG(R_wave_index(1).detections), 'xr', ...
%       'MarkerSize', 10, 'LineWidth', 2);
% title(sprintf('%s', R_wave_index(1).algorithm))

% Run the code to manually confirm if the peaks are correct.
% You may select/de-select any peaks using mouse.
% Follow the instruction inside the script
figure();
Peak_Index1 = manual_script_to_detect_ECG_Peaks(...
                    time, ...
                    ECG, ...
                    R_wave_index(1).detections, ...
                    10);

% Close all figure;
close all;

% Use the following code to remove the path
rmpath(genpath(Loc_Friday_Files));