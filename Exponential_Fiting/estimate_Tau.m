function [Tau_mean, X0_final, Y0_final] = estimate_Tau (X, Y, Pinf, Method)
    switch Method
        case 1
            [Tau_mean, X0_final, Y0_final] = method_1(X, Y, Pinf);
        case 2
            [Tau_mean, X0_final, Y0_final] = method_2(X, Y, Pinf, false);
        otherwise
    end
   
end

function [Tau_mean, X0_final, Y0_final] = method_1(X, Y, Pinf)
    N               = size(X, 1);
    X_new           = repmat(X, [1 N]);
    Y_new           = repmat(Y, [1 N]); 
    X0              = X_new';
    Y0              = Y_new';
    Pinf_new        = ones(N, N) * Pinf;
    Tau             = (X_new - X0) ./ log  ( (Y0 - Pinf_new) ./ (Y - Pinf_new) );
    Tau             = floor(Tau * 1000)/1000;
    Tau(isinf(Tau)) = nan;
    Tau_mean        = nanmean(Tau, 'all');
    [xloc, yloc]    = find(floor((Tau - Tau_mean) * 1000)/1000, 1);
    X0_final       	= X0(xloc, yloc);
    Y0_final        = Y0(xloc, yloc);
end

function [Tau_mean, X0_final, Y0_final] = method_2(X, Y, Pinf, FIT_DATA)
    if FIT_DATA 
        p_fit       = polyfit(X, Y, 6);  
        Y_beat      = polyval(p_fit, X);
    else
        Y_beat      = Y;
    end    
    Ts       	= nanmean(diff(X));
  	Grad_Y_beat = gradient(Y_beat)/Ts;
    Tau_calc    = (Pinf - Y_beat)./Grad_Y_beat;
    Tau_calc(isinf(Tau_calc)) = [];
    Tau_mean    = nanmean(Tau_calc);
    X0_final    = 0;
    Pa          = nanmean((Y_beat - Pinf) .* exp(X/Tau_mean));
    Y0_final    = Pinf + Pa;
end