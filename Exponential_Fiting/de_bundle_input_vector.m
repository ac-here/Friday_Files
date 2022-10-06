function [Tau, X0, Y0, Pinf] = de_bundle_input_vector(Input, X_decay, Y_decay)    
    Pinf            = Input(1); 
    [Tau, X0, Y0]  	= estimate_Tau(X_decay, Y_decay, Pinf, 2); 
end