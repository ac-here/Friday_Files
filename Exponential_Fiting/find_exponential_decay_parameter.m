% Author: Anand Chandrasekhar
% This function computes the best fit parameter for representing a signal
% based on this equation:
% P(x) = P_inf + P0 * exp( - (x/Tau) )
% Assumption: 0< Tau < 1
function [P_inf_sel, ...
            Wave_Er, ...
            Tau_sel, ...
            Est_Y, ...
            X_decay_Ex, Est_Y_Ex] = ...
            find_exponential_decay_parameter(...
                    X_decay, ...
                    Y_decay, ...
                    P_inf, ...
                    range_Tau)
                
    % Range of value of P_inf
    %P_inf           = (P_inf_start:1:min(Y_decay)-1)';
    Index_X_decay   = 1;
    Tau             = nan(length(Index_X_decay), length(P_inf));
    Error           = nan(length(X_decay), length(P_inf));
    
    for j1 = 1:1:length(Index_X_decay)
        
        j               = Index_X_decay(j1);
        X0              = X_decay(j);
        Y0              = Y_decay(j);

        X_test          = X_decay - X0;

        for i = 1:length(P_inf)
            Trans_Y_decay   = Y_decay - P_inf(i);
            Trans_X_test    = X_test;
            Index_rem       = Trans_Y_decay <= 0;
            Trans_Y_decay(Index_rem)    = [];
            Trans_X_test(Index_rem)     = [];
            p_fit           = polyfit(Trans_X_test, log(Trans_Y_decay), 1);
            T               = -1/p_fit(1);
            
            if imag(T)~=0, continue; end
            if T < range_Tau(1) || T > range_Tau(2), continue; end
            Tau(j, i)       = T;
            
            %Error_1         = 1*abs(log(Y0 - P_inf(i)) - p_fit(2));
            %Error(j, i)     = Error_1;
            %Error(j, i)      = (exp(p_fit(2)) - (Y0 - P_inf(i)))^2;   
            
            Est_Y           = P_inf(i) + ...
                               (Y0 - P_inf(i)) * ...
                                   exp(-X_test/Tau(j, i));   
            Error_2         = mean((Y_decay - Est_Y).^2);
            Error(j, i)     = Error_2; 
        end
        
    end
    
    Wave_Er      	= nanmin(nanmin(Error));

    if isnan(Wave_Er)
        P_inf_sel = nan;
        Wave_Er = nan;
        Tau_sel = nan;
        Est_Y = nan;
        return
    end
    
    [j_min, i_min]	= find(Error == Wave_Er);
    
    Tau_sel         = Tau(j_min, i_min);
    P_inf_sel       = P_inf(i_min);
    X0_sel      	= X_decay(j_min);
	Y0_sel        	= Y_decay(j_min);
    
    if imag(Tau_sel)>0 %|| max(P_inf) == P_inf_sel || min(P_inf) == P_inf_sel
        P_inf_sel = nan;
        Wave_Er = nan;
        Tau_sel = nan;
        Est_Y = nan;
        return
    end
    
    Est_Y           = P_inf_sel + ...
                        (Y0_sel - P_inf_sel) * ...
                            exp(-(X_decay - X0_sel)/Tau_sel);
    
    X_decay_Ex      = (X_decay(1):1/1000:X_decay(1)+10)';        
    Est_Y_Ex     	= P_inf_sel + ...
                        (Y0_sel - P_inf_sel) * ...
                            exp(-(X_decay_Ex - X0_sel)/Tau_sel);
                        
%     subplot(1, 2, 1);
%     plot(X_decay, Y_decay , 'ok', X_decay_Ex, Est_Y_Ex, '-r'); hold on;
%     plot(X0_sel, Y0_sel, 'ob', 'MarkerSize', 5, 'MarkerFaceColor', 'b');  
% 
%     subplot(1, 2, 2);
%     plot(P_inf, Error(1, :), 'x-k', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'LineWidth', 3);
%     xlabel('Pinf [mmHg]'); ylabel('Error [mmHg]');
    
end