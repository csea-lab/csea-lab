function varargout = goop(varargin)
% GOOP M-file for goop.fig
%      GOOP, by itself, creates a new GOOP or raises the existing
%      singleton*.
%
%      H = GOOP returns the handle to a new GOOP or the handle to
%      the existing singleton*.
%
%      GOOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GOOP.M with the given input arguments.
%
%      GOOP('Property','Value',...) creates a new GOOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before goop_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to goop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help goop

% Last Modified by GUIDE v2.5 21-Feb-2012 14:18:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @goop_OpeningFcn, ...
                   'gui_OutputFcn',  @goop_OutputFcn, ...
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


% --- Executes just before  goop is made visible.
function  goop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wavelet_GUI (see VARARGIN)

% Choose default command line output for goop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes goop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = goop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function sensorNum_Callback(hObject, eventdata, handles)
% hObject    handle to sensorNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensorNum as text
%        str2double(get(hObject,'String')) returns contents of sensorNum as a double


% --- Executes during object creation, after setting all properties.
function sensorNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensorNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function baseline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in baseline.
function baseline_Callback(hObject, eventdata, handles)
% hObject    handle to baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of baseline





function dataFileName_Callback(hObject, eventdata, handles)
% hObject    handle to dataFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataFileName as text
%        str2double(get(hObject,'String')) returns contents of dataFileName as a double


% --- Executes during object creation, after setting all properties.
function dataFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataFileName = get(handles.dataFileName, 'string');
load(dataFileName)
sensorNum = str2num(get(handles.sensorNum, 'string'));
startBase = round(str2num(get(handles.startBase, 'string'))/4);
endBase = round(str2num(get(handles.endBase, 'string'))/4);
startAxis = str2num(get(handles.startAxis, 'string'));
endAxis = str2num(get(handles.endAxis, 'string'));
bar = get(handles.colorbar, 'Value');
figure

bsc = get(handles.baseline, 'Value');
if bsc == 0
    
if length(sensorNum) == 1 
    if bar == 0 
       contourf(WaData.tAxis,WaData.fAxis,squeeze(WaData.WaPower(sensorNum,:,:))');colorbar
    else 
       contourf(WaData.tAxis,WaData.fAxis,squeeze(WaData.WaPower(sensorNum,:,:))');caxis([startAxis endAxis]),colorbar
    end
else
    if bar == 0 
       contourf(WaData.tAxis,WaData.fAxis,squeeze(mean(WaData.WaPower(sensorNum,:,:),1))');colorbar
    else 
       contourf(WaData.tAxis,WaData.fAxis,squeeze(mean(WaData.WaPower(sensorNum,:,:),1))');caxis([startAxis endAxis]),colorbar 
    end
end

elseif bsc ==1
    
if length(sensorNum) == 1 
    if bar == 0 
        contourf(WaData.tAxis,WaData.fAxis,squeeze(bslcorrWAMat_as(WaData.WaPower(sensorNum,:,:), [startBase:endBase]))');colorbar
    else 
        contourf(WaData.tAxis,WaData.fAxis,squeeze(bslcorrWAMat_as(WaData.WaPower(sensorNum,:,:), [startBase:endBase]))');caxis([startAxis endAxis]),colorbar 
    end
else
% contourf(WaData.tAxis,WaData.fAxis,squeeze(mean(bslcorrWAMat_as(WaData.WaPower(sensorNum,:,:), [startBase:endBase])),1)');colorbar  
    if bar == 0 
        contourf(WaData.tAxis,WaData.fAxis,squeeze(bslcorrWAMat_as(mean(WaData.WaPower(sensorNum,:,:),1) , [startBase:endBase]))');colorbar
    else 
       contourf(WaData.tAxis,WaData.fAxis,squeeze(bslcorrWAMat_as(mean(WaData.WaPower(sensorNum,:,:),1) , [startBase:endBase]))');caxis([startAxis endAxis]),colorbar  %%Does this work? Baseline correcting a mean... 
    end

end

end

% --- Executes on button press in bsc.
function bsc_Callback(hObject, eventdata, handles)
% hObject    handle to bsc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bsc




% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startBase_Callback(hObject, eventdata, handles)
% hObject    handle to startBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startBase as text
%        str2double(get(hObject,'String')) returns contents of startBase as a double


% --- Executes during object creation, after setting all properties.
function startBase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endBase_Callback(hObject, eventdata, handles)
% hObject    handle to endBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endBase as text
%        str2double(get(hObject,'String')) returns contents of endBase as a double


% --- Executes during object creation, after setting all properties.
function endBase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startAxis_Callback(hObject, eventdata, handles)
% hObject    handle to startAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startAxis as text
%        str2double(get(hObject,'String')) returns contents of startAxis as a double


% --- Executes during object creation, after setting all properties.
function startAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endAxis_Callback(hObject, eventdata, handles)
% hObject    handle to endAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endAxis as text
%        str2double(get(hObject,'String')) returns contents of endAxis as a double


% --- Executes during object creation, after setting all properties.
function endAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in colorbar.
function colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colorbar

