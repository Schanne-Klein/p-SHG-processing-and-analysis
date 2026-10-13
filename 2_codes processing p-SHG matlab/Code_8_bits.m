%function crop_conv_gain(pathname,answer)

function Code_8_bits(pathname,answerb)

%pathname = 'D:\Data-Vaky\24_05_13_polar_mosaic\p1_trial_code';

path_ml = 'D:\Data-Vaky\codes\codes pSHG originaux'; %MODIF

path_mij =fullfile(path_ml, 'mij.jar');
path_ij =fullfile(path_ml, 'ij.jar');
javaaddpath(path_mij);
javaaddpath(path_ij);

cd(pathname)
Directories = dir(pathname);
name_dir = {Directories.name};

% Acquisition info

tic

% Récupération du nom


tiff=0;
p_files=0;
d_files=0;
try
    MIJ.exit;
catch
    disp('No instance of Miji to close')
end

% Scaling according to the objective
obj=answerb{5};
s=str2double(answerb{6});
SB = num2str(s);

if strcmp(obj,'25xO')
    pix_obj='1.68'; 
elseif strcmp(obj,'20xZ')
    pix_obj='1.96';
elseif strcmp(obj,'20xZW')
    pix_obj='1.98';
elseif strcmp(obj,'40xZ')
    pix_obj='0.98';
elseif strcmp(obj,'60xO')
    pix_obj='0.71';
else
    fprintf(2, '\n Unknown objective name. Walou\n');
    MIJ.exit;
    return
end
del_16_bits = 1;
scale_bar = str2double(answerb{4});
scale=strcat('distance=', SB, ' known=', pix_obj, ' pixel=1 unit=�m');
%ROI
XCrop=str2double(answerb{2});
ROIX=0;
ROIX=ROIX+XCrop;
ROIY=0;
YCrop=str2double(answerb{3});
MIJ.start
%%
for i = 1:length(name_dir)
    if Directories(i).bytes > 10000 && Directories(i).isdir == 0 % Tiff files supposed that all the other files 
        tiff = tiff +1;
        cd(pathname)
 
        InfoImage=imfinfo(fullfile(pathname, Directories(i).name)); % disp a warning 'Division by zero when processing YResolution'
        mImage=InfoImage(1).Width;
        nImage=InfoImage(1).Height;
        ROIWidth=mImage;
        ROIWidth=ROIWidth-2*XCrop; 
        ROIHeight=nImage;
        ROIHeight=ROIHeight-2*YCrop;
        
       img1 = fullfile(pathname,Directories(i).name);

       IMGpath= sprintf('path=[%s]', img1);
       
       MIJ.run('Open...',IMGpath);
       
       if scale_bar ==1
            MIJ.run('Set Scale...', scale);
       end
       
       ij.IJ.setTool("rectangle");
       ij.IJ.makeRectangle(ROIX, ROIY, ROIWidth, ROIHeight);

       MIJ.run("Crop");
       MIJ.run("Conversions...", " ");
       MIJ.run("Divide...", "value=14");
       MIJ.run("8-bit");
       ij.IJ.save(img1);
       ij.IJ.run('Close');

   
   elseif Directories(i).bytes == 0 && Directories(i).isdir == 1 && strcmp(name_dir{i}(1), 'p') % directories starting with 'p'
        new_dir=fullfile(pathname,name_dir{i});
        new_dir_save=sprintf('%s 8 bit ',name_dir{i});
        mkdir(new_dir_save);
        cd(new_dir)
        pathname2 = pwd;
        list = dir(fullfile('*.tif'));
        name_list = {list.name};
        info=dir(fullfile('*.txt'));
        info_name = {info.name};
        InfoImage=imfinfo(fullfile(pathname2, name_list{1} )); % disp a warning 'Division by zero when processing YResolution'
        mImage=InfoImage(1).Width;
        nImage=InfoImage(1).Height;
        ROIWidth=mImage;
        ROIWidth=ROIWidth-2*XCrop; 
        ROIHeight=nImage;
        ROIHeight=ROIHeight-2*YCrop;
        for var = 1:length(name_list)
            img1 = fullfile(pathname2,name_list(var));
            img2 = fullfile(pathname,name_list(var));
       
            IMGpath= sprintf('path=[%s]', img1{1});
       
            MIJ.run('Open...',IMGpath);
              if scale_bar ==1
             MIJ.run('Set Scale...', scale);
              end
     
            ij.IJ.setTool("rectangle");
            ij.IJ.makeRectangle(ROIX, ROIY, ROIWidth, ROIHeight);
      
            MIJ.run("Crop");
            MIJ.run("Conversions...", " ");
            MIJ.run("Divide...", "value=14");
            MIJ.run("8-bit");
            ij.IJ.save(img2{1});
            ij.IJ.run('Close');
            
        end
        if del_16_bits == 1
                movefile(info_name{1}, pathname, 'f');
                cd(pathname)
                data2delete = Directories(i).name;
                rmdir(data2delete, 's')
        end 
        cd(pathname) 
        p_files = p_files +1;
    elseif Directories(i).bytes == 0 && Directories(i).isdir == 1 && strcmp(name_dir{i}(1), 'd') % Directories starting with 'd'
        d_files = d_files +1;
        new_dir=fullfile(pathname,name_dir{i});
        new_dir_save=sprintf('%s 8 bit ',name_dir{i});
        mkdir(new_dir_save);
        cd(new_dir)
        pathname2 = pwd;
        list = dir(fullfile('*.tif'));
        info=dir(fullfile('*.txt'));
        info_name = {info.name};
        name_list = {list.name};
        InfoImage=imfinfo(fullfile(pathname2, name_list{1} )); % disp a warning 'Division by zero when processing YResolution'
        mImage=InfoImage(1).Width;
        nImage=InfoImage(1).Height;
        ROIWidth=mImage;
        ROIWidth=ROIWidth-2*XCrop; 
        ROIHeight=nImage;
        ROIHeight=ROIHeight-2*YCrop;
        for var = 1:length(name_list)
            img1 = fullfile(pathname2,name_list(var));
            img2 = fullfile(pathname,name_list(var));
      
            IMGpath= sprintf('path=[%s]', img1{1});
       
            MIJ.run('Open...',IMGpath);
%              if scale_bar ==1
%             MIJ.run('Set Scale...', scale);
%              end
            ij.IJ.setTool("rectangle");
            ij.IJ.makeRectangle(ROIX, ROIY, ROIWidth, ROIHeight);
       
            MIJ.run("Crop");
            MIJ.run("Conversions...", " ");
            MIJ.run("Divide...", "value=14");
            MIJ.run("8-bit");
            ij.IJ.save(img2{1});
            ij.IJ.run('Close');
            
        end
        if del_16_bits == 1
            movefile(info_name{1}, pathname, 'f');
            cd(pathname)
            data2delete = Directories(i).name;
            rmdir(data2delete,'s')
        end 
        cd(pathname)

    end
end 

MIJ.exit
toc

end