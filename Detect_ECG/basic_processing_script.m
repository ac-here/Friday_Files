% counter
cnt                 = 1;

% Number of samples in a beat
Samples_beat        = HR * Fs;

% Start index of the window
Start_Sample        = 1;

% End index of the window
End_Sample          = Start_Sample + Samples_beat;

R_wave_Out_detect = R_wave_Out(1).detections;

for i = 1:length(R_wave_Out_detect)
    
    Width_index         = floor(250/1000 * Fs);
    
    Window_Index        = (R_wave_Out_detect(i, 1)-Width_index*0.5 :...
                            R_wave_Out_detect(i, 1) + Width_index*0.5)';
                        
    Window_Index(Window_Index<=0)           = [];
    Window_Index(Window_Index>length(ecg))  = [];
    
    [~, Index_Max]      = max(ecg(Window_Index));
    
    R_wave_Out_detect(i, 1)  = Index_Max + Window_Index(1) - 1;
end

% Remove any nans
R_wave_Out_detect(isnan(R_wave_Out_detect))...
                                        = [];
% Remove repeating elements                                    
R_wave_Out_detect              	= unique(R_wave_Out_detect);


