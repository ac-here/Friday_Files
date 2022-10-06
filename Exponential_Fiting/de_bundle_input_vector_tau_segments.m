function [Pinf, T] = de_bundle_input_vector_tau_segments(Input)    

    Pinf    = Input(1);
    T       = nan(length(Input) - 1, 1);
    
    for i = 2:length(Input)
        T(i-1, 1) = Input(i);
    end
    
end