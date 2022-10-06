% Author    :   Anand Chandrasekhar
% Description:  This function computes and plots the statistics of variable pair. 
%               Specifically, this function plots the scatter and BA plot between 
%               the True and Estimated value.
%
% How to use this function
% Sample Code:
% close all;
% X               = (0:0.05:1)';                      % Sample X
% Y               = X .* X + rand(length(X), 1)/2;   	% Sample Y
% group           = [ones(10, 1); ...                 % Group 1
%                     ones(5, 1)*2; ...               % Group 2
%                     ones(6, 1)*3];                  % Group 3
% color_groups    = {'BLACK', 'RED', 'BLUE'};
% figure(1);
% make_scatter_ba_plot(X, Y, 'X', 'Y', 3, 1);	% plots in cordinate 1 
% make_scatter_ba_plot(X, Y, 'X', 'Y', 3, 2);	% plots in cordinate 2 
% make_scatter_ba_plot(X, Y, 'X', 'Y', 3, 3);	% plots in cordinate 3 
% figure(2);
% make_scatter_ba_plot(X, Y, 'X', 'Y', 2, 1);	% plots in cordinate 1 
% make_scatter_ba_plot(X, Y, 'X', 'Y', 2, 2);	% plots in cordinate 2 
% figure(3);
% make_scatter_ba_plot(X, Y, 'X', 'Y', 1, 1);	% plots in cordinate 1 
% figure(4);
% make_scatter_ba_plot(X, Y);               	% plots in cordinate 1 
% figure(5);
% make_scatter_ba_plot(X, Y, 'X', 'Y', ...      % plots in cordinate 1 
%      	1, 1, group, color_groups); 
% figure(7);
% make_scatter_ba_plot(X, Y, 'X', 'Y', ...      % plots in cordinate 1 
%          	1, 1, group, color_groups, true); 

%
% Input     :   x_axis_data (Estimated or measured value)
%               y_axis_data (True Vaule)
%               x_axis_scatter_label (Name of the True Value)
%               y_axis_scatter_label (Name of the Estimated or measured Value)
%               num_plots   : Total number of plots in the Figure. 
%                               If you want to plot characteritics of 
%                               2 paris of variables, num_plots = 2;
%                               Maximum of 2 variable pairs can be plotted
%               cordinate   : Cordinate of each scatter plot.
%                               If num_plots == 2, cordinate may be {1, 2}
%                               Cordinate = 1 for variable pair 1, and
%                               Cordinate = 2 for variable pait 2.
%               group       : Vector with group labels as 1, 2, 3 ..
%                             Length of group should be same as x_axis_data 
%               color_groups: Cell array of colors for each group
%      condition_print_label: This is a boolean variable
%                           : True  ( Print the label ID)
%                           : False ( Do not print the label ID)
%               Data_ID     : This is a unique number ID to label a data    
% Output    :   r           : Correlation between the variables 
%               rmse        : Root Mean Square Error
%               bias        : Mean error  = mean(Y-X)
%               stdev       : Standard deviation of error  = std(Y-X)
%               NUM_DATA    : Number of data points

function [ax, r, rmse, bias, stdev, NUM_DATA] ...
                = make_scatter_ba_plot(...
                        x_axis_data, y_axis_data,...
                        x_axis_scatter_label, y_axis_scatter_label,...
                        num_plots, cordinate, ...
                        groups, color_groups, ...
                        condition_print_label, Data_ID, ax)
    warning('off');
    if(nargin == 2)
        x_axis_scatter_label = 'X';
        y_axis_scatter_label = 'Y';
        num_plots = 1;
        cordinate = 1;
    end
    
    if ~exist('ax', 'var')
        ax = [];
    end
    
    if ~( exist('groups', 'var') || exist('color_groups', 'var') )
        groups          = ones(length(x_axis_data), 1);
        color_groups    = {'BLACK'};
    elseif isempty(groups) || isempty(color_groups)
        groups          = ones(length(x_axis_data), 1);
        color_groups    = {'BLACK'};        
    end
    
    
    if ~exist('condition_print_label', 'var')
        condition_print_label = true;
    end
    
    if ~exist('Data_ID', 'var')
        % Define identifier for the data points
        Data_ID     = (1:length(x_axis_data))';
    end
    
    if isempty(Data_ID)
        % Define identifier for the data points
        Data_ID     = (1:length(x_axis_data))';
    end
    
    if(num_plots > 4 || ...
            num_plots < 1 || ...
            cordinate>num_plots)
        fprintf('num_plots should be in the range of [1 3], cordinate should be <= num_plots\n');
      	return;
    end
                    
    switch num_plots
        case 1 
            rows    = 2;
            columns = 1;
            coord_1 = 1;
            coord_2 = 2;
        case 2
            rows    = 2;
            columns = 2;
            coord_1 = cordinate;
            coord_2 = 3*(cordinate == 1) + 4*(cordinate == 2);
        case 3
            rows    = 2;
            columns = 3;
            coord_1 = cordinate;
            coord_2 = 4*(cordinate == 1) + ...
                        5*(cordinate == 2) + ...
                        6*(cordinate == 3);
        case 4
            rows    = 2;
            columns = 4;
            coord_1 = cordinate;
            coord_2 = 5*(cordinate == 1) + ...
                        6*(cordinate == 2) + ...
                        7*(cordinate == 3) + ...
                        8*(cordinate == 4);
        otherwise
            fprintf('Error\n');
            return;
    end
                        
    % Set the Plot parameters
    Font_Name = 'Helvetica'; 
    FontSize = 20;
    
    % Check for Nan and remove the specific data point if Nan
    X_nan       = find(isnan(x_axis_data));
    Y_nan       = find(isnan(y_axis_data));
    all_nan     = union(X_nan, Y_nan);
    x_axis_data(all_nan)    = [];
    y_axis_data(all_nan)    = [];
    Data_ID(all_nan)        = [];
    groups(all_nan)         = [];   

    Unique_groups           = unique(groups);    
    if length(Unique_groups) ~= length(color_groups)
        fprintf('Number of colors and groups not matching. \n');
        r           = nan;
        rmse        = nan;
        bias        = nan;
        stdev       = nan;
        NUM_DATA    = nan;
        return
    end
    
    % Number of data points
    NUM_DATA = length(x_axis_data);
    
    % Plot the scatter plot
    Y_cord = (mod(coord_1, columns)==0)*columns + (mod(coord_1, columns)~=0)*mod(coord_1, columns);
    X_cord = ceil(coord_1/columns);
    ax(X_cord, Y_cord) = subplot(rows, columns, coord_1);
    
    for i_group = 1:length(Unique_groups)
        sel_index = groups == Unique_groups(i_group);
        plot(x_axis_data(sel_index), y_axis_data(sel_index), 'ok', ...
                'MarkerSize', 10, ...
                'MarkerFaceColor', color_groups{i_group});         
        hold on;
        %xlim([50 110]); ylim([50 110]); 
        
        % Print labels to the data point
        print_label(x_axis_data(sel_index), ...
                        y_axis_data(sel_index), ...
                        color_groups{i_group}, ...
                        Data_ID, ...
                        condition_print_label);
        
        %if num_plots == 1
            pbaspect([1 1 1]);
        %end
        
    end    
    hold off;
    
    % Calculate the Bias error
    error   = y_axis_data - x_axis_data;
    bias    = mean(error);
    stdev   = std(error);
    
    % Plot the identity line
    hline = refline(1);
    hline.Color = 'k';hline.LineWidth = 1;hline.LineStyle = '--';
    
    % Plot the bias line
    hline = refline(1, bias);
    hline.Color = 'b';hline.LineWidth = 3;hline.LineStyle = '-';

    % Compute Correlation
    R = corrcoef(x_axis_data, y_axis_data);
    r = R(1,2);
       
    % Compute Root Mean Squred Error
    rmse = sqrt(mean(error.^2));
    
    % Set labels, title, and FontSize of the plot
    xlabel(x_axis_scatter_label);
    ylabel(y_axis_scatter_label);
    title(sprintf('[N = %d (Rem = %d), R = %1.2f]', ...
        NUM_DATA, length(all_nan), r));
    set(gca,'FontSize',FontSize);set(gca,'FontName',Font_Name);

    % Plot the BA plot 
    Y_cord = (mod(coord_2, columns)==0)*columns + (mod(coord_2, columns)~=0)*mod(coord_2, columns);
    X_cord = ceil(coord_2/columns);
    ax(X_cord, Y_cord) = subplot(rows, columns, coord_2);    
    
    for i_group = 1:length(Unique_groups)
        sel_index = groups == Unique_groups(i_group);
        plot(x_axis_data(sel_index), error(sel_index), 'ok', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor',color_groups{i_group}); 
        %xlim([50 110]); 
        hold on;
        
        % Print labels to the data point
        print_label(x_axis_data(sel_index), ...
                        error(sel_index), ...
                        color_groups{i_group}, ...
                        Data_ID, ...
                        condition_print_label);
        
        %if num_plots == 1
            pbaspect([1 1 1]);
        %end
    end
    hold off;
    
    % Plot the bias + 1.96*sigma boundary
    hline = refline([0 bias + 1.96*stdev]);
    hline.Color = 'r';hline.LineWidth = 3;hline.LineStyle = '-';
    
    % Plot the bias - 1.96*sigma boundary
    hline = refline([0 bias - 1.96*stdev]);
    hline.Color = 'r';hline.LineWidth = 3;hline.LineStyle = '-';
    
    % Plot the bias
    hline = refline([0 bias]);
    hline.Color = 'b';hline.LineWidth = 3;hline.LineStyle = '-';
    
    % Plot the zero error line
    hline = refline([0 0]);
    hline.Color = 'k';hline.LineWidth = 1;hline.LineStyle = '--';
    
    % Set labels, title, and FontSize of the plot
    xlabel(sprintf('%s', x_axis_scatter_label));
    %ylabel(sprintf('%s - %s',y_axis_scatter_label, x_axis_scatter_label)); 
    ylabel(sprintf('Error = %s - %s','Ydata', 'Xdata'));
    title(sprintf('[ \\mu = %3.1f, \\sigma = %3.1f]', bias, stdev));
    set(gca,'FontSize',FontSize);set(gca,'FontName', Font_Name);
    
   for i = 1:size(ax, 2)
      setappdata(ax(1, i),  'XLim_listeners', linkprop(ax(:, i),'XLim'));
   end
   for i = 1:size(ax, 1)
       setappdata(ax(i, 1), 'YLim_listeners', linkprop(ax(i, :),'YLim'));
   end   
    warning('on');
end
function print_label(X, Y, color, label_id, condition)
    if ~condition, return; end
    
    % Print labels to the data point
    label_id_string = strsplit(num2str(label_id'), ' ');
    
    text(X, Y, strcat('\rightarrow', label_id_string), 'Color', color);
end
