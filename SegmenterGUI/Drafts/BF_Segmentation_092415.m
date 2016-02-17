% Bright field cell segmentation with nuclei stain
%%Christian Meyer 09/24/15
%Segmentation code to find the cells in BF images from CellaVista presorted with the
%cellaVistaFileSorter.m code
%First block of code builds the basic sturcture of to hold the 
%Nuclear and cytoplasmic files.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then the code determines the cytoplasmic
%channel with the largest amount of staining to define the cytoplasm for
%each cell.  Finally each channel is segmented and the intensity, area, and
%nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called segemented with the row and channel name.

clear
%Save the images of the segmentation?
saveIm = 1;
if saveIm == 1
    h=figure;
    set(gcf,'visible','off')
    mkdir('Segmented_Images')
end

imExt = '.jpg';

%The noise filter used is 5.
noise_disk = 5;
%Use a background correction if cidre was used
tophat_rad = 50;  %To correct for uneven illumination correction


%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([NUC.dir filesep '*' imExt]);
NUC.filnms = strcat({NUC.dir}, '/', {NUC.filnms.name});


%Create a structure for each of the channels
Cyto.BF.dir = 'BF';
Cyto.BF.filnms = dir(['BF' filesep '*' imExt]);
Cyto.BF.filnms = strcat('BF', '/', {Cyto.BF.filnms.name});


%Correct directory listings based on the number in the image file between the - -
%eg 20150901141237-1428-R05-C04.jpg
%This is necessary due to matlab dir command sorting placing 1000 ahead of
%999 ect.
for i = 1:size(NUC.filnms,2)
    str = (NUC.filnms{i});idx = strfind(str,'-');
    val(i,1) = str2num(str(idx(1)+1:idx(2)-1));
end
for i = 1:size(NUC.filnms,2)
     str = (Cyto.BF.filnms{i}); idx = strfind(str,'-'); 
     val(i,2) = str2num(str(idx(1)+1:idx(2)-1));
end

[temp idx] = sort(val);
NUC.filnms = {NUC.filnms{idx(:,1)}};
Cyto.BF.filnms = {Cyto.BF.filnms{idx(:,2)}};

%Make a directory for the segemented files
mkdir('Segmented')

%Preallocate for memory
tempIm = imread(char(NUC.filnms(1)));
Im_array  = zeros(size(tempIm,1),size(tempIm,2),2);
SegIm_array  = zeros(size(tempIm,1),size(tempIm,2),2);
Nuc_label = zeros(size(tempIm,1),size(tempIm,2),1);
Label_array = zeros(size(tempIm,1),size(tempIm,2));

wb = waitbar(0.000001,'Time to complete:');
%For all images
for i = 1:size(NUC.filnms,2)
    tic
    CO = struct(); %Cellular object structure.  To be saved
    nm = char(NUC.filnms(i));
    foo = strfind(nm, '-');
    %Store the row and column names from the filename
    rw = nm(foo(2)+1:foo(2)+3);
    cl = nm(foo(3)+1:foo(3)+3);
    
%     %store the time from the file name
%     tim.day = str2double(nm(7:8));
%     tim.hr = str2double(nm(9:10));
%     tim.min = str2double(nm(11:12));

    %Read in all the images and correct with for illumination with CIDRE or
    %tophat.  Store the nuclear image in the first!
    
    tempIm = imread(char(NUC.filnms(i)));
    if size(tempIm,3) ~=1
        tempIm = rgb2gray(tempIm);
    end
    tempIm = imtophat(im2double(tempIm), strel('disk', tophat_rad));
    
    %Convert to 8bit image
    tempIm = im2uint8(tempIm);
    Im_array(:,:,1) = tempIm;
    %read in BF cytoplasmic channels
    tempIm = imread(char(Cyto.BF.filnms(i)));
    
    if size(tempIm,3) ~=1
        tempIm = rgb2gray(tempIm);
    end
    %tempIm = imtophat(im2double(tempIm), strel('disk', tophat_rad));

    %Convert to 8bit image
    tempIm = im2uint8(tempIm);
    Im_array(:,:,2) = tempIm;

    if saveIm == 1
        clf;
        subplot(1,2,1), imshow(Im_array(:,:,1),[]);
        title('Nuclear Original')
        subplot(1,2,2), imshow(Im_array(:,:,2),[]);
        title('Original BF')
        str = sprintf('Segmented_images/Original_%s_%s_%d',rw,cl,i);
        savefig(h,str);
    end
    
    %%Now segment the nucleus
    % To Binary Image with otsu's threshold
    num = multithresh(Im_array(:,:,1),2);
    SegIm_array(:,:,1)	= imquantize(Im_array(:,:,1), num);
    SegIm_array(SegIm_array(:,:,1) == 1) = 0; %Background
    SegIm_array(SegIm_array(:,:,1) == 2) = 1; %Out of focus/less bright nuclei
    SegIm_array(SegIm_array(:,:,1) == 3) = 1; %Bright nuclei
    
    % Remove Noise
    noise = imtophat(SegIm_array(:,:,1), strel('disk', noise_disk));
    SegIm_array(:,:,1) = SegIm_array(:,:,1) - noise;
    
    % Fill Holes
    SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1), 'holes');
    
    %Compute the distance of the binary transformed image using the bright
    %areas of the image as the basins by negating the distance measure
    D = -bwdist(~SegIm_array(:,:,1));
    D = -imhmax(-D,3);  %To prevent oversegmentation...  Make variable in image segmentation in future?
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.    
    
    %Here would be a good place to load a baysian correction model that has
    %been predefined to fix the segmentation....
        
    %Now segement all the channels and chose the one with the largest
    %amount of cell staining as defining the cytoplasmic boundary
    %And use that information for subsequent analysis
        
    [~,threshold] = edge(Im_array(:,:,2),'sobel');
    fudgeFactor = 1;
    tempIm = edge(Im_array(:,:,2),'sobel',threshold*fudgeFactor);
    
    tempIm = imdilate(tempIm, strel('disk', 3));
    tempIm = imfill(tempIm,'holes');
    tempIm = imerode(tempIm,strel('diamond',5));
    tempIm = imerode(tempIm,strel('diamond',5));
    tempIm = imclearborder(tempIm,4);
    tempIm = imdilate(tempIm,strel('disk',5));
    SegIm_array(:,:,2) = tempIm;
    Label_array = bwlabel(SegIm_array(:,:,2));
        
    numCytowoutNuc = 0; % Number of cyptoplasms found without nuclei
    %Now for each channel find the properties of the cytoplasm for each
    %nuclei.  Do not use cytplasms with no nuclei
    CytoLabel = zeros(size(Nuc_label));
    nucl_ids_left = 1:max(max(Nuc_label)); %Keep track of what nuclei have been assigned
    for j = 1:max(max(Label_array))
        cur_cluster = (Label_array==j);
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
            if (sum(sum(cur_cluster))) > sum(sum(ismember(Nuc_label,nucl_ids)))
                CytoLabel(cur_cluster)=nucl_ids;
                %delete the nucleus that have already been processed
                nucl_ids_left(nucl_ids_left==nucl_ids)=[];
            end
        else        
            %get an index to only the nuclei
            nucl_idx=ismember(Nuc_label,nucl_ids);
            %get the x-y coordinates
            %Down sample to reduce computational time
            [nucl_x nucl_y]=find(nucl_idx); %Location of all the nuclear pixels
            [cluster_x cluster_y]=find(cur_cluster);  %Location of all cytoplasm pixels
            group_data= Nuc_label(nucl_idx); %Classification of all nuclear labels

            %classify each pixel in the cluster
            %Dont need every pixel in the nucleus to find nearest neighbor.
            %Cuts down on model building timenumCytowoutNuc = 0; % Number of cyptoplasms found without nuclei
            %Build a model based on spatial information of what each group
            %each x y coordinate is assigned to then use to predict what each
            %cytoplasmic element belongs to...
            knnModel = fitcknn([nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
            CytoLabel(cur_cluster) = predict(knnModel,[cluster_x cluster_y]);

            %delete the nucleus that have already been processed
            for elm = nucl_ids'   % why is there an ' ?
                nucl_ids_left(nucl_ids_left==elm)=[];
            end
        end
    end

    if saveIm == 1
        clf;
        subplot(1,2,1), imshow(label2rgb(CytoLabel),[]);
        subplot(1,2,2), imshow(label2rgb(Nuc_label),[]);
        str = sprintf('Segmented_images/Segmented_%s_%s_%d',rw,cl,i);
        savefig(h,str);
    end
    
    % Segment properties
    p	= regionprops(CytoLabel,'Area','Perimeter');
    %Store the information of each cell's perimeter and area
    Area = [];
    Perimeter = [];
    m = 1;
    if size(p,1) ~= 0
        for k = 1:size(p,1)
            Area(m) = p(k).Area;
            Perimeter(m) = p(k).Perimeter;
            m= m+1;
        end
    end
    %For each channel save information into the structure
    CO.BF.Area = Area;
    CO.BF.Perimeter = Perimeter;
    %Save the nucleus information
    %%Count the number of cells in the image from the number of labels
    CO.cellCount = max(max(Nuc_label));     
    CO.Nuc_label = Nuc_label;
    CO.label = CytoLabel;
    CO.numCytowoutNuc = numCytowoutNuc;
    CO.numCyto = length(unique(CytoLabel))-1;

    %Save segmentation in a directory called segmented
    save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    i %to see a read out as the program runs
    t(i) = toc;
    num = i./size(NUC.filnms,2); 
    %Calculate the time remaining as a rolling average
    chnm = sprintf('Time to complete: %2.2f min', ((size(NUC.filnms,2)-i)*mean(t))./60);
    %Update waitbar
    waitbar(num,wb,chnm);
end
close(wb)

if saveIm ==1
    mkdir('Segmentation_Images/png/')
    file_specs = dir('Segmentation_Images/*fig');
    for i = 1:size(file_specs,1)
        h = openfig(['Segmentation_Images/' file_specs(i).name])
        str = file_specs(i).name;
        id = strfind(str,'.')
        str = file_specs(i).name(1:id-1)
        print(h,['Segmentation_Images/png/' str],'-dpng');
        close(h)
    end

    mkdir('Segmentation_Images/matlab_fig/')
    for i = 1:size(file_specs,1)
        movefile(['Segmentation_Images/' file_specs(i).name],'Segmentation_Images/matlab_fig/')
    end
end

    
 