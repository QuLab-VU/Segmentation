function [classMat,classLabel,im_cell_id] = CreateClassifier(handles,classMat,classLabel,im_cell_id)
num_apo     = 0;num_nuc     = 0;num_over    = 0;
num_under   = 0;num_mito    = 0;im_idx      = 1;

seg_file = dir([handles.expDir filesep 'Segmented/*.mat']);
figure('units','normalized','outerposition',[0 0 1 1])
ax1 = axes('Position',[0 0 .8 1],'Visible','off');
ax2 = axes('Position',[.81 0 1 1],'Visible','off');
axes(ax2); axis([0,1,0,1]);
cnt = 1;
load([handles.expDir filesep 'Segmented/' seg_file(1).name]);
%Draw initial image
DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito);
while 1
    [i,j,input] = ginput(1);
    switch input
        case 113 %q for quit
            break
        case 110 %n for Nucleus %Left mouse click for nucleus
            num_nuc = num_nuc+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('nuc',i,j,CO,im_idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo);
            cnt = cnt + 1;
        case 109 %m for Mitotic Cell
            num_mito = num_mito+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('mito',i,j,CO,im_idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo);
            cnt = cnt + 1;
        case 97 %a for Apoptotic cell
            num_apo = num_apo+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('apo',i,j,CO,im_idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo);
            cnt = cnt + 1;
        case 111 %o for Over Segmented
            num_over = num_over+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('over',i,j,CO,im_idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo);
            cnt = cnt + 1;
        case 117 %u for Under Segmented
            num_under = num_under+1;
            [classMat(cnt,:),im_cell_id(cnt,:),classLabel{cnt}] = reDrawBorders('under',i,j,CO,im_idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo);
            cnt = cnt + 1;
        case 29 %Right arrow for next image
            im_idx = im_idx + 1;
            DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
        case 115 %s for skip Skip 10 images
            im_idx = im_idx + 10;
            DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
        case 28 %left arrow for Previous image
            im_idx = im_idx - 1;
            DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
        case 100 %d for Delete previous selection
            cnt = cnt - 1;
            switch classLabel
                case 'apo'
                    num_apo = num_apo-1;
                case 'mito'
                    num_mito = num_mito-1;
                case 'nuc'
                    num_nuc = num_nuc-1;
                case 'over'
                    num_over = num_over-1;
                case 'under'
                    num_under = num_under-1;
            end
            classMat(cnt,:)     = [];
            classLabel{cnt}     = [];
            im_cell_id(cnt,:)   = [];
            DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
        case 99  %c for Bring up contrast tool
            imcontrast(ax1)
        case 116 %t for toggle between current and next image
            idx_temp = im_idx + 1;
            DrawBorders(handles,idx_temp,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
            waitforbuttonpress()
            DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
    end
end


