function fun_error  = exponential_with_multiple_Tau_segments...
                            (Input, X_decay, Y_decay)
        
    [Est_Y, Y]  = fit_mutiple_tau_segments(Input, X_decay, Y_decay);
        
    % Compute the fitting error
    fun_error 	= sqrt(mean((Est_Y - Y).^2));
end