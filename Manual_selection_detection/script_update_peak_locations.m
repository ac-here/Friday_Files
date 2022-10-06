%Author: Anand Chandrasekhar
% This script updates the Peak locations based on the 
% manual detection
function detections = script_update_peak_locations(...
                                        detections, ...
                                        Add_features, ...
                                        Rem_features, ...
                                        signal_type)
                                    
    
    
    switch signal_type
        case 'ECG'
            Remove_feature      = Rem_features(1).Max_Index;
            Include_features    = Add_features(1).Max_Index;
        case 'PPG'
            Remove_feature      = [Rem_features(1).Max_Index ...
                                    Rem_features(1).Min_Index];
            Include_features  	= [Add_features(1).Max_Index ...
                                    Add_features(1).Min_Index];
        otherwise
    end
    
    if isempty(Remove_feature) && isempty(Include_features)
        
        fprintf('         Cancelled---------------------\n');
        
    else
        
        fprintf('         Orginal #Max_Detections       = #%d\n', size(detections, 1));
    
        % Remove elements from Max_Detections
        row_to_remove = ones(size(detections, 1), 1) * false;
        for i =1:size(Remove_feature, 1)
            row_to_remove 	= row_to_remove + all(detections == Remove_feature(i, :), 2);
        end
        detections(row_to_remove == 1, :)    = [];

        % Add new peak index elements 
        detections                      = [detections; Include_features];
        [~, sort_index]                 = sort(detections, 'ascend');
        detections                      = detections(sort_index(:, 1), :);
        
        % Remove nan elements
        Index_nan                       = isnan(detections(:, 1));
        detections(Index_nan, :)        = [];

        % Remove repeated elements
        num1                            = size(detections, 1);
        [~, unique_index]               = unique(detections(:, 1));
        detections                      = detections(unique_index, :);
        num2                            = size(detections, 1);
        
        

        fprintf('         #Repeated Peaks               = #%d - #%d = #%d\n', num1, num2, num1-num2);
        fprintf('         Final #Max_Detections         = #%d\n', num2);
        fprintf('         ===========================\n');
        
    end
    
    
end