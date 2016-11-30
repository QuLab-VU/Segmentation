function [FeatureSet, FeatureSetVarLabels] = CellFeatureSets(orig_im,label_im,idx,properties)
%This is a reduced feature set of shape and intensity based 
    num_ch = size(orig_im,3);  %Number of channels
    detections = max(label_im(:)); %Number of detected cells
    %Pre-allocate the matrix to hold the image gradient
    Gmag_full = zeros(size(orig_im,1),size(orig_im,2),size(orig_im,3));
    Gdir_full = zeros(size(orig_im,1),size(orig_im,2),size(orig_im,3));
    %Take the gradient of the image
    for i = 1:num_ch
        [Gmag_full(:,:,i), Gdir_full(:,:,i)] = imgradient(orig_im(:,:,i));
    end
    %Save memory by clearing gradient directional information
    clear Gdir_full
    %Properties contains a matlab structure resulting from regionprops function. If not present run again.
    if isempty(properties)
        properties = regionprops(label_im,'Area','Centroid','PixelIdxList','BoundingBox');
    end
    %If not given a list of indices corresponding to cells to calculate
    %features of, run for all of them.
    if isempty(idx)
       idx = 1:detections;
    end
    %Pre-allocate vectors holding the x and y position of all the cells
    xPos_all = zeros(detections,1); yPos_all = zeros(detections,1);
    for i = 1:detections
        xPos_all(i) = properties(i).Centroid(1);
        yPos_all(i) = properties(i).Centroid(2);
    end
    %Pre-allocate FeatureSet Vector  18 shape based and 8 intensity based
    %per channel
    FeatureSet = zeros(size(idx,2),18+8*num_ch);
    %idx is a list of indices of cells to segment.  If empty idx = all cells
    for i =  1:length(idx)        
        if properties(idx(i)).Area ~=0
            %Find the Area
            A = properties(idx(i)).Area;
            %Find perimeter
            tempIm = zeros(properties(idx(i)).BoundingBox(4),properties(idx(i)).BoundingBox(3));
            [y_abs,x_abs] = ind2sub(size(label_im),properties(idx(i)).PixelIdxList);
            y_rel = y_abs-properties(idx(i)).BoundingBox(2)+.5; x_rel = x_abs-properties(idx(i)).BoundingBox(1)+.5;
            idx_rel = sub2ind(size(tempIm),y_rel,x_rel);
            tempIm(idx_rel) = 1;
            BW = bwperim(tempIm);
            P = sum(BW(:));
            %Find Centrality
            x_bar = properties(idx(i)).Centroid(1);
            y_bar = properties(idx(i)).Centroid(2);
            var_x = x_abs-x_bar; var_y = y_abs-y_bar;
            v20 = sum(var_x.^2); v02 = sum(var_y.^2); v11 = sum(var_x.*var_y);
            v12 = sum(var_x.*var_y.^2); v21 = sum(var_x.^2.*var_y);
            v30 = sum(var_x.^3); v03 = sum(var_y.^3);

            foo1 = .5*(v20+v02); foo2 = .5*sqrt(4*v11.^2+(v20-v02).^2);
            C = foo1 - foo2./(foo1+foo2);

            %Find Hu's 7 invariant moments (2nd order)
            u20 = v20/A^2;u02 = v02/A^2;u11 = v11/A^2;u30 = v30/A^3;
            u03 = v03/A^3;u21 = v21/A^3;u12 = v12/A^3;

            H = zeros(7,1);
            H(1) = u20+u02;
            H(2) = (u20-u02)^2+4*u11^2;
            H(3) = (u30-3*u12)^2+(3*u21-u03)^2;
            H(4) = (u30+u12)^2+(u21+u03)^2;
            H(5) = (u30-3*u12)*(u30+u12)*((u30+u12)^2-3*(u21+u03)^2)+(3*u21-u03)*(u21+u03)*(3*(u30+u12)^2-(u21+u03)^2);
            H(6) = (u20-u02)*((u30+u12)^2-(u21+u03)^2)+4*u11*(u30+u12)*(u21+u03);
            H(7) = (3*u21-u03)*(u30+u12)*((u30+u12)^2-3*(u21+u03)^2)-(u30-3*u12)*(u21+u03)*(3*(u30+u12)^2-(u21+u03)^2);

            %Find Extension, Elongation, Dispersion (From Dunn Brown paper in
            %Journal Cell Science 1986
            lambda1 = 2*pi*(H(1)+sqrt(H(2)));
            lambda2 = 2*pi*(H(2)+sqrt(H(2)));

            Ext = log(lambda1)/log(2);
            Dis = log(sqrt(lambda1*lambda2))/log(2);
            El  = log(sqrt(lambda1/lambda2))/log(2);

            %Find distance to 4 nearest objects
            [D, I] = sort(sqrt((xPos_all-x_bar).^2+(yPos_all-y_bar).^2));
            if size(idx,2)>4
            	D = mean(D(2:5));
            else
                D = 0;
            end

            %Find distance of of each pixel from centroid
            PD = sqrt(var_x.^2+var_y.^2);
            meanPD = mean(PD);maxPD = max(PD);minPD = min(PD); stPD = std(PD);

            %Now for the intensity based characteristics
            Max_I = zeros(num_ch,1); Mean_I = zeros(num_ch,1); Min_I = zeros(num_ch,1); Skew_I = zeros(num_ch,1); Std_I = zeros(num_ch,1);
            Max_G_f = zeros(num_ch,1);Mean_G_f = zeros(num_ch,1);Min_G_f = zeros(num_ch,1);Std_G_f = zeros(num_ch,1);
            %Find the max, min, mean, std in intensity of each pixel as
            %well as the gradient for each pixel
            for j = 1:num_ch
                for k = 1:length(x_rel)
                    tempIm(y_rel(k),x_rel(k)) = orig_im(y_abs(k),x_abs(k),j);
                end
                Mean_I(j) = mean(tempIm(idx_rel));
                Min_I(j) = min(tempIm(idx_rel));
                Max_I(j) = max(tempIm(idx_rel));
                Std_I(j) = std(tempIm(idx_rel));
                for k = 1:length(x_rel)
                    tempIm(y_rel(k),x_rel(k)) = Gmag_full(y_abs(k),x_abs(k),j);
                end
                Mean_G_f(j) = mean(tempIm(idx_rel));
                Min_G_f(j) = min(tempIm(idx_rel));
                Max_G_f(j) = max(tempIm(idx_rel));
                Std_G_f(j) = std(tempIm(idx_rel));
            end

            %Put it all together
            FeatureSet(i,:) = [A,P,C,H',Ext,Dis,El,D,meanPD,maxPD,minPD,stPD,...
                Mean_I',Min_I',Max_I',Std_I',Mean_G_f',Min_G_f',Max_G_f',Std_G_f'];
        else
            FeatureSet(i,:) = zeros(1,18+8*num_ch);
        end
    end

    %Include a label with all the names of each variable.    
    FeatureSetVarLabels = {'Area','Perimeter','Circularity','Hu_mom1','Hu_mom2','Hu_mom3',...
        'Hu_mom4','Hu_mom5','Hu_mom6','Hu_mom7','Extension','Dispersion','Elongation',...
        'Mean_Dist_to_closest_objs','Mean_Pixel_Dist','Max_Pixel_Dist','Min_Pixel_Dist',...
        'Std_Pixel_Dist'};
    for i = 1:num_ch
        str1 = sprintf('Mean_Intensity_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Min_Intensity_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Max_Intensity_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Std_Intensity_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    
    for i = 1:num_ch
        str1 = sprintf('Mean_Gradient_full_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Min_Gradient_full_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Max_Gradient_full_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    for i = 1:num_ch
        str1 = sprintf('Std_Gradient_full_CH%i',i);
        FeatureSetVarLabels = [FeatureSetVarLabels, str1];
    end
    

%{
Additional code for downsampling image.
%Downsample the image
half_im = imresize(orig_im, .5); half_label_im = imresize(label_im, .5);
quarter_im = imresize(orig_im, .25); quarter_label_im = imresize(label_im, .25);
eighth_im = imresize(orig_im, .125); eighth_label_im = imresize(label_im, .125);

Gmag_full = zeros(size(orig_im,1),size(orig_im,2),size(orig_im,3));
Gdir_full = zeros(size(orig_im,1),size(orig_im,2),size(orig_im,3));
Gmag_half = zeros(size(half_im,1),size(half_im,2),size(half_im,3));
Gdir_half = zeros(size(half_im,1),size(half_im,2),size(half_im,3));
Gmag_quarter = zeros(size(quarter_im,1),size(quarter_im,2),size(quarter_im,3));
Gdir_quarter = zeros(size(quarter_im,1),size(quarter_im,2),size(quarter_im,3));
Gmag_eighth = zeros(size(eighth_im,1),size(eighth_im,2),size(eighth_im,3));
Gdir_eighth = zeros(size(eighth_im,1),size(eighth_im,2),size(eighth_im,3));

L_full = zeros(size(orig_im,1),size(orig_im,2),size(orig_im,3));
L_half = zeros(size(half_im,1),size(half_im,2),size(half_im,3));
L_quarter = zeros(size(quarter_im,1),size(quarter_im,2),size(quarter_im,3));
L_eighth = zeros(size(eighth_im,1),size(eighth_im,2),size(eighth_im,3));

for i = 1:num_ch
	[Gmag_full(:,:,i), Gdir_full(:,:,i)] = imgradient(orig_im(:,:,i));
	[Gmag_half(:,:,i), Gdir_half(:,:,i)] = imgradient(half_im(:,:,i));
	[Gmag_quarter(:,:,i), Gdir_quarter(:,:,i)] = imgradient(quarter_im(:,:,i));
	[Gmag_eighth(:,:,i), Gdir_eighth(:,:,i)] = imgradient(eighth_im(:,:,i));
	L_full(:,:,i) = del2(double(orig_im(:,:,i)));
	L_half(:,:,i) = del2(double(half_im(:,:,i)));
	L_quarter(:,:,i) = del2(double(quarter_im(:,:,i)));
	L_eighth(:,:,i) = del2(double(eighth_im(:,:,i)));
end

for each cell (i)
for each channel (j)

tempIm = double(L_full(:,:,j));
L_f(j,:) = [mean(tempIm(properties(idx(i)).PixelIdxList)), min(tempIm(properties(idx(i)).PixelIdxList)), max(tempIm(properties(idx(i)).PixelIdxList)),std(tempIm(properties(idx(i)).PixelIdxList))];
tempIm = double(Gmag_full(:,:,j));
G_f(j,:) = [mean(tempIm(properties(idx(i)).PixelIdxList)), min(tempIm(properties(idx(i)).PixelIdxList)), max(tempIm(properties(idx(i)).PixelIdxList)),std(tempIm(properties(idx(i)).PixelIdxList))];

PixelIdx = find(half_label_im == idx(i));
if ~isempty(PixelIdx)
tempIm = double(L_half(:,:,j));
L_h(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
tempIm = double(Gmag_half(:,:,j));
G_h(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
else
L_h(j,:) = [0,0,0,0];
G_h(j,:) = [0,0,0,0];
end

PixelIdx = find(quarter_label_im == idx(i));
if ~isempty(PixelIdx)
tempIm = double(L_quarter(:,:,j));
L_q(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
tempIm = double(Gmag_quarter(:,:,j));
G_q(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
else
L_q(j,:) = [0,0,0,0];
G_q(j,:) = [0,0,0,0];
end

PixelIdx = find(eighth_label_im == idx(i));
if ~isempty(PixelIdx)
tempIm = double(L_eighth(:,:,j));
L_e(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
tempIm = double(Gmag_eighth(:,:,j));
G_e(j,:) = [mean(tempIm(PixelIdx)), min(tempIm(PixelIdx)), max(tempIm(PixelIdx)),std(tempIm(PixelIdx))];
else
L_e(j,:) = [0,0,0,0];
G_e(j,:) = [0,0,0,0];
end


%Do special image transform gradient detailed in Magnesun paper
tempIm = label_im == idx(i);
tempIm = double(tempIm);
[x_P, y_P] = ind2sub(size(label_im),find(BW));
for j = 1:length(x)
tempIm(x(j),y(j)) = min(sqrt((x(j)-x_P).^2+(y(j)-y_P).^2))+1;
end
[Gmag Gdir] = imgradient(tempIm);
Gmag_x = cosd(Gdir(:)).*Gmag(:);
Gmag_y = sind(Gdir(:)).*Gmag(:);
idx = properties(idx(i)).PixelIdxList;

fII = zeros(num_ch,1);fL = zeros(num_ch,1);
for j = 1:num_ch
Gf_mag = Gmag_full(:,:,j); Gf_dir = Gdir_full(:,:,j);
Gfmag_x = cosd(Gf_dir(:)).*Gf_mag(:);
Gfmag_y = sind(Gf_dir(:)).*Gf_mag(:);
fII(j) = nanmean((Gmag_x(idx).*Gfmag_x(idx)+Gmag_y(idx).*Gfmag_y(idx))./(sqrt(Gmag_x(idx).^2+Gmag_y(idx).^2)));
fL(j) = nanmean((Gmag_y(idx).*Gfmag_x(idx)+Gmag_x(idx).*Gfmag_y(idx))./(sqrt(Gmag_x(idx).^2+Gmag_y(idx).^2)));

end


%}
