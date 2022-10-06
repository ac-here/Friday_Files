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
            Error, ...
            BP_sel] = ...
            find_exponential_decay_parameter_multiple_segments(...
                    X_decay, ...
                    Y_decay, ...
                    N)
                            
    if isempty(X_decay) || isempty(Y_decay) || ...
            length(X_decay) ~= length(Y_decay) 
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel] ...
                = initialize_data('Input data not correct');
            return;
    else
        comments        = '';
    end
    
    % Remove nan values
    Rem_me              = find(isnan(X_decay) | isnan(Y_decay));
    X_decay(Rem_me)     = [];
    Y_decay(Rem_me)     = [];
    
    % Seed point to start the X0
    Pinf_seed_point     = Y_decay(end);
    Seg_Time            = linspace(X_decay(1), X_decay(end), N + 1);
    T0                  = Seg_Time(1);
    T_end               = Seg_Time(N+1); 
    
    X0(1, 1)          	= Pinf_seed_point;
    for i = 2:N
        X0(i, 1)        = Seg_Time(i);
    end

    % Equality constraints AeqX = beq;
    Aeq                 = [];
    beq                 = [];
    
    if N > 1
        % Linear Constraints on parameters AX < b
        A            	= [[0 -1 zeros(1, N-2)]; ...
                                zeros(N-1, 1) eye(N-1) + diag(-1*ones(1, N-2), 1)];                        
        b             	= [-T0; zeros(N-2, 1); T_end ];
    else
        A               = [];
        b               = [];
    end
    
    % Lower and Upper bound
    lb                  = [0                T0*ones(1, N-1)];
    ub                  = [Y_decay(end)+1   T_end*ones(1, N-1)];
    
    % Non linear constraints
    nonlcon             = [];
    
    % Options of fmincon
    options             = optimset('Display', 'off', 'Algorithm', 'interior-point');
    
    % Function to estimate error
    fun_error           = @(Input) exponential_with_multiple_Tau_segments(Input, X_decay, Y_decay);
    
    try
        Output          = fmincon(fun_error, X0, A, b, Aeq, beq, lb, ub, nonlcon, options);
        P_inf_sel       = Output(1);
     	[Est_Y, ...
            ~, ...
            X, ...
            Tau_sel, ...
            ~, ~, ...
            Index_block] ...
                        = fit_mutiple_tau_segments(Output, X_decay, Y_decay);
        Est_Y_Ex      	= Est_Y;
        X_decay_Ex   	= X;
        Error           = exponential_with_multiple_Tau_segments(Output, X_decay, Y_decay);
        
        for i = 1:length(Index_block)-1 
            BP_sel(i, 1) = nanmean(Y_decay(Index_block(i):Index_block(i+1)));
        end
        
    catch
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel] ...
                = initialize_data('Error in optimizing');
    end
        
end
function [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, ...
            BP_sel] ...
                = initialize_data(Input_Comment)
	P_inf_sel   = nan;
	Tau_sel     = nan;
    Est_Y       = nan;
    X_decay_Ex  = nan;
    Est_Y_Ex    = nan;
    comments    = Input_Comment;
    BP_sel      = nan;
end