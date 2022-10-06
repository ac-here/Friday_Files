function y = diff5(x, order)

    if ~exist('order', 'var')
        order = 1;
    end
    
    if order > 2
        order = 1;
    end
    
    if isempty(x)
        y = [];
        return
    end

    % Five-point central difference
    x   = x(:);
    x   = [zeros(2,1);x;zeros(2,1)];
    xp2 = x(1:end-4);
    xp1 = x(2:end-3);
    xo  = x(3:end-2);
    xn1 = x(4:end-1);
    xn2 = x(5:end);

    if order == 1   % First derivative
        y = (-xn2 + 8*xn1 - 8*xp1 +xp2)/12;
        y(1:2) = NaN;y(end-1:end) = NaN;
    elseif order == 2   % Second derivative
        y = (-xn2 + 16*xn1 -30*xo + 16*xp1 - xp2)/12;
        y(1:2) = NaN;y(end-1:end) = NaN;
    end

    if sum(~isnan(y))~= 0
        %Three point smoothing
        y = (y + [y(2:end); y(end)] + [y(1); y(1:end-1)])/3;
    end 
    
end