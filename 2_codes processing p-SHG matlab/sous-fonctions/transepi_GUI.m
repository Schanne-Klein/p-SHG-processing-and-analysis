  function varargout = transepi_GUI(varargin)
% TRANSEPI_GUI MATLAB code for transepi_GUI.fig
%      TRANSEPI_GUI, by itself, creates a new TRANSEPI_GUI or raises the existing
%      singleton*.
%
%      H = TRANSEPI_GUI returns the handle to a new TRANSEPI_GUI or the handle to
%      the existing singleton*.
%
%      TRANSEPI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRANSEPI_GUI.M with the given input arguments.
%
%      TRANSEPI_GUI('Property','Value',...) creates a new TRANSEPI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before transepi_GUI_OpeningFcn gets called.  An
%      unrecognized property image_name or invalid value makes property application
%      stop.  All inputs are passed to transepi_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help transepi_GUI

% Last Modified by GUIDE v2.5 18-Jun-2014 09:53:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @transepi_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @transepi_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before transepi_GUI is made visible.
function transepi_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin command line arguments to transepi_GUI (see VARARGIN)

% Choose default command line output for transepi_GUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes transepi_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = transepi_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function z_Callback(hObject, eventdata, handles)
% hObject    handle to z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%val = get(handles.z,'Value');

% set(handles.z,'Value',1);
draw_all(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% set(handles.z,'Max',50)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in load_fichier.
function load_fichier_Callback(hObject, eventdata, handles)
% hObject    handle to load_fichier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear filename
clear pathname
[filename2 pathname2] = uigetfile('*.mat','Sélectionner le ficher de résultat', 'C:\thèse SB\Data\Collagène fibrillé\');
load(strcat(pathname2,'\',filename2));
handles.result_path = pathname2;
handles.RHOXY = RHOXY;
handles.PHIXY = PHIXY;
handles.GOFRXY = QXY;
handles.RHOE = RHOE;
handles.PHIE = PHIE;
handles.GOFRE = QE;
handles.ROIWindow = ROIWindow; %1 X 2 Y 3 W 4 H
handles.size_win = ScanWindowParameters(1); %on suppose que la fenêtre est carrée
handles.name = Name;
set(handles.z,'Max',size(RHOE,3));
set(handles.z,'Min',1);
set(handles.z,'SliderStep',[1/(size(RHOE,3)-1) 1/(size(RHOE,3)-1)*5]);
set(handles.roi_x, 'String', ROIWindow(1));
set(handles.roi_y, 'String', ROIWindow(2));
set(handles.roi_w, 'String', ROIWindow(3));
set(handles.roi_h, 'String', ROIWindow(4));
set(handles.size_window, 'String', ScanWindowParameters(1));
set(handles.image_name, 'String', Name);
guidata(hObject, handles);

% --- Executes on button press in path_image.
function path_image_Callback(hObject, eventdata, handles)
% hObject    handle to path_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname_image = uigetdir('C:\thèse SB\data\Collagène fibrillé\', 'Sélectionner le dossier où se trouvent les images');
handles.image_path = pathname_image;
guidata(hObject, handles);

function draw_all(hObject, eventdata, handles)
k = (get(handles.z,'Value'));
numZ=num2str(k,['%05.' num2str(4) 'd']);
size_win = handles.size_win;
thresh_r2 = str2double(get(handles.thresh, 'string'));
% ROIX = str2double(get(handles.roi_x, 'string'));
ROIX = handles.ROIWindow(1);
% ROIY = str2double(get(handles.roi_y, 'string'));
ROIY = handles.ROIWindow(2);
% ROIWidth = str2double(get(handles.text, 'string'));
ROIWidth = handles.ROIWindow(3);
% ROIHeight = str2double(get(handles.text6, 'string'));
ROIHeight = handles.ROIWindow(4);
name = handles.name;

NbPixelWidth = size (handles.PHIE,1)*size_win;
NbPixelHeight = size (handles.PHIE, 2)*size_win;
Nx = size (handles.PHIE, 1);
Ny = size (handles.PHIE, 2);
Mask_xy = zeros(Nx, Ny);
    Mask_e = zeros(Nx, Ny);
    nb_xy=0;
    nb_e=0;
    rho_z_xy=0;
    rho_z_e=0;
    phi_z_xy=0;
    phi_z_e=0;
    
    for i = 1:Nx
        for j = 1:Ny
            n_x = 4+(i-1)*size_win;
            n_y = 4+(j-1)*size_win;
            if (handles.GOFRXY(i,j,k)>thresh_r2)
                Mask_xy(i,j) = (handles.GOFRXY(i,j,k)-0.5)*2;
                rho_xy(i,j) = handles.RHOXY(i,j,k);
                phi_xy(i,j)=handles.PHIXY(i,j,k);
                nb_xy=nb_xy+1;
                rho_z_xy(nb_xy)=handles.RHOXY(i,j,k);
                phi_z_xy(nb_xy)=handles.PHIXY(i,j,k);
            else
                Mask_xy(i,j) = 0;
                rho_xy(i,j) = 0;
                phi_xy(i,j) = 0;
            end
            
            if (handles.GOFRE(i,j,k)>thresh_r2)
                Mask_e(i,j) = (handles.GOFRE(i,j,k)-0.5)*2;
                rho_e(i,j) = handles.RHOE(i,j,k);
                phi_e(i,j) = handles.PHIE(i,j,k);
                nb_e=nb_e+1;
                rho_z_e(nb_e)=handles.RHOE(i,j,k);
                phi_z_e(nb_e)=handles.PHIE(i,j,k);
            else
                Mask_e(i,j) = 0;
                rho_e(i,j) = 0;
                phi_e(i,j) = 0;
            end  
        end
    end
 
table(1,1) = mean(rho_z_xy);
table(2,1) = std(rho_z_xy);
table(3,1) = nb_xy;
table(1,2) = mean(rho_z_e);
table(2,2) = std(rho_z_e);
table(3,2) = nb_e;
table(4,1) = k;
table(5,1) = mean(phi_z_xy);
table(6,1) = std(phi_z_xy);
table(5,2) = mean(phi_z_e);
table(6,2) = std(phi_z_e);
set(handles.rho_table, 'Data', table);

rect = [ROIX ROIY ROIWidth ROIHeight];
numZ=num2str(k,['%05.' num2str(4) 'd']);
Ixy = imread(strcat(handles.image_path,'\',name,'.shgXYsum_z ',numZ,'.tif'));
% '.shgXYsum_z'
Ixy = imcrop(Ixy, rect);
Ie = imread(strcat(handles.image_path,'\',name,'.shgEpisum_z',numZ,'.tif'));
% .shgEpisum_z
Ie = imcrop(Ie, rect);

[X Y] = meshgrid (size_win/2:size_win:NbPixelHeight-size_win/2,size_win/2:size_win:NbPixelWidth-size_win/2);

key = get(handles.quiveronoff,'Value');
saveon = get(handles.pushbutton4, 'Value');

axes(handles.axes1);
if saveon
    I1 = figure(1);
end
imshow(Ixy, []);
colormap(gray);
%imagesc(Ixy);
if key
    hold on;
    quiver (X,Y,size_win*Mask_xy(:,:).*cos(handles.PHIXY(:,:,k)*pi/180),size_win*Mask_xy(:,:).*sin(handles.PHIXY(:,:,k)*pi/180),'LineWidth',1.5, 'Color','k');
    set(gca,'YDir','reverse');
    %axis([-size_window NbPixelWidth -size_window NbPixelHeight]);
    axis([0 NbPixelHeight 0 NbPixelWidth]);
    axis off;
    hold off;
end
if saveon
    name1 = strcat('Itrans_fromGUI_',numZ);
    saveas(I1,strcat(handles.result_path,'\',name1),'jpg');
    %%
    figure(10)
    quiver (X,Y,size_win*Mask_xy(:,:).*cos(handles.PHIXY(:,:,k)*pi/180),size_win*Mask_xy(:,:).*sin(handles.PHIXY(:,:,k)*pi/180),'LineWidth',1.5, 'Color','k');
    set(gca,'YDir','reverse');
    axis([0 NbPixelHeight 0 NbPixelWidth]);
    %%
end

axes(handles.axes2);
if saveon
    I2 = figure(2);
end
imshow(Ie,[]);
%imagesc(Ie);
colormap('gray');
if key
    hold on;
    quiver (X,Y,size_win*Mask_e(:,:).*cos(handles.PHIE(:,:,k)*pi/180),size_win*Mask_e(:,:).*sin(handles.PHIE(:,:,k)*pi/180), 'LineWidth',1.5,'Color','k');
    set(gca,'YDir','reverse');
    %axis([-size_window NbPixelWidth -size_window NbPixelHeight]);
    axis([0 NbPixelHeight 0 NbPixelWidth]);
    axis off;
    hold off;
end
if saveon
    name1 = strcat('Iepi_fromGUI_',numZ);
    saveas(I2,strcat(handles.result_path,'\',name1),'jpg');
end

axes(handles.axes3);
if saveon
    I3 = figure(3);
end
pcolor(rho_xy(:,:));
colormap('jet');
shading flat;
axis([1 Ny 1 Nx]);
set(gca,'YDir','reverse');
axis equal;
caxis([1 1.5]);
% colorbar;
axis off;
if saveon
    name1 = strcat('rhotrans_fromGUI_',numZ);
    saveas(I3,strcat(handles.result_path,'\',name1),'jpg');
end

axes(handles.axes4)
if saveon
    I4 = figure(4);
end
pcolor(rho_e(:,:));
%colormap('jet');
shading flat;
axis([1 Ny 1 Nx]);
set(gca,'YDir','reverse');
axis equal;
caxis([1 1.5]);
% colorbar;
axis off;
if saveon
    name1 = strcat('rhoepi_fromGUI_',numZ);
    saveas(I4,strcat(handles.result_path,'\',name1),'jpg');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function size_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to size_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function thresh_Callback(hObject, eventdata, handles)
% hObject    handle to thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh as text
%        str2double(get(hObject,'String')) returns contents of thresh as a double
draw_all(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function roi_x_Callback(hObject, eventdata, handles)
% hObject    handle to roi_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_x as text
%        str2double(get(hObject,'String')) returns contents of roi_x as a double

% --- Executes during object creation, after setting all properties.
function roi_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function roi_y_Callback(hObject, eventdata, handles)
% hObject    handle to roi_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_y as text
%        str2double(get(hObject,'String')) returns contents of roi_y as a double

% --- Executes during object creation, after setting all properties.
function roi_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function roi_w_Callback(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text as text
%        str2double(get(hObject,'String')) returns contents of text as a double

% --- Executes during object creation, after setting all properties.
function roi_w_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function roi_h_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text6 as text
%        str2double(get(hObject,'String')) returns contents of text6 as a double

% --- Executes during object creation, after setting all properties.
function roi_h_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function image_name_Callback(hObject, eventdata, handles)
% hObject    handle to image_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of image_name as text
%        str2double(get(hObject,'String')) returns contents of image_name as a double

% --- Executes during object creation, after setting all properties.
function image_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(ancestor(hObject,'figure'))

function size_window_Callback(hObject, eventdata, handles)
% hObject    handle to size_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of size_window as text
%        str2double(get(hObject,'String')) returns contents of size_window as a double

% --- Executes on button press in quiveronoff.
function quiveronoff_Callback(hObject, eventdata, handles)
% hObject    handle to quiveronoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
draw_all(hObject, eventdata, handles);

% Hint: get(hObject,'Value') returns toggle state of quiveronoff

% --------------------------------------------------------------------
function ax1_Callback(hObject, eventdata, handles)
% hObject    handle to ax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to ax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function plot_ax1_Callback(hObject, eventdata, handles)
% hObject    handle to plot_ax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function plot_axes1_Callback(hObject, eventdata, handles)
% hObject    handle to plot_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
draw_all(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes during object deletion, before destroying properties.
function axes3_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
