% Author: Anand Chandrasekhar

% This is an exmaple code on how to use the filters to remove noise in 
% your physiological data
% Please open "high_pass_filter.m" to learn more about High Pass filter.
% Please open "low_pass_filter.m" to learn more about Low Psss Filter

% Requirements:
% Clone this repository https://github.mit.edu/anandc/Friday_Files

% Clear the screen and workspace
clc; clear; close all;

% Use the following code to add the Friday files to the search path
Loc_Friday_Files = '../../Friday_Files/';
addpath(genpath(Loc_Friday_Files));

% To this code, we have attached a sample data that contains
% mean arterial diameter of the carotid artery
load('Sample_data.mat', 'mean_diameter', 'Time');

% Low Pass filter the input signal
lpf_diameter = low_pass_filter(mean_diameter, Time, 5, 10, 0.01, 100);

% High Pass filter the input signal
hpf_diameter = high_pass_filter(mean_diameter, Time, 5, 0.7, 0.01, 100);

%plot the graph: Original Signal
ax(1) = subplot(1, 3, 1);
plot(Time, mean_diameter, '-k');
title('Input Signal');
pbaspect([1 1 1]);

%plot the graph: Low Pass Filtered Signal
ax(2) = subplot(1, 3, 2);
plot(Time, lpf_diameter, '-k');
title('After Low Pass Filter');
pbaspect([1 1 1]);

%plot the graph: High Pass Filtered Signal
ax(3) = subplot(1, 3, 3);
plot(Time, hpf_diameter, '-k');
title('After High Pass Filter');
pbaspect([1 1 1]);
                            
linkaxes(ax, 'y');
linkaxes(ax, 'x');

% Remove Firday files from the search path 
rmpath(genpath(Loc_Friday_Files));                            