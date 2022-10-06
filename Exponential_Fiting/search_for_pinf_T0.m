function fun_error  = search_for_pinf_T0...
                            (Input, X_decay, Y_decay, Grad_Y_decay, Ts)
    
    % Break the input vector into repective parameters
    [P_inf, T0]      	= debundle_Pin_T0_Y0(Input);
    
    % Estimate the exponential function
    Est_Y_decay         = compute_exponential_from_Pinf_T0(X_decay, Y_decay, Grad_Y_decay, P_inf, T0, Ts);
    
    % Compute the fitting error
    fun_error       	= sqrt(nanmean((Est_Y_decay - Y_decay).^2));
end