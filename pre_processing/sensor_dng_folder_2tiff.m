clear; clc; close all;
folder = '/Users/oferhazut/Desktop/D5/DNG/';   % 'C:\Users\amirsaa\Documents\sea_thru_data\D5\dng_sensor\';
savepath = '/Users/oferhazut/Desktop/D5/TIFF/'; % 'C:\Users\amirsaa\Documents\sea_thru_data\D5\tifs_v4\';
files = dir([folder,'*.dng']);
for file = files'
    file_path = [folder,file.name];
    [out, info] = convert_dng2sensor(file_path);
    imwrite(out,[savepath,strrep(file.name,'.dng','.tif')])
end