function [P_calc, ...
            Tau]    = compute_exponential_from_Pinf(...
                            X, Grad_Y, P_inf, ...
                            start_X, start_Y)
   
                
    P_calc(1, 1)    = start_Y;
    T_calc(1, 1)    = start_X;
    Tau(1, 1)       = nan;    
    Prev            = 1;
    Error_Flag     	= false;
    
    for Pre = 2: length(X)
        T_calc(Pre, 1) 	= X(Pre, 1);
        Tau_val         = (P_inf - P_calc(Prev, 1))/Grad_Y(Prev);
        
        %check_me = (0 <= Tau_val && Tau_val <= 0.5);
        
        if Grad_Y(Prev) < -10 && ~Error_Flag %&& check_me          
            Tau(Prev, 1)        = Tau_val;            
        else
            Error_Flag      	= true;
            Tau(Prev, 1)        = Tau(Prev-1, 1);
        end
        
        P_calc(Pre, 1)      = compute_exponential(...
                                T_calc(Pre, 1), ...
                                T_calc(Prev, 1), ...
                                P_calc(Prev, 1), ...
                                Tau(Prev, 1), ...
                                P_inf);
        Prev                = Pre; 
    end
    Tau(Prev, 1)        = nan;    
    
end