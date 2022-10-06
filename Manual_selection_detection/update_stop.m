function stop = update_stop(start, Fs, Delta_T, Len_Input)
    stop    = floor(start + Fs * Delta_T);
    if stop >= Len_Input 
        stop = Len_Input;
    end
end