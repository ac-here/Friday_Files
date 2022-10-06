% Author : Anand Chandrasekhar
% Fitting function c + a*exp(bx)
function [a, b, c, comment] ...
                = fit_exponential_with_bias(X, Y, Y_inf_range, plot_data, color)
    
    a = nan;
    b = nan;
    c = nan;
    
    Fun_exp  = @(a, b, c, x) c + a*exp(b*x);
    
    if ~exist('plot_data', 'var')
        plot_data = false;  
    end
    
    if length(X) ~= length(Y)
        comment = 'Error in length(X, Y)';
        return;
    end
    
    % Remove all nans
    Index = isnan(X) | isnan(Y);
    X = X(~Index);
    Y = Y(~Index);
    
    if length(X) < 3
        comment = 'Not enough data!';
        return;
    end
    
    if plot_data
       plot(X, Y, sprintf('o%s', color)); hold on; 
    end
    
    if ~exist('Y_inf_range', 'var') 
        Y_inf_range   = (0:0.01:mean(Y))';  
    end     
    
    if isempty(Y_inf_range)
        Y_inf_range   = (0:0.01:mean(Y))'; 
    end
    
    
        
    for i = 1:length(Y_inf_range)
        Y_t         = Y - Y_inf_range(i);
        Y_t(Y_t<=0) = eps;
        p_fit(i, :) = polyfit(X, log(Y_t), 1);
        if p_fit(i, 1) < 0
           	a       = exp(p_fit(i, 2));
           	b       = p_fit(i, 1);
          	c       = Y_inf_range(i);
            Er(i, 1)= sqrt(mean((Y - Fun_exp(a, b, c, X)).^2));
        else
            Er(i, 1)= inf;
        end
    end
    
    [~, min_Ind]    = min(Er);
    
    Mean_Y          = mean(Y);
    Er_line         = sqrt(mean((Y - Mean_Y).^2));
    
    if Er(min_Ind)>= Er_line
        a           = 0;
        b           = 0;
        c           = Mean_Y;
        comment    	= 'Fitting line';
    else
        a        	= exp(p_fit(min_Ind, 2));
        b         	= p_fit(min_Ind, 1);
        c          	= Y_inf_range(min_Ind);
        comment  	= '';
    end
    
    if plot_data
        X_plot = linspace(min(X), max(X), 100)';
        plot(X_plot, c + a*exp(b*X_plot), sprintf('-%s', color), 'LineWidth', 3);
        title(sprintf('[a, b, c] = [%f, %f, %f]', a, b, c))
    end
end