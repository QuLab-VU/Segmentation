function [handles] = ExportSegmentationV5(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used

seg_file        = dir([handles.expDir filesep 'Segmented/*.mat']);
fid             = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'r');
if fid < 0
    error('Cannot open file with cell count'); 
end
data            = textscan(fid,'%s %d %s %d','delimiter','\t');
handles.totCell = double(data{2});
handles.totIm   = double(data{4});


%Reorder the files. Necessary because of matlabs strange numbering scheme
to_order = zeros(length(seg_file),1);
for j = 1:length(seg_file)
        temp_id         = strfind(seg_file(j).name,'.');
        to_order(j) = str2double(seg_file(j).name(1:temp_id-1));
end
[~, reorder_id] = sort(to_order,'ascend');
seg_file        = seg_file(reorder_id);

%Create the two tables
for i = 1:length(seg_file)
    load([handles.expDir filesep 'Segmented' filesep seg_file(i).name])
    if i == 1
        if ~isempty(CO.CData.specs.Edge)
            %CO.CData.Cyto = rmfield(CO.CData.Cyto,'class');
            temp                                           = struct2table(CO.CData.Nuc);
            temp.Properties.VariableNames                  = strcat('Nuc_', temp.Properties.VariableNames);
            len(1)                                         = length(temp.Properties.VariableNames);
            if any(strcmp('Cyto',fieldnames(CO.CData)))
                temp                                           = [temp, struct2table(CO.CData.Nuc)];
                len(2)                                         = length(temp.Properties.VariableNames);
                temp.Properties.VariableNames(len(1)+1:len(2)) = strcat('Cyto_', temp.Properties.VariableNames(len(1)+1:len(2)));
            end
            temp                                           = [temp,struct2table(CO.CData.specs)];
            for q = 1:handles.numCh
                str = ['CH_' num2str(q)];
                len(1) = length(temp.Properties.VariableNames);
                temp = [temp, struct2table(CO.CData.(str))];
                len(2) = length(temp.Properties.VariableNames);
                temp.Properties.VariableNames(len(1)+1:len(2)) = strcat(str, temp.Properties.VariableNames(len(1)+1:len(2)));
            end
            T_CellData  = temp;
            T_ImData    = struct2table(CO.ImData);
        end
    else
        if ~isempty(CO.CData.specs.Edge)
            %CO.CData.Cyto = rmfield(CO.CData.Cyto,'class');
            temp                          = struct2table(CO.CData.Nuc);
            temp.Properties.VariableNames = strcat('Nuc_', temp.Properties.VariableNames);
            len(1)                        = length(temp.Properties.VariableNames);
            if any(strcmp('Cyto',fieldnames(CO.CData)))
                temp                                           = [temp, struct2table(CO.CData.Cyto)];
                len(2)                                         = length(temp.Properties.VariableNames);
                temp.Properties.VariableNames(len(1)+1:len(2)) = strcat('Cyto_', temp.Properties.VariableNames(len(1)+1:len(2)));
            end
            temp = [temp,struct2table(CO.CData.specs)];
            for q = 1:handles.numCh
                str                                            = ['CH_' num2str(q)];
                len(1)                                         = length(temp.Properties.VariableNames);
                temp                                           = [temp, struct2table(CO.CData.(str))];
                len(2)                                         = length(temp.Properties.VariableNames);
                temp.Properties.VariableNames(len(1)+1:len(2)) = strcat(str, temp.Properties.VariableNames(len(1)+1:len(2)));
            end
            T_CellData = [T_CellData; temp];
            T_ImData   = [T_ImData; struct2table(CO.ImData)];
        end
    end
end


%Write tables
mkdir([handles.expDir filesep 'Results'])
writetable(T_CellData,[handles.expDir filesep 'Results'  filesep  'Cell_Events.csv'])
writetable(T_ImData, [handles.expDir filesep 'Results' filesep 'Image_Events.csv'])

%save([handles.expDir filesep 'Results' filesep 'Compiled Segmentation Results.mat'],'T_CellData','T_ImData','handles')

ImageParameter = {'Number_Flourescent_Channels_ex_Nuc','Nuclear_Segmentation_Level','Cytoplasm_Segmentation_Level'...
    'Split_Nuclei','Noise_Filter_Cytoplasm','Noise_Filter_Nucleus','Segmentation_Smoothing_Factor',...
    'Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells','BD_pathway_exp'};
tempMat_SegParameters = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border,handles.bd_pathway],'VariableNames',ImageParameter);
switch handles.BackCorrMethod
    case 'CIDRE'
        tempMat_SegParameters.Cidre_Directory = handles.cidreDir;    
    case 'Rolling_Ball'
         tempMat_SegParameters.RollingBall_Filter = handles.rollfilter;
    case 'Const_Threshold'
         tempMat_SegParameters.Background_Threshold = handles.back_thresh;
    case 'Control_Image'
        tempMat_SegParameters.Control_Image = handles.CorrIm_File;
    case 'Correction_Method'
end

writetable(tempMat_SegParameters,[handles.expDir filesep 'Processing Parameters.csv']);

save([handles.expDir filesep 'Results' filesep 'Compiled Segmentation Results.mat'],'T_CellData','T_ImData','tempMat_SegParameters')
end
