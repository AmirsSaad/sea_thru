clear; clc; close all;
folder = 'C:\Users\amirsaa\Documents\sea_thru_data\3249_3349\dng\';
savepath = 'C:\Users\amirsaa\Documents\sea_thru_data\3249_3349\tifs\';
files = dir([folder,'*.dng']);
for file = files'
    file_path = [folder,file.name];
    out = convert_dng2linear(file_path,[]);
    imwrite(out,[savepath,strrep(file.name,'.dng','.tif')])
end