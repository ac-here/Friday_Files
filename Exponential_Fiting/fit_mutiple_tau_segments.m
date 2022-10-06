function [Est_Y, Y, X, ...
            Tau, X0, Y0, ...
            Block_Y] = fit_mutiple_tau_segments(Input, X_decay, Y_decay)
    

    [Pinf, T]   = de_bundle_input_vector_tau_segments(Input);
    
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

    % Initialize Tau  
    Tau             = nan(length(Block_Y)-1, 1);

    % Counter to save the data
    cnt             = 1;

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
        
        %if max(Y) - min(Y) < 1, continue; end

        clear rem_me
        rem_me              = isnan(X) | isnan(Y);
        X(rem_me)           = [];
        Y(rem_me)           = [];

        [Tau(cnt, 1), ...
            X0(cnt, 1), ...
            Y0(cnt, 1)] ...
                            = estimate_Tau(X, Y, Pinf, 2);
        Est_Y_decay         = [Est_Y_decay; compute_exponential(X, X0(cnt, 1), Y0(cnt, 1), Tau(cnt, 1), Pinf)];
        X_save              = [X_save; X];
        Y_save              = [Y_save; Y];
        cnt                 = cnt + 1; 
    end
    
    Est_Y   = Est_Y_decay(2: end, 1);
    Y       = Y_save(2: end, 1);
    X       = X_save(2: end, 1);       
    
    Rem_me  = find(isnan(Est_Y) | isnan(Y) | isinf(Est_Y) | isinf(Y));
    Est_Y(Rem_me)   = [];
    Y(Rem_me)     	= [];
    X(Rem_me)       = [];
end