function [classMat,classLabel,im_cell_id] = CreateClassifier(handles,classMat,classLabel,im_cell_id)
num_apo     = 0;num_nuc     = 0;num_over    = 0;
num_under   = 0;num_mito    = 0;num_junk    = 0;
im_idx      = 1;contrast = 1;

seg_file = dir([handles.expDir filesep 'Segmented/*.mat']);
%reorder
num=zeros(length(seg_file),1);
for j = 1:length(seg_file)
    temp_idx1 = strfind(seg_file(j).name,'_');
    temp_idx2 = strfind(seg_file(j).name,'.');
    num(j) = str2double(seg_file(j).name(temp_idx1(2)+1:temp_idx2-1));
end
[~,reorder_idx]=sort(num,'ascend');
seg_file = seg_file(reorder_idx);

figure('units','normalized','outerposition',[0 0 1 1])
ax1 = axes('Position',[0 0 .8 1],'Visible','off');
ax2 = axes('Position',[.81 0 1 1],'Visible','off');

axes(ax2); axis([0,1,0,1]);
cnt = 1;
if height(classMat)==1
    load([handles.expDir filesep 'Segmented/' seg_file(1).name]);
    T = struct2table(CO.Nuc);
    classMat.Properties.VariableNames = T.Properties.VariableNames;
end
%Draw initial image
[T,CO] = DrawBorders(handles,1,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
while 1
    axes(ax1)
    [i,j,input] = ginputc(1,'Color','w','LineWidth',2);
    switch input
        case 113 %q for quit
            break
        case 106
            num_junk = num_junk + 1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('junk',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 110 %n for Nucleus %Left mouse click for nucleus
            num_nuc = num_nuc+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('nuc',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 109 %m for Mitotic Cell
            num_mito = num_mito+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('mito',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 97 %a for Apoptotic cell
            num_apo = num_apo+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('apo',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 111 %o for Over Segmented
            num_over = num_over+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('over',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 117 %u for Under Segmented
            num_under = num_under+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('under',i,j,CO,im_idx,ax1,T);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            cnt = cnt + 1;
        case 29 %Right arrow for next image
            im_idx = im_idx + 1;
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            SaveClassifier(classMat,classLabel,im_cell_id,handles);
        case 115 %s for skip Skip 10 images
            im_idx = im_idx + 10;
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            SaveClassifier(classMat,classLabel,im_cell_id,handles);
        case 28 %left arrow for Previous image
            im_idx = im_idx - 1;
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
            SaveClassifier(classMat,classLabel,im_cell_id,handles);
        case 100 %d for Delete previous selection
            cnt = cnt - 1;
            switch classLabel{cnt}
                case 'apo'
                    num_apo     = num_apo-1;
                case 'mito'
                    num_mito    = num_mito-1;
                case 'nuc'
                    num_nuc     = num_nuc-1;
                case 'over'
                    num_over    = num_over-1;
                case 'under'
                    num_under   = num_under-1;
                case 'junk'
                    num_junk    = num_junk-1;
            end
            classMat(cnt,:)     = [];
            classLabel{cnt}     = [];
            im_cell_id(cnt,:)   = [];
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
        case 99  %c for Bring up contrast tool
            if contrast < .1
                contrast = contrast + .01;
            elseif contrast < 1
                contrast = contrast + .1;
            else
                contrast = contrast + 1;
            end
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
        case 120 %x decrease contrast
            if contrast == .01
                msgbox('Minumum Contrast Achieved')
                continue;
            elseif contrast < .1
                contrast = contrast - .01;
            elseif contrast < 1
                contrast = contrast - .1;
            else
                contrast = contrast - 1;
            end
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo)
        case 116 %t for toggle between current and next image
            idx_temp = im_idx + 1;
            [~] = DrawBorders(handles,idx_temp,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
            waitforbuttonpress()
            [T,CO] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,CO,contrast);
    end
end
%One final save
SaveClassifier(classMat,classLabel,im_cell_id,handles)



