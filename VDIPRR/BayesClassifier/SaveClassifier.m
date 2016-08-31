function [] = SaveClassifier(classMat,classLabel,im_cell_id,handles)
    %Save during every picture change.
    idx = strfind(handles.expDir,'/');
    ExpName = handles.expDir(idx(end)+1:end);
    str = sprintf('%s/Classifier_%s_%s.mat',handles.expDir,date,ExpName);
    save(str,'classMat','classLabel','im_cell_id','handles')
    