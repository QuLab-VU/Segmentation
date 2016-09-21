function [CO,Im_array] = NaiveSegmentV8(cidrecorrect,NucnumLevel,CytonumLevel,surface_segment,...
    nuclear_segment,noise_disk,nuc_noise_disk,nuclear_segment_factor,surface_segment_factor,...
    smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i,background_corr,CorrIm_file,bd_pathway,...
    back_thresh,thresh_based_bin,im_info,BFnuc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initially read in information about the image and store

CO = struct(); %Cellular object structure.  This is where all the information to be saved is stored
%Find the name of image with the row and column number
%Store the row and column names from the filename  This assumes a specific
%filename format!
if bd_pathway
    CO.filename     = NUC.filnms(i);
    str             = char(NUC.filnms(i));
    idx             = strfind(NUC.filnms(i), 'Well ');
    CO.rw           = str(idx{1}+5);CO.cl = str(idx{1}+6:idx{1}+7);
    %Find the date the folder was made
    temp            = dir(char(NUC.filnms(i)));
    str             = datevec(temp.date);
    CO.tim.day      = str(3);
    CO.tim.month    = str(2);
    CO.tim.year     = str(1);
    CO.tim.hr       = str(4);
    CO.tim.min      = str(5);
else
    CO.filename     = NUC.filnms(i);
    tempIdx         = strfind(NUC.filnms(i),'/');
    nm              = char(NUC.filnms{i}(tempIdx{1}(length(tempIdx{:}))+1:end));
    foo             = strfind(nm, '-');
    CO.rw           = nm(foo(2)+1:foo(2)+3); CO.cl = nm(foo(3)+1:foo(3)+3);
    %Store the time from the file name
    CO.tim.year     = str2double(nm(1:4));
    CO.tim.month    = str2double(nm(5:6));
    CO.tim.day      = str2double(nm(7:8));
    CO.tim.hr       = str2double(nm(9:10));
    CO.tim.min      = str2double(nm(11:12));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now read in all the different channels
%Read in all the images into Im_array matrix and correct for illumination with CIDRE or
%tophat.  Store the nuclear image first!
tempIm = imread(char(NUC.filnms(i)));

%Initialize all the arrays
Im_array    = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
SegIm_array = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
Nuc_label   = zeros(size(tempIm,1),size(tempIm,2),1);
Label_array = zeros(size(tempIm,1),size(tempIm,2),1);

%Convert to single matrix image if rgb image
if size(tempIm,3) ~=1
    tempIm = rgb2gray(tempIm);
    im_info.BitDepth = im_info.BitDepth./3;
end
%Correct with CIDRE map if cidrecorrect is selected
if cidrecorrect
    tempIm = ((double(tempIm))./(NUC.CIDREmodel.v))*mean(NUC.CIDREmodel.v(:));
elseif background_corr %correct with background correction (constant)
    cont = uint16(imread(CorrIm_file));
    tempIm = (tempIm - cont);
    tempIm(tempIm<0) = 0;
end
%The image array holds all the different images read in
Im_array(:,:,1) = tempIm;
%read in all cytoplasmic channels
for q = 1:numCh
    %chnm is used to designate which channel in the structure are used
    chnm = ['CH_' num2str(q)];
    tempIm = imread(char(Cyto.(chnm).filnms(i)));
    if size(tempIm,3) ~=1
        tempIm = rgb2gray(tempIm);
    end
    %Correct with CIDRE model or background correction
    if cidrecorrect
        tempIm = ((double(tempIm))./(Cyto.CH_1.CIDREmodel.v))*mean(Cyto.CH_1.CIDREmodel.v(:));
    elseif background_corr
        cont = uint16(imread(CorrIm_file));
        tempIm = (tempIm - cont);
    end
    %For Channel correction not currently used but can be implimented for
    %spectral overlap
%         if strcmp(chnm,corCH{1}) %If this is a channel to correct
%               if strcmp(corCH{2}, 'Nuc') %If the channel to correct from is the nucleus
%                     temp_chnm = ['CH_' num2str(m)];
%                     tempIm = im2double(tempIm) - corVal/100*im2double(Im_array(:,:,1));
%                     tempIm = corVal/100*im2double(Im_array(:,:,1));
%               else %Loop through to find the channel to correct from
%                     for m = 1:numCh
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now segment the Nucleus

%To avoid segmenting blank images...  Make Variable in future?
if max(std(Im_array(:,:,1))) < 3
    Nuc_label = zeros(size(Nuc_label));
    CO.label = zeros(size(Nuc_label));
elseif thresh_based_bin %Threshold based segmentation
    SegIm_array(:,:,1) = Im_array(:,:,1) > back_thresh(1)*im_info.BitDepth;
    % Remove Noise using the noise_disk
    noise = imtophat(SegIm_array(:,:,1), strel('disk', nuc_noise_disk));
    SegIm_array(:,:,1) = SegIm_array(:,:,1) - noise;
    if numCh==0
        SegIm_array(:,:,1) = imdilate(SegIm_array(:,:,1),strel('disk',smoothing_factor));
    end
    % Fill Holes
    SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1), 'holes');
    %To separate touching nuclei, compute the distance of the binary 
    %transformed image using the bright areas of the image as the basins 
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array(:,:,1));
    D = -imhmax(-D,NucSegHeight);  %Suppress values below NucSegHeight
    Nuc_label = watershed(D); %Run watershed segmentation
    Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.
else %Otherise binarize image with Otsu's thresholding
    if BFnuc==1
            [~,threshold] = edge(Im_array(:,:,1),'sobel');
            SegIm_array(:,:,1) = edge(Im_array(:,:,1),'sobel',threshold*NucnumLevel);
            SegIm_array(:,:,1) = imdilate(SegIm_array(:,:,1),strel('disk',smoothing_factor));
            SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1),'holes');
        
    else
        s = warning('error','images:multithresh:degenerateInput');
        s = warning('error','images:multithresh:noConvergence'); cnt = 0;
        %Try binarizing with the user defined level, if doesn't converge decrease by 1 and try again.
        try num = multithresh(Im_array(:,:,1),NucnumLevel); 
        catch exception
            while cnt<NucnumLevel-1
                try 
                    num = multithresh(Im_array(:,:,1),NucnumLevel-cnt);
                    break;
                end
                cnt = cnt+1;
            end
        end
        SegIm_array(:,:,1)	= imquantize(Im_array(:,:,1), num);
        SegIm_array(SegIm_array(:,:,1) == 1) = 0; %Background
        SegIm_array(SegIm_array(:,:,1) >= 2) = 1; %Nuclei
    end
    % Remove Noise using the noise_disk
    noise = imtophat(SegIm_array(:,:,1), strel('disk', nuc_noise_disk));
    SegIm_array(:,:,1) = SegIm_array(:,:,1) - noise;
    %Smooth resulting Segmentation
    if numCh==0 && smoothing_factor ~=0 && BFnuc==0
        SegIm_array(:,:,1) = imdilate(SegIm_array(:,:,1),strel('disk',smoothing_factor));
    end
    % Fill Holes
    %SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1), 'holes');
    %To separate touching nuclei, compute the distance of the binary 
    %transformed image using the bright areas of the image as the basins 
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array(:,:,1));
    D = -imhmax(-D,NucSegHeight);  %Suppress values below NucSegHeight.
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.
end

%Show the nuclear label
%imshow(label2rgb(Nuc_label),[])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now segment each channel
if numCh >0
    if nuclear_segment==1 && surface_segment == 0
        %If segmentatoin is just a nuclear dilation dilate the nucleus using
        %imdilate function with a disk size specified by nuclear_segment_factor
            Label_array = im2double(imdilate(SegIm_array(:,:,1),strel('disk',abs(nuclear_segment_factor))));
    else %Otherwise segment cytoplasm by otsu's thresholding method
        %Now segement all the channels
        for q = 1:numCh
            chnm = ['CH_' num2str(q)]; %Channel
            %Walk down from the initial number of levels specified until Otsu's method
            %converges by casting the warning messages as errors and then
            %running a while loop in a catch statement
            s = warning('error','images:multithresh:degenerateInput');
            s = warning('error','images:multithresh:noConvergence'); cnt = 1;
            try num = multithresh(Im_array(:,:,q+1),CytonumLevel);
            catch exception
                while cnt<CytonumLevel-1
                  try 
                      num = multithresh(Im_array(:,:,q+1),CytonumLevel-cnt);
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
            noise = imtophat(tempIm, strel('disk', noise_disk));
            SegIm_array(:,:,q+1) = tempIm - noise;
        end
        %Combine all the channels for cytoplasm segmentation
        for q=1:numCh
            Label_array = Label_array + SegIm_array(:,:,q+1);
        end
        %Force to be a binary image
        Label_array(Label_array>1) = 1;
        if smoothing_factor > 0
            Label_array = imdilate(Label_array,strel('disk',smoothing_factor));
        elseif smoothing_factor<0
            Label_array = imerode(Label_array,strel('disk',abs(smoothing_factor)));
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
            [nucl_x nucl_y]=find(nucl_idx); %Location of all the nuclear pixels
            [cluster_x cluster_y]=find(cur_cluster);  %Location of all cytoplasm pixels
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
            for j = 1:length(unique_cells)
                CytoLabel(tempIm == unique_cells(j)) = cnt1;
                cnt1 = cnt1+1;
            end
        else
            temp= [];
            for k = 1:length(nuc_ids)
                temp(k) = sum(sum(tempIm(cur_cluster) == nuc_ids(k)));
            end
            [temp, idx] = max(temp);
            Nuc_label(tempIm == nuc_ids(idx)) = cnt;
            cnt = cnt + 1;
        end 
    end
    %Look at various types of segmentation such as just segmenting the
    %surface or subtracting the Nucleus from a nuclear dilation.
    %if only segmenting the perimeter of each cell to look only as cell
    %surface markers
    temp = [];
    if surface_segment == 1 && nuclear_segment == 0
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
    elseif surface_segment==1 && nuclear_segment == 1
        tempIm = Nuc_label;
        tempIm(tempIm>0) = 1;
        if nuclear_segment_factor<0
            tempIm = im2double(imerode(Nuc_label,strel('disk',abs(nuclear_segment_factor))));
        else
            tempIm = im2double(imdilate(Nuc_label,strel('disk',nuclear_segment_factor)));
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
        CO.Cyto.class.edge          = Edge;
        tempIm = Im_array(:,:,2:end);
        [FeatureSet, FeatureSetVarLabels] = CellFeature_reduced(tempIm,CytoLabel,1:size(p,1),[]);
        CO.Cyto.Area                = FeatureSet(:,1);
        CO.Cyto.Perimeter           = FeatureSet(:,2);
        CO.Cyto.Hu_mom1             = FeatureSet(:,4);
        CO.Cyto.Hu_mom2             = FeatureSet(:,5);
        CO.Cyto.Hu_mom3             = FeatureSet(:,6);
        CO.Cyto.Hu_mom4             = FeatureSet(:,7);
        CO.Cyto.Hu_mom5             = FeatureSet(:,8);
        CO.Cyto.Hu_mom6             = FeatureSet(:,9);
        CO.Cyto.Hu_mom7             = FeatureSet(:,10);
        CO.Cyto.Circularity         = FeatureSet(:,3);
        CO.Cyto.Extension           = FeatureSet(:,11);
        CO.Cyto.Dispersion          = FeatureSet(:,12);
        CO.Cyto.Elongation          = FeatureSet(:,13);
        CO.Cyto.Mean_Dist_to_closest_objs = FeatureSet(:,14);
        %Include a label with all the names of each variable.  
        for q = 1:numCh
            chnm = ['CH_' num2str(q)];   
            tempIm = Im_array(:,:,q+1);
            CO.(chnm).Background        =median(tempIm(CytoLabel==0));
            CO.(chnm).Mean_Pixel_Dist   = FeatureSet(:,15+(numCh-1)*0+q-1);
            CO.(chnm).Max_Pixel_Dist    = FeatureSet(:,16+(numCh-1)*1+q-1);
            CO.(chnm).Min_Pixel_Dist    = FeatureSet(:,17+(numCh-1)*2+q-1);
            CO.(chnm).Std_Pixel_Dist    = FeatureSet(:,18+(numCh-1)*3+q-1);
            CO.(chnm).Mean_Intensity    = FeatureSet(:,19+(numCh-1)*4+q-1);
            CO.(chnm).Min_Intensity     = FeatureSet(:,20+(numCh-1)*5+q-1);
            CO.(chnm).Max_Intensity     = FeatureSet(:,21+(numCh-1)*6+q-1);
            CO.(chnm).Std_Intensity     = FeatureSet(:,22+(numCh-1)*7+q-1);
            CO.(chnm).Mean_Gradient_Full= FeatureSet(:,23+(numCh-1)*8+q-1);
            CO.(chnm).Min_Gradient_Full = FeatureSet(:,24+(numCh-1)*9+q-1);
            CO.(chnm).Max_Gradient_Full = FeatureSet(:,25+(numCh-1)*10+q-1);
            CO.(chnm).Std_Gradient_Full = FeatureSet(:,26+(numCh-1)*11+q-1);
        end
    end
        CO.label            = CytoLabel;
        CO.numCytowoutNuc   = numCytowoutNuc;
        CO.numCyto          = length(unique(CytoLabel))-1;
else %If just the nucleus being segmented
    border_cells    = [Nuc_label(1,:)   Nuc_label(:,size(Nuc_label,2))'   Nuc_label(size(Nuc_label,1),:)  Nuc_label(:,1)'];
    border_cells    = unique(border_cells(border_cells~=0));
    CO.label        = zeros(size(Nuc_label));
    CO.numCytowoutNuc = 0;
    CO.numCyto      = 0;
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
    [FeatureSet, FeatureSetVarLabels]   = CellFeature_reduced(Im_array(:,:,1),Nuc_label,[1:size(p,1)],[]);
    CO.Nuc.Circularity                  =FeatureSet(:,3);
    CO.Nuc.Hu_mom1                      =FeatureSet(:,4);
    CO.Nuc.Hu_mom2                      =FeatureSet(:,5);
    CO.Nuc.Hu_mom3                      =FeatureSet(:,6);
    CO.Nuc.Hu_mom4                      =FeatureSet(:,7);
    CO.Nuc.Hu_mom5                      =FeatureSet(:,8);
    CO.Nuc.Hu_mom6                      =FeatureSet(:,9);
    CO.Nuc.Hu_mom7                      =FeatureSet(:,10);
    CO.Nuc.Extension                    =FeatureSet(:,11);
    CO.Nuc.Dispersion                   =FeatureSet(:,12);
    CO.Nuc.Elongation                   =FeatureSet(:,13);
    CO.Nuc.Mean_Dist_to_closest_objs    =FeatureSet(:,14);
    CO.Nuc.Mean_Pixel_Dist              =FeatureSet(:,15);
    CO.Nuc.Max_Pixel_Dist               =FeatureSet(:,16);
    CO.Nuc.Min_Pixel_Dist               =FeatureSet(:,17);
    CO.Nuc.Std_Pixel_Dist               =FeatureSet(:,18);
    CO.Nuc.Mean_Intensity               =FeatureSet(:,19);
    CO.Nuc.Min_Intensity                =FeatureSet(:,20);
    CO.Nuc.Max_Intensity                =FeatureSet(:,21);
    CO.Nuc.Std_Intensity                =FeatureSet(:,22);
    CO.Nuc.Mean_Gradient_Full           =FeatureSet(:,23);
    CO.Nuc.Min_Gradient_Full            =FeatureSet(:,24);
    CO.Nuc.Max_Gradient_Full            =FeatureSet(:,25);
    CO.Nuc.Std_Gradient_Full            =FeatureSet(:,26);
end        

%For each channel save information into the structure
CO.Centroid         = Centroid;
CO.cellId           = 1:size(p,1);
CO.NucBackground   = median(tempIm(Nuc_label==0));
CO.Nuc.Area         = Area;
CO.Nuc.Perimeter    = Perimeter;
CO.Nuc.Solidity     = Solidity;
CO.Nuc.EulerNumber  = EulerNumber;
CO.Nuc.ConvexArea   = ConvexArea;
CO.class.Edge       = Edge;
CO.class.nucleus    = zeros(length(Edge),1);
CO.class.apoptotic  = zeros(length(Edge),1);
CO.class.mitotic    = zeros(length(Edge),1);
CO.class.debris     = zeros(length(Edge),1);
        
CO.Nuc.MajorAxisLength  = MajorAxisLength;
CO.Nuc.MinorAxisLength  = MinorAxisLength;
CO.Nuc.EquivDiameter    = EquivDiameter;

%Save the nucleus information
%%Count the number of cells in the image from the number of labels
CO.cellCount = max(max(Nuc_label));     
CO.Nuc_label = Nuc_label;


