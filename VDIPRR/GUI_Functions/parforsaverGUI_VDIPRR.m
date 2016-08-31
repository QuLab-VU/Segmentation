function [] = parforsaverGUI_VDIPRR(CO,expDir)
    idx = strfind(CO.ImData.filename,'.');
    idx2 = strfind(CO.ImData.filename,filesep);
    name = CO.ImData.filename(idx2(end)+1:idx(end)-1);
    save([CO.ImData.filename(1:idx2(end)) 'Segmented' filesep name '.mat'], 'CO')
end