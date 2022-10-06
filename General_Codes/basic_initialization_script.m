
clearvars -except Loc_Friday_Files Loc_Basic_Scripts; 
close all force; clc;

% % Create a Diary file
if isfile('myDiaryFile.txt')
    diary off;
    copyfile('myDiaryFile.txt', 'myDiaryFile_saved.txt');
    delete('myDiaryFile.txt');
end

diary myDiaryFile.txt
diary on