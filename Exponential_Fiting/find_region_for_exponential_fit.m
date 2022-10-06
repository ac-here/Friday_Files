% Author:   Anand Chandrasekhar
% This code can help to detect the region for fitting exponential fittin
% from a single beat of a BP waveform.     
% Input :   time ( Time axis of a singe beat)
%           BP_beat ( Single Beat of a waveform)
% Output:   New_T_exp: Time vector for exponential fitting
%           New_P_exp: BP vector for exponetnial fitting
%           Error_Flag: True    : Error in calculations
%                       False   : Computations successfull
%           Error_Message: Reasons for failed computations

function [New_T_exp, New_P_exp, ...
            Error_Flag, Error_Message, ...
            T_exp, P_exp, Index_select] = ...
                find_region_for_exponential_fit(time, BP_beat)
    
    New_T_exp           = [];
    New_P_exp           = [];
    Error_Flag          = false;
    Error_Message       = '';
            
    % Sampling Rate
    Fs                  = 1/mean(diff(time));
    
    % Number of samples per beat
    Samples_per_beat    = round((max(time) - min(time))* Fs);
    
    % Percentage of a samples in the tail 
    % You may assume a number
    Percent_tail        = 50/100;
    
    % Number of samples in the tail
    LEN_TAIL            = floor(Samples_per_beat * Percent_tail);
    
    % Index of the tail region
    Win_BP_Tail         = (length(BP_beat)-LEN_TAIL:length(BP_beat))';
    
    % Locate the minimum of the BP beat in the tail end 
    [~, min_Tail]       = min(BP_beat(Win_BP_Tail));
    
    % Locate the maximum of the beat
	[~, max_Tail]       = max(BP_beat(Win_BP_Tail(1):Win_BP_Tail(1) - 1 + min_Tail));
    
    % Check if the numbers are valid
    if max_Tail>= min_Tail
        Error_Flag      = true;
        Error_Message   = 'Could not find region for exponential fit';
        return
    end 
    
    % Assuming the beat is proper
    % Selcted region for exponetnial fit
    Win_exp         = Win_BP_Tail(1)+max_Tail:Win_BP_Tail(1) - 1+ min_Tail;
    T_exp           = time(Win_exp);
    P_exp           = BP_beat(Win_exp);
    
    % Select region of exponential fit from the Gradient of P_exp
    Grad_P_exp      = diff(P_exp);
    [~, find_max]   = findpeaks(Grad_P_exp, 'MinPeakDistance', length(Grad_P_exp)-2);
    if isempty(find_max)
        Error_Flag      = true;
        Error_Message   = 'Could not find region for exponential fit';
        return
    end     
    [~, min_Tail]   = min(Grad_P_exp(1:find_max));
    if min_Tail >= find_max
        Error_Flag      = true;
        Error_Message   = 'Could not find region for exponential fit';
        return
    end 
    
    Index_select    = min_Tail:find_max;
    New_P_exp       = P_exp(Index_select);
    New_T_exp       = T_exp(Index_select);
    
    Index_select    = Index_select + Win_exp(1) - 1;
    
    if length(New_P_exp) < Samples_per_beat * 10/100
        Error_Flag      = true;
        Error_Message   = 'Could not find region for exponential fit';
        return
    end
end  