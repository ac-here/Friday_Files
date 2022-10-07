function detections = check_if_maxima_minima_correct(signal, detections, Lower_Upper_Bound)

    % Convert signal into column vector
    signal = signal(:);
    
    % Return to the main function if the detections are empty
    if isempty(detections)
        return
    end

    % Foot locations
    minima = detections(:, 2);

    % Peak locations
    maxima = detections(:, 1);

    % Confirm if the located maxima is good
    parfor i = 1:length(minima)
        
        % Index Window
        Crop_sig = signal(minima(i):maxima(i));       

        % Locate maxima
        [Max_val, max_Idx] = max(Crop_sig);

        if Max_val > signal(maxima(i)) & Max_val < Lower_Upper_Bound(2)
            maxima(i) = minima(i) + max_Idx - 1;
        end
            
    end

    detections = [maxima minima];

end


