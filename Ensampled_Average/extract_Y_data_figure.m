function Selected_output = extract_Y_data_figure()

    Figure_handle       = get(gca, 'Children');    
    L_width             = get(Figure_handle, 'LineWidth');
    
    % Get the Y axis of the plots
    % In this project, we assume X axis is same
    All_Inputs          = get(Figure_handle, 'YData');
    All_output      	= cell2mat(All_Inputs)';
    
    if isempty(All_output)
        Selected_output = [];
        return;
    end
    
    % Find all grapgh with linewidth == 0.5
    % Linewidth == 0.5  indicates true data
    % Linewidth == 5    indicates mean of the true data
    Index_of_data       = cell2mat(L_width) == 0.5;
    
    if all(Index_of_data == 0)
        fprintf('Error. Please do not change linewidth of plots\n');
        Selected_output = [];
    else
        % Selected Data plots
        Selected_output = All_output(:, Index_of_data);
    end
        
end