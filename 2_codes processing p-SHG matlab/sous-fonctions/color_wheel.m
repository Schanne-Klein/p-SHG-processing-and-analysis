clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures if you have the Image Processing Toolbox.
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format short g;
format compact;
fontSize = 20;

% Get the screen size in pixels.
screenSize = get(0,'ScreenSize')

% Ask user for the radii and number of colors.
defaultOuterDiameter = round(0.76 * screenSize(4));
defaultInnerDiameter = round(0.25 * defaultOuterDiameter);
% Define the default values.
defaultValues = {num2str(defaultOuterDiameter), num2str(defaultInnerDiameter), '36', '400'};
titleBar = 'Enter parameters';
userPrompt = {'Enter the outer diameter', 'Enter the inner diameter', 'Enter the number of color sectors', 'Enter the gray level outside the wheel'};
caUserInput = inputdlg(userPrompt, titleBar, 1, defaultValues);
if isempty(caUserInput),return,end; % Bail out if they clicked Cancel.
% Extract parameters,
outerRadius = str2num(caUserInput{1}) / 2;		% outer radius of the colour ring
innerRadius = str2num(caUserInput{2}) / 2;		% inner radius of the colour ring
numberOfSectors = str2num(caUserInput{3});		% number of colour segments
grayLevel = str2num(caUserInput{4});		% Gray level outside the wheel.
% Check for a valid number.
if isempty(outerRadius)
    % They didn't enter a number.  
    % They clicked Cancel, or entered a character, symbols, or something else not allowed.
    outerRadius = str2double(defaultValues{1});
    message = sprintf('Outer radius must be a number.\nI will use %d and continue.', outerRadius);
    uiwait(warndlg(message));
end
if isempty(innerRadius)
    % They didn't enter a number.  
    % They clicked Cancel, or entered a character, symbols, or something else not allowed.
    innerRadius = str2double(defaultValues{2});
    message = sprintf('Inner radius must be a number.\nI will use %d and continue.', innerRadius);
    uiwait(warndlg(message));
end
if isempty(numberOfSectors)
    % They didn't enter a number.  
    % They clicked Cancel, or entered a character, symbols, or something else not allowed.
    numberOfSectors = str2double(defaultValues{3});
    message = sprintf('Number of sectors must be a number.\nI will use %d and continue.', numberOfSectors);
    uiwait(warndlg(message));
end
if numberOfSectors < 1 || numberOfSectors > 256
	numberOfSectors = 256;
end

% Get polar coordinates of each point in the domain
[x, y] = meshgrid(-outerRadius : outerRadius);
[theta, rho] = cart2pol(x, y); % theta is an image here.

% Set up color wheel in hsv space.
hueImage = (theta + pi) / (2 * pi);     % Hue is in the range 0 to 1.
hueImage = ceil(hueImage * numberOfSectors) / numberOfSectors;   % Quantize hue 
saturationImage = ones(size(hueImage));      % Saturation (chroma) = 1 to be fully vivid.

% Make it have the wheel shape.
% Make a mask 1 in the wheel, and 0 outside the wheel.
wheelMaskImage = rho >= innerRadius & rho <= outerRadius;
% Hue and Saturation must be zero outside the wheel to get gray.
hueImage(~wheelMaskImage) = 0;
saturationImage(~wheelMaskImage) = 0;
% Value image must be 1 inside the wheel, and the normalized gray level outside the wheel.
normalizedGrayLevel = grayLevel / 255;
valueImage = ones(size(hueImage)); % Initialize to all 1
valueImage(~wheelMaskImage) = normalizedGrayLevel;	% Outside the wheel = the normalized gray level.

% Combine separate h, s, and v channels into a single 3D hsv image.
hsvImage = cat(3, hueImage, saturationImage, valueImage);
% Convert to rgb space for display.
rgb = hsv2rgb(hsvImage);

% Display the final color wheel.
imshow(rgb);
% Add a box around it with the pixel coordinates.
% Comment out the line below if you don't want that.
axis on;
caption = sprintf('Color Wheel with %d Sectors', numberOfSectors);
title(caption, 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
