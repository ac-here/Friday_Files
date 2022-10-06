function Add_features = add_marker(Time, Input_Signal, ...
                                    signal_type, New_features, ...
                                    currkey, Index_Location, ...
                                    Add_features, Index_Signal_Window)
                         
    switch signal_type
        case 'ECG'
                if strcmp(currkey, 'return')
                    New_features(1).Max_Index = Index_Location;
                end
                
                plot(Time(New_features(1).Max_Index), ...
                    Input_Signal(New_features(1).Max_Index), ...
                    'xr', 'MarkerSize', 10, 'LineWidth', 5);
                 Add_features(1).Max_Index = New_features(1).Max_Index;                
                
        case 'PPG'
                if strcmp(currkey, 'return')
                    New_features(1).Max_Index   = Index_Location;
                    Input_Signal_ROI            = Input_Signal(Index_Signal_Window(1):Index_Location);
                    [~, Min_Index]              = min(Input_Signal_ROI);
                    Min_Index                   = Min_Index - 1 + Index_Signal_Window(1);
                    New_features(1).Min_Index   = Min_Index;
                end
                plot(Time(New_features(1).Max_Index), ...
                    Input_Signal(New_features(1).Max_Index), ...
                    '-s', 'MarkerEdgeColor','red',...
                    'MarkerSize', 3, 'LineWidth', 5);
                plot(Time(New_features(1).Min_Index), ...
                    Input_Signal(New_features(1).Min_Index), ...
                    '-s', 'MarkerEdgeColor','blue',...
                    'MarkerSize', 3, 'LineWidth', 5);
                Add_features(1).Max_Index = New_features(1).Max_Index;
                Add_features(1).Min_Index = New_features(1).Min_Index;
                
        otherwise
    end
end