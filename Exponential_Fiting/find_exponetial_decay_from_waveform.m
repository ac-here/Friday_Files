% Author : Anand Chandrasekhar
% Here, we fit a exponential function to the into vector
% Fitting an exponential function : P(x) = P_inf + P0 * exp( - (x/Tau) )
% Range maybe modified while fitting the function

% X                 : Time Vector
% Y                 : Pressure Waveform ( select the diastolic decay region of
%                       the pressure waveform
% P_inf_Range_LIM   : Example : [min(Y)-1, 0]
% Delta_P_inf       : Exmaple 10
% plot_data         : 1 if you want to plot data
% range_Tau         : Exmaple [0.1 0.6]
% delta_inc_P_in    : 0.1
function [Tau_sel, ...
            P_inf_sel, ...
            comments, ...
            start_ptr_min,...
            end_ptr_min, ...
            Num_iteration, ...
            Exp_Y] ...
                    = find_exponetial_decay_from_waveform(...
                            X, ...
                            Y, ...
                            P_inf_Range_LIM, ...
                            Delta_P_inf, ...
                            plot_data, ...
                            range_Tau,...
                            resolution_pressure)

    if length(X) ~= length(Y)
        comments = 'Length mismatch';
        fprintf('Length of X and Y should be same. Error\n')
        return;
    end
    
    if ~exist('delta_inc_P_inf', 'var')
        resolution_pressure = 1;
    end
    
    if exist('P_inf_Range_LIM', 'var') && ~isempty(P_inf_Range_LIM)
        P_inf_range     = P_inf_Range_LIM(1):-resolution_pressure:P_inf_Range_LIM(2);
        Full_range_flag = true;
    end
    
    if isempty(P_inf_Range_LIM)
        P_inf_range     = Y(end)+resolution_pressure:-resolution_pressure:0;
        if isempty(P_inf_range)
            P_inf_range = 0;
        end
        Full_range_flag = true;
    else
        Full_range_flag = false;
    end
    
    comments        = '';
    Len             = 100;
    Num_iteration   = 0;
    Dec_Flag        = false;
    Inc_Flag        = false;
    Full_range_flag = false;
    start_ptr_min   = nan;
	end_ptr_min     = nan;
    if Len > length(X)
        Len = length(X);
    end
    
   while(true) 
        
        Num_iteration = Num_iteration + 1;
        if isempty(P_inf_range)
            P_inf_range  = Y(end)-resolution_pressure:-resolution_pressure:0;
            if isempty(P_inf_range)
                P_inf_range = 0;
            end
            Full_range_flag = true;
        end
        
        if Num_iteration == 40
            P_inf_sel   = nan;
            Tau_sel     = nan;
            comments    = 'Num_iteration == 40';
            break;
        end
        
        Range           = (1:floor(length(X)))';
        Wave_Er         = nan(length(Range), length(Range));
        P_inf           = nan(length(Range), length(Range)); 
        Tau             = nan(length(Range), length(Range)); 
        start_ptr_min   = nan;
        end_ptr_min     = nan;
        cnt             = 1;
        for end_ptr = Range(end)%:-5:Range(1)   
            print_status(end_ptr, Range);        
            for start_ptr = Range(1)%:5:end_ptr-5    % Anand Changed 3/16
             %for start_ptr = end_ptr-5    
                %fprintf('[%1.3f %1.3f]\t', X(start_ptr), X(end_ptr));
                X_decay         = X(start_ptr:end_ptr);
                Y_decay         = Y(start_ptr:end_ptr);


                %if length(X_decay) < Len, continue; end
                %if length(X_decay) > Len+1, continue; end
                
                p_fit           = polyfit(X_decay, Y_decay, 1);
                if p_fit(1) > 0, continue; end

                [P_inf(end_ptr, start_ptr), ...
                    Wave_Er(end_ptr, start_ptr), ...
                    Tau(end_ptr, start_ptr), ...
                    Exp_Y] ...
                                = find_exponential_decay_parameter(...
                                            X_decay, ...
                                            Y_decay, ...
                                            P_inf_range, ...
                                            false, ...
                                            range_Tau);
                cnt = cnt + 1;
                %fprintf('%1.6f\n', Wave_Er(end_ptr, start_ptr));
            end
        end

        minimum       	= nanmin(nanmin(Wave_Er));

        if isnan(minimum)
            P_inf_range  = Y(end)-1:-resolution_pressure:0;
            Full_range_flag = true;
            continue;
        end
        
        if isnan(minimum) && Full_range_flag
            P_inf_sel   = nan;
            Tau_sel     = nan;
            Exp_Y       = [];
            comments    = 'No proper minima for the function';
            return
        end

        [end_ptr_min, start_ptr_min]...
                        = find(Wave_Er == minimum);
        %fprintf('Final Answer = [%1.3f %1.3f]\t', X(start_ptr_min), X(end_ptr_min));
        Tau_sel       	= min(Tau(end_ptr_min, start_ptr_min), [], 'all');
        P_inf_sel   	= min(P_inf(end_ptr_min, start_ptr_min), [], 'all');
        X_decay       	= X(start_ptr_min:end_ptr_min);
        Y_decay       	= Y(start_ptr_min:end_ptr_min);
        
        if Full_range_flag
%            if ~isempty(find(P_inf_sel == [P_inf_range(1) P_inf_range(end)], 1))
%                Tau_sel     = nan;
%                P_inf_sel   = nan;
%                comments    = 'No proper minima for the function';
%            end
           break;
        end

        if ~isempty(find(P_inf_sel == [P_inf_range(1) P_inf_range(end)], 1)) || ...
                abs(P_inf_sel - mean(P_inf_range))>Delta_P_inf/4
            if P_inf_sel == P_inf_range(1)
                P_inf_range = P_inf_sel-Delta_P_inf:P_inf_sel-1;
                P_inf_range(P_inf_range<0)      = [];
                P_inf_range(P_inf_range>Y(end)) = [];
                Dec_Flag    = true;
            else
                P_inf_range = P_inf_sel+1:P_inf_sel+Delta_P_inf;
                P_inf_range(P_inf_range<0) = [];
                P_inf_range(P_inf_range>Y(end)) = [];
                Inc_Flag    = true;
            end
            
            if all([Dec_Flag Inc_Flag])
                P_inf_range     = Y(end)-1:-resolution_pressure:0;
                Full_range_flag = true;
            end    
                
        else
            break;
        end
   end
   
    if plot_data
        subplot(1, 2, 1);
        plot(X, Y, '-k', 'LineWidth', 3); hold on;

        find_exponential_decay_parameter(...
                                X_decay, ...
                                Y_decay, ...
                                P_inf_range, ...
                                true, ...
                                range_Tau);
        title(sprintf('P inf = %3.1f, Tau = %1.3f', P_inf_sel, Tau_sel));
    end
    
end