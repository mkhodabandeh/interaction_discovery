if ~exist('loaded')
    loaded = 1;
    aoeuaouaoeuaoeu = 1;
else
    if loaded == 0
        loaded = 1;
    end
end

datapath_shsthsth = [data_address 'VIRAT/' scene '/'];
names_shtshtnshtn = dir([datapath_shsthsth 'VIRAT*']);
if aoeuaouaoeuaoeu <= length(names_shtshtnshtn)
    file_address = [datapath_shsthsth names_shtshtnshtn(aoeuaouaoeuaoeu).name];
    load(file_address);
    aoeuaouaoeuaoeu = aoeuaouaoeuaoeu+1;
else
    loaded = 0;
end