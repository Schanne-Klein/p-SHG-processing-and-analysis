
function PSHG_saving_function_Vaky2026(pathname2,answer_acquis, answer_anal,sampling, objective, Name, mode)

warning('off', 'MATLAB:xlswrite:AddSheet'); 
try
    MIJ.exit;
catch
    disp('No instance of Miji to close')
end


path_computer = 'D:\Vaky\codes\Vaky 2026 codes processing matlab V2'; %MODIF
addpath('D:\Vaky\codes\Vaky 2026 codes processing matlab V2\Sous-fonctions\CircStat2012a') %location of the sub-functions

% ImageJ loading
path_ml = 'D:\Vaky\codes\Vaky 2026 codes processing matlab V2'; %MODIF

path_mij =fullfile(path_ml, 'mij.jar');
path_ij =fullfile(path_ml, 'ij.jar');
javaaddpath(path_mij);
javaaddpath(path_ij);
MIJ.start

% Info file loading (that was saves in the processing step, contains info about the parameters of processing: binzise...)
filename2='info_result_FFT.mat';

load(fullfile(pathname2,filename2));

%loading the tiles numbers and calculating the total number of tiles (for mosaicking)
tilesx=str2double(answer_acquis{2});
tilesy=str2double(answer_acquis{3});
NumberTiles = tilesx*tilesy;

%limits to filter with the R2
DownR2=str2double(answer_anal{1});
UpR2=str2double(answer_anal{2});

fig_disp_flag=str2double(answer_anal{3}); %for displaying the figure little by little 

% Scaling according to the objective and the sampling chosen

if strcmp(objective,'25xO_Water')
    pix_obj='1.69';
elseif strcmp(objective,'20xZ_Water')
    pix_obj='1.98';
elseif strcmp(objective,'20xO_Air')
    pix_obj='2.11';
elseif strcmp(objective,'20xZ_Air')
    pix_obj='1.95';
end


scale=strcat('distance=', sampling, ' known=', pix_obj, ' pixel=1 unit=µm'); % the scale that will be used for the images on imageJ

namePath=strcat('\','anal_r2', answer_anal{1});
Path_Writing = fullfile(pathname2,namePath);
mkdir(Path_Writing);

bin=BinSize(1); % loading the bin size
PAS=10; %Phi Histo step
tic
% init var: intitalizing many lists to save the data and useful info:
% mean/std... many not used in practice but kept in case 
PathWch = cell(length(channel) ,1);
a0_CH = cell(length(channel) ,1);
PHICH = cell(length(channel) ,1);
R2CH = cell(length(channel) ,1);
RHOCH = cell(length(channel) ,1);
ICH = cell(length(channel) ,1);
intCH = cell(length(channel) ,1);
MaskCHr2 = cell(length(channel) ,1);
MaskCH = cell(length(channel) ,1);
ValidPixelCH = cell(length(channel) ,1);
ValidPixelpercCH = cell(length(channel) ,1);

Phi_CH_mean = cell(length(channel),1);
Phi_CH_sd = cell(length(channel),1);
Phi_CH_circ_sd = cell(length(channel),1);
Phi_CH_circ_var = cell(length(channel),1);
Rho_CH_max = cell(length(channel),1);
Rho_CH_mean = cell(length(channel),1);
Rho_CH_sd = cell(length(channel),1);
I_CH_mean = cell(length(channel),1);
I_CH_sd = cell(length(channel),1);
R2_CH_mean = cell(length(channel),1);
R2_CH_sd = cell(length(channel),1);
R2_noFilter_CH_mean = cell(length(channel),1);
R2_noFilter_CH_sd = cell(length(channel),1);
entropy_CH = cell(length(channel),1);
ICH_nofilt = cell(length(channel),1);
ICH_mean_noBIN = cell(length(channel),1);
ICH_noBINCrop = cell(length(channel),1);
ICH_max = cell(length(channel),1);
ICH_noBIN_temp = cell(length(channel),1);
ICH_noBIN = cell(length(channel),1);
            
%Histo saved in .mat format: not used but kept in case
Phi_CH_hist = cell(length(channel),1);
Rho_CH_hist = cell(length(channel),1);
I_CH_hist = cell(length(channel),1);
R2_CH_hist = cell(length(channel),1);

%%
% Data for Skin Data Processing
SaveListPhi = cell(length(channel),NumberImages);

%%

if ~fig_disp_flag
    h(10)=figure( 'Visible', 'off');
else % display
    h(10)=figure;
end

%% definin the matrices


phi_CH = cell(length(channel),1);
phi_filtered_CH = cell(length(channel),1);
norm_ICH_noBIN  = cell(length(channel),1);
phi_filtered_CHprint09 = cell(length(channel),1);
phi_filtered_CHprint80 = cell(length(channel),1);
phi_filtered_CHprint = cell(length(channel),1);
phi_CHprint09 = cell(length(channel),1);
phi_CHprint80 = cell(length(channel),1);
phi_CHprint  = cell(length(channel),1);
phiCH_hsvimg = cell(length(channel),1);
phiCH_rgbimg = cell(length(channel),1);
R2_CH = cell(length(channel),1);
phiCHhsv = cell(length(channel),1);
phiFiltCHhsv = cell(length(channel),1);
phiFiltCH_hsvimg   = cell(length(channel),1);
phiFiltCH_rgbimg = cell(length(channel),1);
listPhiCH = cell(length(channel),1);
rho_filtered_CH = cell(length(channel),1);
rho_noFilter_CH = cell(length(channel),1);
MaxRhoCH = cell(length(channel),1);
R2_noFilter_CH = cell(length(channel),1);


% Loop on Z
flag_dir3 = {0,0,0,0};
flag_dir4 = {0,0,0,0};
flag_dir6 = {0,0,0,0};
flag_dir7 = {0,0,0,0};


indexHisto = cell(length(channel),1);
indexHistoI = cell(length(channel),1);

count_channel_considered = 0;
%%
for channel_num = [3,4] % loop on every channel of SHG (backward then forward)
    
    if channel(channel_num) % if the channel is considered
        indexHisto{channel_num}=1;
        indexHistoI{channel_num}=-1;
        %
        %%%%%%%%%%%%%%%%%%%%%%%
        %%% Loading results %%%
        %%%%%%%%%%%%%%%%%%%%%%%
        
        struct_load = load(fullfile(pathname2,[ Name, sprintf('.result_FFT_CH0%d.mat', channel_num-1)])); % loading the corresponding matrices info
        

        try
            PHICH{channel_num} = struct_load.(sprintf('PHICH0%d', channel_num-1));
            R2CH{channel_num} = struct_load.(sprintf('R2CH0%d', channel_num-1));
            RHOCH{channel_num} = struct_load.(sprintf('RHOCH0%d', channel_num-1));
            a0_CH{channel_num} = struct_load.(sprintf('a0_CH0%d', channel_num-1));
            ICH_mean_noBIN{channel_num} = struct_load.(sprintf('INTCH0%d_sum_nobin', channel_num-1));
        catch MEE
            error('Wrong # of channel chosen : I was unable to load the mat with this name of variable : either check the channel number or the .mat you try to load !');
        end
        
        % CH0%d folder
        mkdir(fullfile(Path_Writing,sprintf('ch0%d', channel_num-1)));
        
        PathWch{channel_num} = fullfile(Path_Writing,sprintf('\\ch0%d', channel_num-1 ));
        
        % Size parameters
        Nx=size(PHICH{channel_num},1);
        Ny=size(PHICH{channel_num},2);
        Nz=size(ICH_mean_noBIN{channel_num},4);
        NbPixels=Nx*Ny;
        
        listPhi_totalSize_CH(1:Nz,1:Nx*Ny)=NaN; % ??? MP
        
        % Rewrite Phi in anticlockwise direction
        PHICH{channel_num} = -PHICH{channel_num};
        ICH{channel_num}=a0_CH{channel_num};
        flag_dir1 = 0;
        
        
        % R2 filter mask
        MaskCHr2{channel_num} = R2CH{channel_num}>=DownR2 & R2CH{channel_num}<=UpR2; 
        ICH_nofilt{channel_num} = ICH{channel_num};
        
        MaskCH{channel_num}=double(MaskCHr2{channel_num});
        MaskCH{channel_num}(MaskCH{channel_num}==0)=nan;
        

        
        close all
        
        % init for the following
        
        Phi_CH_mean{channel_num} = zeros(Nz,1); % Phi_CH00_mean
        Phi_CH_sd{channel_num} =zeros(Nz,1);
        Phi_CH_circ_sd{channel_num} =zeros(Nz,1);
        Phi_CH_circ_var{channel_num} =zeros(Nz,1);
        Rho_CH_max{channel_num} =zeros(Nz,1);
        Rho_CH_mean{channel_num} =zeros(Nz,1);
        Rho_CH_sd{channel_num} =zeros(Nz,1);
        I_CH_mean{channel_num} =zeros(Nz,1);
        I_CH_sd{channel_num} =zeros(Nz,1);
        R2_CH_mean{channel_num} =zeros(Nz,1);
        R2_noFilter_CH_mean{channel_num} =zeros(Nz,1);
        R2_CH_sd{channel_num} =zeros(Nz,1);
        R2_noFilter_CH_sd{channel_num} =zeros(Nz,1);
        entropy_CH{channel_num} =zeros(Nz,1);
        
        ICH_noBINCrop{channel_num}=ICH_mean_noBIN{channel_num}(round(BinSize/2):end-floor(BinSize/2),round(BinSize/2):end-floor(BinSize/2),:,:);
        ICH_max{channel_num}=max(max(max(max(ICH_noBINCrop{channel_num}))));
        
        %Init of the histo matrices
        Angle=(-89:90);
        Phi_CH_hist{channel_num} = zeros(Nz,length(Angle));
        rho_bin=1:0.02:3;
        Rho_CH_hist{channel_num} = zeros(Nz,length(rho_bin));
        int_bin=1:0.5:60;
        I_CH_hist{channel_num} = zeros(Nz,length(int_bin));
        Angle10=-90+PAS:PAS:90;
        R2_bin=DownR2:0.003:UpR2;
        R2_CH_hist{channel_num} = zeros(Nz,length(R2_bin));
        
        if ~count_channel_considered % if it's the first channel to be considered
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%     Polarisation wheel (legend of phi map)    %%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Pourccircle= 13  ;        % Wheel size as a percentage of the image size
            outerRadius = ceil(Nx/Pourccircle/2);		% external radius of the wheel
            innerRadius = ceil(Nx/Pourccircle/6);		% internal radius of the wheel
            numberOfSectors = 256;		% number of colour segments
            grayLevel = 0;		% Gray level outside the wheel.
            
            % Get polar coordinates of each point in the domain
            [x, y] = meshgrid(-outerRadius : outerRadius);
            [theta, rho] = cart2pol(x, y); % theta is an image here.
            
            % Set up color wheel in hsv space
            hueImage = (theta + pi) / (2 * pi);     % Hue is in the range 0 to 1.
            hueImage = ceil(hueImage * numberOfSectors) / numberOfSectors;   % Quantize hue
            saturationImage = ones(size(hueImage));      % Saturation (chroma) = 1 to be fully vivid.
            
            % Make it have the wheel shape
            % Make a mask 1 in the wheel, and 0 outside the wheel.
            wheelMaskImage = rho >= innerRadius & rho <= outerRadius;
            % Hue and Saturation must be zero outside the wheel to get gray.
            hueImage(~wheelMaskImage) = nan;
            saturationImage(~wheelMaskImage) = nan;
            hueImage=(abs(hueImage*2-1)')*180-90;
            Colorcircle(:,1:outerRadius+1)=hueImage(:,1:outerRadius+1);
            Colorcircle(:,outerRadius+1:outerRadius*2+1)=hueImage(:,outerRadius+1:outerRadius*2+1)*-1;
            [SizeCircle_y, SizeCircle_x ]=size(Colorcircle);
            

        end
        
        %% looping over the z planes
        for Depth=1:Nz
            Depth_n=Depth-1;

            if Depth ==1
                % temporary variables
                PHICH_temp = PHICH{channel_num};
                MaskCH_temp = MaskCH{channel_num};
            end

            for tile=1:NumberTiles
                
                indexHistoI{channel_num}=indexHistoI{channel_num}+2;
                indexHisto{channel_num}=indexHisto{channel_num}+1;

                %%%% Phi angle %%%%
                
                phi_CH{channel_num}=PHICH_temp(:,:,tile,Depth);
                phi_filtered_CH{channel_num}=phi_CH{channel_num}.*MaskCH_temp(:,:,tile,Depth);
                %phi_CH{channel_num}=phi_CH{channel_num}.*MaskCHNoise_temp(:,:,Depth);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                SaveListPhi{channel_num,Depth}=phi_CH{channel_num}(~isnan(phi_CH{channel_num}));

                %%
                % Plot the phi map with the polarisation wheel legend and save it as a jpeg file

                %rewrite the phi filtered

                phi_filtered_CHprint09_temp =-phi_filtered_CH{channel_num}-90;
                phi_filtered_CHprint09_temp(-phi_filtered_CH{channel_num}<0)=0;
                phi_filtered_CHprint80_temp=-phi_filtered_CH{channel_num}+90;
                phi_filtered_CHprint80_temp(-phi_filtered_CH{channel_num}>=0)=0;
                phi_filtered_CHprint{channel_num} = phi_filtered_CHprint09_temp + phi_filtered_CHprint80_temp;

                phi_filtered_CHprint09{channel_num} = phi_filtered_CHprint09_temp;
                phi_filtered_CHprint80{channel_num} = phi_filtered_CHprint80_temp;
                %rewrite the phi
                phi_CHprint09_temp=-phi_CH{channel_num}-90;
                phi_CHprint09_temp(-phi_CH{channel_num}<0)=0;
                phi_CHprint09{channel_num} = phi_CHprint09_temp;
                phi_CHprint80_temp=-phi_CH{channel_num}+90;
                phi_CHprint80_temp(-phi_CH{channel_num}>=0)=0;
                phi_CHprint80{channel_num} = phi_CHprint80_temp;
                phi_CHprint{channel_num} = phi_CHprint09{channel_num} + phi_CHprint80{channel_num};

                %write the phi filtered on a big image with the color wheel
                [phi_x,phi_y,phi_z]=size(phi_filtered_CH{channel_num});
                Nanimage(1:phi_x,1:phi_y+SizeCircle_y)=nan;
                Nanimage(1:SizeCircle_x,phi_y+1:end)=Colorcircle;
                Nanimage209=Nanimage-90;
                Nanimage209(Nanimage<0)=0;
                Nanimage280=Nanimage+90;
                Nanimage280(Nanimage>=0)=0;
                Nanimage2=Nanimage209+Nanimage280;
                Nanimage2(1:phi_x,1:phi_y)=phi_filtered_CHprint{channel_num};

                % Plot in real hsv
                nanimagehsv=(-Nanimage2+90)/180; %between 0 and 1
                phiCH_hsvimg{channel_num} = cat(3, nanimagehsv, ones(size(nanimagehsv)), ones(size(nanimagehsv)));
                phiCH_rgbimg{channel_num} = hsv2rgb(phiCH_hsvimg{channel_num});

                if ~fig_disp_flag
                    h(tile+Depth+1)=figure( 'Visible', 'off');
                else % display
                    h(tile+Depth+1)=figure(tile+Depth+1000);
                end


                ICH_noBIN_temp{channel_num} = ICH_noBINCrop{channel_num}(:,:,tile,Depth);
                ICH_noBIN{channel_num} = ICH_noBIN_temp{channel_num};
                
                
                norm_ICH_noBIN{channel_num} = ICH_noBIN{channel_num}/ICH_max{channel_num};

                
                % Save as a tiff RGB file with ImageJ, with contrast corresponding to R2
                R2CH_temp = R2CH{channel_num};
                R2_CH{channel_num}=R2CH_temp(:,:,tile,Depth);
                phiCHhsv{channel_num} =(-phi_CHprint{channel_num}+90)/180; %between 0 and 1
                phiFiltCHhsv{channel_num} =(-phi_filtered_CHprint{channel_num}+90)/180; %between 0 and 1
                phiCH_hsvimg{channel_num} = cat(3, phiCHhsv{channel_num}, ones(size(phiCHhsv{channel_num})), R2_CH{channel_num}); %hsv: H=angles, S=1, V=R2
                phiFiltCH_hsvimg{channel_num} = cat(3, phiFiltCHhsv{channel_num}, ones(size(phiCHhsv{channel_num})), R2_CH{channel_num}); %same but only keeping pixels with R2 filtered
                phiCH_rgbimg{channel_num} = hsv2rgb(phiCH_hsvimg{channel_num});
                phiFiltCH_rgbimg{channel_num} = hsv2rgb(phiFiltCH_hsvimg{channel_num});


                %%%% Phi angle R2 filtered (H=ang, S=1, V=R2) only with pixels filtered with R2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                name_dir{1} = 'PHI';
                name_dir_spec{1} = 'angR2filtH_1S_R2V';
                flag_dir_cell{1} = flag_dir3{channel_num};
                name_files{1} = [Name '.PHI_angR2filtH_1S_R2V'];
                var_save{1} = phiFiltCH_rgbimg{channel_num};
                plotmatlab{1} = 0;

                %%%% Phi angle  (HSV), same as before but all pixels without filtering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                name_dir{2} = 'PHI';
                name_dir_spec{2} = 'angNofiltH_1S_R2V';
                flag_dir_cell{2} = flag_dir4{channel_num};
                name_files{2} = [Name '.PHI_angNofiltH_1S_R2V'];
                var_save{2} = phiCH_rgbimg{channel_num};
                plotmatlab{2} = 0;

                %%%% Intensity (no filters)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 intCH{channel_num} = ICH_nofilt{channel_num}(:,:,tile,Depth);
                 name_dir{3} = 'INT';
                 name_dir_spec{3} = 'nofilter_a0';
                 flag_dir_cell{3} = flag_dir1;
                 name_files{3} = [Name '.INT_nofilter_a0'];
                 var_save{3} = intCH{channel_num};
                 plotmatlab{3} = 1;


                %%%% Intensity not binned (no filters) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 intCH{channel_num} = ICH_noBIN{channel_num};
                 name_dir{4} = 'INT';
                 name_dir_spec{4} = 'sum_nobin';
                 flag_dir_cell{4} = flag_dir1;
                 name_files{4} = [Name '.INT_sum_nobin'];
                 var_save{4} = intCH{channel_num};
                 plotmatlab{4} = 1;


                %%% R2 ( no filters) %%%%
                name_dir{5} = 'R2';
                name_dir_spec{5} = 'nofilter';
                flag_dir_cell{5} = flag_dir7{channel_num};
                name_files{5} = [Name '.R2_nofilter'];
                R2_noFilter_CH{channel_num}=R2CH_temp(:,:,tile,Depth);
                var_save{5} = R2_noFilter_CH{channel_num};
                plotmatlab{5} = 1;


                %%%% Anisotropy parameter Rho (no filters)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rho_noFilter_CH{channel_num} = RHOCH{channel_num}(:,:,tile,Depth);
                name_dir{6} = 'RHO';
                name_dir_spec{6} = 'nofilter';
                name_files{6} = [Name '.RHO_nofilter'];
                flag_dir_cell{6} = flag_dir6{channel_num};
                var_save{6} = rho_noFilter_CH{channel_num};
                plotmatlab{6} = 1;


                %%%% Anisotropy parameter Rho filtered (keeping pixels with R2>threshold, and keeping only 1<rho<3) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rho_filtered_CH{channel_num} = RHOCH{channel_num}(:,:,tile,Depth);
                rho_filtered_CH{channel_num} = rho_filtered_CH{channel_num}.*MaskCH{channel_num}(:,:,tile,Depth);
                rho_filtered_CH_temp = rho_filtered_CH{channel_num};
                rho_filtered_CH_temp(rho_filtered_CH_temp>3)=nan;    % Suppression de Rho > 3
                rho_filtered_CH_temp(rho_filtered_CH_temp<1)=nan;    % Suppression de Rho < 1
                rho_filtered_CH{channel_num} = rho_filtered_CH_temp;
                MaxRhoCH{channel_num}=max((max(max(max(rho_filtered_CH{channel_num})))),1.1);
                name_dir{7} = 'RHO';
                name_dir_spec{7} = 'filtered';
                name_files{7} = [Name '.RHO_filtered'];
                flag_dir_cell{7} = flag_dir6{channel_num};
                var_save{7} = rho_filtered_CH{channel_num};
                plotmatlab{7} = 1;

                %Creation of subdirectory for each metric (INT, PHI, RHO, R2) inside the channel directory
                %Creation of sub-subdirectory for the several versions of
                %the metric (filtered/non-filtered). 
                % In each of these sub-subdirectory, the .tif image is
                % saved for each tile and Z plane with the
                % corresponding numbers. (In case no several planes or no tiles, still saving as if only 1 tile/z-plane) 
                for num_plot = 1:length(name_files)
                    % Open on ImageJ and save as a tiff file
                    %creating directory (if not existant) to save the
                    %images of the tiles and z positions of this type
                    if (~flag_dir_cell{num_plot})
                        mkdir(fullfile(PathWch{channel_num},name_dir{num_plot}));
                        mkdir(fullfile(PathWch{channel_num},name_dir{num_plot}, name_dir_spec{num_plot}));
                        flag_dir_cell{num_plot} = 1;
                    end

                    name_img_disp = sprintf('CH0%d_%s_z%s_t%s.1f.tif',channel_num-1, name_files{num_plot}, num2str(Depth_n, '%04.f'), num2str(tile, '%04.f'));
                    img1= fullfile(PathWch{channel_num}, name_dir{num_plot},name_dir_spec{num_plot}, name_img_disp);
                    
                    % ie intensity: multiplication by 10 and saving in 16 bits.
                     if (num_plot == 3 || num_plot == 4)  
                         %Note the intensity maps are summed over all
                         %polarizations (before this multiplication by 10 => *180 at the end)
                         norm = 1;   
                         var_norm = var_save{num_plot}./norm;
                         var_norm =uint16(10*var_norm);
                         
                     % ie R2 or rho: multiplication by 10000 and saving in 16 bits    
                     elseif (num_plot == 5 || num_plot == 6 || num_plot == 7) 
                         norm = 1;   
                         var_norm = var_save{num_plot}./norm;
                         var_norm =uint16(10000*var_norm);
                     
                    % no changes for the orientation maps (HSV)
                     else 
                         var_norm = var_save{num_plot};
                     end

                    imwrite(var_norm,img1,'tif');
                    IMGpath= sprintf('path=[%s]', img1); 
                    MIJ.run('Open...',IMGpath);

                    MIJ.run('Set Scale...', scale);
                    if (num_plot == 3 || num_plot == 4)
                        MIJ.run('Fire');
                        command_LUT_bounds = sprintf('setMinAndMax(%d, %d)', min(min(var_norm)), max(max(var_norm)));
                        ij.IJ.runMacro(command_LUT_bounds)
                    end


                    ij.IJ.save(img1);
                    ij.IJ.run('Close');

                 end

                flag_dir3{channel_num} = flag_dir_cell{1}; flag_dir4{channel_num} = flag_dir_cell{2}; flag_dir1= flag_dir_cell{3}; flag_dir7{channel_num} = flag_dir_cell{5};

                phi_filtered_CH_temp = phi_filtered_CH{channel_num};
                listPhiCH{channel_num}=phi_filtered_CH_temp(~isnan(phi_filtered_CH_temp)); %list of the non-NaN values in phi_filtered



            end % Z
        end % end tiles
        
        % in case mode =0 or 1 (XYPZ and XYP cases respectively), take all
        % the images in the created directory and convert them to a stack. 
        % So at the end, in each SHG channel directory, we 7 stacks (XYPZ) or 7
        % images (XYZ) with the right scaling
        if  mode == 0 || mode == 1
            mainFolder = PathWch{channel_num};
            
            subfolders = dir(mainFolder);
            subfolders = subfolders([subfolders.isdir]);
            subfolders = subfolders(~ismember({subfolders.name},{'.','..'}));
            
             for s1 = 1:length(subfolders)
                subFolder1Path = fullfile(mainFolder, subfolders(s1).name);
                
                subsubfolders = dir(subFolder1Path);
                subsubfolders = subsubfolders([subsubfolders.isdir]);
                subsubfolders = subsubfolders(~ismember({subsubfolders.name},{'.','..'}));
                
                for s2 = 1:length(subsubfolders)
                    subFolder2Path = fullfile(subFolder1Path, subsubfolders(s2).name);
                    
                    tifs = dir(fullfile(subFolder2Path,'*.tif'));
                    tifs = {tifs.name};
                    if isempty(tifs), continue; end
                    tifs = sort(tifs);
                    
                    firstImage = imread(fullfile(subFolder2Path, tifs{1}));
                    [rows, cols, channels_img] = size(firstImage);
                    stack = zeros(rows, cols, channels_img, length(tifs), 'like', firstImage);
                    
                    for k = 1:length(tifs)
                        stack(:,:,:,k) = imread(fullfile(subFolder2Path, tifs{k}));
                    end
                    
                    
                    stackName = fullfile(mainFolder, ...
                        sprintf('CH0%d_%s_%s_%s_stack.tif', channel_num-1, Name, subfolders(s1).name, subsubfolders(s2).name));
                    
                    for k = 1:size(stack,4)
                        if k == 1
                            imwrite(stack(:,:,:,k), stackName, 'WriteMode', 'overwrite', ...
                                'Compression', 'none');
                        else
                            imwrite(stack(:,:,:,k), stackName, 'WriteMode', 'append', ...
                                'Compression', 'none');
                        end
                    end

                    img1= stackName;
                    IMGpath= sprintf('path=[%s]', img1); % strcat('path=', img1);
                    MIJ.run('Open...',IMGpath);
                    MIJ.run('Set Scale...', scale);
                    ij.IJ.save(img1);
                    ij.IJ.run('Close');

                    
                    rmdir(subFolder2Path, 's');
                end
                rmdir(subFolder1Path, 's');
            end
        
        end
    end
end

for channel_num = [1,2] % loop on every channel 2PEF (forward then backward)
    
    if channel(channel_num) % if the channel is considered
        indexHisto{channel_num}=1;
        indexHistoI{channel_num}=-1;
        %
        %%%%%%%%%%%%%%%%%%%%%%%
        %%% Loading results %%%
        %%%%%%%%%%%%%%%%%%%%%%%
               
        struct_load = load(fullfile(pathname2,[ Name, sprintf('.result_FFT_CH0%d.mat', channel_num-1)]));
        
        % only loading the intensity images: binned (a0) and not binned
        try
            ICH_mean_noBIN{channel_num} = struct_load.(sprintf('INTCH0%d_sum_nobin', channel_num-1));
            a0_CH{channel_num} = struct_load.(sprintf('a0_CH0%d', channel_num-1));
        catch MEE
            error('Wrong # of channel chosen : I was unable to load the mat with this name of variable : either check the channel number or the .mat you try to load !');
        end
        
        % CH0%d folder
        mkdir(fullfile(Path_Writing,sprintf('ch0%d', channel_num-1 )));
        
        PathWch{channel_num} = fullfile(Path_Writing,sprintf('\\ch0%d', channel_num-1));
        ICH{channel_num}=a0_CH{channel_num};
        flag_dir1 = 0;
        
         
        % Size parameters
        Nx=size(ICH_mean_noBIN{channel_num},1);
        Ny=size(ICH_mean_noBIN{channel_num},2);
        Nz=size(ICH_mean_noBIN{channel_num},4);
        
        
        % non binned intensity
        ICH_nofilt{channel_num} = ICH{channel_num};
        
                
        
        close all
        
        % init for the following
        %% 
      
        I_CH_mean{channel_num} =zeros(Nz,1);
        I_CH_sd{channel_num} =zeros(Nz,1);
        
        ICH_noBINCrop{channel_num}=ICH_mean_noBIN{channel_num}(round(BinSize/2):end-floor(BinSize/2),round(BinSize/2):end-floor(BinSize/2),:,:);
        
        %Init of the histo matrices
        int_bin=1:0.5:60;
        I_CH_hist{channel_num} = zeros(Nz,length(int_bin));
       
         
        for Depth=1:Nz
            Depth_n=Depth-1;

            for tile=1:NumberTiles
                indexHistoI{channel_num}=indexHistoI{channel_num}+2;
                indexHisto{channel_num}=indexHisto{channel_num}+1;

                ICH_noBIN_temp{channel_num} = ICH_noBINCrop{channel_num}(:,:,tile,Depth);
                ICH_noBIN{channel_num} = ICH_noBIN_temp{channel_num};


                %%%% Intensity (no filters)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                intCH{channel_num} = ICH{channel_num}(:,:,tile,Depth);
                name_dir{1} = 'INT';
                name_dir_spec{1} = 'a0';
                flag_dir_cell{1} = flag_dir1;
                name_files{1} = [Name '.INT_a0'];
                var_save{1} = intCH{channel_num};
                plotmatlab{1} = 1;

                 %%%% Intensity no bin (no filters) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 intCH{channel_num} = ICH_noBIN{channel_num};
                 name_dir{2} = 'INT';
                 name_dir_spec{2} = 'sum_nobin';
                 flag_dir_cell{2} = flag_dir1;
                 name_files{2} = [Name '.INT_sum_nobin'];
                 var_save{2} = intCH{channel_num};
                 plotmatlab{2} = 1;

                for num_plot = 1:2
                    % Open on ImageJ and save as a tiff file
                    if (~flag_dir_cell{num_plot})
                        mkdir(fullfile(PathWch{channel_num},name_dir{num_plot}));
                        mkdir(fullfile(PathWch{channel_num},name_dir{num_plot}, name_dir_spec{num_plot}));

                        flag_dir_cell{num_plot} = 1;
                    end

                    name_img_disp = sprintf('CH0%d_%s_z%s_t%s.1f.tif',channel_num-1, name_files{num_plot}, num2str(Depth_n, '%04.f'), num2str(tile, '%04.f'));
                    img1= fullfile(PathWch{channel_num}, name_dir{num_plot}, name_dir_spec{num_plot}, name_img_disp);
                    
                    % saving the intensity map (summed over all
                    % polarizations) *10, in 16 bits
                    norm = 1;   
                    var_norm = var_save{num_plot}./norm;
                    var_norm = uint16(10*var_norm);

                    imwrite(var_norm,img1,'tif');
                    IMGpath= sprintf('path=[%s]', img1); 
                    MIJ.run('Open...',IMGpath);

                    MIJ.run('Set Scale...', scale);
                    MIJ.run('Fire');
                    command_LUT_bounds = sprintf('setMinAndMax(%d, %d)', min(min(var_norm)), max(max(var_norm)));
                    ij.IJ.runMacro(command_LUT_bounds)

                    ij.IJ.save(img1);

                    ij.IJ.run('Close');


                 end

                flag_dir1= flag_dir_cell{3};



            end % tile (x,y)
    end% Z
        
        %     end
        % end

        % convert to just a stack/image in case XYPZ or XYZ modes, exactly
        % as in the SHG channels case...
       if mode == 0 || mode == 1
            mainFolder = PathWch{channel_num};
            
            subfolders = dir(mainFolder);
            subfolders = subfolders([subfolders.isdir]);
            subfolders = subfolders(~ismember({subfolders.name},{'.','..'}));
            
             for s1 = 1:length(subfolders)
                subFolder1Path = fullfile(mainFolder, subfolders(s1).name);
                
                subsubfolders = dir(subFolder1Path);
                subsubfolders = subsubfolders([subsubfolders.isdir]);
                subsubfolders = subsubfolders(~ismember({subsubfolders.name},{'.','..'}));
                
                for s2 = 1:length(subsubfolders)
                    subFolder2Path = fullfile(subFolder1Path, subsubfolders(s2).name);
                    
                    tifs = dir(fullfile(subFolder2Path,'*.tif'));
                    tifs = {tifs.name};
                    if isempty(tifs), continue; end
                    tifs = sort(tifs);
                    
                    firstImage = imread(fullfile(subFolder2Path, tifs{1}));
                    [rows, cols, channels_img] = size(firstImage);
                    stack = zeros(rows, cols, channels_img, length(tifs), 'like', firstImage);
                    
                    for k = 1:length(tifs)
                        stack(:,:,:,k) = imread(fullfile(subFolder2Path, tifs{k}));
                    end
                    
                    
                    stackName = fullfile(mainFolder, ...
                        sprintf('CH0%d_%s_%s_%s_stack.tif', channel_num-1, Name, subfolders(s1).name, subsubfolders(s2).name));
                    
                    for k = 1:size(stack,4)
                        if k == 1
                            imwrite(stack(:,:,:,k), stackName, 'WriteMode', 'overwrite', ...
                                'Compression', 'none');
                        else
                            imwrite(stack(:,:,:,k), stackName, 'WriteMode', 'append', ...
                                'Compression', 'none');
                        end
                    end

                    img1= stackName;
                    IMGpath= sprintf('path=[%s]', img1); % strcat('path=', img1);
                    MIJ.run('Open...',IMGpath);
                    MIJ.run('Set Scale...', scale);
                    ij.IJ.save(img1);
                    ij.IJ.run('Close');

                    
                    rmdir(subFolder2Path, 's');
                end
                rmdir(subFolder1Path, 's');
            end
        
        end
        
                
        end
    end
    


%%
toc

MIJ.exit;
close all;
end