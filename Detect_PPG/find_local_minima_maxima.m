% Author: Anand Chandrasekhar
% Locates the actual local maxima or minima
% Input:    signal              Input signal
%           Centre_Index        Centre Index of the Local window
%                               It should be a sample point
%           Local_Win_Th        Width of the local window
%                               Units Seconds
%           Fs                  Sampling Rate of the signals
%           Location            = 'Max' : Finds the Maximum
%                               = 'Min' : Finds the Minimum
% Ouput     local_point         Location of the modified feature 
function local_point = find_local_minima_maxima(...
                signal, ...
                Centre_Index, ...
                Local_Win_Th, ...
                Fs, Location)
    
    window_start                = floor(Centre_Index - Local_Win_Th*Fs); 
    window_end                  = floor(Centre_Index + Local_Win_Th*Fs);
    Index_local_Win             = window_start:window_end;
    
    if ~(any(Index_local_Win > length(signal)) || any(Index_local_Win < 1)) 
        switch Location
            case 'Max'
                [~, local_point]    = findpeaks(signal(Index_local_Win));
                local_point         = min(local_point);
            case 'Min'
                [~, local_point]    = findpeaks(-signal(Index_local_Win));
                local_point         = max(local_point);
            otherwise
                fprintf('Error\n');            
        end
        if isempty(local_point)
            local_point         = nan;
        else
            local_point         = Index_local_Win(1) + local_point - 1;
        end
    else
        local_point             = Centre_Index;
    end        
    
    
end
