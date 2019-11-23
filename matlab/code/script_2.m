clear; clc; close all;
addpath code/
im = im2double(imread('data/T_S04857.tiff'));

figure
imshow(im)
title('original')
saveas(gcf,'original.jpg')
%%
imshow(mask_point_operation(im,ones(size(im)),'red_contrast_stretch'));
title('red channel contrast stretch')
saveas(gcf,'red_contrast_stretch.jpg')
figure
imshow(mask_point_operation(im,ones(size(im)),'red_histeq'));
title('red channel hist eq')
saveas(gcf,'red_histeq.jpg')