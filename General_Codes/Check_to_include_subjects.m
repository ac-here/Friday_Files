% Author: Anand Chandrasekhar
% This script can be used to include subjects
% Input:    ID:             ID of the subject to test for inclusion/exclusion
%           ID_to_include   List of ID of subjects to include
%           Force_Run:      if True, always include the subject
function Flag = Check_to_include_subjects(ID, ID_to_include, Force_Run)
    Flag = true;
    if ~Force_Run
            if ~any((ID == ID_to_include) ==1)
                fprintf('%16s\t', 'Need not analyze');
                Flag = false;
            else
                fprintf('%16s\t', 'Analyze data');
            end
    end
end