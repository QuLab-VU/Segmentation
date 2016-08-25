function [] = MLClassifiers(option,handles)
    if option == 1
        [classMat,classLabel,im_cell_id] = CreateClassifier(handles,[],[],cell(0));
        %Now Build a classifier
        
        
        msgbox('Good One!')
        %Save the results
        str = sprintf('%s/Classifier_%s.mat',handles.expDir,date);
        save(str,'classMat','classLabel','im_cell_id')
    elseif option == 2
        %Add to existing classifier
        [filename, pathname] = uigetfile('*.mat','Select Classifier')
        load([pathname filesep filename]);
        if ~exist('classMat')
            msgbox('You did not select a file with classifier info!')
            return
        end
        [classMat,classLabel,im_cell_id] = CreateClassifier(handles,classMat,classLabel,im_cell_id);

    else
        [filename, pathname] = uigetfile('*.mat','Select Classifier')
        if isequal(filename,0) || isequal(pathname,0)
           msgbox('You must select a file or click Create Classifier')
           return
        end
        load([pathname filesep filename]);
        
    end
    
    %Now 