%calculates intensity as function of Z and polar from images
clear all;
close all;
% for polarimetry data analyis
Path='C:\Users\Cl\Documents\Pierre\2015_10_14 poumon_BOOP_lame 3_Zone5\XYPZ_Zone5\';
Name = 'XYPZ_Zone5';
%Angle parameters
AngleInDegrees='True';
AngleMin=0;
AngleMax=360;
AngleStep=20;
Angle = AngleMin:AngleStep:AngleMax;
AngleDeg = AngleMin:AngleStep:AngleMax;

PolaXName='ch00';   %transmitted
PolaYName='ch02';   %reflected
Extension='tif';
Gain=1;
NumberImage=1;
DeltaZ=1;
%PolaX=zeros((AngleMax-AngleMin)/AngleStep+1,NumberImage);
%PolaY=zeros((AngleMax-AngleMin)/AngleStep+1,NumberImage);
nb_digit=4;
I0 = imread(strcat(Path,Name,'.',PolaXName,'.','0001','.','0001','.',Extension));
% I0 = imread(strcat(Path,Name,'.',PolaXName,'.','0001','.',Extension));
ImageWidth=size(I0,2);
ImageHeight=size(I0,1);
% diagBBO0.ch00.0006.0002.tif 
%ROI and image parameters in percent
ROIWidth_percent =30;
ROIHeight_percent =30;
ROIWidth=round(ImageWidth*ROIWidth_percent/100);
ROIHeight=round(ImageHeight*ROIHeight_percent/100);
ROIX=round(ImageWidth*(1-ROIWidth_percent/100)/2);
ROIY=round(ImageHeight*(1-ROIHeight_percent/100)/2);

% ROIX = 252;
% ROIY = 162;
% ROIWidth = 45;
% ROIHeight = 18;

Window_ = [ROIX ROIY ROIWidth ROIHeight];

c = [ROIX, ROIX+ROIWidth, ROIX+ROIWidth, ROIX]; 
r = [ROIY, ROIY, ROIY+ROIHeight, ROIY+ROIHeight];
%Mask = poly2mask(c,r,ImageHeight,ImageWidth); %logic array
   %in um

Mask = zeros (ImageHeight, ImageWidth);
            for i1 = ROIX:ROIX+ROIWidth-1
                for j1 = ROIY:ROIY+ROIHeight-1
                    Mask(i1,j1) = 1;
                end
            end

Z = (0:(NumberImage-1))*DeltaZ;

for Angle_ind = 1:length(Angle)
    Angle_str = num2str(Angle_ind,['%05.' num2str(nb_digit) 'd']);
    for Depth = 1:NumberImage
        numZ=num2str(Depth,['%05.' num2str(nb_digit) 'd']);
        IX = imread(strcat(Path, Name,'.',PolaXName,'.',Angle_str ,'.',numZ,'.',Extension));
        %IX = imread(strcat(Path, Name,'.',PolaXName,'.',numZ,'.',Angle_str ,'.',Extension));
%         IX = imread(strcat(Path, Name,'.',PolaXName,'.',Angle_str ,'.',Extension));
        PolaX(Angle_ind,Depth) = sum(sum(uint16(Mask).*IX))/ROIWidth/ROIHeight/Gain;
        IY = imread(strcat(Path, Name,'.',PolaYName,'.',Angle_str ,'.',numZ,'.',Extension));
        %IY = imread(strcat(Path, Name,'.',PolaYName,'.',numZ,'.',Angle_str ,'.',Extension));
%        IY = imread(strcat(Path, Name,'.',PolaYName,'.',Angle_str ,'.',Extension));
  PolaY(Angle_ind,Depth) = sum(sum(uint16(Mask).*IY))/ROIWidth/ROIHeight/Gain;
    end    
end
PolaX = PolaX';
PolaY = PolaY';
Angle = AngleMin/180*pi:AngleStep/180*pi:AngleMax/180*pi;
set(0,'DefaultFigureWindowStyle','docked');

if NumberImage==1
    figure(1);
    polar(Angle, PolaX, '.b');
    figure(2);
    polar(Angle, PolaY, '.r');
else
    figure(1);
    pcolor(AngleDeg, -Z, PolaX);
    shading flat
    figure(2);
    pcolor(AngleDeg, -Z, PolaY);
    shading flat
end
name = Name;
Ang=AngleDeg';
PX=PolaX';
PY=PolaY';

infoF = fopen(strcat(Path,Name,'.','info','.','txt'));
line = [];
while ~strncmp(line, 'Comment :', 9)
    line = fgetl(infoF);
end
fclose(infoF);
Info = line;
data = {Angle, Z, PolaX , PolaY, Window_, Info};
save(strcat(name, '.mat'), 'data');


pol = [Angle', PolaX', PolaY'];
save([Path,'polar'], 'pol', '-ASCII');
%clear all
%load QWERTY.mat
%delete QWERTY.mat

