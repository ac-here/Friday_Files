function [Pinf, T, Tau] = de_bundle_free_parameter(Input)    

    Pinf    = Input(1);
    
    
    N       = length(Input) - 1;
    n       = (N + 1)/2;
    
    T       = nan(n - 1, 1);
    for i = 2:n
        T(i-1, 1) = Input(i);
    end
    
    Tau     = nan(n, 1); 
    for i = n+1:2*n
        Tau(i-n, 1) = Input(i);
    end
    
end