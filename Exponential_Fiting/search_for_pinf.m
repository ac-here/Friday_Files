function fun_error  = search_for_pinf...
                            (Input, X_decay, Y_decay, Grad_Y_decay)
    
    % Break the input vector into repective parameters
    P_inf               = Input;
    
    % Estimate the exponential function
    Est_Y_decay         = compute_exponential_from_Pinf(X_decay, Grad_Y_decay, P_inf, X_decay(1), Y_decay(1));
    
    % Compute the fitting error
    fun_error       	= sqrt(nanmean((Est_Y_decay - Y_decay).^2));
end