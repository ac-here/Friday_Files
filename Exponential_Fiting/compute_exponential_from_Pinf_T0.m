function [P_calc, ...
            Tau]    = compute_exponential_from_Pinf_T0(...
                            X, Y, ...
                            Grad_Y, P_inf, ...
                            X0, Ts)   

    N                   = length(X);
    P_calc              = nan(N, 1);
    Tau                 = (P_inf - Y)./Grad_Y;  
    
    Tau(Tau > 1)        = 0;
    Tau(Tau < 0)        = 0;
    
    [~, Index0]         = min(abs(X - X0));    
    P_calc(Index0)      = Y(Index0);
    Y0                  = P_calc(Index0);
    
    Index_tail          = (Index0+1:N);
    Tau_tail            = Tau(Index_tail);
    Sum_1_Tau_tail      = [nan; cumsum(1./Tau_tail)];
   	Pest                = P_inf + (Y0 - P_inf) .* exp(-Ts * Sum_1_Tau_tail);
    P_calc(Index_tail)  = Pest(2:end);   
    
    Index_head          = (1:Index0-1); 
    Tau_head            = flipud(Tau(Index_head));
    Sum_1_Tau_head      = [nan; cumsum(1./Tau_head)];
    Sum_1_Tau_head      = flipud(Sum_1_Tau_head);
    Pest                = P_inf + (Y0 - P_inf) .* exp(Ts * Sum_1_Tau_head);    
    P_calc(Index_head)  = Pest(1:end-1); 
  
end