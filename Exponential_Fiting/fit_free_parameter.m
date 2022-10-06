function [Est_Y, Y, X, ...
            Tau, X0, Y0, ...
            Block_Y] = fit_free_parameter(Input, X_decay, Y_decay)
    

    [Pinf, ...
        T, ...
        Tau]   = de_bundle_free_parameter(Input);
    
    if isempty(T)
        T       = max(X_decay);
    end
    
    Block_Y     = nan(length(T), 1);    

    % Break the Pressure wave into multiple segments    
    for i = 1:length(T)
        [~, Ind]        = min(abs(T(i) - X_decay));
        Block_Y(i, 1)   = Ind;
    end
    Block_Y         = [1; Block_Y; length(X_decay)];
    
    % Remove repeated elements
    Block_Y         = unique(Block_Y); 

    Est_Y_decay = nan(1);
    X_save      = nan(1);
    Y_save      = nan(1);
    X0          = nan(1);
    Y0          = nan(1);
    
    Block_Y     = sort(Block_Y, 'ascend');
        
    for i = 2:length(Block_Y)
        
        Index               = (Block_Y(i-1):Block_Y(i)-1);
        Y                   = Y_decay(Index);
        X                   = X_decay(Index);
        
        if max(Y) - min(Y) < 0.3, continue; end

        % Remove nan/inf variables
        clear rem_me
        rem_me              = isnan(X) | isnan(Y) | isinf(X) | isinf(Y);
        X(rem_me)           = [];
        Y(rem_me)           = [];
        Y0(i-1, 1)          = mean(Y);
        X0(i-1, 1)          = interp1(Y, X, Y0(i-1, 1));
        
        
        Est_Y_decay         = [Est_Y_decay; compute_exponential(X, X0(i-1, 1), Y0(i-1, 1), Tau(i-1, 1), Pinf)];
        X_save              = [X_save; X];
        Y_save              = [Y_save; Y];
    end
    
    Est_Y   = Est_Y_decay(2: end, 1);
    Y       = Y_save(2: end, 1);
    X       = X_save(2: end, 1);       
    
    Rem_me  = find(isnan(Est_Y) | isnan(Y) | isinf(Est_Y) | isinf(Y));
    Est_Y(Rem_me)   = [];
    Y(Rem_me)     	= [];
    X(Rem_me)       = [];
end