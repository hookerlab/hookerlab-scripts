function varargout = pop_gen_gui(varargin)
% POP_GEN_GUI MATLAB code for pop_gen_gui.fig
%      POP_GEN_GUI, by itself, creates a new POP_GEN_GUI or raises the existing
%      singleton*.
%
%      H = POP_GEN_GUI returns the handle to a new POP_GEN_GUI or the handle to
%      the existing singleton*.
%
%      POP_GEN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POP_GEN_GUI.M with the given input arguments.
%
%      POP_GEN_GUI('Property','Value',...) creates a new POP_GEN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pop_gen_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pop_gen_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pop_gen_gui

% Last Modified by GUIDE v2.5 29-May-2015 14:33:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pop_gen_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pop_gen_gui_OutputFcn, ...
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


% --- Executes just before pop_gen_gui is made visible.
function pop_gen_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pop_gen_gui (see VARARGIN)

% Choose default command line output for pop_gen_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

h = findobj('Tag', 'gamma_gui');
gamma_bomb_data = guidata(h);
directory = get(gamma_bomb_data.csv_dir, 'String');
set(handles.place,'String', directory);
% UIWAIT makes pop_gen_gui wait for user response (see UIRESUME)
% uiwait(handles.population_generation);


% --- Outputs from this function are returned to the command line.
function varargout = pop_gen_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list.
function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list


% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,filepath,~]=uigetfile(fullfile(pwd,'*.bld'),'Pick Data File');
cd(filepath)
set(handles.cur_file,'String',fullfile(filepath,filename))
guidata(hObject, handles);


% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add a selected file to the population list
entries = get(handles.list,'String');
value = get(handles.list,'Value');
newEntryName  = { get(handles.cur_file,'String') };

if ~strcmp(newEntryName,'Filename')
    on_list = false;
    for m=1:length(entries)
        if strcmp(entries(m),newEntryName)
            on_list = true;
        end
    end
    if ~on_list
        if value > 0 && strcmp(entries(1,:),'List of bld Data Files')
            entries = newEntryName;
            value = 1;
        else
            entries = [entries; newEntryName];
            value = value+1;
        end
        if value > 0
            set(handles.remove, 'Enable', 'on');
        end
        set(handles.list,'String',entries,'Value',value);
    else
        warndlg('This file has already been added to the list.');
    end
end


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove a selected file from the population list
entries = get(handles.list, 'String');
value = get(handles.list, 'Value');

entries(value) = [];
nentries = length(entries);

if value > nentries
    value = value-1;
end

set(handles.list,'Value',value,'String',entries)

if nentries == 0
    set(handles.remove,'Enable','off')
end


function cur_file_Callback(hObject, eventdata, handles)
% hObject    handle to cur_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cur_file as text
%        str2double(get(hObject,'String')) returns contents of cur_file as a double


% --- Executes during object creation, after setting all properties.
function cur_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cur_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in analyze.
function analyze_Callback(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Produce Parent Fraction Data from the selected population and continue on
% to analyze the rest of the data (returns to Gamma_Bomb_GUI
complete = false;
if strcmp(get(handles.list,'String'),'List of bld Data Files')
    warndlg('Please add at least one bld file to the list of data files.', 'File List Empty');
else
complete = pop_parent_fraction(get(handles.list,'String'), get(handles.place,'String'));
end
if complete
    h = findobj('Tag', 'gamma_gui');
    gamma_bomb_data = guidata(h);
    set(gamma_bomb_data.pop_gen_button, 'Enable', 'off', 'String', 'Parent Fraction Ready!');
    close(pop_gen_gui);
    return;
end



function place_Callback(hObject, eventdata, handles)
% hObject    handle to place (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of place as text
%        str2double(get(hObject,'String')) returns contents of place as a double


% --- Executes during object creation, after setting all properties.
function place_CreateFcn(hObject, eventdata, handles)
% hObject    handle to place (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_pop.
function open_pop_Callback(hObject, eventdata, handles)
% hObject    handle to open_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read in the imported population
entries = get(handles.list, 'String');
value = get(handles.list, 'Value');
[list_len,~] = size(entries);
[filename,filepath,~]=uigetfile(fullfile(pwd,'*.bld'),'Import Existing Population');
fID = fopen(fullfile(filepath,filename),'r');
list = textscan(fID,'%s\n');
fclose(fID);
new_entries = list{1};

% Account for Empty List
if list_len == 0 || (list_len == 1 && strcmp(entries(1,:),'List of bld Data Files'))
    for m=1:size(new_entries)
        if m == 1
            entries = [new_entries{m}];
        else
            entries = [entries; new_entries{m}];
        end
    end
    value = length(new_entries);
% Ensure that duplicate data files are not added
else
    for m=1:size(new_entries)
        on_list = false;
        for n=1:size(entries)
            if strcmp(entries(n,:),new_entries{m})
                on_list = true;
            end
        end
        if ~on_list
            entries = [entries; new_entries{m}];
            value = value+1;
        end
    end
end

set(handles.list,'String',entries,'Value',value);



% --- Executes on button press in save_pop.
function save_pop_Callback(hObject, eventdata, handles)
% hObject    handle to save_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Save the current list of files to be used again later (bld file)
value = get(handles.list, 'Value');
entries = get(handles.list, 'String');
if value < 2
    warndlg('Cannot save populations with fewer than 2 data files.  Please add more data files to the list.', 'Populatin Too Small');
else
    [filename,filepath] = uiputfile('population.bld', 'Save Population As');
    fID = fopen(fullfile(filepath,filename),'w');
    fprintf(fID,'%s\n',entries{:});
    fclose(fID);
end
