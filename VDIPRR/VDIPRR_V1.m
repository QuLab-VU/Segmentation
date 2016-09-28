function varargout = VDIPRR_V1(varargin)
% VDIPRR_V1 MATLAB code for VDIPRR_V1.fig
%      VDIPRR_V1, by itself, creates a new VDIPRR_V1 or raises the existing
%      singleton*.
%
%      H = VDIPRR_V1 returns the handle to a new VDIPRR_V1 or the handle to
%      the existing singleton*.
%
%      VDIPRR_V1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VDIPRR_V1.M with the given input arguments.
%
%      VDIPRR_V1('Property','Value',...) creates a new VDIPRR_V1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VDIPRR_V1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VDIPRR_V1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VDIPRR_V1

% Last Modified by GUIDE v2.5 14-Sep-2016 11:37:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VDIPRR_V1_OpeningFcn, ...
                   'gui_OutputFcn',  @VDIPRR_V1_OutputFcn, ...
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


% --- Executes just before VDIPRR_V1 is made visible.
function VDIPRR_V1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VDIPRR_V1 (see VARARGIN)

% Choose default command line output for VDIPRR_V1
addpath('GUI_Functions','BayesClassifier')
handles.axes1
handles.output = hObject;
%Initialize the default settings.  If you wish to change them you must
%change them both here and in the guide editor of the specific field you
%wish to change.
%Experimental Directory
handles.expDir  = 'Desktop';
handles.masterDir = 'Desktop';
%Image Extension
handles.imExt = '.tif';
%Number of levels to use in Otsu's thresholding for the nuclear stain
handles.NucnumLevel = 3;
%Size of disk applied to nuclear channel to filter out noise
handles.nuc_noise_disk = 7;
%Factor to smooth the segementation by dilating and eroding the binarized
%image
handles.smoothing_factor = 1; 
%Clear the border cells?
handles.cl_border = 1;
%Keep track of the image number
handles.imNum = 1;
%Value to assist watershed algorithm in splitting nuclei. See lines 91-95
%in NaiveSegmentv2
handles.NucSegHeight = 1;
%Directory of the Cidre map
handles.cidreDir = 'CIDRE_correction_maps' ;
%If using a control image to correct for illumination
handles.CorrIm_file = 'DsRed-Control.tif';
%For constant thresholding
handles.back_thresh = 0;
%Constrast of image
handles.contrast = 1;
%Stores whether to segment the plate
handles.proceed = 0; handles.startdate = date;
%Handles
handles.BatchExp = 0;
handles.whichExp = [];

handles; %Show handles in command window after starting up
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VDIPRR_V1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VDIPRR_V1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Sort out segmentation parameters using the findobj() function to find the
%current value of every field

%Find if this is a batch job..
handles.BatchExp = get(handles.checkbox11,'Value');
%Deal with user option to either over write, write new, or skip


handles.choice = questdlg('How would you like to treat previously existing results?', ...
	'File Overwrite Options', ...
	'Overwrite (old will be deleted)','Rewrite (new folder will be created)','Skip','Skip');

if isempty(handles.choice)
    error('Must choose an option for dealing with files')
end

%If you want the handles structure to be saved in your home directory
%Makes it easy to find errors in the code.
%save(['Handles.mat'],'handles')
if handles.BatchExp %If a batch experiment
    All_Exp = dir(handles.masterDir); %Find all the files
    t = zeros(length(All_Exp),1);
    wb = waitbar(0,'Estimated Time Remaining (hrs)');
    for i = 3:length(All_Exp) %Ignore the . and .. directory
        tic
        try %If encounters an error it will keep processing and write a textfile with the failed directories.
            if All_Exp(i).isdir %Only run if it is a directory
                handles.expDir = [handles.masterDir filesep All_Exp(i).name];
                disp(All_Exp(i).name);
                %Initialize the handles by reading parameters from each
                %widget
                [handles] = InitializeHandles_VDIPRR(handles);
                switch handles.choice
                    case 'Rewrite (new folder will be created)'
                        str = [handles.expDir filesep 'Results_' date];
                        t = exist(str,'dir');
                        if t==7
                            temp = dir([handles.expDir filesep 'Results_' date '_*']);
                            cnt = length(temp);
                            movefile([handles.expDir filesep 'Results_' date],[handles.expDir filesep 'Results_' date '_' num2str(cnt+1)])
                            movefile([handles.expDir filesep 'Segmented_' date],[handles.expDir filesep 'Segmented_' date '_' num2str(cnt+1)])
                        end
                        mkdir([handles.expDir filesep 'Results_' date ]);
                        mkdir([handles.expDir filesep 'Segmented_' date ]);
                        handles.startdate = date;
                        handles.proceed = 1;
                    case 'Overwrite (old will be deleted)'
                        handles.proceed = 1;
                        temp = dir([handles.expDir filesep 'Results*']);
                        try
                            for j = 1:length(temp)
                                rmdir([handles.expDir filesep temp(j).name],'s')
                            end
                            temp = dir([handles.expDir filesep 'Segmented*']);
                            for j = 1:length(temp)
                                rmdir([handles.expDir filesep temp(j).name],'s')
                            end
                        end
                        mkdir([handles.expDir filesep 'Segmented_' date ]);
                        mkdir([handles.expDir filesep 'Results_' date]);
                        handles.startdate = date;
                    case 'Skip'
                        temp = dir([handles.expDir filesep 'Results*']);
                        if isempty(temp)
                            handles.proceed = 1;
                            mkdir([handles.expDir filesep 'Segmented_' date ]);
                            mkdir([handles.expDir filesep 'Results_' date]);
                        else
                            handles.proceed = 0;
                        end
                end
                if handles.proceed
                    if handles.Parallel
                       MultiChSegmenter_Parallel_VDIPRR(handles)
                    else
                       MultiChSegmentNoParallel_VDIPRR(handles)
                    end
                    %Export the results of the segmentation.
                    h=msgbox('Exporting Now...');
                    ExportSegmentation_VDIPRR(handles)
                    try
                        close(h)
                    end
                end
            end
        catch
            rmdir([handles.expDir filesep 'Segmented_' date ],'s')
            rmdir([handles.expDir filesep 'Results_' date ],'s')
            disp(sprintf('There was an error segmenting %s',All_Exp(i).name))
            fid = fopen('Failed Directories.txt','wt');
            fprintf(fid,'%s\n',All_Exp(i).name);
            fclose(fid);
        end
        t(i-2) = toc;
        str = sprintf('Estimated Time Remaining (hrs): %.2f',(mean(t(1:i-2))*(length(All_Exp)-i))/3600);
        waitbar((i-2)/(length(All_Exp)-1),wb,str)
    end
else
    [handles] = InitializeHandles_VDIPRR(handles);
    switch handles.choice
        case 'Rewrite (new folder will be created)'
            str = [handles.expDir filesep 'Results_' date];
            t = exist(str,'dir');
            if t==7
                temp = dir([handles.expDir filesep 'Results_' date '_*']);
                cnt = length(temp);
                movefile([handles.expDir filesep 'Results_' date '_' cnt+1],[handles.expDir filesep 'Results_' date])
                movefile([handles.expDir filesep 'Segmented_' date],[handles.expDir filesep 'Segmented_' date '_' num2str(cnt+1)])
            end       
            mkdir([handles.expDir filesep 'Results_' date ]);
            mkdir([handles.expDir filesep 'Segmented_' date ]);
            handles.startdate = date;
            handles.proceed = 1;
        case 'Overwrite (old will be deleted)'
            handles.proceed = 1;
            temp = dir([handles.expDir filesep 'Results*']);
            try
                for j = 1:length(temp)
                    rmdir([handles.expDir filesep temp(j).name],'s')
                end
                temp = dir([handles.expDir filesep 'Segmented*']);
                for j = 1:length(temp)
                    rmdir([handles.expDir filesep temp(j).name],'s')
                end
            end
            mkdir([handles.expDir filesep 'Segmented_' date ]);
            mkdir([handles.expDir filesep 'Results_' date]);
            handles.startdate = date;
        case 'Skip'
            temp = dir([handles.expDir filesep 'Results*']);
            if isempty(temp)
                handles.proceed = 1;
                mkdir([handles.expDir filesep 'Segmented_' date ]);
                mkdir([handles.expDir filesep 'Results_' date]);
            else
                handles.proceed = 0;
            end
    end

    if handles.proceed
        if handles.Parallel
           MultiChSegmenter_Parallel_VDIPRR(handles)
        else
           MultiChSegmentNoParallel_VDIPRR(handles)
        end
        h=msgbox('Exporting Now...');
        ExportSegmentation_VDIPRR(handles)
        try
            close(h)
        end
    end
end
try
    close(wb)
end
guidata(hObject, handles);




% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

handles.cidrecorrect = (get(hObject,'Value'));
% Hint: get(hObject,'Value') returns toggle state of checkbox9
temp = get(hObject,'Value');
if temp
    set(handles.checkbox9,'Visible','off');
    set(handles.pushbutton14,'Visible','off');
else
    set(handles.checkbox9,'Visible','on');
    set(handles.pushbutton14,'Visible','on');
end
if handles.cidrecorrect == 1
    h = handles.pushbutton3';
    set(h,'Visible','on')
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cidreDir = uigetdir();
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.expDir = uigetdir();
handles.masterDir = handles.expDir;
set(hObject,'String',handles.expDir)
guidata(hObject, handles);



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.NucnumLevel = get(hObject,'Value');
h = handles.edit11;
set(h,'String',num2str(handles.NucnumLevel))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
handles.NucnumLevel = str2num(get(hObject,'String'));
h = handles.slider1;
set(h,'Value',handles.NucnumLevel)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.BatchExp = get(handles.checkbox11,'Value');

if handles.BatchExp
    All_Exp = dir(handles.expDir);
    if isempty(handles.whichExp)
        handles.expDir = [handles.masterDir filesep All_Exp(selected).name];
    else
        handles.expDir = handles.whichExp;
    end
    [handles] = InitializeHandles_VDIPRR(handles);
    set(handles.pushbutton7,'Visible','on')
    segmenterTestGUI_VDIPRR(handles)
else
    [handles] = InitializeHandles_VDIPRR(handles);
    set(handles.pushbutton7,'Visible','on')
    segmenterTestGUI_VDIPRR(handles)
end
guidata(hObject, handles);



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
handles.ChtoSeg = str2double(get(hObject,'String'))
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles] = InitializeHandles_VDIPRR(handles);
if handles.imNum ~= length(handles.im_file)
    handles.imNum = handles.imNum + 2;
else
    handles.imNum = 1;
end
pushbutton6_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%AnalysisGUI(handles.expDir)
str = sprintf('Exporting now...This box will close once finished.\n  Look in the Experiment Directory for:\nCompiled Segmentation Results.mat  Contains all data\nImage Events.csv Information about individual cells\nCell Events.csv Contains individual frame information')
h = msgbox(str)

%Send to a function to export all the data
[handles] = ExportSegmentationV4(handles)
close(h)

%set(handles.pushbutton15,'Visible','on')
%set(handles.pushbutton9,'Visible','on')

    
guidata(hObject,handles)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save([handles.expDir filesep 'Handles.mat'],'handles')
MLClassifiers(1,handles);
'hello'
guidata(hObject,handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.NucSegHeight = get(hObject,'Value');
h = handles.edit13;
set(h,'String',num2str(handles.NucSegHeight))
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
handles.NucSegHeight = str2double(get(hObject,'String'));
h = handles.slider2;
set(h,'Value',handles.NucSegHeight);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
handles.Parallel = get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
if get(hObject,'Value')
    handles.viewNuc = 1;
else
    handles.viewNuc = 0;
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = getframe(handles.axes1);
[x,map] = frame2im(h);
mkdir([handles.expDir filesep 'ExportedImages']);
filename = [handles.expDir filesep 'ExportedImages' filesep 'Image_' num2str(handles.imNum) '.png'];
imwrite(x,filename,'png')
%save([handles.expDir filesep 'Processing_parameters.mat'],'handles');
guidata(hObject,handles)


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.CytonumLevel = get(hObject,'Value')
h = handles.edit14;
set(h,'String',num2str(handles.CytonumLevel))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
handles.CytonumLevel = str2num(get(hObject,'String'));
h = handles.slider3;
set(h,'Value',handles.CytonumLevel)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
handles.nuc_noise_disk = str2double(get(hObject,'String'))
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.CorrIm_file, path] = uigetfile('*.*','Pick Correction Image');
handles.CorrIm_file = strcat(path,handles.CorrIm_file);
guidata(hObject,handles)


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
temp = get(hObject,'Value');
if temp
    set(handles.checkbox1,'Visible','off');
    set(handles.pushbutton3,'Visible','off');
    set(handles.pushbutton14,'Visible','on');
%     set(handles.checkbox10,'Visible','off');
%     set(handles.slider4,'Visible','off');
else
    set(handles.checkbox1,'Visible','on');
    set(handles.pushbutton3,'Visible','on');
%     set(handles.checkbox10,'Visible','on');
%     set(handles.slider4,'Visible','on');
end
guidata(hObject,handles)


function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

val = str2double(get(hObject,'String'));
if val <= length(handles.im_file)
    handles.imNum = val-1;
    pushbutton6_Callback(hObject, eventdata, handles)
else
    errordlg('Outside of image range')
end
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text30,'String',get(hObject,'Value'))


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
% temp = get(hObject,'Value');
% if temp
%     set(handles.checkbox1,'Visible','off');
%     set(handles.pushbutton3,'Visible','off');
%     set(handles.slider4,'Visible','on');
%     set(handles.checkbox9,'Visible','off');
%     set(handles.pushbutton14,'Visible','off');
% else
%     set(handles.checkbox1,'Visible','on');
%     set(handles.pushbutton3,'Visible','on');
%     set(handles.checkbox9,'Visible','off');
%     set(handles.pushbutton14,'Visible','off');
% end
guidata(hObject,handles)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MLClassifiers(2,handles);
guidata(hObject,handles)



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.contrast < .1
    handles.contrast = handles.contrast + .01;
elseif handles.contrast < 1
    handles.contrast = handles.contrast + .1;
else
    handles.contrast = handles.contrast + 1;
end
pushbutton6_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.contrast == .01
    msgbox('Minumum Contrast Achieved')
elseif handles.contrast < .1
    handles.contrast = handles.contrast - .01;
elseif handles.contrast < 1
    handles.contrast = handles.contrast - .1;
else
    handles.contrast = handles.contrast - 1;
end
pushbutton6_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
if get(hObject, 'Value')==1
    set(handles.pushbutton18,'Visible','On')
else
    set(handles.pushbutton18,'Visible','Off')
end

% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.whichExp = uigetdir(handles.expDir);
guidata(hObject,handles)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
%Which background correction method?
choice  = get(handles.popupmenu1,'Value');
switch choice
    case 1
        handles.BackCorrMethod = 'None';
        set(handles.pushbutton3,'Visible','Off')
        set(handles.edit18,'Visible','Off')
        set(handles.slider4,'Visible','Off')
        set(handles.pushbutton14,'Visible','Off')
        set(handles.text30,'Visible','Off')
    case 2
        handles.BackCorrMethod = 'CIDRE';
        set(handles.pushbutton3,'Visible','On')
        set(handles.edit18,'Visible','Off')
        set(handles.slider4,'Visible','Off')
        set(handles.pushbutton14,'Visible','Off')
        set(handles.text30,'Visible','Off')
    case 3
        handles.BackCorrMethod = 'RollBallFilter';
        set(handles.pushbutton3,'Visible','Off')
        set(handles.edit18,'Visible','On')
        set(handles.slider4,'Visible','Off')
        set(handles.pushbutton14,'Visible','Off')
        set(handles.text30,'Visible','Off')
    case 4
        handles.BackCorrMethod = 'ConstThresh';
        set(handles.pushbutton3,'Visible','Off')
        set(handles.edit18,'Visible','Off')
        set(handles.slider4,'Visible','On')
        set(handles.pushbutton14,'Visible','Off')
        set(handles.text30,'Visible','On')
    case 5
        handles.BackCorrMethod = 'ImageSub';
        set(handles.pushbutton3,'Visible','Off')
        set(handles.edit18,'Visible','Off')
        set(handles.slider4,'Visible','Off')
        set(handles.pushbutton14,'Visible','On')
        set(handles.text30,'Visible','Off')
end
guidata(hObject,handles)



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



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
