clear all 
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
% imtool close all;  % Close all imtool figures if you have the Image Processing Toolbox.
% clear;  % Erase all existing variables. Or clearvars if you want.
% workspace;  % Make sure the workspace panel is showing.
% format short g;
% format compact;
% fontSize = 20;


outerRadius = 50;		% outer radius of the colour ring
innerRadius = 10;		% inner radius of the colour ring
numberOfSectors = 256;		% number of colour segments
grayLevel = 0;		% Gray level outside the wheel.



% Get polar coordinates of each point in the domain
[x, y] = meshgrid(-outerRadius : outerRadius);
% x=[xt -xt; xt -xt];
% y=[yt -yt; yt -yt];
[theta, rho] = cart2pol(x, y); % theta is an image here.

% Set up color wheel in hsv space.
hueImage = (theta + pi) / (2 * pi);     % Hue is in the range 0 to 1.
hueImage = ceil(hueImage * numberOfSectors) / numberOfSectors;   % Quantize hue 
saturationImage = ones(size(hueImage));      % Saturation (chroma) = 1 to be fully vivid.

% Make it have the wheel shape.
% Make a mask 1 in the wheel, and 0 outside the wheel.
wheelMaskImage = rho >= innerRadius & rho <= outerRadius;
% Hue and Saturation must be zero outside the wheel to get gray.
hueImage(~wheelMaskImage) = nan;
saturationImage(~wheelMaskImage) = nan;
hueImage=abs(hueImage*2-1)';
% Value image must be 1 inside the wheel, and the normalized gray level outside the wheel.
normalizedGrayLevel = grayLevel / 255;
valueImage = ones(size(hueImage)); % Initialize to all 1
valueImage(~wheelMaskImage) = normalizedGrayLevel;	% Outside the wheel = the normalized gray level.

sc(hueImage,'hsv',[0 0 0]);

