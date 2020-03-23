clear; clc; close all;
addpath code/
d =  im2double(imread('../data/depthT_S04857.tif'));
im = im2double(imread('../data/T_S04857.tiff'));
im = im(1:size(d,1),1:size(d,2),:);
%%
M3 = DepthQuantization(d,3);
M1 = DepthQuantization(d,1);




% %%
% I1 = mask_point_operation(im,M,'red_histeq');
% % I1(:,:,1) = imgaussfilt(I1(:,:,1),5);
% 
% I2 = mask_point_operation(im,M,'red_contrast_stretch');
% 
% figure
% subplot(2,1,1)
% imshow(im)
% 
% subplot(2,1,2)
% imshowpair(I1,I2,'montage');
% 
% saveas(gcf,)