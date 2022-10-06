function detections = update_peak_minima_locations(signal, detections, Fs, Lower_Upper_Bound)

    % Convert signal into column vector
    signal = signal(:);
    
    % Return to the main function if the detections are empty
    if isempty(detections)
        return
    end

    Intial_num_detection = size(detections, 1);
    
    % Remove Probably error detection
    detections = remove_error_detections(signal, detections, Lower_Upper_Bound);
    
    for iteration = 1:100    
        [detections, Abort_Flag] = find_new_maxima_minima(...
                                        signal, detections, ...
                                        Lower_Upper_Bound, Fs, ...
                                        'Based on Mimia locations');
        if Abort_Flag, break; end
    end        
    
    for iteration = 1:100    
        [detections, Abort_Flag] = find_new_maxima_minima(...
                                        signal, detections, ...
                                        Lower_Upper_Bound, Fs, ...
                                        'Based on Amplitude');
        if Abort_Flag, break; end
    end

    % Remove Probably error detection
    detections = remove_error_detections(signal, detections, Lower_Upper_Bound);
   
    %fprintf('Total number of new detections = %d\t', size(detections, 1)-Intial_num_detection);
end

function [detections, Abort_Flag] = find_new_maxima_minima(...
                                        signal, detections, ...
                                        Lower_Upper_Bound, Fs, ...
                                        Method)

    % Get Peak and Foot
    [Peak_Loc, Foot_Loc] = get_Peak_Foot(detections);
        
    % Variabels to save new foot and peaks
    New_detect_foot = [];%nan(1, 1);
    New_detect_peak = [];%nan(1, 1);  
    
    clear Peak_Foot
        
    parfor i = 1:length(Peak_Loc)-1
        Index                   = (Peak_Loc(i):Peak_Loc(i+1));
        Beat_peak_to_peak       = signal(Index);
        Avg_Ht_Beat_start       = 0.75 * (signal(Peak_Loc(i)) - signal(Foot_Loc(i))) + signal(Foot_Loc(i));
        if any(Beat_peak_to_peak <= Lower_Upper_Bound(1) | Beat_peak_to_peak >= Lower_Upper_Bound(2)) 
            continue;
        end
        
        switch Method
            case 'Based on Mimia locations'                
                 Peak_Foot          = locate_Minima_Maxima(signal, Index, Foot_Loc(i+1), Lower_Upper_Bound, Fs);
            case 'Based on Amplitude'
                    Logic_wave  	= (gradient((Beat_peak_to_peak - Avg_Ht_Beat_start) > 0) > 0);
                    Index_located 	= find(Logic_wave, 1, 'first');
                    Temporary_Index = Index(1) + Index_located - 1;
                if Foot_Loc(i+1) >= Temporary_Index
                    Index           = (Temporary_Index-floor(0.5*Fs):Temporary_Index);
                    Peak_Foot       = locate_Minima_Maxima(signal, Index, Foot_Loc(i), Lower_Upper_Bound, Fs);
                else
                    Peak_Foot = [];
                end
            otherwise
        end
        
        if ~isempty(Peak_Foot)
            New_detect_peak = [New_detect_peak; Peak_Foot(1)];
            New_detect_foot = [New_detect_foot; Peak_Foot(2)];
        end
    end
    
    clear Peak_Foot
    
    Num_current_beats   = length(Peak_Loc);  
    Peak_Loc            = [Peak_Loc; New_detect_peak];
    Foot_Loc            = [Foot_Loc; New_detect_foot];
    [~,Idx_sort]        = sort(Peak_Loc, 'ascend');
    Peak_Loc            = Peak_Loc(Idx_sort);
    Foot_Loc            = Foot_Loc(Idx_sort);
    [~, Idx_uni]        = unique(Peak_Loc);
    Peak_Loc            = Peak_Loc(Idx_uni);
    Foot_Loc            = Foot_Loc(Idx_uni);
    Rem_me              = isnan(Peak_Loc)|isnan(Foot_Loc);
    Peak_Loc(Rem_me)    = [];
    Foot_Loc(Rem_me)    = [];

    if (length(Peak_Loc) - Num_current_beats) == 0 
        %fprintf('Num = %d \t', length(Peak_Loc) - Num_current_beats);
        %fprintf('Threshold reached. \n');
        Abort_Flag = true;
    else
        %fprintf('Num = %d \n', length(Peak_Loc) - Num_current_beats);
        Abort_Flag = false;
    end
    
    % Update the detections
    detections = [Peak_Loc Foot_Loc]; 
end

function [Peak_Loc, Foot_Loc] = get_Peak_Foot(detections)
    Peak_Loc = detections(:, 1);
    Foot_Loc = detections(:, 2);
end

function detections = remove_error_detections(signal, detections, Lower_Upper_Bound)

    % Get Peak and Foot
    [Peak_Loc, Foot_Loc] = get_Peak_Foot(detections); 

    % Remove Probably error detection
    Rem_me = false(length(Foot_Loc), 1);
    Rem_me = Rem_me | (Lower_Upper_Bound(1)> signal(Foot_Loc)) | (signal(Foot_Loc) > Lower_Upper_Bound(2));
    Rem_me = Rem_me | (Lower_Upper_Bound(1)> signal(Peak_Loc)) | (signal(Peak_Loc) > Lower_Upper_Bound(2));
    detections(Rem_me, :) = [];
end

function Peak_Foot = locate_Minima_Maxima(signal, Index, Next_Foot, Lower_Upper_Bound, Fs)
    Beat_peak_to_peak       = signal(Index);
    [Val, Min_Index]        = min(Beat_peak_to_peak);
    Min_Index               = Index(1) + Min_Index -1;
    Peak_Foot               = [];
    if any(Beat_peak_to_peak <= Lower_Upper_Bound(1) | Beat_peak_to_peak >= Lower_Upper_Bound(2)) 
        return;
    end
    if Next_Foot ~= Min_Index
        if Val > Lower_Upper_Bound(1)                                
            Index                   = (Min_Index:Min_Index+0.5*Fs);
            Beat_subset             = signal(Index);
            [Val, Max_Index]        = max(Beat_subset);
            Max_Index               = Index(1) + Max_Index -1;                
            if Val < Lower_Upper_Bound(2)
                Peak_Foot(1, 1) = Max_Index;
                Peak_Foot(1, 2) = Min_Index;
            end                
        end
    end
end