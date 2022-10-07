% Author: Anand Chandrasekhar
% Locates the actual local maxima or minima
% Input:    signal              Input signal
%           Centre_Index        Centre Index of the Local window
%                               It should be a sample point. It could be
%                               the detected minima or maxima
%           Local_Win_Th        Width of the local window
%                               Units Seconds
%           Fs                  Sampling Rate of the signals
%           Location            = 'Max' : Finds the Maximum
%                               = 'Min' : Finds the Minimum
% Ouput     local_point         Location of the modified feature 
function [local_point, ...
            change_located] = find_local_minima_maxima(...
                                signal, ...
                                Centre_Index, ...
                                Local_Win_Th, ...
                                Fs, Location, ...
                                Lower_Upper_Bound)

    if ~exist('Lower_Upper_Bound', 'var')
        Lower_Upper_Bound = [-inf inf];
    end

    Current_value               = signal(Centre_Index);
    window_start                = floor(Centre_Index - Local_Win_Th*Fs); 
    window_end                  = floor(Centre_Index + Local_Win_Th*Fs);
    Index_local_Win             = window_start:window_end;

    % Initialize the variabels
    local_point                 = Centre_Index;
    change_located              = false;
    
    if ~(any(Index_local_Win > length(signal)) || any(Index_local_Win < 1)) 
        switch Location
            case 'Max'

                %plot(signal); hold on;
                %plot(Index_local_Win, signal(Index_local_Win), '-k', 'LineWidth', 3); 

                [Max_Val, local_point]      = max(signal(Index_local_Win));
                [local_point, Min_Idx]      = min(local_point);
                Max_Val                     = Max_Val(Min_Idx);

                %plot(Centre_Index, Current_value, 'xk', 'LineWidth', 3);
                %plot(Index_local_Win(local_point), Max_Val, 'or', 'MarkerFaceColor','r'); hold off; 

                if (Current_value > Max_Val) || (Max_Val >= Lower_Upper_Bound(2)) || local_point == 1 || local_point == length(Index_local_Win)
                    local_point = [];
                end

            case 'Min'
                [Min_val, local_point]      = min(signal(Index_local_Win));
                [local_point, Max_Idx]      = max(local_point);
                Min_val                     = Min_val(Max_Idx);
                if (Current_value < Min_val) || (Min_val <= Lower_Upper_Bound(1)) || local_point == 1 || local_point == length(Index_local_Win)
                    local_point = [];
                end
            otherwise
                fprintf('Error\n');            
        end
        if isempty(local_point)
            local_point         = nan;
            change_located      = false;
        else
            local_point         = Index_local_Win(1) + local_point - 1;
            if Centre_Index ~= local_point
                change_located  = true;
            else
                change_located  = false;
            end
        end
    else
        local_point             = Centre_Index;
        change_located          = false;
    end            
end
