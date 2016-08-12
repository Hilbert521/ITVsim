function varargout = ITVsim(varargin)
% ITVSIM MATLAB code for ITVsim.fig
%      ITVSIM, by itself, creates a new ITVSIM or raises the existing
%      singleton*.
%
%      H = ITVSIM returns the handle to a new ITVSIM or the handle to
%      the existing singleton*.
%
%      ITVSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ITVSIM.M with the given input arguments.
%
%      ITVSIM('Property','Value',...) creates a new ITVSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ITVsim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ITVsim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ITVsim

% Last Modified by GUIDE v2.5 30-Oct-2014 13:04:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ITVsim_OpeningFcn, ...
                   'gui_OutputFcn',  @ITVsim_OutputFcn, ...
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


% --- Executes just before ITVsim is made visible.
function ITVsim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ITVsim (see VARARGIN)

% Choose default command line output for ITVsim
handles.output = hObject;

% sets the 3D view/control of the simulation.
view(3); rotate3d on; 

% loads the .m files inside the algorithms folder.
files = dir('algorithms/*.m');
set(handles.algorithmPopup, 'String', {files.name}');
set(handles.algorithmPopup, 'Enable', 'on');
addpath(fullfile(pwd, 'algorithms'));

guidata(hObject, handles);
% UIWAIT makes ITVsim wait for user response (see UIRESUME)
% uiwait(handles.mainWindow);


% --- Outputs from this function are returned to the command line.
function varargout = ITVsim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function lodSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lodSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.lodText, 'String', round(get(hObject, 'Value')));

% --- Executes during object creation, after setting all properties.
function lodSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lodSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function samplesSlider_Callback(hObject, eventdata, handles)
% hObject    handle to samplesSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.samplesText, 'String', round(get(hObject, 'Value')));

% --- Executes during object creation, after setting all properties.
function samplesSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplesSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in generateTerrainBtn.
function generateTerrainBtn_Callback(hObject, eventdata, handles)
% hObject    handle to generateTerrainBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% gets values from sliders.
lod  = round(get(handles.lodSlider, 'Value'));
samples = round(get(handles.samplesSlider, 'Value'));

handles.colormapLength = 64;

% plots the terrain.
axes(handles.renderer); hold off;
[X, Y, Z1] = terrain(samples, lod, 'Generating terrain LOD');
handles.terrain = surf(X, Y, Z1); hold on; colormap('default');

% plots anomalies.
[X, Y, Z2] = terrain(samples, lod, 'Generating anomalies LOD');
handles.anomalies = pcolor(X, Y, Z2);
axes(handles.anomalyRenderer);
handles.anomaliesTop = pcolor(X, Y, Z2);
axes(handles.renderer);

% adjusts colormaps.
csize = handles.colormapLength; 
colormap([jet(csize); cool(csize)]);
zmin = min(Z1(:)); zmax = max(Z1(:));
set(handles.anomalies, 'ZData', 0*Z1 + zmin);
C1 = min(csize, round((csize-1)*(Z1-zmin)/(zmax-zmin))+1);
zmin = min(Z2(:)); zmax = max(Z2(:));
C2 = csize + min(csize, round((csize-1)*(Z2-zmin)/(zmax-zmin))+1);
set(handles.terrain,   'CData', C1);
set(handles.anomalies, 'CData', C2);
set(handles.anomaliesTop, 'CData', C2);
set(handles.terrain,   'CDataMapping', 'direct');
set(handles.anomalies, 'CDataMapping', 'direct');
set(handles.anomaliesTop, 'CDataMapping', 'direct');

rotate3d on; light;
shadingPopup_Callback(handles.shadingPopup, eventdata, handles);
lightingPopup_Callback(handles.lightingPopup, eventdata, handles);
guidata(hObject, handles);

% --- Executes on selection change in shadingPopup.
function shadingPopup_Callback(hObject, ~, handles)
% hObject    handle to shadingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns shadingPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shadingPopup
contents = cellstr(get(hObject,'String'));
switch contents{get(hObject, 'Value')}
    case 'Faceted'
        shading faceted;
    case 'Flat'
        shading flat;
    case 'Interp'
        shading interp;
end

% --- Executes during object creation, after setting all properties.
function shadingPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shadingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lightingPopup.
function lightingPopup_Callback(hObject, eventdata, handles)
% hObject    handle to lightingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lightingPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lightingPopup
contents = cellstr(get(hObject,'String'));
switch contents{get(hObject, 'Value')}
    case 'None'
        lighting none;
    case 'Flat'
        lighting flat;
    case 'Gouraud'
        lighting gouraud;
    case 'Phong'
        lighting phong;
end

% --- Executes during object creation, after setting all properties.
function lightingPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lightingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in simulateBtn.
function simulateBtn_Callback(hObject, eventdata, handles)
% hObject    handle to simulateBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (~isfield(handles, 'terrain') || ~isfield(handles, 'anomalies'))
    generateTerrainBtn_Callback(handles.generateTerrainBtn, eventdata, handles);
    handles = guidata(hObject);
end
robots = round(get(handles.robotsSlider, 'Value'));
set(handles.anomalyMapSlider, 'Value', 0);
set(handles.anomalyMapSlider, 'Max', robots);
set(handles.anomalyMapSlider, 'SliderStep', [1/robots, 1/robots]);
set(handles.anomalyMapSlider, 'Enable', 'on');
set(handles.stopBtn, 'Enable', 'on');
set(handles.lodSlider, 'Enable', 'off');
set(handles.simulateBtn, 'Enable', 'off');
set(handles.robotsSlider, 'Enable', 'off');
set(handles.samplesSlider, 'Enable', 'off');
set(handles.timestepSlider, 'Enable', 'off');
set(handles.saveTerrainBtn, 'Enable', 'off');
set(handles.loadTerrainBtn, 'Enable', 'off');
set(handles.generateTerrainBtn, 'Enable', 'off');
simulation(handles);

% --- Executes on slider movement.
function robotsSlider_Callback(hObject, eventdata, handles)
% hObject    handle to robotsSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.robotsText, 'String', round(get(hObject, 'Value')));

% --- Executes during object creation, after setting all properties.
function robotsSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to robotsSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function timestepSlider_Callback(hObject, eventdata, handles)
% hObject    handle to timestepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.timestepText, 'String', get(hObject, 'Value'));

% --- Executes during object creation, after setting all properties.
function timestepSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in stopBtn.
function stopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopBtn, 'Enable', 'off');
set(handles.lodSlider, 'Enable', 'on');
set(handles.simulateBtn, 'Enable', 'on');
set(handles.robotsSlider, 'Enable', 'on');
set(handles.samplesSlider, 'Enable', 'on');
set(handles.timestepSlider, 'Enable', 'on');
set(handles.saveTerrainBtn, 'Enable', 'on');
set(handles.loadTerrainBtn, 'Enable', 'on');
set(handles.generateTerrainBtn, 'Enable', 'on');
set(handles.anomalyMapSlider, 'Enable', 'off');
set(handles.anomalyMapSlider, 'Value', 0.0);

% --- Executes during object creation, after setting all properties.
function anomalyMapSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anomalyMapSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function algorithmPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to algorithmPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveTerrainBtn.
function saveTerrainBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveTerrainBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles, 'terrain') && ~isfield(handles, 'anomalies')
    uiwait(msgbox('Please generate a terrain before trying to save it.', 'Error', 'modal'));
    return;
end
[filename, pathname] = uiputfile('terrain.mat');
if ~isequal(filename, 0) && ~isequal(pathname, 0)
    XT = get(handles.terrain, 'XData');
    YT = get(handles.terrain, 'YData');
    ZT = get(handles.terrain, 'ZData');
    ZA = get(handles.anomalies, 'CData');
    save(strcat(pathname, filename), 'XT', 'YT', 'ZT', 'ZA');
end

% --- Executes on button press in loadTerrainBtn.
function loadTerrainBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadTerrainBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.mat');
if ~isequal(filename, 0) && ~isequal(pathname, 0)
    data = load(strcat(pathname, filename));
    if (~isfield(data, 'XT') || ~isfield(data, 'YT') || ~isfield(data, 'ZT') || ~isfield(data, 'ZA'))
        uiwait(msgbox(strcat(filename, ' is not a valid terrain file.'), 'Error', 'modal'));
        return;
    end
    
    % TODO: split generateTerrainBtn into modules and reuse the code.
 
    % plots the terrain.
    axes(handles.renderer); hold off;
    handles.terrain = surf(data.XT, data.YT, data.ZT); hold on; 
    colormap('default'); handles.colormapLength = 64;

    % plots anomalies.
    handles.anomalies = pcolor(data.XT, data.YT, data.ZA);
    axes(handles.anomalyRenderer);
    handles.anomaliesTop = pcolor(data.XT, data.YT, data.ZA);
    axes(handles.renderer);

    % adjusts colormaps.
    csize = handles.colormapLength; 
    colormap([jet(csize); cool(csize)]);
    zmin = min(data.ZT(:)); zmax = max(data.ZT(:));
    set(handles.anomalies, 'ZData', 0*data.ZT + zmin);
    C1 = min(csize, round((csize-1)*(data.ZT-zmin)/(zmax-zmin))+1);
    zmin = min(data.ZA(:)); zmax = max(data.ZA(:));
    C2 = csize + min(csize, round((csize-1)*(data.ZA-zmin)/(zmax-zmin))+1);
    set(handles.terrain,   'CData', C1);
    set(handles.anomalies, 'CData', C2);
    set(handles.anomaliesTop, 'CData', C2);
    set(handles.terrain,   'CDataMapping', 'direct');
    set(handles.anomalies, 'CDataMapping', 'direct');
    set(handles.anomaliesTop, 'CDataMapping', 'direct');

    rotate3d on; light;
    shadingPopup_Callback(handles.shadingPopup, eventdata, handles);
    lightingPopup_Callback(handles.lightingPopup, eventdata, handles);
    guidata(hObject, handles); 
end
