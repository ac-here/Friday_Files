% Author: Anand Chandrasekhar

% Use this code for learning how to use the exponential fitting cuve
% Model of the exponential curve
% P(x) = P_inf + P0 * exp( - (x/Tau) )

clear;clc; close; 

% Sampling Frequency
Fs      = 250;

% Time constant
Tau     = [0.1, 0.5, 0.3, 0.2, 0.4];
t       = [0,   0.1, 0.2, 0.3, 0.4, 0.5];

% P infinite
P_inf   = 0;

% P vector function
P_fun   = @(t, P_inf, P0, T0, Tau) P_inf + (P0 - P_inf) * exp( - (t - T0)/Tau ); 
P       = [];
T       = [];
Tau_i   = [];
P0      = 10;
T0      = 0;
PA      = P0;
TA      = T0;

for i = 1:length(Tau)
    T_cal  	= (t(i)+1/Fs:1/Fs:t(i+1))'; 
    P_calc  = P_fun(T_cal, P_inf, PA, TA, Tau(i));
    P       = [P; P_calc];
    T       = [T; T_cal];
    Tau_i   = [Tau_i; ones(length(T_cal), 1)*Tau(i)];
    PA      = P_calc(end);
    TA      = T_cal(end);
end

Sum_Tau     = 0;    
for i = 1:length(P)    
    Sum_Tau     = Sum_Tau + 1/Tau_i(i); 
    P1(i, 1)    = P_inf + (P0 - P_inf) * exp( -(T(i) - T0)* Sum_Tau/i);
    S_Tau(i, 1) = Sum_Tau/i;
end

Est_S_Tau       = log( (P0 - P_inf)./ (P - P_inf) ) ./ (T - T0);
i_array         = (1:length(Est_S_Tau))';  

Est_sum_Tau     = S_Tau .* i_array;
diff_sum_Tau    = [nan; diff(Est_sum_Tau)];
Est_Tau         = 1./diff_sum_Tau; 
hist(Est_Tau- Tau_i);

