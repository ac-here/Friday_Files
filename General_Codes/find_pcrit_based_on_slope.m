% Author: Anand Chandrasekhar
% Use this function to calculate Pcrit from X and Y Data
% Here, Pcrit can be estimated from the Y axis intercept of the MAP versus PP*HR  
% Input:    
%           time                    Time vector
%                                   Express in seconds.or datetime format
%           Y_axis_MAP_data         (Mean Arterial Pressure)
%           X_axis_data             X axis could be CO or [PP HR_BPM]%                                   
%           block_time_in_minutes   Block of time for finding the fit.
%                                   Express in minutes. 
%           threshold_X             max(X) - min(X) should be greater than
%                                   threshold_X
%           range_X                 All values of X should be between
%                                   range_X(1) and range_X(2)
%           range_Y                 All values of Y should be between
%                                   range_Y(1) and range_Y(2)
%           threshold_Length        Minum length for computing linear fit
%           factor                  factor of block_time_in_minutes to update Pcrit
%                                   factor = 0.5;
% Output    Pcrit       
function [Pcrit, R, Error_Message, Time_stamp, MAP_value] ...
                            = find_pcrit_based_on_slope(...
                                time, ...
                                X_axis_data, Y_axis_MAP_data, ...
                                block_time_in_minutes, ...
                                threshold_X, ...
                                range_X, ...
                                range_Y, ...
                                threshold_Length, ...
                                factor)

    % Error Message
    Error_Message{1, 1} = '';

    % Estimated Pcrit
    Pcrit           = nan(1, 1);

    % Mean MAP
    MAP_value       = nan(1, 1);

    % Estimated Starling resistor
    R               = nan(1, 1); 

    % Time stamp for Pcrit and R
    Time_stamp      = nan(1, 1);
    
    % R2 value
    r2_value        = nan(1, 1);

    if isempty(X_axis_data) || isempty(Y_axis_MAP_data) || isempty(time)
        Error_Message{1, 1} = 'Empty X or Y';
        return;
    end

    % Check if time is in datatime format
    TIME_IN_DATETIME_FORMAT = isdatetime(time(1));

    % Block time in minutes
    Blck_time               = block_time_in_minutes;

    if TIME_IN_DATETIME_FORMAT        
        block_time_in_minutes   = minutes(block_time_in_minutes);        
        T_calc                  = time;
    else
        % Convert time in seconds to minutes
        T_calc          = time/60;
    end  

    if length(X_axis_data) ~= length(Y_axis_MAP_data)
        Error_Message{1, 1} = 'Inconsistent length of X and Y';
        return;
    end

    % Estimate X axis_data
    X_data          = ones(size(X_axis_data, 1), 1);
    for i = 1:size(X_axis_data, 2)
        X_data      = X_data .* X_axis_data(:, i);
    end

    if ~exist('factor', 'var')
        factor = 0.5;
    end

    if ~exist('threshold_Length', 'var')
        threshold_Length = 5;
    end

    if ~exist('threshold_X', 'var')
        threshold_X = inf;
    end

    if ~exist('range_X', 'var')
        range_X = [-inf inf];
    end

    if ~exist('range_Y', 'var')
        range_Y = [-inf inf];
    end

    if isempty(range_X)
        range_X = [-inf inf];
    end

    if isempty(range_Y)
        range_Y = [-inf inf];
    end

    if block_time_in_minutes <= 0
        N               = length(X_data);
        MSG             = sprintf('block_time_in_minutes <= 0');
        Error_Message   = repmat({MSG}, [N, 1]);
        return;
    end
 
    % Ensure the ranges are in the right order
    range_X = sort(range_X);
    range_Y = sort(range_Y);

    if T_calc(end) - T_calc(1) <= block_time_in_minutes        
        N               = length(X_data);
        MSG             = sprintf('Duration less than %3.1f minutes', Blck_time);
        Error_Message   = repmat({MSG}, [N, 1]);
        return;
    end

    % Initialize the starting point time
    T_start     = T_calc(1);

     % Starting pointer 
    counter_i   = 1;

    % Calculate Pcrit and R 
    while (T_start + block_time_in_minutes) < max(T_calc)  
    
        % End point time
        T_end = T_start + block_time_in_minutes; 
    
        % Index of time=T_calc between [T_start and T_end]
        T_idx           = find(T_start<=T_calc & T_calc < T_end);

        % Update the time stamp 
        Time_stamp(counter_i, 1) = T_start*60;

        % Get X, Y Data
        X               = X_data(T_idx);
        Y               = Y_axis_MAP_data(T_idx);
        rem_me          = isnan(X)|...
                            isnan(Y)|...
                            range_X(1) > X |...
                            range_X(2) < X | ...
                            range_Y(1) > Y | ...
                            range_Y(2) < Y;
        X(rem_me)       = [];
        Y(rem_me)       = [];

        % Confirm if the data is valid
        if isempty(X) || isempty(Y)

            Error_Message{counter_i, 1} = 'Empty X or Y';

            Pcrit(counter_i, 1)         = nan;
            MAP_value(counter_i, 1)     = nan;
            R(counter_i, 1)             = nan; 
            r2_value(counter_i, 1)      = nan;

            % Update starting pointer and the counter
            [T_start, counter_i] = update_Tstart_counter(T_start, block_time_in_minutes, factor, counter_i);

            continue; 
        end        
       
        % Locate unique values
        [~, Idx_uni]    = unique(X);
        X               = X(Idx_uni);
        Y               = Y(Idx_uni);

        if length(X) < threshold_Length 

            Error_Message{counter_i, 1} = sprintf('length(X)=%d<%d', length(X), threshold_Length);

            Pcrit(counter_i, 1)         = nan;
            MAP_value(counter_i, 1)     = nan;
            R(counter_i, 1)             = nan; 
            r2_value(counter_i, 1)      = nan;
            
            % Update starting pointer and the counter
            [T_start, counter_i] = update_Tstart_counter(T_start, block_time_in_minutes, factor, counter_i);

            continue; 
        end

        % Remove outliers 
        xP = prctile(X, [5 95]); 
        select_Idx = X > xP(1) & X < xP(2);
        X = X(select_Idx);
        Y = Y(select_Idx);

        %
        %warning('off');
        %p_fit           = robustfit(X, Y);
        %p_fit           = flipud(p_fit)';
        %warning('on');

        p_fit           = polyfit(X, Y, 1);  
        
%        Y_est = polyval(p_fit, X);
%         MAT = corrcoef(Y_est, Y);
%         r_value = MAT(1, 2);
%         r2_value(counter_i, 1) = r_value^2;

        if max(X) - min(X) >= threshold_X && p_fit(1) > 0 && p_fit(2) > 0           
            Pcrit(counter_i, 1)         = p_fit(2);
            R(counter_i, 1)             = p_fit(1); 
            MAP_value(counter_i, 1)     = mean(Y); 
            Error_Message{counter_i, 1} = '';
        elseif max(X) - min(X) < threshold_X
            Error_Message{counter_i, 1} = sprintf('max(X)-min(X) = %4.1f<%d', max(X) - min(X), threshold_X);
            Pcrit(counter_i, 1)         = nan;
            MAP_value(counter_i, 1)     = nan;
            R(counter_i, 1)             = nan;
        elseif p_fit(1) <= 0 
            Error_Message{counter_i, 1} = 'p_fit(1) <= 0';
            Pcrit(counter_i, 1)         = nan;
            MAP_value(counter_i, 1)     = nan;
            R(counter_i, 1)             = nan;
        elseif p_fit(2) <= 0 
            Error_Message{counter_i, 1} = 'p_fit(2) <= 0';  
            Pcrit(counter_i, 1)         = nan;
            MAP_value(counter_i, 1)     = nan;
            R(counter_i, 1)             = nan;
        end
    
        % Update starting pointer and the counter
        [T_start, counter_i] = update_Tstart_counter(T_start, block_time_in_minutes, factor, counter_i);
    end    
end
function [T_start, counter_i] = update_Tstart_counter(T_start, block_time_in_minutes, factor, counter_i)
    T_start     = T_start + block_time_in_minutes*factor;
    counter_i   = counter_i +1;
end