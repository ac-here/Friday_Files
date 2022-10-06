% Author: Anand Chandrasekhar
% This is a series of basic functions to ensure 
% the quality of the BP beat selected is good.
% Input     time             (Time vector of the single beat)
%           BP_beat          (BP waveform of the single beat)   
%           Samples_per_beat (Num of samples in previous beat)
%           Samples_per_beat_multiplication_factor 
%                           (This number decides the alllowed range of 
%                           samples per beat in the new beat)
%                           (1) Lower threshold 
%                           (2) Upper Threshold                   
%           multimodal_threshold 
%                           This is an input for the function:
%                           check_if_signal_is_multimodal.m
%                           Find the details in the function
%
function Error_message = check_quality_beats(...
                            time, signal_beat, ...
                            Samples_per_beat, ...
                            Samples_per_beat_multiplication_factor, ...
                            multimodal_threshold)
    
    if isempty(time)||isempty(signal_beat)
        Error_message   = 'Empty time/signal beats';
        return; 
    end
    
    if length(time) == 1 || length(signal_beat) == 1
        Error_message   = 'time/signal beats not enough length';
        return; 
    end
    
    if ~exist('Samples_per_beat', 'var')
        Error_message   = 'Samples_per_beat Missing';
        return; 
    end
                
    if length(time) ~= length(signal_beat)
        Error_message   = 'Length of the time/signal beats not matching';
        return;
    end
    
    if length(signal_beat) <= Samples_per_beat_multiplication_factor(1)*Samples_per_beat
        Error_message   = 'Len(signal) <= Factor1*Samples_per_beat';
        return;
    end
    
    if length(signal_beat) >= Samples_per_beat_multiplication_factor(2)*Samples_per_beat
        Error_message   = 'Len(signal) >= Factor2*Samples_per_beat';
        return;
    end
    
    if mean(signal_beat) < 0
        Error_message   = 'Mean(signal) < 0';
        return;
    end
    
    if check_if_signal_is_multimodal(signal_beat, multimodal_threshold, Samples_per_beat)
        Error_message   = 'Beat is multimodal';
        return;
    end
    Error_message = '';
end