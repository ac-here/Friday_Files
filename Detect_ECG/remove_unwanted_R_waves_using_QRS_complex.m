% Author:   Anand Chandrasekhar
% This function assist detection of R Waves. It checks if the detected R
% wave have a resonable shape QRS complex. The function assumes the width
% of the QRS complex to be 100ms. This code might help to fix minor error 
% in ECG peak detection. 
% Input         R_wave_index_In     (Detected R Wave locations)
%               time                (Units of seconds)
%               ecg                 
% Output        R_wave_index_Out    Modified Peak locations
function R_wave_index_Out         = remove_unwanted_R_waves_using_QRS_complex(...
                                        R_wave_index_In, ...
                                        time, ...
                                        ecg)

    % Sampling Rate of the signal
    Fs                  = 1./mean(diff(time));
    
    % R wave Peak locations
    R_wave_index_Out    = ones(length(R_wave_index_In), 1) * nan;
    
    % Width of QRS complex
	delta_time_QRS  	= 100/1000; 
    delta_Index_half   	= floor(delta_time_QRS * Fs * 0.5);
    
    % Loop over all the detected R waves
    for i = 1:length(R_wave_index_In)
        
        % Minimum and maximum index of the QRS complex 
        I0                  = R_wave_index_In(i) - delta_Index_half;
        I1                  = R_wave_index_In(i) + delta_Index_half;
        
        % Select the index window
        Window_Index        = (I0: I1)';
        
        % Remove index outside the range
        Window_Index(Window_Index <= 0)           = [];
        Window_Index(Window_Index > length(ecg))  = [];
        
        
        % Check the peak of the ROI
        [~, Loc]            = max(ecg(Window_Index));
        
        % Save the peak index.
        R_wave_index_Out(i) = Loc - 1 + Window_Index(1);  
    end
    
    % Save the output
    R_wave_index_Out(isnan(R_wave_index_Out))  = [];
    
    % Remove repeating elements                                    
    R_wave_index_Out              	= unique(R_wave_index_Out);
end