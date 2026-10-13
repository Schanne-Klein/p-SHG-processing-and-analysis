%Written by Clothilde 2021-11-18

clearvars;
close all;
clc;
%% path for the sub-functions
path_computer = 'D:\Vaky\codes\Vaky 2026 codes processing matlab V2'; %path where the sous-fonctions are
addpath(fullfile(path_computer, 'Sous-fonctions'));

path_dflt_uigetdir = 'D:\Vaky\D14_and_PTB_samples\2026-09-29-samplesJuly_D14PTB\D14F_slide3_S5\mp1\data_satcorr'; % path of the data
%7*9

% Selection of the data (dialog box)
pathname = uigetdir(path_dflt_uigetdir);
if ~pathname
    fprintf(2, '\n User canceled : program ends. Walou \n');
    return
end



%% list of the files (images)
%L=dir([pathname,'\*.ch00.0001.tif']);
lis_files=dir([pathname,'\*.tif']);
L = lis_files(1);

% info about resizing, choose the right objective
objectiveList = {'25xO_Water', '20xZ_Water', '20xO_Air', '20xZ_Air'};
[objIdx, ok] = listdlg( ...
    'PromptString', 'Select objective (only for scaling):', ...
    'SelectionMode', 'single', ...
    'ListString', objectiveList);

if ~ok
    return  % user cancelled
end

objective = objectiveList{objIdx};

% Sampling 
prompt = {'Sampling (only for scaling):'};
name = 'Rescaling info';
defaultanswer = {'5'};
sampling = inputdlg(prompt, name, 1, defaultanswer, 'on');




%% choice of the mode of acquisition
choice = questdlg('What kind of images ?', ...
    'File format', ...
    'XYP','XYPZ','Mosaic XYPZ', 'Mosaic XYPZ');
switch choice
    case 'XYP'
        mode = 1;
    
    case 'XYPZ'
        mode = 0;
        
    case 'Mosaic XYPZ'
        mode = 2;
end

% choose the channels to consider in the process/analysis
prompt={'CH00 (1:yes 0:no):',...
    'CH01 (1:yes 0:no):',...
    'CH02 (1:yes 0:no):',...
    'CH03 (1:yes 0:no):'};
name='Select channels';
numlines=1;
defaultanswer={'1','1','1','1'};
answer1=inputdlg(prompt,name,numlines,defaultanswer,'on');
channel=str2double(answer1);

list = dir(fullfile(pathname, '*.tif'));
name_lol = {list.name};

% Part of the code getting the "prefix" of the file names
ct = 1; 
while ~strcmp(name_lol{1}(ct), '.')
    ct = ct+1;
end
name_dflt=name_lol{1}(1:ct-1); 


InfoImage=imfinfo(fullfile(pathname, name_lol{1})); % disp a warning 'Division by zero when processing YResolution'
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;


% Acquisition info to enter
prompt={
    'Binning size:',...
     'Number of tiles in x (if Mosaic XYPZ):',...
    'Number of tiles in y (if Mosaic XYPZ):',...
    'Minimum Z position:',...nam
    'Number of Z positions:',...
    'Minimum angle value:',...
    'Maximum angle value:',...
    'Angle step:',...
    'Keep the 1st polar (1:yes 0:no):'};

name='Input processing parameters';
numlines=1;

defaultanswer={'2','1','1','1','1','0','170','10','1'};
answer_acquis=inputdlg(prompt,name,numlines,defaultanswer,'on');

% entering info for analysis: ranges of R2 filtering and whether we want to
% display the figures during the code
name='Input analysis parameters';
prompt={'Lower R2 threshold:',...
    'Upper R2 threshold:',...
    'Figure display ?'};
numlines=1;
defaultanswer={'0.5','1','1'};
answer_anal=inputdlg(prompt,name,numlines,defaultanswer,'on');


% Regetting prefix (to make sure, when many images)

for i=1:length(L)
    
    Name_all=L(i).name;

    ct = 1;
    while ~strcmp(Name_all(ct), '.')
        ct = ct+1;
    end
    Name=Name_all(1:ct-1); 

    list = dir(fullfile(pathname, [Name '*.tif']));
    name_lol = {list.name}; 
    
    ct = 1;
    while ~strcmp(name_lol{1}(ct), '.')
        ct = ct+1;
    end
    Name=name_lol{1}(1:ct-1); 


    
%% calling the code for processing (saved in matrices .mat)

Path_Writing = PSHG_FFT_Process_function_Vaky2026(pathname,channel, answer_acquis, name_lol, mode, Name, mImage, nImage);

%% calling the code for saving images out of these matrices
PSHG_saving_function_Vaky2026(Path_Writing,answer_acquis, answer_anal,sampling, objective, Name, mode)



end





