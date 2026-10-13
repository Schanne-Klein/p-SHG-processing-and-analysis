Height =nImage;
Width = mImage;

BinSize = str2double(answer2{1});
%eight_bits_image = str2double(answer{14});
NbPixelWidth = Width-BinSize+1;
NbPixelHeight = Height-BinSize+1;
[X, Y] = meshgrid (1:NbPixelWidth,1:NbPixelHeight);
%ROIWindow = [ROIX ROIY ROIWidth ROIHeight];

%c = [ROIX, ROIX+ROIWidth, ROIX+ROIWidth, ROIX];
%r = [ROIY, ROIY, ROIY+ROIHeight, ROIY+ROIHeight];

% Z range

tilesx=str2double(answer2{2});
tilesy=str2double(answer2{3});
NumberTiles = tilesx*tilesy;
Zmin=str2double(answer2{4});
NumberImages=str2double(answer2{5});
Zindex=(Zmin:Zmin+NumberImages-1);

% Angle parameters
% Angle range when SHG acquisition : 0-180° or 0-360°
% /!\ Do not count two times the point at 0 and 180° or 0 and 360°
% Angles in degrees
AngleMin=str2double(answer2{6});
AngleMax=str2double(answer2{7});
AngleStep=str2double(answer2{8});
polar1=str2double(answer2{9});

% Creation of an FFT folder in the data folder
if sat_cor ==1
    Path_Writing = fullfile(pathname,['FFT_bin' answer2{1} '_satcor']);
else
    Path_Writing = fullfile(pathname,['FFT_bin' answer2{1}]);
end
% if (exist(Path_Writing)==7)
%     path_old=[Path_Writing '_old'];
%     movefile(Path_Writing,path_old);
% end
%mkdir(Path_Writing);

%if polar1==0 %the first polar is removed
%    Angle=(AngleMin+AngleStep)/180*pi:AngleStep/180*pi:(AngleMax+AngleStep)/180*pi;
%else
Angle=AngleMin/180*pi:AngleStep/180*pi:AngleMax/180*pi;
%end
DeltaAngle=AngleMax-AngleMin+AngleStep;

if (length(name_lol)/(length(find(channel~=0))*length(Angle)) < NumberImages)
    if ~mod(length(name_lol)./(length(find(channel~=0))*length(Angle)), 1) % integer
        fprintf(2, '\n You chose %d Z, but I detected only %d :\\  \n', NumberImages, (length(name_lol)./(length(find(channel~=0))*length(Angle))));
        NumberImages = round(length(name_lol)./(length(find(channel~=0))*length(Angle)));
        if NumberImages == 1
            XYP = 1;
        end
        
    else % float
        NumberImages = max(1,floor(length(name_lol)./(length(find(channel~=0))*length(Angle))));
        fprintf(2, '\n Seems there is a problem with the number of files in the folder and the parameters you chose (# of polar, Z ...) \n');
    end
end

% Other parameters
PixRate=str2double(answer2{10});
Extension='tif';
nb_digit=4;


sat=str2double(answer3{1});
%noise=str2double(answer2{2});

pCH_save  = cell(length(channel),1); % yeah, init just to avoid matlab's warning ^^

if ~(DeltaAngle==180 || DeltaAngle==360)
    pCHint = cell(length(channel),1);
end

PCHRAW = cell(length(channel),1);
PCHRAW(channel==1) = {zeros(length(1:Height),length(1:Width), length(Angle))};
ICH_angle = cell(length(channel),1);
ICH_angle(channel==1) = {zeros(length(1:Height),length(1:Width), length(Angle))};


% ***t = Matrix that changes for every depth
a0_CHt = cell(length(channel),1);
a2_CHt = cell(length(channel),1);
a4_CHt = cell(length(channel),1);
b1_CH = cell(length(channel),1);
b2_CH = cell(length(channel),1);

pCHt = cell(length(channel),1);
pCHt(channel==1) =  {zeros(floor(length(1:Height)-BinSize+1),floor(length(1:Width)-BinSize+1), length(Angle))};

rho_CH_FFT = cell(length(channel),1);
ratio_31_15_xyy_yyx = cell(length(channel),1);
ratio_33_15_xxx_yyx = cell(length(channel),1);

PHICHt = cell(length(channel),1);
% RHOCHt = cell(length(channel),1);
pCH_FFTt = cell(length(channel),1);
R2CHt = cell(length(channel),1);

% Matrix that contains every depth
PHICH = cell(length(channel),1);
PHICH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
NAN=NaN(floor(length(1:Height-1))-BinSize+1,floor(length(1:Width-1)-BinSize+1));
RHOCH = cell(length(channel),1);
RHOCH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
R2CH = cell(length(channel),1);
R2CH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
% pCH_FFT = cell(length(channel),1);
% pCH_FFT(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages, length(Angle))};
% pCH = cell(length(channel),1);
% pCH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages, length(Angle))};
% ICH_ang_all = cell(length(channel),1);
% ICH_ang_all(channel==1) =  {zeros(floor(length(1:Height)),floor(length(1:Width)), NumberTiles, NumberImages, length(Angle))};
PCHRAW_all = cell(length(channel),1);
PCHRAW_all(channel==1) =  {zeros(floor(length(1:Height)),floor(length(1:Width)), NumberTiles, NumberImages)};
ICH_mean_noBIN = cell(length(channel),1);
ICH_mean_noBIN(channel==1) = {zeros(floor(length(1:Height)),floor(length(1:Width)), NumberTiles, NumberImages)};
ICH_mean_noBIN_temp = cell(length(channel),1);
ICH_mean_noBIN_temp(channel==1) = {zeros(floor(length(1:Height)),floor(length(1:Width)))};

a0_CH = cell(length(channel),1);
a0_CH(channel==1) =  {zeros(floor(length(1:Height)-BinSize+1),floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
a2_CH = cell(length(channel),1);
a2_CH(channel==1) =  {zeros(floor(length(1:Height)-BinSize+1),floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
a4_CH = cell(length(channel),1);
a4_CH(channel==1) =  {zeros(floor(length(1:Height)-BinSize+1),floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};

tile = 3;
numT = num2str(tile,['%05.' num2str(nb_digit) 'd']);
Depth= 1;
numZ=num2str(Zindex(Depth),['%05.' num2str(nb_digit) 'd']);
channel_num = 1;
Angle_ind=13;
Angle_str=num2str(13,['%05.' num2str(nb_digit) 'd']);
Numero_image=[Angle_str '.'  numZ '.' numT];
ICH_temp = imread(fullfile(pathname, strcat(Name,sprintf('.CH0%d.', channel_num-1),Numero_image,'.',Extension)));
ICH_temp_db=double(ICH_temp);
ICHW_temp_db = ICH_temp_db(1:Height,1:Width);
[mI,nI]=size(ICHW_temp_db);

PCHRAW{channel_num}(:,:,Angle_ind) = ICHW_temp_db;
ICH_angle{channel_num}(:,:,Angle_ind) = ICHW_temp_db;

PCHRAW{channel_num}(PCHRAW{channel_num}>sat)=nan;