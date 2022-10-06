function [Est_Y, Y, X, Tau, X0, Y0] = fit_mutiple_tau(Pinf, X_decay, Y_decay, Interval_to_break)
    % Break the Pressure wave into multiple segments
    Block_Y = (1:Interval_to_break:length(Y_decay));
    
    % Initialize Tau  
    Tau     = nan(length(Block_Y), 1);

    % Counter to save the data
    cnt     = 1;

    Est_Y_decay = nan(Interval_to_break+1, 1);
    X_save      = nan(Interval_to_break+1, 1);
    Y_save      = nan(Interval_to_break+1, 1);
    X0          = nan(1, 1);
    Y0          = nan(1, 1); 
        
    for i = 2:length(Block_Y)
        Index               = (Block_Y(i-1):Block_Y(i));
        Y                   = Y_decay(Index);
        X                   = X_decay(Index);

        clear rem_me
        rem_me              = isnan(X) | isnan(Y);
        X(rem_me)           = [];
        Y(rem_me)           = [];

        if length(X) <= Interval_to_break, continue; end 
        [Tau(cnt, 1), ...
            X0(cnt, 1), ...
            Y0(cnt, 1)] ...
                            = estimate_Tau(X, Y, Pinf, 2);
        Est_Y_decay(:, cnt) = compute_exponential(X, X0(cnt, 1), Y0(cnt, 1), Tau(cnt, 1), Pinf);
        X_save(:, cnt)      = X;
        Y_save(:, cnt)      = Y;
        cnt                 = cnt + 1; 
    end
    
    Est_Y   = Est_Y_decay(:);
    Y       = Y_save(:);
    X       = X_save(:);    
end