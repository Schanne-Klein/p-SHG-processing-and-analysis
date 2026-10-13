function Path_Writing = PSHG_FFT_Process_function_Vaky2026(pathname,channel, answer_acquis, name_lol, mode, Name, mImage, nImage)

%% Information about the data %%

Height =nImage;
Width = mImage;

BinSize = str2double(answer_acquis{1});
NbPixelWidth = Width-BinSize+1;
NbPixelHeight = Height-BinSize+1;
[X, Y] = meshgrid (1:NbPixelWidth,1:NbPixelHeight);

% Z range

tilesx=str2double(answer_acquis{2});
tilesy=str2double(answer_acquis{3});
NumberTiles = tilesx*tilesy;
Zmin=str2double(answer_acquis{4});
NumberImages=str2double(answer_acquis{5});
Zindex=(Zmin:Zmin+NumberImages-1);

% Angle parameters
% Angle range when SHG acquisition : 0-180° or 0-360°
% /!\ Do not count two times the point at 0 and 180° or 0 and 360°
% Angles in degrees
AngleMin=str2double(answer_acquis{6});
AngleMax=str2double(answer_acquis{7});
AngleStep=str2double(answer_acquis{8});
polar1=str2double(answer_acquis{9});

% Creation of an FFT folder in the data folder

Path_Writing = fullfile(pathname,['FFT_bin' answer_acquis{1}]);

mkdir(Path_Writing);


Angle=AngleMin/180*pi:AngleStep/180*pi:AngleMax/180*pi;
DeltaAngle=AngleMax-AngleMin+AngleStep;

if (length(name_lol)/(length(find(channel~=0))*length(Angle)) < NumberImages)
    if ~mod(length(name_lol)./(length(find(channel~=0))*length(Angle)), 1) % integer
        fprintf(2, '\n You chose %d Z, but I detected only %d :\\  \n', NumberImages, (length(name_lol)./(length(find(channel~=0))*length(Angle))));
        NumberImages = round(length(name_lol)./(length(find(channel~=0))*length(Angle)));
        if NumberImages == 1
            mode = 1;
        end
        
    else % float
        NumberImages = max(1,floor(length(name_lol)./(length(find(channel~=0))*length(Angle))));
        fprintf(2, '\n Seems there is a problem with the number of files in the folder and the parameters you chose (# of polar, Z ...) \n');
    end
end

% Other parameters
Extension='tif';
nb_digit=4;


pCH_save  = cell(length(channel),1); % yeah, init just to avoid matlab's warning ^^

if ~(DeltaAngle==180 || DeltaAngle==360)
    pCHint = cell(length(channel),1);
end

PCHRAW = cell(length(channel),1);
PCHRAW(channel==1) = {zeros(length(1:Height),length(1:Width), length(Angle))};
ICH_angle = cell(length(channel),1);
ICH_angle(channel==1) = {zeros(length(1:Height),length(1:Width), length(Angle))};

% ***t = Matrix that changes for every depth and tile
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
pCH_FFTt = cell(length(channel),1);
R2CHt = cell(length(channel),1);

% Matrix that contains every depth and tile
PHICH = cell(length(channel),1);
PHICH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
RHOCH = cell(length(channel),1);
RHOCH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};
R2CH = cell(length(channel),1);
R2CH(channel==1) =  {zeros(floor(length(1:Height))-BinSize+1,floor(length(1:Width)-BinSize+1), NumberTiles, NumberImages)};

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

%% Loop on every tile and Depth%%
totalSteps = NumberTiles * NumberImages;
currentStep = 0;

h = waitbar(0, 'Starting processing...');
for tile=1:NumberTiles
    numT = num2str(tile,['%05.' num2str(nb_digit) 'd']);
    
    for Depth=1:NumberImages
        % Waiting bar update
        currentStep = currentStep + 1;
        progress = currentStep / totalSteps;
        
        waitbar(progress, h, sprintf( ...
            'Tile %d/%d – Z %d/%d (%.1f%%)', ...
            tile, NumberTiles, Depth, NumberImages, progress*100));

        tic
        numZ=num2str(Zindex(Depth),['%05.' num2str(nb_digit) 'd']);

            for channel_num = 1:2 % loop on every channel
                    % PCH0iRAW : 3D stack with the images at all the angles
                    % for one Z and tile
                if channel(channel_num) % if the channel is considered
                    % Loop on every angle to build the 3D stack PCH0iRAW
                    for Angle_ind=1:length(Angle)

                        if (polar1==0 && Angle_ind==1) % The last polar (at 180° or 360°) is set at the first place
                            if AngleMax==170
                                Angle_str=num2str(19,['%05.' num2str(nb_digit) 'd']);
                            elseif AngleMax==350
                                Angle_str=num2str(37,['%05.' num2str(nb_digit) 'd']);
                            else
                                Angle_str=num2str(1,['%05.' num2str(nb_digit) 'd']);
                            end
                        else
                            Angle_str=num2str(Angle_ind,['%05.' num2str(nb_digit) 'd']);

                        end

                        % Name of the images depending on the mode chosen
                        % (extractin the polarization angle and the Z plane-tile if it applies)
                        if mode==1
                            Numero_image=Angle_str;
                        elseif mode==0 
                            Numero_image=[Angle_str '.' numZ];
                        elseif mode==2 
                            Numero_image=[Angle_str '.'  numZ '.' numT];
                        end

                        % Loading images, taking the good ROI
                        ICH_temp = imread(fullfile(pathname, strcat(Name,sprintf('.CH0%d.', channel_num-1),Numero_image,'.',Extension)));
                        ICH_temp_db=double(ICH_temp);
                        ICHW_temp_db = ICH_temp_db(1:Height,1:Width);
                        [mI,nI]=size(ICHW_temp_db);

                        PCHRAW{channel_num}(:,:,Angle_ind) = ICHW_temp_db;
                        ICH_angle{channel_num}(:,:,Angle_ind) = ICHW_temp_db;
                        
                        clearvars  ICH_temp ICHW_temp_db

                        % Image binning
                        pCH_savetemp = pCH_save{channel_num};
                        pCH_savetemp(:,:,Angle_ind)=filter2(ones(BinSize),PCHRAW{channel_num}(:,:,Angle_ind),'valid');
                        pCHt{channel_num}(:,:,Angle_ind)=pCH_savetemp(1:end,1:end,Angle_ind)/BinSize/BinSize;

                        clearvars  pCH_savetemp


                    end

                    % Mean on the third dimension (angle) : intensity map for the Z and tile!
                    ICH_mean_noBIN_temp{channel_num}=squeeze(mean(ICH_angle{channel_num},3));


                    if DeltaAngle==180

                        FC_CH_temp=fft(pCHt{channel_num},[],3); % FFT along the third dimension (angle), dim=3.
                        a0_CHt{channel_num} = abs(squeeze(FC_CH_temp(:,:,1))); % "squeeze" makes a0 become a 2D matrix

                        %
                    elseif DeltaAngle==360

                        FC_CH_temp=fft(pCHt{channel_num},[],3);
                        a0_CHt{channel_num} = abs(squeeze(FC_CH_temp(:,:,1)));


                    end




                    %% Saving results for the 2PEF  channels %%               
                    %Multplication my 18!! equivalent to the intensity summed over all polarizations
                    ICH_mean_noBIN{channel_num}(:,:,tile,Depth) = 18.*ICH_mean_noBIN_temp{channel_num};
                    a0_CH{channel_num}(:,:,tile,Depth) = a0_CHt{channel_num};

                    % Maxime : I chose to save the variables with the name of the channel, so I need to split here the different cases. That way, the result of this code can be put in the old code, and if results matrices from different channels are opened at the same time, they do not overwrite.
                    % I put the commented part after if you want to avoid this splitting.

                    if tile==NumberTiles
                        %Saving in .mat
                        t2=tic;
                        switch channel_num
                            case 2
                                INTCH01_sum_nobin = ICH_mean_noBIN{channel_num};  a0_CH01 =  a0_CH{channel_num};
                                save (fullfile(Path_Writing, ['\' Name '.result_FFT_CH01.mat']), 'INTCH01_sum_nobin', 'a0_CH01','-mat');
                            case 1
                                INTCH00_sum_nobin = ICH_mean_noBIN{channel_num}; a0_CH00 =  a0_CH{channel_num};
                                save (fullfile(Path_Writing, ['\' Name '.result_FFT_CH00.mat']), 'INTCH00_sum_nobin', 'a0_CH00', '-mat');
                        end
                        
                        t2 = toc(t2);
                        fprintf('\n The final saving in big matrices lasted %.1f seconds\n', t2);
                    end


                end
            end

            for channel_num = [3, 4] % loop on every channel
                    % PCH0iRAW : 3D stack with the images at all the angles
                    % for one Z and tile
                if channel(channel_num) % if the channel is considered
                    % Loop on every angle to build the 3D stack PCH0iRAW
                    for Angle_ind=1:length(Angle)

                        if (polar1==0 && Angle_ind==1) % The last polar (at 180° or 360°) is set at the first place
                            if AngleMax==170
                                Angle_str=num2str(19,['%05.' num2str(nb_digit) 'd']);
                            elseif AngleMax==350
                                Angle_str=num2str(37,['%05.' num2str(nb_digit) 'd']);
                            else
                                Angle_str=num2str(1,['%05.' num2str(nb_digit) 'd']);
                            end
                        else
                            Angle_str=num2str(Angle_ind,['%05.' num2str(nb_digit) 'd']);

                        end

                        % extracting the polarization angle value, z plane
                        % and tile number depending on the mode
                        if mode==1
                            Numero_image=Angle_str;
                        elseif mode==0 
                            Numero_image=[Angle_str '.' numZ];
                        elseif mode==2 
                            Numero_image=[Angle_str '.'  numZ '.' numT];
                        end


                        % Loading images, taking the good ROI

                        ICH_temp = imread(fullfile(pathname, strcat(Name,sprintf('.CH0%d.', channel_num-1),Numero_image,'.',Extension)));
                        ICH_temp_db=double(ICH_temp);
                        ICHW_temp_db = ICH_temp_db(1:Height,1:Width);
                        [mI,nI]=size(ICHW_temp_db);

                        PCHRAW{channel_num}(:,:,Angle_ind) = ICHW_temp_db;
                        ICH_angle{channel_num}(:,:,Angle_ind) = ICHW_temp_db;
                      
                        clearvars  ICH_temp ICHW_temp_db

                        % Image binning 
                        pCH_savetemp = pCH_save{channel_num};
                        pCH_savetemp(:,:,Angle_ind)=filter2(ones(BinSize),PCHRAW{channel_num}(:,:,Angle_ind),'valid');

                        pCHt{channel_num}(:,:,Angle_ind)=pCH_savetemp(1:end,1:end,Angle_ind)/BinSize/BinSize;

                        clearvars  pCH_savetemp

                    end

                    % Mean on the third dimension (angle) : intensity map for the Z !
                    ICH_mean_noBIN_temp{channel_num}=squeeze(mean(ICH_angle{channel_num},3));
  

                    % FFT coefficients computation according to the angle range (180° or 360°).
                    if DeltaAngle==180

                        FC_CH_temp=fft(pCHt{channel_num},[],3); % FFT along the third dimension (angle), dim=3.
                        a0_CHt{channel_num} = abs(squeeze(FC_CH_temp(:,:,1))); % "squeeze" makes a1_CH00 become a 2D matrix
                        a2_CHt{channel_num} = abs(2*squeeze(FC_CH_temp(:,:,2)));
                        a4_CHt{channel_num} = -abs(2*squeeze(FC_CH_temp(:,:,3)));
                        b1_CH{channel_num} = 2*squeeze(FC_CH_temp(:,:,2));
                        b2_CH{channel_num} = 2*squeeze(FC_CH_temp(:,:,3));

                        %
                    elseif DeltaAngle==360

                        FC_CH_temp=fft(pCHt{channel_num},[],3);
                        a0_CHt{channel_num} = abs(squeeze(FC_CH_temp(:,:,1)));
                        a2_CHt{channel_num} = abs(2*squeeze(FC_CH_temp(:,:,3)));
                        a4_CHt{channel_num} = -abs(2*squeeze(FC_CH_temp(:,:,5)));
                        b1_CH{channel_num} = 2*squeeze(FC_CH_temp(:,:,3));
                        b2_CH{channel_num} = 2*squeeze(FC_CH_temp(:,:,5));


                        % When the angle range is neither 180° nor 360° --> interpolation (no extrapolation!)
                    else
                        Angleint = AngleMin/180*pi:AngleStep/180*pi:(180+AngleMin-AngleStep)/180*pi;
                        %end
                        for ii=1:NbPixelHeight
                            for jj=1:NbPixelWidth

                                pCHint{channel_num}(ii,jj,:)=interp1(Angle,pCHt{channel_num}(ii,jj,:),Angleint,'spline','extrap');

                            end
                        end
                        % Same computation than before, but here with the interpolated pCH0i

                        FC_CH=fft(pCHint{channel_num},[],3);
                        a0_CHt{channel_num} = abs(squeeze(FC_CH(:,:,1)));
                        a2_CHt{channel_num} = abs(2*squeeze(FC_CH(:,:,2)));
                        a4_CHt{channel_num} = -abs(2*squeeze(FC_CH(:,:,3)));
                        b1_CH{channel_num} = 2*squeeze(FC_CH(:,:,2));
                        b2_CH{channel_num} = 2*squeeze(FC_CH(:,:,3));

                    end
                    %%%%%%%%%%%%        CH0%d        %%%%%%%%%%%%

                    %% Calculation of Phi

                    % cf OE 2010 ICFO
                    phi_CH_1=-angle(b1_CH{channel_num})/2*180/pi; % in [-pi/2, pi/2]
                    phi_CH_2=(-angle(b2_CH{channel_num})-pi)/4*180/pi; % Vaky's version: ang instead of atan


                    only_phi1 = 0;
                    switch only_phi1
                        case 1
                            phi_CH_FFT = phi_CH_1;
                        case 0 % phi1 & phi2
                            fprintf(2, '\n warning : phi1&phi2 used ! \n');
                            phi_CH_200=phi_CH_2; % phi2 non recalé
                            % cf Brasselet JOSAA 2016
                            corr_phi2 = 3;
                            switch corr_phi2
                                case 1 % recalage brutal (donne des trous)
                                    phi_CH_200=phi_CH_2;
                                    phi_CH_2(phi_CH_2<0 & phi_CH_2>=-45 & phi_CH_1>45)=phi_CH_2(phi_CH_2<0 & phi_CH_2>=-45 & phi_CH_1>45) + 2*45;
                                    phi_CH_2(phi_CH_2>0 & phi_CH_2<=45 & phi_CH_1<-45)=phi_CH_2(phi_CH_2>0 & phi_CH_2<=45 & phi_CH_1<-45) - 2*45;

                                    phi_CH_2(phi_CH_2<0 & phi_CH_2>-45 & phi_CH_1<-45)=phi_CH_2(phi_CH_2<0 & phi_CH_2>-45 & phi_CH_1<-45) - 45;
                                    phi_CH_2(phi_CH_2>0 & phi_CH_2<45 & phi_CH_1>45)=phi_CH_2(phi_CH_2>0 & phi_CH_2<45 & phi_CH_1>45) + 45;

                                    phi_CH_2(phi_CH_2<0 & phi_CH_2>-45 & phi_CH_1<45 & phi_CH_1>0)=phi_CH_2(phi_CH_2<0 & phi_CH_2>-45 & phi_CH_1<45 & phi_CH_1>0) + 45;
                                    phi_CH_2(phi_CH_2>0 & phi_CH_2<45 & phi_CH_1<0 & phi_CH_1>-45)=phi_CH_2(phi_CH_2>0 & phi_CH_2<45 & phi_CH_1<0 & phi_CH_1>-45) - 45;

                                case 2 % Claire
                                    phi_CH_diff=phi_CH_2-phi_CH_1;
                                    phi_CH_2UP=phi_CH_2-45; %%phi_CH00_diff>0
                                    phi_CH_2UP(phi_CH_diff(:,:)<0)=0;
                                    phi_CH_2DOWN=phi_CH_2+45; %%phi_CH00_diff<0
                                    phi_CH_2DOWN(phi_CH_diff(:,:)>0)=0;
                                    phi_CH_2 = phi_CH_2UP+phi_CH_2DOWN;

                                case 3 % JOSAA 2016

                                    for ii = 1:size(phi_CH_2, 1)
                                        for jj = 1:size(phi_CH_2, 2)
                                            phi_CH_2_mm = phi_CH_2(ii,jj);
                                            % %                                     mm_mat(ii,jj) = 0;
                                            %for mm=[-2, -1, 1, 2]
                                            for mm=[-1, 1]
                                                %if ((abs(phi_CH_1(ii,jj)-(phi_CH_2(ii,jj) + mm*45)) < abs(phi_CH_1(ii,jj)-phi_CH_2_mm)))% && ((phi_CH_2(ii,jj) + mm*45) <= 90) && ((phi_CH_2(ii,jj) + mm*45) >= -90))
                                                    %phi_CH_2_mm = phi_CH_2(ii,jj) + mm*45;
                                                    % %                                             mm_mat(ii,jj) = mm;
                                                 if ((abs(phi_CH_1(ii,jj)-(phi_CH_2(ii,jj) + mm*90)) < abs(phi_CH_1(ii,jj)-phi_CH_2_mm)))% && ((phi_CH_2(ii,jj) + mm*45) <= 90) && ((phi_CH_2(ii,jj) + mm*45) >= -90))
                                                    phi_CH_2_mm = phi_CH_2(ii,jj) + mm*90;
                                                end
                                            end
                                            phi_CH_2(ii,jj) = phi_CH_2_mm;
                                        end
                                    end
       

                            end

                            eta_CH=a2_CHt{channel_num}.^2./(a2_CHt{channel_num}.^2+4.*a4_CHt{channel_num}.^2);
                            phi_CH_FFT=(eta_CH.*phi_CH_1+(1-eta_CH).*phi_CH_2);
                            % because phi_CH_2 can be above 90 or below -90
                            if corr_phi2 == 3
                                phi_CH_FFT(phi_CH_FFT>90) = phi_CH_FFT(phi_CH_FFT>90) - 180;
                                phi_CH_FFT(phi_CH_FFT<-90) = phi_CH_FFT(phi_CH_FFT<-90) + 180;
                            end
                    end

                    %% Calculation of Rho
                    % Kleinman + cylindrical symmetries imply khi_xyy = khi_yyx or d_31 = d_15
                    % (1 = y, 2 = z, 3 =x)
                    % this hypothesis is made when calculating only rho
                    D = a0_CHt{channel_num} + a2_CHt{channel_num} + a4_CHt{channel_num};
                    K = a0_CHt{channel_num} - a2_CHt{channel_num} + a4_CHt{channel_num};
                    rho_CH_FFT{channel_num} = sqrt(abs(D./K));

                    % otherwise ratio of coeff must be calculated separately
                    CC = a0_CHt{channel_num} - a4_CHt{channel_num} - (a0_CHt{channel_num} + a4_CHt{channel_num}).^2;
                    ratio_31_15_xyy_yyx{channel_num} = K/CC;
                    ratio_33_15_xxx_yyx{channel_num} = D/CC;

                    %% Storing Phi and Rho in matrices
                    PHICHt{channel_num} = phi_CH_FFT-Angle(1)*180/pi*ones(size(phi_CH_FFT));
                    PHICHt{channel_num}=PHICHt{channel_num}-180*(PHICHt{channel_num}>90);
                    PHICHt{channel_num}=PHICHt{channel_num}+180*(PHICHt{channel_num}<=-90);
                    RHOCHt = rho_CH_FFT;


                    %% Computation of the theoretical intensity evolution with the angle (theoretical butterfly diagram)
                    for Angle_ind=1:length(Angle)
                        a(1:NbPixelHeight,1:NbPixelWidth)=Angle(Angle_ind);
                        p=PHICHt{channel_num}*pi/180;
                        if (DeltaAngle==180 || DeltaAngle==360)
                            pCH_FFTt{channel_num}(:,:,Angle_ind) =(a4_CHt{channel_num}.*cos(4*(a-p))+a2_CHt{channel_num}.*cos(2*(a-p))+a0_CHt{channel_num})/length(Angle);
                        else
                            pCH_FFTt{channel_num}(:,:,Angle_ind) =(a4_CHt{channel_num}.*cos(4*(a-p))+a2_CHt{channel_num}.*cos(2*(a-p))+a0_CHt{channel_num})/length(Angleint);
                        end
                    end

                    %% Computation of R2
                    for ii=1:NbPixelHeight
                        for jj=1:NbPixelWidth
                            R2CHt{channel_num}(ii,jj)=squeeze(rsquare(pCHt{channel_num}(ii,jj,:),pCH_FFTt{channel_num}(ii,jj,:)));
                        end
                    end



                    %% Saving results in mat%%
                    figure(channel_num);
                    % Plot of fibril orientation vectors for every pixel, vector length = R2
                    quiver(X,Y,R2CHt{channel_num}.*cos(PHICHt{channel_num}*pi/180),...
                        R2CHt{channel_num}.*sin(PHICHt{channel_num}*pi/180));
                    set(gca,'YDir','reverse');
                    axis([0 NbPixelWidth+1 0 NbPixelHeight+1]); title(sprintf('Channel # %d', channel_num-1 ));

                    PHICH{channel_num}(:,:,tile,Depth) = PHICHt{channel_num};
                    RHOCH{channel_num}(:,:,tile,Depth) = RHOCHt{channel_num};
                    R2CH{channel_num}(:,:,tile,Depth) = R2CHt{channel_num};
                    a0_CH{channel_num}(:,:,tile,Depth) = a0_CHt{channel_num};
                    a2_CH{channel_num}(:,:,tile,Depth) = a2_CHt{channel_num};
                    a4_CH{channel_num}(:,:,tile,Depth) = -a4_CHt{channel_num}; % positive values
                    ICH_mean_noBIN{channel_num}(:,:,tile,Depth) = 18.*ICH_mean_noBIN_temp{channel_num};% multiplication by 18!!


                    % Maxime : I chose to save the variables with the name of the channel, so I need to split here the different cases. That way, the result of this code can be put in the old code, and if results matrices from different channels are opened at the same time, they do not overwrite.
                    % I put the commented part after if you want to avoid this splitting.

                    if tile==NumberTiles


                        t2=tic;
                        switch channel_num

                            case 3
                                PHICH02 = PHICH{channel_num}; RHOCH02 = RHOCH{channel_num};
                                R2CH02 = R2CH{channel_num}; INTCH02_sum_nobin = ICH_mean_noBIN{channel_num};
                                a0_CH02 = a0_CH{channel_num}; a2_CH02 = a2_CH{channel_num}; a4_CH02 = a4_CH{channel_num};
                                save (fullfile(Path_Writing, ['\' Name '.result_FFT_CH02.mat']), 'PHICH02', 'RHOCH02',...
                                    'R2CH02', 'INTCH02_sum_nobin', 'a0_CH02','a2_CH02','a4_CH02','-mat');

                            case 4
                                PHICH03 = PHICH{channel_num}; RHOCH03 = RHOCH{channel_num};
                                R2CH03 = R2CH{channel_num}; INTCH03_sum_nobin = ICH_mean_noBIN{channel_num};
                                a0_CH03 = a0_CH{channel_num}; a2_CH03 = a2_CH{channel_num}; a4_CH03 = a4_CH{channel_num};
                                save (fullfile(Path_Writing, ['\' Name '.result_FFT_CH03.mat']), 'PHICH03', 'RHOCH03',...
                                    'R2CH03', 'INTCH03_sum_nobin', 'a0_CH03','a2_CH03','a4_CH03','-mat');
                        end

                        t2 = toc(t2);
                        fprintf('\n The final saving in big matrices lasted %.1f seconds\n', t2);
                    end
                end
            end
        %end

        clearvars  p a

        toc
    end % end loop in Z
end % end loop in mosaic (x,y)

close(h);

%% Save general variables %%

%General infos
save(fullfile(Path_Writing, 'info_result_FFT.mat'), 'channel', 'BinSize', 'Zmin', 'NumberImages', 'AngleMin', 'AngleMax', 'AngleStep', '-mat');

end
