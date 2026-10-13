%% Réalisation de piles d'images pour chaque canal de détection: 
%% pour chaque z en fonction de l'angle de la polarisation incidente
%% Et somme de toutes les composantes linéaires pour ne pas favoriser
%% d'orientation particulière au niveau imagerie
% Version 2011-08-23

clear all;
close all;
clc;
%% Au labo
javaaddpath 'c:\Program Files\MATLAB\R2015b\java\mij.jar'
javaaddpath 'c:\Program Files\MATLAB\R2015b\java\ij.jar'
MIJ.start
%% A la maison
% javaaddpath 'C:\Program Files\MATLAB\R2010b\java\mij.jar'
% javaaddpath 'C:\Program Files\MATLAB\R2010b\java\ij.jar'
% MIJ.start

%% Path Name Parameters
Path = uigetdir('C:\Users\teulon\Desktop\Claire\Collagene\Polar_linéaire_collagene\', 'Select the data files directory');
PathW = uigetdir(Path, 'Select the directory to write the new images');
% Name='d3';

%% Static parameters
Gain=1;
nb_digit=4;
PolaXYName='ch00';   %SHG trans X
FluoName = 'ch01';  %2PEF epi
%PolaYName='ch03';   %SHG trans Y
PolaEpi='ch02';     %SHG épi
Extension='tif';
prompt={'Enter file name:',...
        'Enter index of the minimum Z position:',...
        'Enter index of the maximum Z position:',...
        'Enter index of the minimum angle:',...
        'Enter index of the maximum angle:'};
name='Input parameters';
numlines=1;
defaultanswer={'860lin','1','51','1','18'};
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

I0 = imread(strcat(Path,'\',Name,'.',PolaXYName,'.','0001','.','0001','.',Extension));
ImageWidth=size(I0,2);
ImageHeight=size(I0,1);
%%
NbZ = Zmax-Zmin+1;
nb_agl = agl_max-agl_min+1;

h=waitbar(0,'Calcul en cours');

for ii = agl_min:agl_max
    waitbar(i/nb_agl,h);
    
    IXYsum = zeros (ImageWidth, ImageHeight);
    IEpisum = zeros (ImageWidth, ImageHeight);      
    
    for i = 1:NbZ
    
        Z = i+Zmin-1;
        %numZ=num2str(z,['%05.' num2str(nb_digit) 'd']);
        iiAngle=num2str(ii,['%05.' num2str(nb_digit) 'd']);
        numZ=num2str(Z,['%05.' num2str(nb_digit) 'd']);
%         IX = imread(strcat(Path,'\',Name,'.',PolaXName,'.',iiAngle,'.',numZ,'.',Extension));
%         IY = imread(strcat(Path,'\',Name,'.',PolaYName,'.',iiAngle,'.',numZ,'.',Extension));
        IXY = imread(strcat(Path,'\',Name,'.',PolaXYName,'.',iiAngle,'.',numZ,'.',Extension));
        IEpi = imread(strcat(Path,'\',Name,'.',PolaEpi,'.',iiAngle,'.',numZ,'.',Extension));
%         IF = imread(strcat(Path,'\',Name,'.',FluoName,'.',iiAngle,'.',numZ,'.',Extension));
        %IXstack(:,:,ii) = IX;
        %IXsum(:,:) = IXsum + IX;
        %IYstack(:,:,ii) = IY;
        %IYsum(:,:) = IYsum + IX;
        IXYstack(:,:,i) = IXY;
        IEpistack(:,:,i) = IEpi;
%         IFluostack(:,:,ii) = IF;
        %IEpisum(:,:) = IEpisum + IEpi;

        %IFstack(:,:,ii) = IF;
        %ISmax = max(max(max(ISstack)));
        %IFmax = max(max(max(IFstack)));

    end 
%     MIJ.createImage([Name 'shgX'],IXstack);
%     ij.IJ.save([PathW, Name 'shgX_z' numZ '.tif']);
%     ij.IJ.run('Close');
%     MIJ.createImage([Name 'shgXsum'],IXsum);
%     ij.IJ.save([Path, Name '_Z.' numZ '_shgXsum' '.tif']);
%     ij.IJ.run('Close');
%     MIJ.createImage([Name 'shgY'],IYstack);
%     ij.IJ.save([PathW, Name 'shgY_z' numZ '.tif']);
%     ij.IJ.run('Close');
%     MIJ.createImage([Name 'shgYsum'],IYsum);
%     ij.IJ.save([Path, Name '_Z.' numZ '_shgYsum' '.tif']);
%     ij.IJ.run('Close');
%     MIJ.createImage([Name 'shgEpi'],IEpistack);
%     ij.IJ.save([PathW, Name 'shgEpi_z' numZ '.tif']);
%     ij.IJ.run('Close');
    IEpisum = uint16(sum(IEpistack,3));
    MIJ.createImage(IEpisum);
    ij.IJ.save([strcat(PathW, '\'), Name '.shgEpisum_Angle' iiAngle '.tif']);
    ij.IJ.run('Close');
    %IXYsum = (sum(IXstack,3) + sum(IYstack,3));
    IXYsum = uint16(sum(IXYstack,3));
    MIJ.createImage(IXYsum);
    ij.IJ.save([strcat(PathW, '\'), Name '.shgXYsum_Angle' iiAngle  '.tif']);
    ij.IJ.run('Close');
%     IFsum = uint16(sum(IFluostack,3));
%     MIJ.createImage(IFsum);
%     ij.IJ.save([strcat(PathW, '\'), Name '.Fluosum_z' numZ  '.tif']);
%     ij.IJ.run('Close');

end
close (h);


   