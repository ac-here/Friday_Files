function fun_error  = non_linear_estimate_exponential_parameter_with_multiple_Tau...
                            (Pinf, X_decay, Y_decay)
    
    
    % Interval to break the Pressure waveform
    Interval_to_break = 50;
                        
    [Est_Y, Y]  = fit_mutiple_tau(Pinf, X_decay, Y_decay, Interval_to_break);
        
    % Compute the fitting error
    fun_error 	= sqrt(mean((Est_Y - Y).^2));
end