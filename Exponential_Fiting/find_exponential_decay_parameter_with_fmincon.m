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
            find_exponential_decay_parameter_with_fmincon(...
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
    end
    
    BP_sel              = nanmean(Y_decay);
    
    % Remove nan values
    Rem_me              = find(isnan(X_decay) | isnan(Y_decay));
    X_decay(Rem_me)     = [];
    Y_decay(Rem_me)     = [];
    
    % Seed point to start the X0
    Pinf_seed_point     = Y_decay(end);
    X0                  = Pinf_seed_point;
    
    % Linear Constraints on parameters
    A                   = [];
    b                   = [];
    
    % Equality constraints
    Aeq                 = [];
    beq                 = [];
    
    % Lower and Upper bound
    lb                  = 0;
    ub                  = Y_decay(end)+1;
    
    % Non linear constraints
    nonlcon             = [];
    
    % Options of fmincon
    options             = optimset('Display','off');
    
    % Function to estimate error
    fun_error           = @(Input) non_linear_estimate_exponential_parameter(Input, X_decay, Y_decay);
    
    try
        Input              	= fmincon(fun_error, X0, A, b, Aeq, beq, lb, ub, nonlcon, options);
     	[Tau_sel, ...
            X0_sel, ...
            Y0_sel, ...
            P_inf_sel]      = de_bundle_input_vector(Input, X_decay, Y_decay);
    
        Est_Y               = compute_exponential(X_decay, X0_sel, Y0_sel, Tau_sel, P_inf_sel);    
        
        X_decay_Ex          = (X_decay(1):1/100:X_decay(1)+10)';        
        Est_Y_Ex            = compute_exponential(X_decay_Ex, X0_sel, Y0_sel, Tau_sel, P_inf_sel);
    catch
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex] ...
                = initialize_data('Error in optimizing');
    end
        
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