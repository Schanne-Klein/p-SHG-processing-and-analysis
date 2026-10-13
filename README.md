# Codes explanation

## 1- Python code for raw data pre-processing
The code imports the needed packages
It takes the needed variables: 
o	images path
o	size to crop on each size (in pixels!): eg. If we set 210*200 pixels in the acquisitions and want to have 200*200 we put cropx=5 and cropy=0 (Don’t consider the sampling!, as if in sampling 1)
o	whether in the ‘XYZ’ mode or not
o	Objective and sampling
o	Whether saturation correction and the pixels rate (kHz)

A subdirectory is created “data_satcorr” or “data_nosat” (depending on whether saturation was chosen or not).
Images are cropped on each side based on the cropping chosen and the sampling .

- Division of each image by 14
  
1- If no saturation correction: 
- Conversion of the image to 8 bits (taking the normalization into account to have the right values!, could be removed if unnecessary)
- Saving the images in the new directory with the right scale (depending on the pixel size ie objective, and the sampling)
 
2- If saturation correction: 
-	Application of the saturation correction (depending on the pixels rate entered and the laser pulse rate: 80 MHz)
-	Conversion to 8 bits
-	Saving of the images with the scaling

If ‘XYZ’, take the saved images and stack all them for each channel and save with the right scaling. Otherwise the images are just kept as they are since no need for stacking (XY) or need for processing first with the MALTAB code (XYPZ,XYP, mosaick XYPZ).
Remove all the original raw data.

## 2- MATLAB code for p-SHG data processing
The main code is “PSHG_FFT_ProcessAndSaving_Vaky2026.m”.  
The code asks the users many answers: 
o	Directory path (which can also be entered manually at the beginning of the code)
o	Choice of objective
o	Sampling
o	Mode of acquisition: XYP, XYPZ, mosaick XYPZ
o	The channels to process
o	Acquisition/processing parameters: binning siz (generally 2), #tiles x, # tiles y (keep at 1 if no mosaicking), min Z plane, # Z planes, min ang value, Max ang, ang step
o	Saving parameters: R2 filtering range mainly…
The code extracts the “prefix” of the images, to include them in the saving.
The code calls the processing function (another code) the a saving function (another code).

For processing (“PSHG_FFT_Process_function_Vaky2026.m”): 
The code processes all images in big matrices: 
o	The forward and backward SHG channels are processed to obtain a big matrix with the raw processed data for each channel: rho, phi, R2, intensity (summed over all polarization) no binned and all the FFT coefficients a0 (intensity binned), a2, a4.
o	For the 2PEF channels, only the intensities (binned and not binned) are saved.
Note that this is to be changed if other channels are used in the acquisition, different processing is wanted...

For saving ("PSHG_saving_function_Vaky2026.m”):
Initializing many matrices to filter and save the data. 
For the SHG channels: 
o	loading of the matrices processed. Loop for each Z plane (1 if XYP) and tile (1 if XYP or XYPZ) to save all images. 
o	The phi images go through adjustment of the coordinates (orientation direction and y axis inversion). And are converted to HSV format in a filtered version (chosen R2 filters) and non filtered version: H=ang, S=1, V=R2 every time. 
o	7 maps are created: 
1- the HSV filtered -> saved later same way
2- HSV not filtered-> saved later same way
3- the intensity binned (no filters) -> saved later *10, in 16 bits
4- the intensity not binned (no filters) -> saved later *10, in 16 bits
5-	the anisotropy parameter rho not-filtered with all values -> saved later *10000, in 16 bits
6-	the rho filtered (pixels with R2>0.5 and 1<rho<3) -> saved later *10000, in 16 bits
7-	R2 not filtered-> saved later *10000, in 16 bits
At the end, all of these maps are saved (for SHG, and only intensity maps for other modalities such as 2PEF) in a sub-directory.  

## 3- The mosaic reconstruction python code
The code takes several parameters for reconstruction of mosaics exactly as in the stitching plugin in ImageJ. 
It starts with the z plane and channel wanted, stitches the intensity map and saved the tiles configuration text file for stitching other images. 
It stitches other z planes of this same map and channel and stacks them (with the right scale). 
Then, all intensity maps and R2 are stitched and saved in other channels similarly. 
So far, the stitching is done using Linear Blending fusion.
Finally, the orientation and anisotropy maps are stitched without linear blending, by cutting at the center of the overlapping region for stitching neighboring tiles. 

## 4- The organization analysis python code
Given a directory containig folders for all samples, this code calculated the organization level over the orientation maps saved from p-SHG (forward direction). 
The metrics considered are the entropy and circular variance, calculated over pixels with R2>0.7. 
The results are saved in an excel sheet. 
