clear; clc; close all;
addpath code/
d =  im2double(imread('../data/depthT_S04857.tif'));
im = im2double(imread('../data/T_S04857.tiff'));
im = im(1:size(d,1),1:size(d,2),:);
%%
M6 = DepthQuantization(d,6);
M1 = DepthQuantization(d,1);
%%
figure()
imshow(mask_point_operation(im,M1,'red_histeq'))
saveas(gcf,'../M1_red_histeq.jpg')
close;

figure()
imshow(mask_point_operation(im,M6,'red_histeq'))
saveas(gcf,'../M6_red_histeq.jpg')
close;

figure()
imshow(mask_point_operation(im,M1,'red_contrast_stretch'))
saveas(gcf,'../M1_red_contrast_stretch.jpg')
close;

figure()
imshow(mask_point_operation(im,M6,'red_contrast_stretch'))
saveas(gcf,'../M6_red_contrast_stretch.jpg')
close;
