function fun_error  = non_linear_estimate_exponential_parameter...
                            (Input, X_decay, Y_decay)
    
    % Break the input vector into repective parameters
    [Tau, X0, Y0, Pinf] = de_bundle_input_vector(Input, X_decay, Y_decay);
    
    % Estimate the exponential function
    Est_Y_decay         = compute_exponential(X_decay, X0, Y0, Tau, Pinf);
    
    % Compute the fitting error
    fun_error       	= sqrt(mean((Est_Y_decay - Y_decay).^2));
end