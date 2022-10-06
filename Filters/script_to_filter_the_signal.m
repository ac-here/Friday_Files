% Remove Nan from the input 
Index_nan           = isnan(Input);
Input(Index_nan)    = nanmean(Input);

% Filtered output  
output              = filtfilt(d,Input);
output(Index_nan)   = nan;