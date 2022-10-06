% Author:       Anand Chandrasekhar
% Function:     This scripts waits for the user to remove data 
%               from the plots. Then saves the remaining data 
% Input         Input_data:         Input data organized as column vectors
%               Threshold_percent   Check the function
%                                   compute_mean_based_on_Nan.m
%               no_print            Boolean variable.
%                                   = True: deactivate all fprintf commands
%                                   = false: activate fprintf commands
%                                   Default value is false
function output_data = remove_data_from_plot(Input_data, Threshold_percent, no_print)
    
    if ~exist('no_print', 'var')
        no_print = false;
    end
    
    % Plot the figure with the following attributes.
    % my_closereq: This function will be called when one clode the figure
    % UserData: This variable stores the data 
    fig             = figure(...
                            'CloseRequestFcn',@my_closereq, ...     % This function is called when the figure is closed
                            'UserData', 0);

    % Initialize the Userdata variable
    data            = struct();
    data.output     = [];       % this variable holds the data vectors plotted in the figure.
    data.flag       = false;    % this variable is set, when the figure is closed 
    fig.UserData    = data;
    plotedit(fig.Number, 'on');
    
    % Please do not change the LineWidth = 0.5 and 5
    % In the algorithm described in extract_Y_data_figure,
    % we use that as parameter to distinguish the data
    Line_Width_data     = 0.5;
    Line_Width_mean     = 5;    
    
    if size(Input_data, 2) == 1
        fprintf('Only 1 beat present\t');
    end
    
    % Total number of beats
    N_Total = size(Input_data, 2);
    
    plot(Input_data, 'LineWidth', Line_Width_data); hold on;    
    plot(compute_mean_based_on_Nan(Input_data, Threshold_percent), ...
            '-k', 'LineWidth', Line_Width_mean); hold off;
    title(sprintf('N = [%d/%d] Left CLCIK >> "DELETE" >> Close', N_Total, N_Total));
    pbaspect([1 1 1]);
        
    Graph_selected_state    = false;
    
    while ~fig.UserData.flag
        Button_pressed = waitforbuttonpress();
        switch Button_pressed
            case 0
                    % Mouse is clicked
                    Graph_selected_state        = true;              
            case 1
                    % check if Mouse clicked
                    if Graph_selected_state                
                        Graph_selected_state  	= false;
                        output_data             = extract_Y_data_figure();
                        plot(output_data); hold on;                        
                        plot(compute_mean_based_on_Nan(output_data, Threshold_percent), '-k', 'LineWidth', 5); hold off 
                        title(sprintf('N = [%d/%d] Left CLCIK >> "DELETE" >> Close', size(output_data, 2), N_Total));
                        pbaspect([1 1 1]);
                    end                 
            otherwise
        end
    end
    
    % close the figure
	delete(gcf);
    
    if ~no_print
        fprintf('Manually remove signals which may be noisy!\n');
        fprintf('Use the MOUSE to remove noisy waveforms.\n');
        fprintf('Click on the graphs using the MOUSE. Click and Press "DELETE"\n');
        fprintf('Close the figure once you complete removing noisy data\n');
    end
    
    % Runs this code if output_data was not created
    if ~exist('output_data', 'var')
        output_data = Input_data;
    end
       
    if ~no_print
        fprintf('Status:\n')
        fprintf('Total input # beats = %5d\n', size(Input_data, 2));
        fprintf('Total noisy # beats = %5d\n', size(Input_data, 2) - size(output_data, 2));
    end

end