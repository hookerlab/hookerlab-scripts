function varargout = gamma_bomb_gui(varargin)
% GAMMA_BOMB_GUI MATLAB code for gamma_bomb_gui.fig
%      GAMMA_BOMB_GUI, by itself, creates a new GAMMA_BOMB_GUI or raises the existing
%      singleton*.
%
%      H = GAMMA_BOMB_GUI returns the handle to a new GAMMA_BOMB_GUI or the handle to
%      the existing singleton*.
%
%      GAMMA_BOMB_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMMA_BOMB_GUI.M with the given input arguments.
%
%      GAMMA_BOMB_GUI('Property','Value',...) creates a new GAMMA_BOMB_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamma_bomb_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamma_bomb_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamma_bomb_gui

% Last Modified by GUIDE v2.5 03-Jun-2015 15:19:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamma_bomb_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gamma_bomb_gui_OutputFcn, ...
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


% --- Executes just before gamma_bomb_gui is made visible.
function gamma_bomb_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gamma_bomb_gui (see VARARGIN)

% Choose default command line output for gamma_bomb_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gamma_bomb_gui wait for user response (see UIRESUME)
% uiwait(handles.gamma_gui);


% --- Outputs from this function are returned to the command line.
function varargout = gamma_bomb_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function xls_ffile_Callback(hObject, eventdata, handles)
% hObject    handle to xls_ffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xls_ffile as text
%        str2double(get(hObject,'String')) returns contents of xls_ffile as a double


% --- Executes during object creation, after setting all properties.
function xls_ffile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xls_ffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in get_xls_ffile.
function get_xls_ffile_Callback(hObject, eventdata, handles)
% hObject    handle to get_xls_ffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,filepath,~]=uigetfile(fullfile(pwd,'*.xls;*xlsx'),'Pick Template File');
cd(filepath)
set(handles.xls_ffile,'String',fullfile(filepath,filename))
guidata(hObject, handles);


function csv_dir_Callback(hObject, eventdata, handles)
% hObject    handle to csv_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of csv_dir as text
%        str2double(get(hObject,'String')) returns contents of csv_dir as a double


% --- Executes during object creation, after setting all properties.
function csv_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to csv_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in get_csv_dir.
function get_csv_dir_Callback(hObject, eventdata, handles)
% hObject    handle to get_csv_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.csv_dir,'String',uigetdir(pwd))
guidata(hObject, handles);

% --- Executes on selection change in tracer.
function tracer_Callback(hObject, eventdata, handles)
% hObject    handle to tracer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tracer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tracer


% --- Executes during object creation, after setting all properties.
function tracer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in allons_y.
function allons_y_Callback(hObject, eventdata, handles)
% hObject    handle to allons_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','ligand',get(handles.ligand,'String'));
cd(get(handles.csv_dir,'String'));

% Quickly check data to make sure all the times make sense
dlg={'***Template***'};
template_TOI=datestr(xlsread(get(handles.xls_ffile,'String'),4),'HH:MM:SS');
dlg(end+1)={['Template TOI = ' template_TOI]};
col_mx=xlsread(get(handles.xls_ffile,'String'),2);
first_sample_t=datestr(col_mx(2,1),'HH:MM:SS');
dlg(end+1)={['First Draw Time = ' first_sample_t]};

% First csv file
dlg(end+1)={'***CSV***'};
csv_files=ls(get(handles.csv_dir,'String'));
fid_in = fopen(fullfile(get(handles.csv_dir,'String'),csv_files(3,:)),'r');
csv_dat_str = '%d%s%s%d%d%d%d%d%f%s%f%f%f%s';
csv_dat= textscan(fid_in,csv_dat_str,'delimiter',',','HeaderLines',1,'EndOfLine','\n');
csv_read_t=datestr(csv_dat{3}{1},'HH:MM:SS');
dlg(end+1)={['First Read Time = ' csv_read_t]};

% Bay 6 Dose info and Frame1.hdr
hd=home_dir(get(handles.xls_ffile,'String'));
if exist(fullfile(hd,'PET','Dose_info.xls'),'file')
    dlg(end+1)={'***Dose Info***'};
    di=xlsread(fullfile(hd,'PET','Dose_info.xls'),1);
    dose_calib_t=datestr(di(3,7),'HH:MM:SS');
    dlg(end+1)={['Dose Calib. Time = ' dose_calib_t]};
    Series_t=datestr(di(3,1),'HH:MM:SS');
    dlg(end+1)={['Series Time = ' Series_t]};
    Acq_t=datestr(di(3,1),'HH:MM:SS');
    dlg(end+1)={['Acq Time = ' Acq_t]};
end
dlg(end+1)={'***Frame 1***'};
if exist(fullfile(hd,'PET','Frame1.lst.hdr'),'file')
    pd=read_i_hdr(fullfile(hd,'PET','Frame1.lst.hdr'));
    PET_start_t=pd.StudyTimeHhMmSs;
elseif exist(fullfile(hd,'PET','Frame1.hdr'),'file')
    pd=read_i_hdr(fullfile(hd,'PET','Frame1.hdr'));
    PET_start_t=pd.StudyTimeHhMmSs;
else
    PET_start_t='';
end
dlg(end+1)={['Frame1.lst.hdr Start Time = ' PET_start_t]};
dlg(end+1)={''};
dlg(end+1)={'Do these times make sense?'};
button=questdlg(dlg);

% Was a population curve generated for the parent fraction?
population_bool = false;
if (strcmp(get(handles.pop_gen_button, 'String'), 'Parent Fraction Ready!'))
    population_bool = true;
end

% Begin Data Analysis if times make sense
switch button
    case 'Yes'
contents = cellstr(get(handles.tracer,'String'));
format = cellstr(get(handles.report_format,'String'));
    display(get(handles.xls_ffile,'String'))
    display(get(handles.csv_dir,'String'))
    display(contents{get(handles.tracer,'Value')})
    display(str2num(get(handles.bkgnd,'String')))
if isempty(get(handles.bkgnd,'String'))
gamma_bomb(get(handles.xls_ffile,'String'),get(handles.csv_dir,'String'),...
    contents{get(handles.tracer,'Value')},get(handles.met_cor,'Value'),...
    get(handles.dose_info_ffile, 'String'), format{get(handles.report_format, 'Value')},population_bool)
else
    display('Static Background Entered...')
gamma_bomb(get(handles.xls_ffile,'String'),get(handles.csv_dir,'String'),...
    contents{get(handles.tracer,'Value')},get(handles.met_cor,'Value'),...
    get(handles.dose_info_ffile, 'String'), format{get(handles.report_format, 'Value')},population_bool,str2num(get(handles.bkgnd,'String')))    
end
otherwise
end

function bkgnd_Callback(hObject, eventdata, handles)
% hObject    handle to bkgnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bkgnd as text
%        str2double(get(hObject,'String')) returns contents of bkgnd as a double


% --- Executes during object creation, after setting all properties.
function bkgnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bkgnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in met_cor.
function met_cor_Callback(hObject, eventdata, handles)
% hObject    handle to met_cor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of met_cor


% --- Executes on button press in adj_csv.
function adj_csv_Callback(~, eventdata, handles)
% hObject    handle to adj_csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time_inc_GUI


% --- Executes on button press in dose_info.
function dose_info_Callback(hObject, eventdata, handles)
% hObject    handle to dose_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,filepath,~]=uigetfile(fullfile(pwd,'*.xls;*xlsx'),'Pick Dose Info File');
cd(filepath)
set(handles.dose_info_ffile,'String',fullfile(filepath,filename))
guidata(hObject, handles);



function dose_info_ffile_Callback(hObject, eventdata, handles)
% hObject    handle to dose_info_ffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dose_info_ffile as text
%        str2double(get(hObject,'String')) returns contents of dose_info_ffile as a double


% --- Executes during object creation, after setting all properties.
function dose_info_ffile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dose_info_ffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in report_format.
function report_format_Callback(hObject, eventdata, handles)
% hObject    handle to report_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns report_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from report_format


% --- Executes during object creation, after setting all properties.
function report_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to report_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pop_gen_button.
function pop_gen_button_Callback(hObject, eventdata, handles)
% hObject    handle to pop_gen_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (strcmp(get(handles.csv_dir,'String'),'Edit Text'))
    warndlg('Please choose a CSV dir before continuing.', 'Must Select CSV Directory');
else
   pop_gen_gui();
   %set(handles.pop_gen_button, 'Enable', 'off', 'String', 'Parent Fraction Ready!');
end



function ligand_Callback(hObject, eventdata, handles)
% hObject    handle to ligand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ligand as text
%        str2double(get(hObject,'String')) returns contents of ligand as a double


% --- Executes during object creation, after setting all properties.
function ligand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ligand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end
