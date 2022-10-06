function [Index_to_search_for_peaks, ...
            Condition, ...
            Er_Msg] = find_index_to_search(signal_subset)


    % Initialize conditions
    Condition = false(7, 1);
    
    Index_to_search_for_peaks(1, 1) = 1; 
    Index_to_search_for_peaks(2, 1) = length(signal_subset);
    
    Er_Msg = {};

    % Starting point of signal subject
    Sig0 = signal_subset(1);

    % Transform the signal into a new domain to locate peaks  
    Y = -1 * abs(signal_subset - Sig0);

    % Find the peaks of the smoothed vector
    [~, Max_Index] = findpeaks(Y);

    if isempty(Max_Index)
        return;
    end

    if length(Max_Index) == 1
        return;
    end
    
    % Quanlity check 1
    % Check if there are more than 2 MAx locations detected
    Condition(1, 1) = length(Max_Index) >= 2;    

    % Quality check 2
    % check if there is a proper minima and maxima in the sected region
    for i = 2:length(Max_Index)
        detect_loc              = [1; Max_Index(i)];
        sig_win                 = signal_subset(detect_loc(1):detect_loc(2));
        [sig_MAX, Index_max]    = max(sig_win);
        Condition(2, 1)         = Index_max >= 10;
        Condition(3, 1)         = Index_max <= (length(sig_win)-10);
        Condition(4, 1)         = sig_win(1) < sig_MAX;
        Condition(5, 1)         = sig_win(end) < sig_MAX; 
        Condition(6, 1)         = abs((sig_win(end) - sig_win(1))/sig_win(1)*100) < 10;

        if all(Condition(2:6))
            break;
        end
    end

    Condition(7, 1) = ~(length(Max_Index) == i);

    Index_to_search_for_peaks = detect_loc;

    Er_Msg = make_error_message(Er_Msg, Condition);
end

function Er_Msg = make_error_message(Er_Msg, Condition)
    if ~Condition(1)
        Er_Msg          = [Er_Msg; {'Not enough Maxima detected from transformed signal'}];
    end

    if ~Condition(2)
        Er_Msg          = [Er_Msg; {'Maxima located closer to the starting point'}];
    end

    if ~Condition(3)
        Er_Msg          = [Er_Msg; {'MAxima located closer to the end point'}];
    end

    if ~Condition(4)
        Er_Msg          = [Er_Msg; {'Located maxima less than starting value of transfomed signal'}];
    end

    if ~Condition(5)
        Er_Msg          = [Er_Msg; {'Located maxima less than ending value of transfomed signal'}];
    end
    
    if ~Condition(6)
        Er_Msg          = [Er_Msg; {'Starting and ending vlaue of the transfomred signal very different'}];
    end

    if ~Condition(7)
        Er_Msg          = [Er_Msg; {'Using the maxima at the end of the signal. Probable error in signal morphology'}];
    end

end
