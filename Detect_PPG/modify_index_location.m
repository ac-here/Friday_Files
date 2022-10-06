function Index = modify_index_location(Index, Start_Index)
    % This condition is necessary if the peak of the R wave is
    % located at the end of the signal
    if Index > Start_Index(end)
        Index = Start_Index(end);
    elseif Index < 0
        Index = 1;
    end
    
end