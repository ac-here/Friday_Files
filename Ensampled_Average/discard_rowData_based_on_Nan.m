function Input_signals = discard_rowData_based_on_Nan(Input_signals, Threshold_percent)
    % Compute the number of nan in every column
    Num_row_nan         = sum(isnan(Input_signals), 2);
        
    % Compute the percentage of nan in every column (aka waveform)
    Percent_nan         = Num_row_nan/size(Input_signals, 2) * 100;
    
    % Locate index of columns to be discarded
    Index_row_more_nan  = Percent_nan>Threshold_percent;
    
    % Discard the columns with more nan than set by threshold
    Input_signals(Index_row_more_nan, :) = nan;  
end