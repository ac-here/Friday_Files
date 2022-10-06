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
            find_exponential_decay_parameter_with_Pinf_T0(...
                    X_decay, ...
                    Y_decay)
                
                       
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
    
    % Remove nan values
    Rem_me              = find(isnan(X_decay) | isnan(Y_decay));
    X_decay(Rem_me)     = [];
    Y_decay(Rem_me)     = [];
    
    Ts                  = nanmean(diff(X_decay));
    Grad_Y_decay        = gradient(Y_decay)/Ts;
    
    % Seed point to start the X0
    Pinf_seed_point     = Y_decay(end);
    T0                  = X_decay(1);
    X0                  = [Pinf_seed_point T0];
    
    % Linear Constraints on parameters
    A                   = [];
    b                   = [];
    
    % Equality constraints
    Aeq                 = [];
    beq                 = [];
    
    % Lower and Upper bound
    lb                  = [ 0               X_decay(1)];
    ub                  = [ Y_decay(end)    X_decay(end)];
    
    % Non linear constraints
    nonlcon             = [];
    
    % Options of fmincon
    options             = optimset('Display','off');
    
    % Function to estimate error
    fun_error           = @(Input) search_for_pinf_T0(Input, X_decay, Y_decay, Grad_Y_decay, Ts);
    
    try
        Input              	= fmincon(fun_error, X0, A, b, Aeq, beq, lb, ub, nonlcon, options);
        [P_inf_sel, ...
            T0_sel]        	= debundle_Pin_T0_Y0(Input);
        [Est_Y, ...
            Tau_sel]        = compute_exponential_from_Pinf_T0(X_decay, Y_decay, Grad_Y_decay, P_inf_sel, T0_sel, Ts);
        X_decay_Ex          = X_decay;        
        Est_Y_Ex            = Est_Y;
        BP_sel              = Y_decay;
    catch
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel] ...
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