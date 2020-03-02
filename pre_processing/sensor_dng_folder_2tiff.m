clear; clc; close all;
folder = 'C:\Users\amirsaa\Documents\sea_thru_data\D5\dng_sensor\';
savepath = 'C:\Users\amirsaa\Documents\sea_thru_data\D5\sensor_tifs\';
files = dir([folder,'*.dng']);
for file = files'
    file_path = [folder,file.name];
    [out, info] = convert_dng2sensor(file_path);
    imwrite(out,[savepath,strrep(file.name,'.dng','.tif')])
end