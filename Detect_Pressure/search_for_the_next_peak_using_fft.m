function [MAXIMA_LOCATED_FLAG, ...
            Index_window, ...
            F0] = search_for_the_next_peak_using_fft(...
                                time, signal, ...
                                T_start_point_index, ...
                                MAXIMA_LOCATED_FLAG, ...
                                Index_window, ...
                                duration_for_computing_FFT, ...
                                Allowed_threshold_signal, ...
                                Fs)
    if ~MAXIMA_LOCATED_FLAG
        
        continue_locating_window = true;
        
        counter = 1;
        
        DO_NOT_COMPUTE_FLAG = false;
        
        while continue_locating_window
            
            % Locate the index for computing FFT
            Index_locate_FFT    = time(T_start_point_index) < time & ...
                                            time <= (time(T_start_point_index) + duration_for_computing_FFT);
                                        
            % Time stamp for computing FFT
            T_fft               = time(Index_locate_FFT);
                  
            % IF Time vector is empty, shift the starting point to the next
            % avaiable data
            if isempty(T_fft)
                New_T0              = min(time(time > time(T_start_point_index)));
                T_start_point_index = find(time == New_T0);
                continue;
            end
            
            % Comfirm if sufficient data is available
            if max(T_fft) >= max(time) - duration_for_computing_FFT
                DO_NOT_COMPUTE_FLAG = true;
                break
            end
            
            % Ensure the starting point of time vector is 0 s.
            T_fft               = T_fft - T_fft(1);
            
            % Locate the signal waveform
            Sig_fft             = signal(Index_locate_FFT);

            if any(Allowed_threshold_signal(1) > Sig_fft | Allowed_threshold_signal(2) < Sig_fft)
                T_start_point_index = T_start_point_index + length(T_fft);
                continue_locating_window = true;
                counter = counter + 1;
            else
                continue_locating_window = false;
            end
            
            %if counter == 10
            %    DO_NOT_COMPUTE_FLAG = true;
            %    break;
            %else
            %    DO_NOT_COMPUTE_FLAG = false;
            %end
            
        end
        
        if DO_NOT_COMPUTE_FLAG
            MAXIMA_LOCATED_FLAG = false;
            Index_window = [];
            F0 = [];
            return;
        end
        
        [Samples_beat, F0]  = find_freq_of_signal(Fs, Sig_fft, 0.5, 2, 4096);

        if F0 > 0.5 && F0 <= 2.5
            Index_window        = (T_start_point_index+Samples_beat: T_start_point_index + 2*Samples_beat);
            MAXIMA_LOCATED_FLAG = true;
        else
            MAXIMA_LOCATED_FLAG = false;
        end
    else
        F0 = [];        
    end
    
end