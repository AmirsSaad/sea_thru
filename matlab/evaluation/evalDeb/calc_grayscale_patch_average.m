function [ angles ] = calc_grayscale_patch_average( img, data, scale )
%Calc angle in RGB space between [1,1,1] and the RGB values of the given
%coords
%   Inputs:
%   data - struct with the fields:
%       locations: [4ª2 double] - coordinates of color chart
%       horizontal: [18ª1 double] - center coordinates of color patches
%       vertical: [18ª1 double] - center coordinates of color patches

yC = round(data.locations(:,2).*scale);
xC = round(data.locations(:,1).*scale);
img_chart = img(min(yC):max(yC), min(xC):max(xC), :);

% filter chart to suppress noise
filt_size = [5,5];
img_chart_ave = im_median(img_chart,filt_size);

x_colors = round(data.horizontal(1:6).*scale) - min(xC)+1; % 6 neutral patches
y_colors = round(data.vertical(1:6).*scale) -min(yC) + 1;

[h,w, ~] = size(img_chart_ave);
ind_square = sub2ind([h,w],y_colors, x_colors);
color_squares = cat(2, img_chart_ave(ind_square),...
    img_chart_ave(ind_square+h*w), img_chart_ave(ind_square+2*h*w));

angles = dot(color_squares, ones(size(color_squares)), 2) ./...
    ( sqrt(sum( color_squares.^2,2)).* sqrt(3));

angles = acosd(angles);  % Return angles in degrees

end % function calc_grayscale_patch_average
