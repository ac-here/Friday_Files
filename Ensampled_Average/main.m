% Author: Anand Chandrasekhar

% This is an exmaple code on how to use the "compute_ensampled_average_using_R_wave.m"
% Please open "compute_ensampled_average_using_R_wave.m" to learn more.

% Requirements:
% Clone this repository https://github.mit.edu/anandc/Friday_Files

% Clear the screen and workspace
clc; clear; close all;

% Use the following code to add the Friday files to the search path
Loc_Friday_Files = '../../Friday_Files/';
addpath(genpath(Loc_Friday_Files));

% To this code, we have attached a sample data.
%load('Sample_data1.mat', 'Signal', 'Time', 'R_wave_loc');
load('Sample_data2.mat', 'Signal', 'Time', 'R_wave_loc');

% Set the interpolation factor
N_interpolation = 100;

[New_X, New_Y, ...
stack_input_removed_noise] = compute_ensampled_average_using_R_wave( ...
                                Signal, ...
                                Time, ...
                                R_wave_loc, ...
                                N_interpolation);

% plot the data
plot(New_X, stack_input_removed_noise); hold on;
plot(New_X, New_Y, '-k', 'LineWidth', 5); hold off;
title('Ensampled Beat');
                            
% Remove Firday files from the search path 
rmpath(genpath(Loc_Friday_Files));                     
                            



