% Author Anand Chandrasekhar
% Function: Copy a structure from one to another
% Requirement: Structure should be one dimensional
function Struct_destination = copy_struct(...
                                Struct_source, ...
                                Struct_destination, ...
                                Loc_source, ...
                                Loc_destination)

    if isempty(Struct_destination) || isempty(Struct_source)
        Struct_destination = Struct_source;
        return;
    end
    
    if ~(size(Struct_destination, 1) == 1 || ...
            size(Struct_destination, 2) == 1)
        fprintf('Error!! Structure should be one dimensional\n');
        Struct_destination      = [];
        return;
    end
    
    if ~(size(Struct_source, 1) == 1 || ...
            size(Struct_source, 2) == 1)
        fprintf('Error!! Structure should be one dimensional\n');
        Struct_destination      = [];
        return;
    end
            
    if Loc_source <= length(Struct_source)
        feild_name_source       = fieldnames(Struct_source(Loc_source));
    else
        fprintf('Error!! Index of "Source Structure" should be less than [%d]\n', length(Struct_source));        
        return;
    end
    
    if Loc_destination <= length(Struct_destination)
        feild_name_destination  = fieldnames(Struct_destination(Loc_destination));
    else
        Struct_destination(Loc_destination)...
                                = Struct_source(Loc_source);
        return;
    end
    
    feild_name_only_source  = setdiff(feild_name_source, feild_name_destination);
    feild_name_to_copy      = union(...
                                intersect(feild_name_source, feild_name_destination), ...
                                feild_name_only_source);
                            
    feild_name_destination	= reshape(feild_name_destination, [length(feild_name_destination) 1]);
    feild_name_to_copy    	= reshape(feild_name_to_copy, [length(feild_name_to_copy) 1]);
                                
    
    Struct_source       = reshape(Struct_source, [ numel(Struct_source) 1 ] ); 
    Struct_destination  = reshape(Struct_destination, [ numel(Struct_destination) 1 ] ); 

    for j = 1:size(feild_name_to_copy, 1)        
        
        if any(strcmp(feild_name_destination, feild_name_to_copy{j, 1}))  
            if isstruct (Struct_destination(Loc_destination).(feild_name_to_copy{j, 1})) 
                                
                Struct_d    = Struct_destination(Loc_destination).(feild_name_to_copy{j, 1});
                Struct_s	= Struct_source(Loc_source).(feild_name_to_copy{j, 1}); 
                N        	= length(Struct_d);
                
                for i = 1:N
                     save_struct = copy_struct( Struct_s, ...
                                                Struct_d, ...
                                                i, ...
                                                i);
                    Struct_destination(Loc_destination).(feild_name_to_copy{j, 1})...
                                = copy_struct( save_struct, ...
                                                Struct_destination(Loc_destination).(feild_name_to_copy{j, 1}), ...
                                                i, ...
                                                i);
                end  
                
            else 
                Struct_destination(Loc_destination).(feild_name_to_copy{j, 1}) ...
                    = Struct_source(Loc_source).(feild_name_to_copy{j, 1});                 
            end
        else
            Struct_destination(Loc_destination).(feild_name_to_copy{j, 1}) ...
                    = Struct_source(Loc_source).(feild_name_to_copy{j, 1});
        end        
    end
end