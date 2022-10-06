% Author:       Anand Chandrasekhar           

% Requirements:
% Signal Processing Toolbox of MATLAB
% "General_Codes" in https://github.mit.edu/anandc/Friday_Files

% This tool mainly helps you to help manually add/remove detections of
% features of a phyiological signal. For instance, if you detected the
% R-waves peaks of the ECG signal using Pan-Tomkins algorithm, you may use
% this tool to visualize those features and if necessary add new or remove
% exisiting peaks using mouse and keyboard. 
% How to use this visualiztion
% tool is described here:
% The visulization tool loads a Window_Frame of the input signal with the
% detections. If you have done any detections, if uses a default algorithm
% to make the detections. Use the following instrustions to add new
% or remove exisiting detections.
%       1. Wait for the program to load the window_frame(10s) of the signal.
%       2. You can scroll through the signals using "L/R Arrow" keys.
%       3. If you need to modify features in a beat:
%           a.  To add features in a beat, select the beat using 
%               LEFT mouse click and press "SPACE" or "RETURN". 
%                   (i).    Press "SPACE", the defualt algorithm  
%                           will run on that specific beat to detect 
%                           the features.
%                   (ii).   Press "RETURN" to select the point of click.
%                           This feature is only avaiable for ECG signals.
%           b.  To remove features in a beat, select the beat using
%               LEFT mouse click and press "DELETE".
%       4. If you want to discontinue the manual detection, follow these 
%          options.
%           a.  RIGHT mouse click at any point of time.
%           b.  Scroll to the end of the data using RIGHT Arrow Key

%clear the screen
clc; close all; clear;

% Load the sample ECG files shown here to test the program
load('sample_ECG.mat', 'ECG', 'time', 'R_wave_loc');

% Manually check if the detections are correct.

    % Here, we load exisiting detections
    Max_Index = manual_detect(time, ECG, R_wave_loc, 10, 'ECG');

    %  Here, we run some default algorithm to perform the detections
    % Max_Index = manual_detect(time, ECG, [], 10, 'ECG');

% Use the following code to remove the path
rmpath(genpath(Loc_Friday_Files));