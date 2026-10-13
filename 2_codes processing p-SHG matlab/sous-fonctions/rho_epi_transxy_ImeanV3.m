 % Fit des données dans une fenêtre, pour différents Z
% détermination de l'orientation de l'angle des fibrilles: phi
% détermination de rho
% Calcul de l'intensité moyenne sur la fenêtre considérée pour le calcul de
% rho
% Modification des paramètres du fit A<0, -Inf<B<Inf et C>0
% est également calculé un terme de contraste au niveau de la variation en
% polarimétrie
% Version du 24/02/2011

clear all;
close all;
clc;
% for polarimetry data analyis
pathname = uigetdir('C:\Users\teulon\Desktop\Claire\Tendon', 'Select the data files directory');
mkdir(strcat(pathname,'\Fit'));
% Path='G:\data\2010-11-15.cornée BDY\d1.20x_8bit\';
% Name = 'd1';
Path_Writing = strcat(pathname,'\Fit');

choice = questdlg('What kind of images ?', ...
	'File name format', ...
	'XYP','XYPZ','XYPZ');
% Handle response
switch choice
    case 'XYP'
        XYP = 1;
    case 'XYPZ'
        XYP = 0;
end

choice = questdlg('Is there multiple channels ?', ...
	'Number of channels', ...
	'1','2','2');
% Handle response
switch choice
    case '1'
        bshg = 0;
    case '2'
        bshg = 1;
end

prompt={'Enter the file name:',...
        'Enter the ROI_X value:',...
        'Enter the ROI_Y value:',...
        'Enter the ROI Width value:',...
        'Enter the ROI_Height value:',...
        'Enter the size of the window:',...
        'Enter the minimum Z position:',...
        'Enter the number of Z positions:',...
        'Enter the value of Z step:'...
        'Enter the minimum angle value:',...
        'Enter the maximum angle value:',...
        'Enter the angle step:',...
        'Enter the pixel rate (kHz):'};
name='Input parameters';
numlines=1;
defaultanswer={'p1','1','1','900','600','5','1','1','0.5','-10','120','10','100'};
answer=inputdlg(prompt,name,numlines,defaultanswer,'on');

Name = answer{1};
 
%Angle parameters
AngleInDegrees='True';
AngleMin=str2num(answer{10});
AngleMax=str2num(answer{11});
AngleStep=str2num(answer{12});
Angle = AngleMin:AngleStep:AngleMax;

ROIX = str2num(answer{2});
ROIY = str2num(answer{3});
ROIWidth = str2num(answer{4});
ROIHeight = str2num(answer{5});

SRate = str2num(answer{13});

PolaXYName='ch00';   %transmitted pola XY
%PolaYName='ch03';   %transmitted pola Y
if bshg==1
PolaEpiName='ch02';   %epi detected
end
Extension='tif';
Gain=14;
Zmin = str2num(answer{7});
NumberImage = str2num(answer{8});
dz=str2num(answer{9});
nb_digit=4;

if XYP==1
I0 = imread(strcat(pathname,'\',Name,'.',PolaXYName,'.','0001','.',Extension));
else
I0 = imread(strcat(pathname,'\',Name,'.',PolaXYName,'.','0001','.','0001','.',Extension));
end
ImageWidth=size(I0,2);
ImageHeight=size(I0,1);

%%
ScanWindowParameters = str2num(answer{6});
%Filt = ones(ScanWindowParameters)/prod(ScanWindowParameters);
NbPixelWidth = floor(ROIWidth/ScanWindowParameters);
NbPixelHeight = floor(ROIHeight/ScanWindowParameters);
[X Y] = meshgrid (1:NbPixelWidth,1:NbPixelHeight);
ROIWindow = [ROIX ROIY ROIWidth ROIHeight];

c = [ROIX, ROIX+ROIWidth, ROIX+ROIWidth, ROIX]; 
r = [ROIY, ROIY, ROIY+ROIHeight, ROIY+ROIHeight];
% Mask = poly2mask(c,r,ImageHeight,ImageWidth); %logic array
   %in um
Zindex = (Zmin:Zmin+NumberImage-1);
Angle = AngleMin/180*pi:AngleStep/180*pi:AngleMax/180*pi;
g = fittype('a*cos(4*(x-phi))+b*cos(2*(x-phi))+c',...
    'coefficients',{'a','b','c','phi'}); 
phimin = 0; 
phimax = pi/2;

h=waitbar(0,'Calcul en cours');
for Depth = 1:NumberImage
    tic
    waitbar(Depth/NumberImage,h);
    for Angle_ind = 1:length(Angle)
        Angle_str = num2str(Angle_ind,['%05.' num2str(nb_digit) 'd']);
        numZ=num2str(Zindex(Depth),['%05.' num2str(nb_digit) 'd']);
        
        if XYP==1
        IXY = imread(strcat(pathname, '\', Name,'.',PolaXYName,'.',Angle_str,'.',Extension));
        if bshg==1
            IEpi = imread(strcat(pathname, '\', Name,'.',PolaEpiName,'.',Angle_str,'.',Extension));
        end
        else
        IXY = imread(strcat(pathname, '\', Name,'.',PolaXYName,'.',Angle_str,'.',numZ ,'.',Extension));
        if bshg==1
            IEpi = imread(strcat(pathname, '\', Name,'.',PolaEpiName,'.',Angle_str,'.',numZ ,'.',Extension));
        end
        end
        %IX = imread(strcat(pathname, '\', Name,'.',PolaXName,'.',Angle_str ,'.',Extension));
%         IXW = IX(ROIY:ROIY+ROIHeight-1,ROIX:ROIX+ROIWidth-1);
%         IYW = IY(ROIY:ROIY+ROIHeight-1,ROIX:ROIX+ROIWidth-1); 
        IXYW = IXY(ROIY:ROIY+ROIHeight-1,ROIX:ROIX+ROIWidth-1);
        PXY(:,:,Angle_ind) = IXYW(:,:);%IXYW = IXW + IYW;
        
        % Elimination des pixels qui saturent 
        %Limite de saturation :
        sat=80/SRate*100*Gain;%*ScanWindowParameters(1)*ScanWindowParameters(2);
        PXY(PXY>sat)=nan;
        
        if bshg==1
        IEpiW = IEpi(ROIY:ROIY+ROIHeight-1,ROIX:ROIX+ROIWidth-1);
        PEpi(:,:,Angle_ind) = IEpiW(:,:);
        PEpi(PEpi>sat)=nan;
        end
      
        %PolaX(Angle_ind,Depth) = sum(sum(uint16(Mask).*IX))/ROIWidth/ROIHeight/Gain;
    end
        
%     ii0 = ceil(ScanWindowParameters(1)/2);ii1 = (size(IXW,1)-ceil(ScanWindowParameters(1)/2));
%     jj0 = ceil(ScanWindowParameters(2)/2);jj1 = (size(IXW,2)-ceil(ScanWindowParameters(2)/2));

    for Angle_ind = 1:length(Angle)
        pXY_savetemp(:,:,Depth,Angle_ind)=filter2(ones(ScanWindowParameters),PXY(:,:,Angle_ind),'valid');
        pXY_save(:,:,Depth,Angle_ind)=pXY_savetemp(1:ScanWindowParameters:end,1:ScanWindowParameters:end,Depth,Angle_ind)/ScanWindowParameters/ScanWindowParameters/Gain;
        clearvars  pXY_savetemp

        if bshg==1
             pEpi_savetemp(:,:,Depth,Angle_ind)=filter2(ones(ScanWindowParameters),PEpi(:,:,Angle_ind),'valid');
             pEpi_save(:,:,Depth,Angle_ind)=pEpi_savetemp(1:ScanWindowParameters:end,1:ScanWindowParameters:end,Depth,Angle_ind)/ScanWindowParameters/ScanWindowParameters/Gain;
             clearvars  pEpi_savetemp
        end 
    end
    IXY_mean(:,:,Depth)=mean( pXY_save(:,:,Depth,:),4);

    if bshg==1
            IEpi_mean(:,:,Depth) = mean(pEpi_save(:,:,Depth,:),4);                
    end


    for ii = 1:NbPixelHeight
        for jj = 1:NbPixelWidth
             pXY(:)=(pXY_save (ii,jj,Depth,:));

                if bshg==1
%
                      pEpi(:)=(pEpi_save (ii,jj,Depth,:));
                end

                     
            % Fit de l'intensité en fonction de la pola en transmission
            [fresult, gof, output] = fit(Angle.', pXY.', g,...
            'Lower',[-Inf, -Inf, 0, phimin],'Upper',[Inf, Inf, Inf, phimax], 'StartPoint', [-2, 2, 2, pi/4]);
            A = fresult.a;
            B = fresult.b;
            C = fresult.c;
%            if (gof.rsquare > 0.8) && (gof.rsquare < 1)                
               if (B>0)
                    phi = fresult.phi;
                    rho = sqrt((A+B+C)/(A-B+C));
                else
                    phi = fresult.phi-pi/2;
                    rho = sqrt((A-B+C)/(A+B+C));
                    B=-B;
                end
%
%                 if (rho<1)
%                     rho = 1/rho;

%             min_fit = C+A-abs(B);
%             max_fit = C-A;
%             gamma = (max_fit-min_fit)/(max_fit+min_fit);
     
              gamma = (abs(B)-2*A)/(2*C-abs(B));
            
              gofr = gof.rsquare;
            
%              else rho = 0;
%                  phi = 0;
%                  gamma=0;
%                  gofr=0;
%              end
            AXY(ii,jj,Depth) = A;
            BXY(ii,jj,Depth) = B;
            CXY(ii,jj,Depth) = C;
            RHOXY(ii,jj,Depth) = rho;
            PHIXY(ii,jj,Depth) = phi*180/pi;
            GOFRXY(ii,jj,Depth) = gofr;
            gammaXY(ii,jj,Depth) = gamma;    
            
%              for Angle_ind = 1:length(Angle) %calcul de l'intnsité en fonction de l'angle dans la fenêtre d'intérêt
                 p=PHIXY(ii,jj)*pi/180;
                 pXY_fit (ii,jj,Depth,:) =AXY(ii,jj,Depth).*cos(4*(Angle-p))+BXY(ii,jj,Depth).*cos(2*(Angle-p))+CXY(ii,jj,Depth);
%              end         
 
             if bshg==1
                        % Fit de l'intensité en fonction de la pola en épi
                        [fresult, gof, output] = fit(Angle.', pEpi.', g,...
                        'Lower',[-Inf, -Inf, 0, phimin],'Upper',[Inf, Inf, Inf, phimax], 'StartPoint', [-2, 2, 2, pi/4]);
                        A = fresult.a;
                        B = fresult.b;
                        C = fresult.c;
            %              if (gof.rsquare > 0.8) && (gof.rsquare < 1)                
                            if (B>0)
                                phi = fresult.phi; 
                                rho = sqrt((A+B+C)/(A-B+C));
                            else               
                                phi = fresult.phi-pi/2;
                                rho = sqrt((A-B+C)/(A+B+C));
                                B=-B;
                            end

            %                 if (rho<1)
            %                     rho = 1/rho;
%                         min_fit = C+A-abs(B);
%                         max_fit = C-A;
%                         gamma = (max_fit-min_fit)/(max_fit+min_fit);
                        
                        gamma = (abs(B)-2*A)/(2*C-abs(B));

                        gofr = gof.rsquare;


            %              else rho = 0; 
            %                 phi = 0;
            %                  gamma=0;
            %                  gofr=0;
            %              end
                        AE(ii,jj,Depth) = A;
                        BE(ii,jj,Depth) = B;
                        CE(ii,jj,Depth) = C;
                        RHOE(ii,jj,Depth) = rho;
                        PHIE(ii,jj,Depth) = phi*180/pi;
                        GOFRE(ii,jj,Depth) = gofr;
                        gammaE(ii,jj,Depth)= gamma;

%              for Angle_ind = 1:length(Angle) %calcul de l'intnsité en fonction de l'angle dans la fenêtre d'intérêt
                 p=PHIE(ii,jj)*pi/180;
                 pEpi_fit (ii,jj,Depth,:) =AE(ii,jj,Depth).*cos(4*(Angle-p))+BE(ii,jj,Depth).*cos(2*(Angle-p))+CE(ii,jj,Depth);
%              end    
 
            end
        end
        
    end
    figure(1);
    quiver (X,Y,GOFRXY(:,:,Depth).*cos(PHIXY(:,:,Depth)*pi/180),GOFRXY(:,:,Depth).*sin(PHIXY(:,:,Depth)*pi/180));
    set(gca,'YDir','reverse');
    axis([0 NbPixelWidth+1 0 NbPixelHeight+1]);

if bshg==1
    figure(2);
    quiver (X,Y,GOFRE(:,:,Depth).*cos(PHIE(:,:,Depth)*pi/180),GOFRE(:,:,Depth).*sin(PHIE(:,:,Depth)*pi/180));
    set(gca,'YDir','reverse');
    axis([0 NbPixelWidth+1 0 NbPixelHeight+1]);
end
    toc
end
close (h);

figure(1);
quiver (X,Y,GOFRXY(:,:,1).*cos(PHIXY(:,:,1)*pi/180),GOFRXY(:,:,1).*sin(PHIXY(:,:,1)*pi/180));
set(gca,'YDir','reverse');
axis([0 NbPixelWidth+1 0 NbPixelHeight+1]);

QXY=GOFRXY;


if bshg==1
QE=GOFRE;
save (strcat(Path_Writing, '\result_fit.mat'), 'PHIE', 'PHIXY', 'RHOE', 'RHOXY',...
    'QE', 'QXY', 'ROIWindow', 'ScanWindowParameters', 'pXY_fit','pEpi_fit','pXY_save','pEpi_save', 'Name', '-mat');

figure(2);
quiver (X,Y,GOFRE(:,:,1).*cos(PHIE(:,:,1)*pi/180),GOFRE(:,:,1).*sin(PHIE(:,:,1)*pi/180));
set(gca,'YDir','reverse');
axis([0 NbPixelWidth+1 0 NbPixelHeight+1]);
else
save (strcat(Path_Writing, '\PSHG_results_fit.mat'), 'PHIXY', 'RHOXY',...
    'QXY', 'ROIWindow', 'ScanWindowParameters', 'pXY_fit','pXY_save', 'Name', '-mat');

figure(2);    
end


