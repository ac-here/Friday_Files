function [Add_features, Rem_features] = intialize_features(signal_type)
    switch signal_type
        case 'ECG'
            Rem_features(1).Max_Index = nan;
            Add_features(1).Max_Index = nan;
        case 'PPG'
            Rem_features(1).Max_Index = nan;
            Rem_features(1).Min_Index = nan;
            Add_features(1).Max_Index = nan;...
            Add_features(1).Min_Index = nan;
        otherwise
    end
end