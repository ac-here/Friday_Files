function [output, Min_val, Max_val] = perform_Min_Max_Normalization(Input)
    
    Min_val = nanmin(Input);
    Max_val = nanmax(Input); 
    output  = (Input - min(Input))./(max(Input) - min(Input));
    
end