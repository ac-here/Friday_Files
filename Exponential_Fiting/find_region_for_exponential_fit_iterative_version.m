% Author:   Anand Chandrasekhar
% This code can help to detect the region for fitting exponential fit
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
                find_region_for_exponential_fit_iterative_version(...
                        time, BP_beat, ...
                        Percent_Tail, ...
                        Minimum_points_required_to_fit_EXP)
    
    New_T_exp           = [];
    New_P_exp           = [];
    Error_Flag          = false;
    Index_select        = [];
    Error_Message       = '';
    
    % Set this variable to a value to decide the minimum of data required
    % to fit an exponential
    if ~exist('Minimum_points_required_to_fit_EXP', 'var')
        Minimum_points_required_to_fit_EXP = 10;
    end
    
    % Percentage of a samples in the tail 
    % You may assume a number
    if ~exist('Percent_Tail', 'var')
        Percent_Tail        = (25:-1:20)'/100;
    end
            
    % Sampling Rate
    Fs                  = 1/mean(diff(time));
    
    % Number of samples per beat
    Samples_per_beat    = round((max(time) - min(time))* Fs);
    
    Min_Tail            = nan(length(length(Percent_Tail)), 1);
    Find_Max            = nan(length(length(Percent_Tail)), 1);
    Height              = nan(length(length(Percent_Tail)), 1);
    Win_Exp             = nan(length(length(Percent_Tail)), 1);
    Save_Data          	= struct();
    ORDER_POLYNOMIAL  	= 9;
    
    for i = 1:length(Percent_Tail)
        
        Percent_tail        = Percent_Tail(i, 1);
    
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
            Error_Flag(i, 1) = true;            
            continue;
        else
            Error_Flag(i, 1) = false;
        end 
    
        % Assuming the beat is proper
        % Selected region for exponetnial fit
        Win_exp         = Win_BP_Tail(1)+max_Tail:Win_BP_Tail(1) - 1+ min_Tail;
        T_exp           = time(Win_exp);
        P_exp           = BP_beat(Win_exp);
        
        % Check if the numbers are valid
        if length(T_exp) < ORDER_POLYNOMIAL
            Error_Flag(i, 1) = true;            
            continue;
        else
            Error_Flag(i, 1) = false;
        end 
        
        % Fit a higher order polynomial to remove noise
        warning('off');
        fit_p           = polyfit(T_exp, P_exp, ORDER_POLYNOMIAL);
        P_exp           = polyval(fit_p, T_exp);
        warning('on');
        
        Save_Data(i, 1).P_exp = P_exp;
        Save_Data(i, 1).T_exp = T_exp;
        
        % Select region of exponential fit from the Gradient of P_exp
        
        % We are using 5 point Runge Kutaa method to differential the
        % signal
        Grad_P_exp   	= diff(P_exp);
        %diff5
        
        % Use this segment of the code to get simple differentiation
        %y               = diff(P_exp);
        %y               = (y + [y(2:end); y(end)] + [y(1); y(1:end-1)])/3;
        %Grad_P_exp      = y;
        
%         close; subplot(1, 2, 1); plot(time, BP_beat);hold on;
%         plot(T_exp, P_exp); yyaxis('right'); 
%         plot(T_exp(1:end-1), Grad_P_exp); hold off;                
%         
%         T_exp_rem_nan               = T_exp;
%         Grad_P_exp_rem_nan          = Grad_P_exp;
%         rem_nan                     = isnan(Grad_P_exp_rem_nan);
%         Grad_P_exp_rem_nan(rem_nan)	= [];
%         T_exp_rem_nan(rem_nan)      = [];
%         p_fit                       = polyfit(T_exp_rem_nan, Grad_P_exp_rem_nan, 9);
%         Grad_P_exp_rem_nan          = polyval(p_fit, T_exp_rem_nan);
%         Grad_P_exp                  = Grad_P_exp_rem_nan;
%         
% %         plot(T_exp_rem_nan, Grad_P_exp_rem_nan, '-k'); hold off; 

        [~, find_max]   = findpeaks(Grad_P_exp, 'MinPeakDistance', length(Grad_P_exp)-2);
        if isempty(find_max)  
            
            % Anand: Added these extra condition for analysing the Mouse
            % data
            [~, find_max] = max(Grad_P_exp);
            if ~(find_max == length(Grad_P_exp))                            
                Error_Flag(i, 1) = true;            
                continue;
            end
            
        else
            Error_Flag(i, 1) = false;
        end     
        [~, min_Tail]   = min(Grad_P_exp(1:find_max));
        if min_Tail >= find_max
            Error_Flag(i, 1) = true;            
            continue;
        else
            Error_Flag(i, 1) = false;
        end 
        Win_Exp(i, 1)   = Win_exp(1, 1);
        Min_Tail(i, 1)  = min_Tail;
        Find_Max(i, 1)  = find_max;
        Height(i, 1)    = P_exp(Min_Tail(i, 1)) - P_exp(Find_Max(i, 1));
        %if ~Error_Flag(i, 1) 
        %    break;
        %end
        
    end

    if all(Error_Flag) || all(isnan(Height))
        Error_Message   = 'Could not find region for exponential fit'; 
        Error_Flag      = true;
        return;
    else
        Error_Message   = '';
        Error_Flag      = false;
    end
    
    [~, max_height] = nanmax(Height);
    P_exp           = Save_Data(max_height, 1).P_exp;
    T_exp           = Save_Data(max_height, 1).T_exp;
    Index_select    = Min_Tail(max_height):Find_Max(max_height);
    New_P_exp       = P_exp(Index_select);
    New_T_exp       = T_exp(Index_select);
    
    Index_select    = Index_select + Win_Exp(max_height) - 1;
    
    % if length(New_P_exp) < Samples_per_beat * 9/100
    % Anand 1/10/2021:  Changed from 10% to 9% for analysing mouse data
    % Anand 12/10/2021: Changed from 9% to static number for analyzing vital
    %                   data (#20)
    % Anand 12/12/2021: Changed from #20 to #10 to analyse mouse data
    % Anand 5/2/2022: changed from #10 to #6 to analyse mouse data
    if length(New_P_exp) < Minimum_points_required_to_fit_EXP
        Error_Flag      = true;
        Error_Message   = sprintf('Region for exponential fit has less(= %d < %d) data points', ...
                                length(New_P_exp), ...
                                Minimum_points_required_to_fit_EXP);
        return
    end
end
    
    
    
    