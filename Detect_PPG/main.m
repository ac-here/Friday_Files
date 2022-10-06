% This function detects Minima and Maxima locations of a PPG signal

% Following authors created a wrapper for all ECG detections presented here 
% Author:       Anand Chandrasekhar           

% Requirements:
% Clone this repository https://github.mit.edu/anandc/Friday_Files

% We have attached a sample data to test our code.
% Run this script to explore the features of PPG detection

%clear the screen
clc; close all; clear

% Load the data
load('Sample_data1.mat', 'Signal', 'Time');

Org_detections = find_max_min_PPG(Time, Signal);                                                                          

% Run the code to manually confirm if the peaks are correct.
% You may select/de-select any peaks using mouse.
% Follow the instruction inside the script
% figure();
detections = manual_detect(Time, Signal, Org_detections, 30, 'PPG');

subplot(2, 1, 1);
plot(Time, Signal);hold on;
plot(Time(Org_detections(:, 1)), Signal(Org_detections(:, 1)),'or');
plot(Time(Org_detections(:, 2)), Signal(Org_detections(:, 2)),'*b');hold off; 
title('Original Detections')

subplot(2, 1, 2);
plot(Time, Signal);hold on;
plot(Time(detections(:, 1)), Signal(detections(:, 1)),'or');
plot(Time(detections(:, 2)), Signal(detections(:, 2)),'*b');hold off;  
title('Detections after manual removal')
