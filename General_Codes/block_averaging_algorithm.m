% Author: Anand Chandrasekhar
% This algorithm may be used to average Y in blocks of data in X based on 
% constraints on data in X_constraint.
% Input     X                   :   X axis of the plot generated.
%           Y                   :   Y axis of the plot to be generated
%                                   if there are more than one Y data, put  
%                                   them in mutiple columns 
%           X_Range             :   Limit on the X data for averaging.
%                                   X_Range(1) is the starting point.
%                                   X_Range(2) is the interval 
%                                   X_Range(3) is the endpoint.
%                                   We create an array from X_Range(1) to 
%                                   X_Range(3) with X_Range(2) as the
%                                   interval. Y will averages based on
%                                   these intervals, along with the
%                                   constraints given in
%                                   X_constraint_limit.
%           X_constraint        :   Array of Input which will be used as a 
%                                   constraint in averaging Y.
%           X_constraint_limit  :   This variable has the same format of
%                                   the input: X_Range. We may use this variable
%                                   to put contraints while averaging the Y
%                                   data based on limits gvien in X_Range.
%           LENGTH              :   Use this variable to stop 
%                                   averaging data with #N less than 
%                                   LENGTH.     
%           plot_me             :   True (Plots the results)
%                                   False(No plots)
%           label_name          :   Name of the label for the plots;
%                                   label_name{1, 1} X axis name
%                                   label_name{2, 1} Y axis name
%                                   label_name{3, 1} Constant 
%                                   label_name{1, 2} Units for X axis 
%                                   label_name{2, 2} Units for X axis 
%                                   label_name{3, 2} Units for Constant
function [out_X, ...
            out_mean, out_mean_MOE, ...
            Const_val, Const_MOE, ...
            Max_Len, Index_struct, ...
            out_X_MOE] ...
                    = block_averaging_algorithm(...
                                    X, Y, X_Range, ...
                                    X_constraint, X_constraint_limit, ...
                                    LENGTH, ...
                                    plot_me, ...
                                    label_name)
                                
    % Initialize the outputs
    out_mean    = nan(1, 1, 1); % Mean of the Y values 
    out_mean_MOE= nan(1, 1, 1); % Confidence interval of the Y values
    out_X       = nan(1, 1, 1); % Mean of the X value
    out_X_MOE  	= nan(1, 1, 1); % Confidence interval of the X value 
    Const_val   = nan;
    Const_MOE  	= nan;
    
    if isempty(X) || isempty(Y) || isempty(X_Range) 
        fprintf('Error in Input\t');
        return;
    end
    
    if ~exist('plot_me', 'var'), plot_me = false; end
    
    if ~exist('label_name', 'var'), label_name = {'--', '---'}; end
    
    if ~exist('LENGTH', 'var'), LENGTH = 5; end
    
    if ~exist('X_constraint', 'var') || ~exist('X_constraint_limit', 'var')
        X_constraint        = []; 
        X_constraint_limit  = [];            
    end
            
    if isempty(X_constraint)
        label_name{3, 1} = '---';
        label_name{3, 2} = '---';
    end
    
    if size(label_name, 2) == 1
        label_name{1, 2} = '---';
        label_name{2, 2} = '---';
        label_name{3, 2} = '---';        
    end
    
    if ~isempty(X_constraint_limit) && ~isempty(X_constraint)
        % Create an array for X axis based on X_Range
        X_constraint_array = X_constraint_limit(1):X_constraint_limit(2):X_constraint_limit(3);  
        CONSTRAINT_PRESENT = true; 
    else
        CONSTRAINT_PRESENT = false;
    end
        
    % Create an array for X axis based on X_Range
    X_array = X_Range(1):X_Range(2):X_Range(3);

    if max(X_array) < max(X)
        X_array = [X_array X_array(end) + X_Range(2)];
    end
    
    if size(X_constraint, 2) >= 2
        fprintf('#Columns in X_constraint should be 1\t');
        return;
    end  

    Index_struct = struct();
        
    for i = 1:length(X_array)-1
        
        % create a window of accepatable X values
        clear Win_Index;     
        
        if ~CONSTRAINT_PRESENT
            
            % Run this script if there are no constraints on X axis
            Win_Index               = find(X_array(i) <= X & X < X_array(i+1));
            [output_mean(i, :, 1), ...
                output_mean_CI(i, :, 1), ...
                Len(i, :, 1)]       = calcualte_mean_CI(Y, Win_Index, LENGTH);
            
            [output_X(i, 1, 1), ...
                output_X_CI(i, 1, 1), ...
                ~]                  = calcualte_mean_CI(X, Win_Index, LENGTH);
            
            %output_X(i, 1, 1)       = mean(X(Win_Index), 1, "omitnan");
          	output_X(i, 2, 1)       = nan;
            Index_struct(i, 1).Win_Index  = Win_Index;
        else
            
            for j = 1:length(X_constraint_array)-1
                Win_Index = find(...
                                    X_array(i) <= X & ...
                                    X <= X_array(i+1) & ...
                                    X_constraint_array(j) <= X_constraint & ...
                                    X_constraint <= X_constraint_array(j+1)...
                                );
                        
                [output_mean(i, :, j), ...
                    output_mean_CI(i, :, j), ...
                    Len(i, :, j)]   = calcualte_mean_CI(Y, Win_Index, LENGTH); 
                
                [output_X(i, 1, j), ...
                    output_X_CI(i, 1, j), ...
                    ~]   = calcualte_mean_CI(X, Win_Index, LENGTH);
                
                [output_X(i, 2, j), ...
                    output_X_CI(i, 2, j), ...
                    ~]   = calcualte_mean_CI(X_constraint, Win_Index, LENGTH);
                %output_X(i, 1, j)   = mean(X(Win_Index), 1, "omitnan");
                %output_X(i, 2, j)   = mean(X_constraint(Win_Index), 1, "omitnan");
                Index_struct(i, j).Win_Index  = Win_Index;
            end
            
        end   
        
    end
    
    % Calculate the number of data points in each curve
    Len_values = sum(Len, 1);Len_values = Len_values(:);
    
    % Rank them based on the number
    [~, I]      = sort(Len_values, 'descend');  
    Index_struct= Index_struct(:, I(1));
    Max_Len     = Len_values(I(1));
    
 	out_mean    = output_mean(:, :, I(1));
 	out_mean_MOE	= output_mean_CI(:, :, I(1));
    
    out_X       = output_X(:, 1, I(1));
    out_X_MOE	= output_X_CI(:, 1, I(1));
    
    if CONSTRAINT_PRESENT
        Const_val 	= output_X(:, 2, I(1));
        Const_MOE	= output_X_CI(:, 2, I(1));
    else
        Const_val 	= nan;
        Const_MOE	= nan;
    end
    
    %Const_val   = mean(output_X(:, 2, I(1)), 1, "omitnan");
    %Const_std   = nanstd(output_X(:, 2, I(1)));
    if plot_me 
        plot(X, Y, 'xk', 'MarkerSize', 10); hold on; 
        for j = 1:size(out_mean, 2)
            plot(out_X, out_mean(:, j), ...
                    'x-r', ...
                    'LineWidth', 3, ...
                    'MarkerSize', 10);
            errorbar(out_X, ...
                    out_mean(:, j), ...
                    out_mean_MOE(:, j), ...
                    'Color', 'r', ...
                    'LineWidth', 2, ...
                    'LineStyle','-');
            title(sprintf('%s = %3.1f +- %3.1f%s', ...
                    label_name{3, 1}, ...
                    Const_val, ...
                    Const_MOE, ...
                    label_name{3, 2}));
            xlabel(sprintf('%s [%s]', label_name{1, 1}, label_name{1, 2}));
            ylabel(sprintf('%s [%s]', label_name{2, 1}, label_name{2, 2}));
            set(gca, 'FontSize', 20);
            
            Min = min(out_X(~isnan(out_mean), 1));
            Max = max(out_X(~isnan(out_mean), 1));
            if Min < Max
                xlim([Min Max]);
            end
            
            Min = min(out_mean(~isnan(out_mean), j));
            Max = max(out_mean(~isnan(out_mean), j));
            if Min < Max
                ylim([Min Max]);
            end
            
        end
        pbaspect([1 1 1]);
    end
end
function [output_mean, ...
            output_CI, ...
            Len] = calcualte_mean_CI(Y, Win_Index, LENGTH)
    Len = length(Win_Index);
    if Len < LENGTH
        output_mean = nan(1, size(Y, 2));   
        output_CI  = nan(1, size(Y, 2));
    else
        output_mean     = mean(Y(Win_Index, :), 1, "omitnan");
        [~, output_CI]  = calculate_confidence_interval(Y(Win_Index, :), 95);        
        %output_CI       = nanstd(Y(Win_Index, :));
    end
end