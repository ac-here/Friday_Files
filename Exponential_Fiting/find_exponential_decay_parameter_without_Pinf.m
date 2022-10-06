 % Author: Anand Chandrasekhar
% This function computes the best fit parameter for representing a signal
% based on this equation:
% P(x) = P_inf + P0 * exp( - (x/Tau) )
% Assumption: 0< Tau < 1
function [P_inf_sel, ...
            Tau_sel, ...
            comments, ...
            Est_Y, ...
            X_decay_Ex, Est_Y_Ex, ...
            BP_sel] = ...
            find_exponential_decay_parameter_without_Pinf(...
                    X_decay, ...
                    Y_decay, ...
                    range_Tau)                
                       
    if isempty(X_decay) || isempty(Y_decay) || ...
            length(X_decay) ~= length(Y_decay) 
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, ...
            BP_sel] ...
                = initialize_data('Input data not correct');
            return;
    else
        comments        = '';
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, ...
            BP_sel] ...
                = initialize_data(comments);
    end
    
    % Remove nan values
    Rem_me              = find(isnan(X_decay) | isnan(Y_decay));
    X_decay(Rem_me)     = [];
    Y_decay(Rem_me)     = []; 
    
    % Trim the Y signal at the lower point region
    [~, trim_index_min] = min(Y_decay);
    [~, trim_index_max] = max(Y_decay);
    Index_selected      = (trim_index_max:trim_index_min);
    X_decay_trim        = X_decay(Index_selected);
    Y_decay_trim        = Y_decay(Index_selected);
    
    % Downsample the X and Y vector   
    X_decay_downsample 	= linspace(min(X_decay_trim), max(X_decay_trim), 10)';
    Y_decay_downsample 	= interp1(X_decay_trim, Y_decay_trim, X_decay_downsample);   
    
    Ts                  = nanmean(diff(X_decay_downsample));
    Grad_Y_decay        = gradient(Y_decay_downsample)/Ts;
    New_Y               = abs(Grad_Y_decay);
    Grad_New_Y          = gradient(New_Y)/Ts; 
    
    Tau_sel             = -New_Y./Grad_New_Y; 
    
    rem_me              = isnan(Tau_sel) | Tau_sel < range_Tau(1) | Tau_sel > range_Tau(2);
    Tau_sel(rem_me)     = nan;
    
    P_inf_estimates     = Grad_Y_decay.*Tau_sel + Y_decay_downsample;
    
    Rem_me                          = P_inf_estimates < 10;
    P_inf_estimates(Rem_me)       	= [];
    Tau_sel(Rem_me)               	= [];
    Y_decay_downsample(Rem_me)    	= [];
    X_decay_downsample(Rem_me)  	= [];
    P_inf_sel                       = nanmedian(P_inf_estimates);
    
    %close; plot(Y_decay_downsample, P_inf_estimates, '-ok', 'LineWidth', 3);
    %yyaxis('right'); plot(Y_decay_downsample, Tau_sel, '-r', 'LineWidth', 3);   
    
    %Method 1 : Compute waveform from each Tau
    Est_Y               = Y_decay_downsample(1);
    for i = 2:length(X_decay_downsample)
        Est_Y(i, 1)   	= compute_exponential(X_decay_downsample(i), X_decay_downsample(i-1), Est_Y(i-1), Tau_sel(i), P_inf_sel);        
    end
    %Method 2 : Compute waveform from each median of all Tau
    Est_Y               = compute_exponential(X_decay_downsample, X_decay_downsample(1), Y_decay_downsample(1), nanmedian(Tau_sel), P_inf_sel);
    
    X_decay_Ex          = X_decay_downsample;
    Est_Y_Ex            = Est_Y;
    BP_sel              = Y_decay_downsample;
        
end
function [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel] ...
                = initialize_data(Input_Comment)
	P_inf_sel   = nan;
	Tau_sel     = nan;
    Est_Y       = nan;
    X_decay_Ex  = nan;
    Est_Y_Ex    = nan;
    BP_sel      = nan;
    comments    = Input_Comment;
end