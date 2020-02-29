clear; clc; close all;
folder = 'C:\Users\amirsaa\Documents\sea_thru_data\D5\dng\';
savepath = 'C:\Users\amirsaa\Documents\sea_thru_data\D5\tifs\';
files = dir([folder,'*.dng']);
for file = files'
    file_path = [folder,file.name];
    [out, info] = convert_dng2linear(file_path,[]);
    out = convert_linear2rgb(out,info);
    imwrite(out,[savepath,strrep(file.name,'.dng','.tif')])
end