%DIP analysis
load('Compiled Segmentation Results.mat')
test = ' Vim Epcam Costain'
%CH1 epcam, CH2 is vim  %all in column 3 row2-4 is the Trametinib row5-7 is
%the BEZ235

figure()
hist(log(Seg.NucArea),50)
xlabel('Log(Nuclear Area)')
ylabel('Frequency')
title('Nuclear Area')
set(gca,'fontsize',20)


figure()
hist(log(Seg.Nuc_IntperA),50)
xlabel('Log(Nuclear Intensity per Area)')
ylabel('Frequency')
title('Nuclear Intensity per Area')
set(gca,'fontsize',20)

figure()
hist(log(Seg.NucInt),50)
xlabel('Log(Nuclear Intensity)')
ylabel('Frequency')
title('Nuclear Intensity')
set(gca,'fontsize',20)

figure()
hist(Seg.Nuc_IntperA,50)
rw = unique(Seg.RW,'rows');
cl = unique(Seg.CL,'rows');
% 
% filenames = dir('Segmented')
% im_stack = zeros(512,512,300);
% for i = 3:300
%     temp = load(filenames(i).name)
%     CO = temp.CO;
%     im_stack(:,:,i) = CO.Nuc_label;
% end
% imwrite(im_stack(:,:,1),'Stack.tif');
% for k = 2:300
%     imwrite(im_stack(:,:,k),'Stack.tif','writemode','append');
% end
to_remove = find(Seg.NucArea==0);
to_remove = intersect(to_remove,find(Seg.NucInt == 0));
Seg.NucArea(~ismember(1:length(Seg.NucArea)));

to_remove = union(find(abs(mean(log(Seg.NucArea(Seg.NucArea>0)))-log(Seg.NucArea)) > 3 * std(log(Seg.NucArea(Seg.NucArea>0)))),...
    find(abs(mean(log(Seg.NucInt(Seg.NucInt>0)))-log(Seg.NucInt)) > 3*std(log(Seg.NucInt(Seg.NucInt>0)))));

X = [0:.1:max(log(Seg.NucInt))];
Y = normpdf(X,mean(log(Seg.NucInt(~ismember(1:length(Seg.NucArea),to_remove)))),std(log(Seg.NucInt(~ismember(1:length(Seg.NucArea),to_remove)))))

figure()
hist(log(Seg.NucInt),50)
xlabel('Log(Nuclear Intensity)')
ylabel('Frequency')
title('Nuclear Intensity')
set(gca,'fontsize',20)
hold on
plot(X,Y*10^5)


FormatIn = 'MM-HH-dd-mm-yyyy';ExpTime = [];
cnt = 1;
for i = 1:length(Seg.yearFile)
        str = sprintf('%d-%d-%d-%d-%d',Seg.minFile(i),Seg.hourFile(i),Seg.dayFile(i),Seg.monthFile(i),Seg.yearFile(i));
        dn = datenum(str,FormatIn);
        if ~ismember(dn, ExpTime)
            ExpTime(cnt) = dn;
            cnt = cnt + 1;
        end
end   
ExpWell = []; cnt = 1;
for i = 1:length(Seg.RowSingle)
    str = sprintf('%s-%s',Seg.RowSingle(i,:),Seg.ColSingle(i,:));
    if ~ismember(str,ExpWell)
        ExpWell{cnt} = str;
        cnt = cnt + 1;
    end
end
ExpTime = sort(ExpTime);
numTimPts = length(ExpTime);
plateSz = length(ExpWell);
CellCountsMat = zeros(plateSz,numTimPts)
for i = 1:length(Seg.Nuc_IntperA)
    if ~ismember(i,to_remove)
        str = sprintf('%d-%d-%d-%d-%d',Seg.min(i),Seg.hour(i),Seg.day(i),Seg.month(i),Seg.year(i));
        dn = datenum(str,FormatIn);
        tim = find(dn == ExpTime);
        str = sprintf('%s-%s',Seg.RW(i,:),Seg.CL(i,:));
        well = find(strcmp(str,ExpWell));
        CellCountsMat(well,tim) = CellCountsMat(well,tim)+1;
    end
end

FormatOut = 'MM_HH_dd_mmm_yy';
T = array2table(CellCountsMat);
HeaderName = cell(numTimPts,1);
for i = 1:numTimPts
    HeaderName{i} = strcat('Time_', datestr(ExpTime(i),FormatOut));
end
T.Properties.VariableNames = HeaderName;
T.Properties.RowNames = ExpWell;
 
writetable(T,'CellCountMatrix.csv');


%Time in Min
ExpTim_min = (ExpTime-ExpTime(1)).*24;
rep = {'R02','R03','R04'}

% filename = '20160216 HCC1143 + drug_plate_map.xlsx'
% [num,txt,raw] = xlsread(filename);
% treament_rows = [7,8];

%Convert all Wells into Row column format
for i=1:numTimPts
    Log2Ch(:,i) = log(CellCountsMat(:,i)./CellCountsMat(:,1))./log(2);
end
idx = [];
for i = 1:length(rep)
    idx = [idx,find(cellfun(@isempty,strfind(ExpWell,rep{i}))==0)];
end

numCond = 10;
temp = unique(Seg.CL,'rows');
cond_nm = cell(1);
for i = 1:length(temp)
    cond_nm{i} = temp(i,:);
end

Conditions = {'DMSO','1uM','.25uM','62.5nM','15.6nM','3.9nM','976pM','244pM','61pM','15.2pM'}
figure()
hold on
col_map = jet(numCond);
for i = 2:numCond
    con_id = intersect(idx,find(cellfun(@isempty,strfind(ExpWell,cond_nm{i}))==0));
    shadedErrorBar(ExpTim_min,mean(Log2Ch(con_id,:)),std(Log2Ch(con_id,:))/sqrt(length(rep)),{'color',col_map(i,:)})
    scatter(ExpTim_min,mean(Log2Ch(con_id,:)),500,col_map(i,:),'.');
    text(ExpTim_min(end),mean(Log2Ch(con_id,end)),Conditions{i},'FontSize',20)
end
title('SUM149 Trametinib')
xlabel('Time (Hr)')
ylabel('DIP');
set(gca,'fontsize',30);

