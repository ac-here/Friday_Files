function [Data_curr, ...
            Loc_destination]...
                        = copy_file (   File_curr, ...
                                        File_before, ...
                                        struct_name)

    % Data folder
    [filepath, name]    = fileparts(pwd);
    Current_folder      = name;
    Code_Num            = strsplit(Current_folder, 'code_');
    [filepath, protocol]= fileparts(filepath);
    filepath            = fileparts(filepath);
    Data_Home           = fullfile(filepath, ...
                            'Data', ...
                            protocol);  
    Data_folder         = sprintf('Processed_Data_%s', Code_Num{2});       
    Data_curr           = fullfile(Data_Home, Data_folder);
    
    % Check if these folders exist
    if ~isfolder(Data_curr)
        fprintf('Folder created at %s\n', Data_curr);
        mkdir(Data_curr);
    else
        fprintf('Folder already present at %s\n', Data_curr);
    end
    
    file_dir    = dir(Data_Home);
    Table       = struct2table(file_dir);
    Data_Index  = find(strcmp(Table.name, Data_folder)); 
    Data_before = fullfile(Data_Home, Table.name{Data_Index-1});
    
    % Loctaion of the file
    Data_curr   = fullfile(Data_curr, File_curr);
    Data_before = fullfile(Data_before, File_before);

    % If necessary, Copy the base file from previous process. 
    if ~isfile (Data_curr)
        copyfile(Data_before, Data_curr);    
        fprintf('File copied from %s\n', Data_before);
        load(Data_curr, struct_name);
        eval(sprintf('Loc_destination = (1:size(%s, 2))', struct_name));
    else    
        fprintf('File already present at %s\n', Data_curr);   
        
        fprintf('Current file = %s\n', Data_curr);
        load(Data_curr, struct_name);
        eval(sprintf('Mat_curr = %s;', struct_name));
        eval(sprintf('clear %s;', struct_name));
        
        fprintf('Previous file = %s\n', Data_before);
        load(Data_before, struct_name)
        eval(sprintf('Mat_before = %s;', struct_name));
        eval(sprintf('clear %s;', struct_name));
        
        % convert to Table
        Table       = struct2table(Mat_before);

        % Create an array of ID
        D_array    = Table.Change_detected;
        
        % New Index to add
        New_Index       = find(D_array == 1);        
        Loc_destination = nan(length(New_Index), 1);
        cnt             = 1;
        
        for i = 1:length(Mat_before)
            
            % Check if any change detected. If not, 
            % set Change_detected = false.
            if ~any(New_Index == i)  
                if isempty(Mat_curr(i).Change_detected)
                    Mat_curr(i).Change_detected = false;
                end
                continue;
            end
                            
            Logic = strcmp(Table.ID, Mat_before(i).ID);
            if ~any(Logic)
                Loc_destination(cnt)    = size(Mat_curr, 2) + 1;
            else
                Loc_destination(cnt)      = find(Logic);
            end
            
            Mat_curr    = copy_struct(Mat_before, Mat_curr, ...
                                i , Loc_destination(cnt));            
            fprintf('ID = %s is added to the new structure from the previous file\n', ...
                                Mat_curr(Loc_destination(cnt)).ID);
            cnt         = cnt + 1;
        end
        
    end
    
    eval(sprintf('%s = Mat_curr;', struct_name));
    eval(sprintf('save(Data_curr, ''%s'')',struct_name));  
end