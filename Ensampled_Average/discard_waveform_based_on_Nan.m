function Input_signals = discard_waveform_based_on_Nan(Input_signals, Threshold_percent)
% Compute the number of nan in every column
    Num_col_nan         = sum(isnan(Input_signals), 1);
        
    % Compute the percentage of nan in every column (aka waveform)
    Percent_nan         = Num_col_nan/size(Input_signals, 1) * 100;
    
    % Locate index of columns to be discarded
    Index_col_more_nan  = Percent_nan>Threshold_percent;
    
    % Discard the columns with more nan than set by threshold
    Input_signals(:, Index_col_more_nan) = [];  
end