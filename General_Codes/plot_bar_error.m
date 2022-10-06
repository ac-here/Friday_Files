% Author: Anand Chandrasekkhar
% Use this function to plot the mean values of differnt variables in
% differnt clouds. Here, Number of columns represent the number of clouds
% and the number of rows signifies the number of variables within a cloud.
% Input X_names :   X_names is the name of the clouds.
%                   X_names is a cell array.
%                   X_names = {'X', 'Y', 'Z', 'XX'};
%       Y       :   Y axis data 
%                   size = [Nx, Ny]
%                   Here, Ny is the number of variables
%                   Y = [1 2 3 4; 5 6 7 8; 9 10 11 12];
%                   Make sure 
%       Y_MOE   :   Margin of Error for each element in Y
%                   Y_MOE = [1 2 3 4; 5 6 7 8; 9 10 11 12]/10;
%       Vars    :   There are the name of the variables to plot
%                   Vars is a cell array.
%                   Vars = {'a', 'b', 'c'};
%       h_values:   Output from ttest 
%                   Results for null Hypothesis
%                   h_values = ones(3, 4);  
%       N       :   Number of subjects in each bar plot
%                   N = [1 2 3 4; 5 6 7 8; 9 10 11 12];
%       y_label :   Y axis label 
%                   y_label = 'string_label';   

function plot_bar_error(X_names, Y, Y_MOE, Vars, h_values, N, y_label)

    if size(Y, 2) ~= length(X_names)
        fprintf('Data not formated properly: size(Y, 1) ~= length(X_names)\n');
        return;
    end

    if size(Y, 1) ~= length(Vars)
        fprintf('Data not formated properly: size(Y, 2) ~= length(Vars)\n');
        return;
    end

    if any(size(Y_MOE) ~= size(Y))
        fprintf('Data not formated properly: any(size(Y_MOE) ~= size(Y))\n');
        return;
    end

    if ~exist('N', 'var')
        N = ones(size(Y));
        print_N = false;
    else
        print_N = true;
    end

    if any(size(N) ~= size(Y))
        fprintf('Data not formated properly: any(size(N) ~= size(Y))\n');
        return;
    end

    Bar_width   = 0.8;
    X           = (1:length(X_names));
    bar(X, Y', Bar_width); pbaspect([1 1 1]);
    set(gca, 'XTickLabel', X_names);
    hold on
    
    
    nbars       = size(Y, 1);
    ngroups     = size(Y, 2);    
    groupwidth  = min(Bar_width, nbars/(nbars + 1.5));
    X           = (1:ngroups) - groupwidth/2 + (2*(1:nbars)'-1) * groupwidth / (2*nbars);  
    
    errorbar(X, Y, Y_MOE, ...
    'vertical', ...
    'Color', 'k', ...
    'LineWidth', 3, ...
    'LineStyle', 'none', 'CapSize', 15);
    hold off;
    legend(Vars);

    star_to_print = repmat({'(-)'}, size(h_values));
    star_to_print(h_values == 1) = {'(*)'};

    X1      = X(:);
    Y1      = Y(:);
    Y_MOE1  = Y_MOE(:);
    star_to_print1 = star_to_print(:);
    %text(X1, Y1 + Y_MOE1, star_to_print1, 'FontSize', 50, 'Color', 'k');

    if print_N    
        clear N_array
        for i = 1:size(N, 1)
            for j = 1:size(N, 2)
                N_array(i, j) = {num2str(N(i, j))};
            end
        end
        N_array = N_array(:);
        N_array = strcat('N= ', N_array);
        print_me= strcat(star_to_print1, N_array);
    else
        print_me = star_to_print1;
    end

    X1      = X(:) - ((X(2, 1) - X(1, 1))*Bar_width/2);
    h       = text(X1, Y1 + Y_MOE1 + Y_MOE1*10/100, print_me, 'FontSize', 15, 'Color', 'k');
    set(h,'Rotation',90);

    set(gca, 'FontSize', 20);
    ylabel(y_label);
end