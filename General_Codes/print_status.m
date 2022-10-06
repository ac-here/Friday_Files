function print_status(Index, Range)

    Max_Range       = max(Range);
    Min_Range       = min(Range);
    Max_Min_Range   = Max_Range - Min_Range;
    
    IndexPercent_25 = floor(0.25 * Max_Min_Range + Min_Range);
    IndexPercent_50 = floor(0.50 * Max_Min_Range + Min_Range);
    IndexPercent_75 = floor(0.75 * Max_Min_Range + Min_Range);
    IndexPercent_100 = floor(1 * Max_Min_Range + Min_Range);
    
    switch Index
        case IndexPercent_25
                fprintf('25%%\t');
        case IndexPercent_50
                fprintf('50%%\t');
        case IndexPercent_75
                fprintf('75%%\t');
        case IndexPercent_100
                fprintf('100%%\t');
        otherwise
    end
    
end