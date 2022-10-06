function start = decrement_starting_point(...
                    start, ...
                    Delta_T, ...
                    Fs)

    % Update the starting point of the display window
    start    = start - floor(Fs * Delta_T);

    % Check this condition to make sure we are withtin the range of the 
    % array index
    if start < 1
        start = 1;
    end
end