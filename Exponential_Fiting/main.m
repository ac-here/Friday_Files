% Author: Anand Chandrasekhar

% Use this code for learning how to use the exponential fitting cuve
% Model of the exponential curve
% P(x) = P_inf + P0 * exp( - (x/Tau) )

clear;

% Add Friday files into the MATLAB search path
Loc_Friday_Files = '../../Friday_Files/';
addpath(genpath(Loc_Friday_Files));

clc; close; 

% Generate a signal


% Sampling Frequency
Fs      = 250;

% Time vector
t       = (0:1/Fs:1)';
t0      = (0:1/Fs:0.1)';
t1      = (t0(end)+1/Fs:1/Fs:0.3)';
t2      = (t1(end)+1/Fs:1/Fs:0.6)';
t3      = (t2(end)+1/Fs:1/Fs:0.8)';
t4      = (t3(end)+1/Fs:1/Fs:t(end))';

% Time constant
Tau     = 0.2;
Tau0    = 0.1;
Tau1    = 0.2;
Tau2    = 0.3;
Tau3    = 0.4;
Tau4    = 0.2;

% P infinite
P_inf   = 30;

% P0
PA      = 10;

% P vector function
P_fun   = @(t, P_inf, P0, T0, Tau) P_inf + (P0 - P_inf) * exp( - ( (t - T0)/Tau ) ); 

% P vector
%P       = P_fun(t, P_inf, P_inf + PA, 0, Tau);
      
P0      = P_fun(t0, P_inf, P_inf + PA, 0, Tau0);
P1      = P_fun(t1, P_inf, P0(end), t0(end), Tau1);
P2      = P_fun(t2, P_inf, P1(end), t1(end), Tau2);
P3      = P_fun(t3, P_inf, P2(end), t2(end), Tau3);
P4      = P_fun(t4, P_inf, P3(end), t3(end), Tau4);
P       = [P0; P1; P2; P3; P4];

[Error_Message,...
            Tau_sel, ...
            P_inf_sel, ...
            Index_select, ...
            BP_sel] = find_exponential_fit_main(...
                            t, P, ...
                            true, ...
                            [0 1], ... 
                            '', ...
                            true, ...
                            10, ...
                            (50:-1:20));                      
                        
% Run these scripts at the end of the code
basic_closing_script;                        
    