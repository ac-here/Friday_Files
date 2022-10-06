function [P_inf_sel, Tau_sel, ...
        X_decay_Ex, Est_Y_Ex, ...
        Error_Message, ...
        BP_sel]...
                        = gradient_method(...
                                New_T_exp, New_P_exp, ...
                                range_Tau, APPLY_FITTING)
    rem_nan            	= isnan(New_P_exp);
    New_P_exp(rem_nan)  = [];
    New_T_exp(rem_nan)  = [];   

    switch APPLY_FITTING
        case true
            warning('off');
            p_fit               = polyfit(New_T_exp, New_P_exp, 9);  
            fit_beat            = polyval(p_fit, New_T_exp);
            warning('on');
        case false
            fit_beat            = New_P_exp;
        otherwise
    end
    
    try
    
        Ts                  = nanmean(diff(New_T_exp));
        Grad_fit_beat       = gradient(fit_beat)/Ts;
        abs_Grad_fit_beat  	= abs(Grad_fit_beat);

        [New_T_exp, New_P_exp, ...
        Error_Flag, Error_Message, ...
        ~, ~, ~] = ...
            find_region_for_exponential_fit_iterative_version(New_T_exp, abs_Grad_fit_beat);
        
        if Error_Flag
            [P_inf_sel, Tau_sel, ...
            X_decay_Ex, Est_Y_Ex, Error_Message, BP_sel] ...
                        = initialize_variables(Error_Message);
        	return
        end

        [P_inf_sel_0, ...
        Tau_sel, ...
        Error_Message, ...
        ~, ...
        X_decay_Ex, Est_Y_Ex, ...
        BP_sel] = ...
        find_exponential_decay_parameter_with_fmincon(...
                New_T_exp, ...
                New_P_exp, ...
                range_Tau);

        P_inf_sel   = nanmean(fit_beat + (Tau_sel.* Grad_fit_beat)) - P_inf_sel_0;  
        Est_Y_Ex    = Est_Y_Ex * Tau_sel + P_inf_sel;
        
    catch ME
        [P_inf_sel, Tau_sel, ...
            X_decay_Ex, Est_Y_Ex, Error_Message, BP_sel] ...
                        = initialize_variables(ME.message);
    end
end
function [P_inf_sel, Tau_sel, ...
    X_decay_Ex, Est_Y_Ex, Error_Message, BP_sel] ...
                        = initialize_variables(error_message)
    P_inf_sel           = nan;
    Tau_sel             = nan;
    X_decay_Ex          = [];
    Est_Y_Ex            = [];
    Error_Message       = error_message;
    BP_sel              = nan;
end