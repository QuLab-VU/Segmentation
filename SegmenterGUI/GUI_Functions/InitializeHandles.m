function [handles] = InitializeHandles(handles)
handles.imExt        = get(findobj('Tag','edit6'),'String');
handles.numCh        = str2double(get(findobj('Tag','edit4'),'String'));
handles.NucnumLevel  = str2double(get(findobj('Tag','edit11'),'String'));
handles.CytonumLevel = str2double(get(findobj('Tag','edit14'),'String'));
handles.col          = get(findobj('Tag','edit9'),'String');
handles.row          = get(findobj('Tag','edit8'),'String');
handles.ChtoSeg      = str2double(get(findobj('Tag','edit12'),'String'));
handles.Parallel     = get(findobj('Tag','checkbox6'),'Value');

if get(findobj('Tag','checkbox7'),'Value')
    handles.ChtoSeg = 0;
end

handles.nuclear_segment         = get(findobj('Tag','checkbox2'),'Value');
handles.surface_segment         = get(findobj('Tag','checkbox3'),'Value');
handles.nuclear_segement_factor = str2double(get(findobj('Tag','edit2'),'String'));
handles.surface_segment_factor  = str2double(get(findobj('Tag','edit3'),'String'));
handles.smoothing_factor        = str2double(get(findobj('Tag','edit10'),'String'));
handles.nuc_noise_disk          = str2double(get(findobj('Tag','edit15'),'String'));
handles.noise_disk              = str2double(get(findobj('Tag','edit7'),'String'));

contents = cellstr(get(findobj('Tag','popupmenu1'),'String'));
handles.BackCorrMethod = contents{get(findobj('Tag','popupmenu1'),'Value')};

%Which background correction method?
switch handles.BackCorrMethod
    case 'Rolling_Ball'
        handles.rollfilter = str2double(get(handles.edit17,'String'));
    case 'Const_Threshold'
        handles.back_thresh = get(handles.slider4,'Value');
    case 'GainMap_Image'
        if isempty(handles.CorrIm_file)
            msgbox('Error: No Control Image Selected')
            return
        end
        for q = 1:handles.numCh+1
            handles.GainMap(:,:,q) =  double(imread(handles.CorrIm_file{q}));
        end
    case 'Control_Image'
        if isempty(handles.CorrIm_file)
            msgbox('Error: No Control Image Selected')
            return
        end
        for q = 1:handles.numCh+1
            handles.CorrMap(:,:,q) =  double(imread(handles.CorrIm_file{q}));
        end
    case 'CIDRE'
        if isempty(handles.cidreDir)
            msgbox('Error: No CIDRE Directory Selected')
            return
        end        
        handles.CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
        handles.CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
end

handles.BFnuc = get(findobj('Tag','checkbox11'),'Value');

%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
%A lot of messy code to set up the file structure depending on whether it
%is the bd pathway or cellavista instrument.
well_cnt = 1;
if handles.bd_pathway
    if isempty(handles.nucIm) && handles.numCh>0
        [tmp, ~] = uigetfile('*.*','Select first nuclear image in any well',handles.expDir);
        idx = strfind(tmp,'n0');
        handles.nucIm = tmp(1:idx+1);
        for i= 1:handles.numCh
            [tmp, ~] = uigetfile('*.*',sprintf('Select first image for CH %i in any well',i),handles.expDir);
            idx = strfind(tmp,'n0');
            handles.cytoIm{i} = {tmp(1:idx+1)};
        end
    end
    %Set up structure with the filenames of the images to be segmented
    %Nuclei Directory (N)
    filenms = dir(handles.expDir);NUC = struct('filnms',cell(1));
    for q = 1:handles.numCh
        chnm = ['CH_' num2str(q)];
        Cyto.(chnm) = struct('filnms',cell(1));
    end
    for i = 3:length(filenms)
        idx = strfind(filenms(i).name, 'Well ');
        if filenms(i).isdir && ~isempty(idx)
            [temp] = dir([handles.expDir filesep filenms(i).name filesep handles.nucIm '*']);
            if isempty(NUC.filnms)
                NUC.filnms = {strcat(handles.expDir, filesep, filenms(i).name, filesep, temp.name)};
            else
                NUC.filnms = [NUC.filnms; {strcat(handles.expDir, '/', filenms(i).name, filesep, temp.name)}];
            end
            for q = 1:handles.numCh
                chnm = ['CH_' num2str(q)];
                if isempty(Cyto.(chnm).filnms)
                    temp = dir(char(strcat(handles.expDir,filesep,filenms(i).name,filesep,handles.cytoIm{q},'*')));
                    Cyto.(chnm).filnms = {strcat(handles.expDir,filesep,filenms(i).name,filesep,temp.name)};
                else
                    temp = dir(char(strcat(handles.expDir,filesep,filenms(i).name,filesep,handles.cytoIm{q},'*')));
                    Cyto.(chnm).filnms = [Cyto.(chnm).filnms; strcat(handles.expDir,filesep,filenms(i).name,filesep,temp.name)];
                end                
            end
            well_cnt = well_cnt+1;
        end
    end
    if isempty(NUC.filnms)
        msgbox('You are not in a directory with images in file structure "Well ###"... Or maybe you forgot to change the Row Col boxes to match the correct format.  Try again')
        return
    end
    handles.NUC = NUC;
    handles.Cyto = Cyto;
else
    NUC.dir = 'Nuc';
    NUC.filnms = dir([handles.expDir filesep NUC.dir filesep '*' handles.imExt]);
    NUC.filnms = strcat(handles.expDir, '/', {NUC.dir}, '/', {NUC.filnms.name});
    if isempty(NUC.filnms)
        msgbox('You are not in a directory with sorted images... Try again')
        return
    end

    %Create a structure for each of the channels
    for i = 1:handles.numCh
        chnm = ['CH_' num2str(i)];
        Cyto.(chnm).dir = chnm;
        Cyto.(chnm).filnms = dir([handles.expDir filesep chnm filesep '*' handles.imExt]);
        Cyto.(chnm).filnms = strcat(handles.expDir, '/',chnm, '/', {Cyto.(chnm).filnms.name});
    end
    if handles.numCh==0
        Cyto = struct();
    end
    %Correct directory listings based on the number in the image file between the - -
    %eg the 1428 in the file name 20150901141237-1428-R05-C04.jpg
    %This is necessary due to matlab dir command sorting placing 1000 ahead of
    %999.
    val = zeros(size(NUC.films,2),1);
    for i = 1:size(NUC.filnms,2)
        str = (NUC.filnms{i});idx = strfind(str,'-');
        val(i) = str2double(str(idx(1)+1:idx(2)-1));
    end
    [~, idx] = sort(val);
    NUC.filnms = NUC.filnms(idx);
    for j = 1:handles.numCh
        chnm = ['CH_' num2str(j)];
        size(Cyto.(chnm).filnms)
        size(NUC.filnms)
        for i = 1:size(NUC.filnms,2)
            str = (Cyto.(chnm).filnms{i});idx = strfind(str,'-');
            val(i) = str2double(str(idx(1)+1:idx(2)-1));
        end
        [~, idx] = sort(val);
        Cyto.(chnm).filnms = Cyto.(chnm).filnms(idx);
    end
    handles.NUC = NUC;
    handles.Cyto = Cyto;
end



