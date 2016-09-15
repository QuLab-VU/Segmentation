function output_args=segmentCytoUsingNuclei_v2(input_args)
%segments cytoplasm binary image using data from nuclear label matrix
img_cyto=input_args.CytoImage.Value;
nucl_lbl=input_args.NuclearLabel.Value;

%do preliminary segmentation of cytoplasm
cyto_lbl=bwlabeln(img_cyto);
new_lbl=zeros(size(cyto_lbl));
%segmenting the clusters into individual cells

%get the nuclei ids present in the cluster
nr_clusters=max(cyto_lbl(:));

%keep track of a list of nucl_ids
nucl_ids_left = unique(nucl_lbl);
nucl_ids_left(nucl_ids_left==0) = [];

for i=1:nr_clusters
    cur_cluster=(cyto_lbl==i);
    %get the nuclei ids present in the cluster
    nucl_ids=nucl_lbl(cur_cluster);   
    nucl_ids=unique(nucl_ids);
    %remove the background id
    nucl_ids(nucl_ids==0)=[];
    if isempty(nucl_ids)
        %don't add objects without nuclei
        continue;
    end
    if (length(nucl_ids)==1)
        %only one nucleus - assign the entire cluster to that id
        new_lbl(cur_cluster)=nucl_ids;
        %delete the nucleus that have already been processed
        nucl_ids_left(nucl_ids_left==nucl_ids)=[];
        continue; 
    end
    %get an index to only the nuclei
    nucl_idx=ismember(nucl_lbl,nucl_ids);
    %get the x-y coordinates
    [nucl_x nucl_y]=find(nucl_idx);
    [cluster_x cluster_y]=find(cur_cluster);
    group_data=nucl_lbl(nucl_idx);
    %classify each pixel in the cluster
    pixel_class=knnclassify([cluster_x cluster_y],[nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
    new_lbl(cur_cluster)=pixel_class;
    
    %delete the nucleus that have already been processed
    for elm = nucl_ids'   % why is there an ' ?
        nucl_ids_left(nucl_ids_left==elm)=[];
    end
    
end

output_args.LabelMatrix=new_lbl;
% output_args.LabelMatrixLeft=nucl_ids_left; % added on 15NOV12

output_args.LabelMatrixLeft=nucl_lbl;

%end segmentCytoUsingNuclei
end