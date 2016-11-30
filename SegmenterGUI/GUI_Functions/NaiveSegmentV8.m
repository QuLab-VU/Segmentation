function [CO,Im_array] = NaiveSegmentV8(handles,i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initially read in information about the image and store

CO = struct(); %Cellular object structure.  This is where all the information to be saved is stored
%Find the name of image with the row and column number
%Store the row and column names from the filename  This assumes a specific
%filename format!
if handles.bd_pathway
    handles.im_info         = imfinfo(char(handles.NUC.filnms(i)));
    CO.ImData.filename      = handles.NUC.filnms(i);
    str                     = char(handles.NUC.filnms(i));
    idx                     = strfind(handles.NUC.filnms(i), 'Well ');
    CO.ImData.rw            = str(idx{1}+5);
    CO.ImData.cl            = str(idx{1}+6:idx{1}+7);
    %Find the date the folder was made
    str                     = datevec(handles.im_info.FileModDate);
    CO.ImData.tim.day       = str(3);
    CO.ImData.tim.month     = str(2);
    CO.ImData.tim.year      = str(1);
    CO.ImData.tim.hr        = str(4);
    CO.ImData.tim.min       = str(5);
else
    CO.ImData.filename      = handles.NUC.filnms(i);
    tempIdx                 = strfind(handles.NUC.filnms(i),'/');
    nm                      = char(handles.NUC.filnms{i}(tempIdx{1}(length(tempIdx{:}))+1:end));
    foo                     = strfind(nm, '-');
    CO.ImData.rw            = nm(foo(end-1)+1:foo(end-1)+3);
    CO.ImData.cl            = nm(foo(end)+1:foo(end)+3);
    %Store the time from the file name
    CO.ImData.tim.year      = str2double(nm(1:4));
    CO.ImData.tim.month     = str2double(nm(5:6));
    CO.ImData.tim.day       = str2double(nm(7:8));
    CO.ImData.tim.hr        = str2double(nm(9:10));
    CO.ImData.tim.min       = str2double(nm(11:12));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now read in all the different channels
%Read in all the images into Im_array matrix and correct for illumination with CIDRE or
%tophat.  Store the nuclear image first!
tempIm = imread(char(handles.NUC.filnms(i)));

%Initialize all the arrays
Im_array    = zeros(size(tempIm,1),size(tempIm,2),handles.numCh+1);
SegIm_array = zeros(size(tempIm,1),size(tempIm,2),handles.numCh+1);
Nuc_label   = zeros(size(tempIm,1),size(tempIm,2),1);
Label_array = zeros(size(tempIm,1),size(tempIm,2),1);

%Convert to single matrix image if rgb image
if size(tempIm,3) ~=1
    tempIm = rgb2gray(tempIm);
    handles.im_info.BitDepth = handles.im_info.BitDepth./3;
end

%The image array holds all the different images read in
Im_array(:,:,1) = tempIm;
%read in all cytoplasmic channels
for q = 1:handles.numCh
    %chnm is used to designate which channel in the structure are used
    chnm = ['CH_' num2str(q)];
    tempIm = imread(char(handles.Cyto.(chnm).filnms(i)));
    if size(tempIm,3) ~=1
        tempIm = rgb2gray(tempIm);
    end
    
    %For Channel correction not currently used but can be implimented for
    %spectral overlap
    %         if strcmp(chnm,corCH{1}) %If this is a channel to correct
    %               if strcmp(corCH{2}, 'Nuc') %If the channel to correct from is the nucleus
    %                     temp_chnm = ['CH_' num2str(m)];
    %                     tempIm = im2double(tempIm) - corVal/100*im2double(Im_array(:,:,1));
    %                     tempIm = corVal/100*im2double(Im_array(:,:,1));
    %               else %Loop through to find the channel to correct from
    %                     for m = 1:handles.numCh
    %                         if strcmp(temp_chnm,corCH{1}]
    %                            tempIm = im2double(tempIm) - corVal/100*im2double(Im_array(:,:,m+1));
    %                            tempIm = corVal/100*im2double(Im_array(:,:,1));
    %                         end
    %                     end
    %               end
    %         end
    %Store in the Image array
    Im_array(:,:,q+1) = tempIm;
end

for q=1:handles.numCh+1
    %Correct Image:
    switch handles.BackCorrMethod
        case 'CIDRE'
            Im_array(:,:,q)  = (Im_array(:,:,q))./(handles.CIDREmodel.v)*mean(handles.CIDREmodel.v(:));
        case 'Rolling_Ball'
            tempIm           = imopen(squeeze(Im_array(:,:,q)),strel('disk',handles.rollfilter));
            Im_array(:,:,q)  = Im_array(:,:,q) - tempIm;
        case 'GainMap_Image'
            gain             = squeeze(handles.GainMap(:,:,q));
            Im_array(:,:,q)  = Im_array(:,:,q)./gain * mean(gain(:));
        case 'Const_Threshold'
            Im_array(:,:,q)  = Im_array(:,:,q) - max(max(Im_array(:,:,q)))*handles.back_thresh;
        case 'Control_Image'
            cont             = squeeze(handles.CorrMap(:,:,q));
            Im_array(:,:,q)  = (Im_array(:,:,q) - cont);
            tempIm           = squeeze(Im_array(:,:,q));
            tempIm(tempIm<0) = 0;
            Im_array(:,:,q)  = tempIm;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now segment the Nucleus
%To avoid segmenting blank images...  Make Variable in future?
if max(std(Im_array(:,:,1))) < 3
    Nuc_label = zeros(size(Nuc_label));
    CO.label = zeros(size(Nuc_label));
else %Otherise binarize image with Otsu's thresholding
    if handles.BFnuc==1 %Use brightfield to define cells shape
        [~,threshold]      = edge(Im_array(:,:,1),'sobel');
        SegIm_array(:,:,1) = edge(Im_array(:,:,1),'sobel',threshold*handles.NucnumLevel);
        SegIm_array(:,:,1) = imdilate(SegIm_array(:,:,1),strel('disk',handles.smoothing_factor));
        SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1),'holes');
        
    else
        s = warning('error','images:multithresh:degenerateInput');
        s = warning('error','images:multithresh:noConvergence'); cnt = 0;
        %Try binarizing with the user defined level, if doesn't converge decrease by 1 and try again.
        try num = multithresh(Im_array(:,:,1),handles.NucnumLevel);
        catch 
            while cnt<handles.NucnumLevel-1
                try
                    num = multithresh(Im_array(:,:,1),handles.NucnumLevel-cnt);
                    break;
                end
                cnt = cnt+1;
            end
        end
        SegIm_array(:,:,1)	= imquantize(Im_array(:,:,1), num);
        SegIm_array(SegIm_array(:,:,1) == 1) = 0; %Background
        SegIm_array(SegIm_array(:,:,1) >= 2) = 1; %Nuclei
    end
    % Remove Noise using the handles.noise_disk
    noise = imtophat(SegIm_array(:,:,1), strel('disk', handles.nuc_noise_disk));
    SegIm_array(:,:,1) = SegIm_array(:,:,1) - noise;
    %Smooth resulting Segmentation
    if handles.numCh==0 && handles.smoothing_factor > 0 && handles.BFnuc==0
        SegIm_array(:,:,1) = imdilate(SegIm_array(:,:,1),strel('disk',handles.smoothing_factor));
    elseif handles.numCh==0 && handles.smoothing_factor < 0 && handles.BFnuc==0
        SegIm_array(:,:,1) = imerode(SegIm_array(:,:,1),strel('disk',handles.smoothing_factor));
    end
    % Fill Holes
    %SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1), 'holes');
    %To separate touching nuclei, compute the distance of the binary
    %transformed image using the bright areas of the image as the basins
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array(:,:,1));
    D = -imhmax(-D,handles.NucSegHeight);  %Suppress values below NucSegHeight.
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.
end

%Show the nuclear label
%imshow(label2rgb(Nuc_label),[])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now segment each channel
if handles.numCh >0
    if handles.nuclear_segment==1 && handles.surface_segment == 0
        %If segmentatoin is just a nuclear dilation dilate the nucleus using
        %imdilate function with a disk size specified by handles.nuclear_segment_factor
        Label_array = im2double(imdilate(SegIm_array(:,:,1),strel('disk',abs(handles.nuclear_segment_factor))));
    else %Otherwise segment cytoplasm by otsu's thresholding method
        %Now segement all the channels
        for q = 1:handles.numCh
            %Walk down from the initial number of levels specified until Otsu's method
            %converges by casting the warning messages as errors and then
            %running a while loop in a catch statement
            s = warning('error','images:multithresh:degenerateInput');
            s = warning('error','images:multithresh:noConvergence'); cnt = 1;
            try num = multithresh(Im_array(:,:,q+1),handles.CytonumLevel);
            catch 
                while cnt<handles.CytonumLevel-1
                    try
                        num = multithresh(Im_array(:,:,q+1),handles.CytonumLevel-cnt);
                        break;
                    end
                    cnt = cnt+1;
                end
            end
            %Run Otsu's method with the number of levels that converged
            %Quantize the image based on multithreshold.  Set every level above 1 to cell and 1 to background (0)
            tempIm= imquantize(Im_array(:,:,q+1), num);
            tempIm(tempIm == 1) = 0; %Background
            % all other levels are considered significant
            tempIm(tempIm > 1) = 1;
            % Remove Noise
            noise = imtophat(tempIm, strel('disk', handles.noise_disk));
            SegIm_array(:,:,q+1) = tempIm - noise;
        end
        %Combine all the channels for cytoplasm segmentation
        for q=1:handles.numCh
            Label_array = Label_array + SegIm_array(:,:,q+1);
        end
        %Force to be a binary image
        Label_array(Label_array>1) = 1;
        if handles.smoothing_factor > 0
            Label_array = imdilate(Label_array,strel('disk',handles.smoothing_factor));
        elseif handles.smoothing_factor<0
            Label_array = imerode(Label_array,strel('disk',abs(handles.smoothing_factor)));
        end
        % Fill Holes
        Label_array = imfill(Label_array, 'holes');
    end
    %Label cytoplasm cell staining
    Label_array = bwlabel(Label_array);
    numCytowoutNuc = 0; % Count the number of cyptoplasms found without nuclei
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Now assign each cytoplasm to a nucleus
    
    %Now use a knn identifier to assign each cytoplasm to a nucleus
    %Now for each channel find the properties of the cytoplasm for each
    %nuclei.  Do not use cytplasms with no nuclei
    CytoLabel = zeros(size(Nuc_label));
    nucl_ids_left = 1:max(max(Nuc_label)); %To keep track of what nuclei have been assigned
    for j = 1:max(max(Label_array))
        cur_cluster = (Label_array==j); %Find the current cluster of cytoplasmic labels
        %get the nuclei ids present in the cluster
        nucl_ids=Nuc_label(cur_cluster);
        nucl_ids=unique(nucl_ids);
        %remove the background id
        nucl_ids(nucl_ids==0)=[];
        if isempty(nucl_ids)
            %don't add objects without nuclei
            numCytowoutNuc = numCytowoutNuc + 1;
            continue;
        elseif (length(nucl_ids)==1)
            %only one nucleus - assign the entire cluster to that id
            %Only add if the cytoplasm is larger than the nucleus
            if (sum(sum(cur_cluster))) > .8*sum(sum(ismember(Nuc_label,nucl_ids)))
                CytoLabel(cur_cluster)=nucl_ids;
                %delete the nucleus that have already been processed
                nucl_ids_left(nucl_ids_left==nucl_ids)=[];
            end
        else
            %Use of knn classifier
            %get an index to only the nuclei
            nucl_idx=ismember(Nuc_label,nucl_ids);
            %get the x-y coordinates
            [nucl_x, nucl_y]=find(nucl_idx); %Location of all the nuclear pixels
            [cluster_x, cluster_y]=find(cur_cluster);  %Location of all cytoplasm pixels
            group_data= Nuc_label(nucl_idx); %Classification of all nuclear labels
            %Classify each pixel in the cluster. Dont need every pixel in the nucleus to find nearest neighbor.
            %Cuts down on model building time. Build a model based on spatial information of what each group
            %each x y coordinate is assigned to then use to predict what each
            %cytoplasmic element belongs to...
            knnModel = fitcknn([nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
            CytoLabel(cur_cluster) = predict(knnModel,[cluster_x cluster_y]);
            %delete the nucleus that have already been processed
            for elm = nucl_ids'
                nucl_ids_left(nucl_ids_left==elm)=[];
            end
        end
    end
    %Reorder to have unique labels
    tempIm = CytoLabel;
    unique_cells = unique(CytoLabel(CytoLabel~=0));
    CytoLabel = zeros(size(CytoLabel));
    cnt = 1;
    for j = 1:length(unique_cells)
        CytoLabel(tempIm == unique_cells(j)) = cnt;
        cnt = cnt+1;
    end
    %Reorder to match the reordered cytoplasm.
    tempIm = Nuc_label;
    Nuc_label = zeros(size(Nuc_label));
    cnt = 1;
    for j = 1:max(max(CytoLabel))
        cur_cluster = (CytoLabel==j); %Find the current cell
        %get the nuclei ids present in the cluster
        nuc_ids = unique(tempIm(cur_cluster));
        nuc_ids = nuc_ids(nuc_ids~=0);
        if length(nuc_ids)==1
            Nuc_label(tempIm == nuc_ids) = cnt;%Find the nucleus that corresponds to that cluster
            cnt = cnt+1;
        elseif isempty(nuc_ids) %for the rare event when the knn predict predicts only a set of for a nucleus which are not in the nuclear label
            CytoLabel(CytoLabel == j) = 0;
            tempIm = CytoLabel;
            unique_cells = unique(CytoLabel(CytoLabel~=0));
            CytoLabel = zeros(size(CytoLabel));
            cnt1 = 1;
            for k = 1:length(unique_cells)
                CytoLabel(tempIm == unique_cells(k)) = cnt1;
                cnt1 = cnt1+1;
            end
        else
            temp= zeros(length(nuc_ids),1);
            for k = 1:length(nuc_ids)
                temp(k) = sum(sum(tempIm(cur_cluster) == nuc_ids(k)));
            end
            [~, idx] = max(temp);
            Nuc_label(tempIm == nuc_ids(idx)) = cnt;
            cnt = cnt + 1;
        end
    end
    %Look at various types of segmentation such as just segmenting the
    %surface or subtracting the Nucleus from a nuclear dilation.
    %if only segmenting the perimeter of each cell to look only as cell
    %surface markers
    if handles.surface_segment == 1 && handles.nuclear_segment == 0
        %Now for each cytoplasm find the perimeter
        PerimId = cell(max(max(CytoLabel)),1);
        for j = 1:max(max(CytoLabel))
            cur_cluster = (CytoLabel == j);
            PerimId{j} = find(bwperim(cur_cluster)==1);
        end
        %Now compile all the perimeters
        temp = zeros(size(Nuc_label));
        for j = 1:max(max(CytoLabel))
            temp(PerimId{j}) = 1;
        end
        %Dialate the perimeters
        Cell_Surface_Mask = imdilate(temp,strel('disk',surface_segment_factor));
        CytoLabel(Cell_Surface_Mask==0)= 0;
    elseif handles.surface_segment==1 && handles.nuclear_segment == 1
        tempIm = Nuc_label;
        tempIm(tempIm>0) = 1;
        if handles.nuclear_segment_factor<0
            tempIm = im2double(imerode(tempIm,strel('disk',abs(handles.nuclear_segment_factor))));
        else
            tempIm = im2double(imdilate(tempIm,strel('disk',handles.nuclear_segment_factor)));
        end
        CytoLabel(tempIm>0) = 0;
    end
    %Show the cytoplasmic label
    %imshow(label2rgb(CytoLabel),[])
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get the properties of each segmented cells for each channel and Nucleus
    p	= regionprops(CytoLabel,'PixelIdxList','Perimeter','Centroid');
    if size(p,1) ~=0
        %Mark the border cells
        border_cells = [CytoLabel(1,:)   CytoLabel(:,size(CytoLabel,2))'   CytoLabel(size(CytoLabel,1),:)  CytoLabel(:,1)'];
        border_cells = unique(border_cells(border_cells~=0));
        Edge = zeros(size(p,1),1);
        for k = 1:size(p,1)
            Edge(k) = ismember(k,border_cells);
        end
        tempIm = Im_array(:,:,2:end);
        [FeatureSet, FeatureSetVarLabels] = CellFeatureSets(tempIm,CytoLabel,1:size(p,1),[]);
        CO.CData.Cyto.Area                = FeatureSet(:,1);
        if handles.ParmReduced==1
            CO.CData.Cyto.Perimeter                 = FeatureSet(:,2);
            CO.CData.Cyto.Hu_mom1                   = FeatureSet(:,4);
            CO.CData.Cyto.Hu_mom2                   = FeatureSet(:,5);
            CO.CData.Cyto.Hu_mom3                   = FeatureSet(:,6);
            CO.CData.Cyto.Hu_mom4                   = FeatureSet(:,7);
            CO.CData.Cyto.Hu_mom5                   = FeatureSet(:,8);
            CO.CData.Cyto.Hu_mom6                   = FeatureSet(:,9);
            CO.CData.Cyto.Hu_mom7                   = FeatureSet(:,10);
            CO.CData.Cyto.Circularity               = FeatureSet(:,3);
            CO.CData.Cyto.Extension                 = FeatureSet(:,11);
            CO.CData.Cyto.Dispersion                = FeatureSet(:,12);
            CO.CData.Cyto.Elongation                = FeatureSet(:,13);
            CO.CData.Cyto.Mean_Dist_to_closest_objs = FeatureSet(:,14);
        end
        %Include a label with all the names of each variable.
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            tempIm                         = Im_array(:,:,q+1);
            CO.ImData.(chnm).Background    = median(tempIm(CytoLabel==0));
            CO.CData.(chnm).Mean_Intensity = FeatureSet(:,19+(handles.numCh-1)*4+q-1);
            if handles.ParmReduced==1
                CO.CData.(chnm).Mean_Pixel_Dist    = FeatureSet(:,15+(handles.numCh-1)*0+q-1);
                CO.CData.(chnm).Max_Pixel_Dist     = FeatureSet(:,16+(handles.numCh-1)*1+q-1);
                CO.CData.(chnm).Min_Pixel_Dist     = FeatureSet(:,17+(handles.numCh-1)*2+q-1);
                CO.CData.(chnm).Std_Pixel_Dist     = FeatureSet(:,18+(handles.numCh-1)*3+q-1);
                CO.CData.(chnm).Min_Intensity      = FeatureSet(:,20+(handles.numCh-1)*5+q-1);
                CO.CData.(chnm).Max_Intensity      = FeatureSet(:,21+(handles.numCh-1)*6+q-1);
                CO.CData.(chnm).Std_Intensity      = FeatureSet(:,22+(handles.numCh-1)*7+q-1);
                CO.CData.(chnm).Mean_Gradient_Full = FeatureSet(:,23+(handles.numCh-1)*8+q-1);
                CO.CData.(chnm).Min_Gradient_Full  = FeatureSet(:,24+(handles.numCh-1)*9+q-1);
                CO.CData.(chnm).Max_Gradient_Full  = FeatureSet(:,25+(handles.numCh-1)*10+q-1);
                CO.CData.(chnm).Std_Gradient_Full  = FeatureSet(:,26+(handles.numCh-1)*11+q-1);
            end
        end
    end
    CO.label = CytoLabel;
    CO.ImData.numCytowoutNuc = numCytowoutNuc;
    CO.ImData.numCyto        = length(unique(CytoLabel))-1;
else %If just the nucleus being segmented
    border_cells             = [Nuc_label(1,:)   Nuc_label(:,size(Nuc_label,2))'   Nuc_label(size(Nuc_label,1),:)  Nuc_label(:,1)'];
    border_cells             = unique(border_cells(border_cells~=0));
    if handles.ParmReduced==1;
        CO.label = zeros(size(Nuc_label));
    end
    CO.ImData.numCytowoutNuc = 0;
    CO.ImData.numCyto        = 0;
end  %This is the end of cytoplasm segmentation.
%Store similar information for the Nucleus segmentation.
%This information will eventually be used in the baysian classifier to
%identify different cells.
p	= regionprops(Nuc_label,'PixelIdxList','Perimeter','MajorAxisLength',...
    'MinorAxisLength','EquivDiameter','Solidity','EulerNumber','ConvexArea','Centroid','Eccentricity');
Int = zeros(size(p,1),1); Area = zeros(size(p,1),1); Perimeter = zeros(size(p,1),1);MajorAxisLength = zeros(size(p,1),1);
MinorAxisLength = zeros(size(p,1),1); EquivDiameter = zeros(size(p,1),1); Solidity = zeros(size(p,1),1);
EulerNumber = zeros(size(p,1),1); ConvexArea= zeros(size(p,1),1);Centroid = zeros(size(p,1),2);
Edge = zeros(size(p,1),1);
tempIm = Im_array(:,:,1);
if size(p,1) ~= 0
    for k = 1:size(p,1)
        Centroid(k,:)       = p(k).Centroid;
        Int(k)              = sum(tempIm(p(k).PixelIdxList));
        Area(k)             = length(p(k).PixelIdxList);
        Perimeter(k)        = p(k).Perimeter;
        MajorAxisLength(k)  = p(k).MajorAxisLength;
        MinorAxisLength(k)  = p(k).MinorAxisLength;
        EquivDiameter(k)    = p(k).EquivDiameter;
        Solidity(k)         = p(k).Solidity;
        EulerNumber(k)      = p(k).EulerNumber;
        ConvexArea(k)       = p(k).ConvexArea;
        Edge(k)             = ismember(k,border_cells);
    end
    [FeatureSet, FeatureSetVarLabels]         = CellFeatureSets(Im_array(:,:,1),Nuc_label,[1:size(p,1)],[]);
    CO.CData.Nuc.Area                         = Area;
    CO.CData.Nuc.Mean_Intensity               = FeatureSet(:,19);
    if handles.ParmReduced==1;
        CO.CData.Nuc.Circularity                  = FeatureSet(:,3);
        CO.CData.Nuc.Hu_mom1                      = FeatureSet(:,4);
        CO.CData.Nuc.Hu_mom2                      = FeatureSet(:,5);
        CO.CData.Nuc.Hu_mom3                      = FeatureSet(:,6);
        CO.CData.Nuc.Hu_mom4                      = FeatureSet(:,7);
        CO.CData.Nuc.Hu_mom5                      = FeatureSet(:,8);
        CO.CData.Nuc.Hu_mom6                      = FeatureSet(:,9);
        CO.CData.Nuc.Hu_mom7                      = FeatureSet(:,10);
        CO.CData.Nuc.Extension                    = FeatureSet(:,11);
        CO.CData.Nuc.Dispersion                   = FeatureSet(:,12);
        CO.CData.Nuc.Elongation                   = FeatureSet(:,13);
        CO.CData.Nuc.Mean_Dist_to_closest_objs    = FeatureSet(:,14);
        CO.CData.Nuc.Mean_Pixel_Dist              = FeatureSet(:,15);
        CO.CData.Nuc.Max_Pixel_Dist               = FeatureSet(:,16);
        CO.CData.Nuc.Min_Pixel_Dist               = FeatureSet(:,17);
        CO.CData.Nuc.Std_Pixel_Dist               = FeatureSet(:,18);
        CO.CData.Nuc.Min_Intensity                = FeatureSet(:,20);
        CO.CData.Nuc.Max_Intensity                = FeatureSet(:,21);
        CO.CData.Nuc.Std_Intensity                = FeatureSet(:,22);
        CO.CData.Nuc.Mean_Gradient_Full           = FeatureSet(:,23);
        CO.CData.Nuc.Min_Gradient_Full            = FeatureSet(:,24);
        CO.CData.Nuc.Max_Gradient_Full            = FeatureSet(:,25);
        CO.CData.Nuc.Std_Gradient_Full            = FeatureSet(:,26);
        CO.CData.Nuc.Perimeter                    = Perimeter;
        CO.CData.Nuc.Solidity                     = Solidity;
        CO.CData.Nuc.EulerNumber                  = EulerNumber;
        CO.CData.Nuc.ConvexArea                   = ConvexArea;
    end
end

%For each channel save information into the structure
CO.ImData.NucBackground   = median(tempIm(Nuc_label==0));
handles.ParmReduced
if handles.ParmReduced==1;
    CO.CData.Nuc.MajorAxisLength  = MajorAxisLength;
    CO.CData.Nuc.MinorAxisLength  = MinorAxisLength;
    CO.CData.Nuc.EquivDiameter    = EquivDiameter;
end
CO.Nuc_label = Nuc_label;

%Save the nucleus information
%%Count the number of cells in the image from the number of labels
CO.ImData.cellCount = max(max(Nuc_label));


CO.CData.specs.filename   = repmat(CO.ImData.filename,CO.ImData.cellCount,1);
CO.CData.specs.rw         = repmat(CO.ImData.rw,CO.ImData.cellCount,1);
CO.CData.specs.cl         = repmat(CO.ImData.cl,CO.ImData.cellCount,1);
CO.CData.specs.day        = repmat(CO.ImData.tim.day,CO.ImData.cellCount,1);
CO.CData.specs.year       = repmat(CO.ImData.tim.year,CO.ImData.cellCount,1);
CO.CData.specs.month      = repmat(CO.ImData.tim.month,CO.ImData.cellCount,1);
CO.CData.specs.hr         = repmat(CO.ImData.tim.hr,CO.ImData.cellCount,1);
CO.CData.specs.min        = repmat(CO.ImData.tim.min,CO.ImData.cellCount,1);
CO.CData.specs.Centroid_i = Centroid(:,1);
CO.CData.specs.Centroid_j = Centroid(:,2);
CO.CData.specs.cellId     = 1:size(p,1)'; CO.CData.specs.cellId = CO.CData.specs.cellId'; 
CO.CData.specs.Edge       = Edge;

