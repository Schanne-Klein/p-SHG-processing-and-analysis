%% Réalisation de piles d'images pour chaque canal de détection: 
%% pour chaque z en fonction de l'angle de la polarisation incidente
%% Et somme de toutes les composantes linéaires pour ne pas favoriser
%% d'orientation particulière au niveau imagerie
% Version 2011-08-23

clear all;
close all;
clc;
%% Au labo
%Chargement de l'appli imageJ
javaaddpath 'C:\Users\laboratoire\Desktop\margaux\Codes_Matlab\Traitement données 18-12-2015\mij.jar'
javaaddpath 'C:\Users\laboratoire\Desktop\margaux\Codes_Matlab\Traitement données 18-12-2015\ij.jar'
MIJ.start

%% A la maison
% javaaddpath 'C:\Program Files\MATLAB\R2010b\java\mij.jar'
% javaaddpath 'C:\Program Files\MATLAB\R2010b\java\ij.jar'
% MIJ.start

%% Path Name Parameters
Path = uigetdir('C:\Users\laboratoire\Desktop\margaux\Données', 'Select the data files directory');
%PathW = uigetdir(Path, 'Select the directory to write the new images');
mkdir(strcat(Path,'\Intensity_maps'));
PathW = strcat(Path,'\Intensity_maps');
% Name='d3';

%% Selection des channels
prompt={'CH00 (1:yes 0:no):',...
        'CH01 (1:yes 0:no):',...
        'CH02 (1:yes 0:no):',...
        'CH03 (1:yes 0:no):'};
name='Select channels';
numlines=1;
defaultanswer={'1','1','1','1'};
answer1=inputdlg(prompt,name,numlines,defaultanswer,'on');
channel=str2num(cell2mat((answer1(:))));

%% Static parameters
Gain=14; %14 pour 16-bit images
nb_digit=4;
%PolaXYName='ch00';   %SHG trans X
%FluoName = 'ch01';  %2PEF epi
%PolaYName='ch03';   %SHG trans Y
%PolaEpi='ch02';     %SHG épi
Extension='tif';
prompt={'Enter file name:',...
        'Enter minimum Z position:',...
        'Enter maximum Z position:',...
        'Enter index of the minimum angle:',...
        'Enter index of the maximum angle:'};
name='Input parameters';
numlines=1;
defaultanswer={'d1','1','30','1','19'};
answer=inputdlg(prompt,name,numlines,defaultanswer,'on');

pause(5);

Name = answer{1};

% Zmin = 1;       %z min où l'on regarde la polarimétrie
% Zmax = 21;       %z max où l'on regarde la polarimétrie
Zmin = str2num(answer{2});
Zmax = str2num(answer{3});

% Pour ne pas favoriser d'orientation, somme de -90 à +85°, pas de 5°
% !!! Attention aux bonnes valeurs pour la boucle sur les angles => ii !!!
% AngleMin = -90;
% AngleMax = 80;
% PasAngle = 10;
% nbAngle = (AngleMax-AngleMin)/PasAngle+1; 

agl_min = str2num(answer{4});
agl_max = str2num(answer{5});

if channel(1)==1
    I0 = imread(strcat(Path,'\',Name,'.','ch00','.','0001','.','0001','.',Extension));
elseif channel(2)==1
    I0 = imread(strcat(Path,'\',Name,'.','ch01','.','0001','.','0001','.',Extension));
elseif channel(3)==1
    I0 = imread(strcat(Path,'\',Name,'.','ch02','.','0001','.','0001','.',Extension));
elseif channel(4)==1
    I0 = imread(strcat(Path,'\',Name,'.','ch03','.','0001','.','0001','.',Extension));
end
ImageWidth=size(I0,2);
ImageHeight=size(I0,1);

%%
NbZ = Zmax-Zmin+1;
nb_agl = agl_max-agl_min+1;

h=waitbar(0,'Calcul en cours');

for i = 1:NbZ %boucle sur Z
    
    waitbar(i/NbZ,h);
    Z = i+Zmin-1;
    
%     IXsum = zeros (ImageWidth, ImageHeight);
%     IYsum = zeros (ImageWidth, ImageHeight);
    IXYsum = zeros (ImageWidth, ImageHeight);
    IEpisum = zeros (ImageWidth, ImageHeight);
    
    for ii = agl_min:agl_max %boucle sur les angles
        
        iiAngle=num2str(ii,['%05.' num2str(nb_digit) 'd']);
        numZ=num2str(Z,['%05.' num2str(nb_digit) 'd']);
        if channel(1)==1
            Ich0 = imread(strcat(Path,'\',Name,'.','ch00','.',iiAngle,'.',numZ,'.',Extension));
            Ich0_AngleStack(:,:,ii) = Ich0;
        end
        if channel(2)==1
            Ich1 = imread(strcat(Path,'\',Name,'.','ch01','.',iiAngle,'.',numZ,'.',Extension));
            Ich1_AngleStack(:,:,ii) = Ich1;
        end
        if channel(3)==1
            Ich2 = imread(strcat(Path,'\',Name,'.','ch02','.',iiAngle,'.',numZ,'.',Extension));
            Ich2_AngleStack(:,:,ii) = Ich2;
        end
        if channel(4)==1
            Ich3 = imread(strcat(Path,'\',Name,'.','ch03','.',iiAngle,'.',numZ,'.',Extension));
            Ich3_AngleStack(:,:,ii) = Ich3;
        end
        
    end 
    
    %Pour le Z actuel : somme de toutes les polar en une seule image
    
    if channel(1)==1
        Ich0sum = uint16(sum(Ich0_AngleStack,3));
        MIJ.createImage(Ich0sum);
        ij.IJ.save([strcat(PathW, '\'), Name '.ch00.z' numZ '.tif']);
        ij.IJ.run('Close');
        Ich0stackZ(:,:,i)=Ich0sum;
    end
    if channel(2)==1
        Ich1sum = uint16(sum(Ich1_AngleStack,3));
        MIJ.createImage(Ich1sum);
        ij.IJ.save([strcat(PathW, '\'), Name '.ch01.z' numZ '.tif']);
        ij.IJ.run('Close');
        Ich1stackZ(:,:,i)=Ich1sum;
    end
    if channel(3)==1
        Ich2sum = uint16(sum(Ich2_AngleStack,3));
        MIJ.createImage(Ich2sum);
        ij.IJ.save([strcat(PathW, '\'), Name '.ch02.z' numZ '.tif']);
        ij.IJ.run('Close');
        Ich2stackZ(:,:,i)=Ich2sum;
    end
    if channel(4)==1
        Ich3sum = uint16(sum(Ich3_AngleStack,3));
        MIJ.createImage(Ich3sum);
        ij.IJ.save([strcat(PathW, '\'), Name '.ch03.z' numZ '.tif']);
        ij.IJ.run('Close');
        Ich3stackZ(:,:,i)=Ich3sum;
    end %

end

%% Somme de tous les z
% if channel(1)==1
%     Ich0sumZ = uint16(sum(Ich0stackZ,3));
%     MIJ.createImage(Ich0sumZ);
%     ij.IJ.save([strcat(PathW, '\'), Name '.Ich0sum' '.tif']);
%     ij.IJ.run('Close');
% end
% if channel(2)==1
%     Ich1sumZ = uint16(sum(Ich1stackZ,3));
%     MIJ.createImage(Ich1sumZ);
%     ij.IJ.save([strcat(PathW, '\'), Name '.Ich1sum' '.tif']);
%     ij.IJ.run('Close');
% end
% if channel(3)==1
%     Ich2sumZ = uint16(sum(Ich2stackZ,3));
%     MIJ.createImage(Ich2sumZ);
%     ij.IJ.save([strcat(PathW, '\'), Name '.Ich2sum' '.tif']);
%     ij.IJ.run('Close');
% end
% if channel(4)==1
%     Ich3sumZ = uint16(sum(Ich3stackZ,3));
%     MIJ.createImage(Ich3sumZ);
%     ij.IJ.save([strcat(PathW, '\'), Name '.Ich3sum' '.tif']);
%     ij.IJ.run('Close');
% end

close (h);


   