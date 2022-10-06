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
            find_exponential_decay_free_parameter(...
                    X_decay, ...
                    Y_decay, ...
                    range_Tau, ...
                    N)
                            
    if isempty(X_decay) || isempty(Y_decay) || ...
            length(X_decay) ~= length(Y_decay) 
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel, Error] ...
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
    Tau_seed_point      = 0.3;
    Seg_Time            = linspace(X_decay(1), X_decay(end), N + 1);
    T0                  = Seg_Time(1);
    T_end               = Seg_Time(N+1); 
    
    X0(1, 1)          	= Pinf_seed_point;
    for i = 2:N
        X0(i, 1)        = Seg_Time(i);
    end
    
    X0                  = [X0; ones(N, 1)*Tau_seed_point];

    % Equality constraints AeqX = beq;
    Aeq                 = [];
    beq                 = [];
    
    if N > 1
        % Linear Constraints on parameters AX < b
        A            	= [[0 -1 zeros(1, N-2)]; ...
                                zeros(N-1, 1) eye(N-1) + diag(-1*ones(1, N-2), 1)];                        
        b             	= [-T0; zeros(N-2, 1); T_end ];
        A               = [A zeros(size(A, 1), N)];
        
        %A1              = zeros(N-1, N);
        %A2              = [diag(-1*ones(1, N-1), 0) zeros(N-1, 1) ] + [ zeros(N-1, 1) eye(N-1) ];
        %A               = [A; A1 -1*A2];        
        %b               = [b; ones(N-1, 1) * 0];
        
    else
        A               = [];
        b               = [];
    end
    
    Ub_Tau              = range_Tau(2);
    Lb_Tau              = range_Tau(1);
   
    % Lower and Upper bound
    lb                  = [0                T0*ones(1, N-1)     Lb_Tau*ones(1, N)];
    ub                  = [Y_decay(end)+1   T_end*ones(1, N-1)  Ub_Tau*ones(1, N)];
    
    % Non linear constraints
    nonlcon             = [];
    
    % Options of fmincon
    options             = optimset('Display', 'off', 'Algorithm', 'interior-point');
    
    % Function to estimate error
    fun_error           = @(Input) exponential_with_free_parameter(Input, X_decay, Y_decay);
    
    try
        Output          = fmincon(fun_error, X0, A, b, Aeq, beq, lb, ub, nonlcon, options);
        P_inf_sel       = Output(1);
     	[Est_Y, ...
            ~, ...
            X, ...
            Tau_sel, ...
            ~, ~, ...
            Index_block] ...
                        = fit_free_parameter(Output, X_decay, Y_decay);
        Est_Y_Ex      	= Est_Y;
        X_decay_Ex   	= X;
        Error           = exponential_with_free_parameter(Output, X_decay, Y_decay);
        
        for i = 1:length(Index_block)-1 
            BP_sel(i, 1) = nanmean(Y_decay(Index_block(i):Index_block(i+1)));
        end
        
    catch
        [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, BP_sel, Error] ...
                = initialize_data('Error in optimizing');
    end
        
end
function [P_inf_sel, Tau_sel, ...
            comments, Est_Y, ...
            X_decay_Ex, Est_Y_Ex, ...
            BP_sel, Error] ...
                = initialize_data(Input_Comment)
	P_inf_sel   = nan;
	Tau_sel     = nan;
    Est_Y       = nan;
    X_decay_Ex  = nan;
    Est_Y_Ex    = nan;
    comments    = Input_Comment;
    BP_sel      = nan;
    Error       = nan;
end