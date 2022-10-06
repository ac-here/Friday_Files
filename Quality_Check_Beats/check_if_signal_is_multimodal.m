% Author: Anand Chandrasekhar
% Use this function to check if the signal is multimodal
% Input:    Input_wave: Single beat of a waveform
%           Threshold:  Allowed percentage relative error to classify a
%                       peak as error. Example: 20
%           Samples_per_beat: Numbers of samples in a beat.
%                             This number should be calculated from
%                             previous beats. 
function Error_flag = check_if_signal_is_multimodal(Input_wave, Threshold, Samples_per_beat)
    
    if length(Input_wave)-1 <= Samples_per_beat
        Error_flag = false;
        return
    else
        [Val, ~]    = findpeaks(Input_wave, 'MinPeakDistance', Samples_per_beat);    
        max_Val     = max(Val);
        Index       = (max_Val - Val)/max_Val * 100 <= Threshold;
        Error_flag  = ~(length(find(Index == 1)) == 1);
    end
end