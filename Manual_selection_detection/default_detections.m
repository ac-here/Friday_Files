function detections = default_detections(Time, Input_Signal, signal_type, detections)
    if  isempty(detections)
        fprintf('Running the default detection algorithm\n');
        switch signal_type 
            case 'ECG'
                R_wave_index    = find_R_Wave_ECG(Time, Input_Signal, 1);
                detections      = R_wave_index(1).detections;
                detections      = detections(:);
            case 'PPG'
                
            otherwise
                return
        end
    end
end