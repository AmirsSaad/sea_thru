function [ angles ] = calc_angular_error( img, data, scale, ref_colors )
%Calc angle in RGB space between the RGB values of img at the given coords
%and the reference colors
%   Inputs:
%   -------
%   img  - image to sample from
%   data - struct with the fields:
%       locations: [4ª2 double] - coordinates of color chart
%       horizontal: [18ª1 double] - center coordinates of color patches
%       vertical: [18ª1 double] - center coordinates of color patches
%   scale - the image scale (scale the coordinates accordingly)
%   ref_colors - reference colors to compare to

n_colors = size(ref_colors, 2);

yC = round(data.locations(:,2).*scale);
xC = round(data.locations(:,1).*scale);
img_chart = img(min(yC):max(yC), min(xC):max(xC), :);

% filter chart to suppress noise
filt_size = [5,5];
img_chart_ave = im_median(img_chart,filt_size);

x_colors = round(data.horizontal(1:n_colors).*scale) - min(xC)+1;
y_colors = round(data.vertical(1:n_colors).*scale) -min(yC) + 1;

[h,w, ~] = size(img_chart_ave);
ind_square = sub2ind([h,w],y_colors, x_colors);
color_squares = cat(1, img_chart_ave(ind_square)',...
img_chart_ave(ind_square+h*w)',img_chart_ave(ind_square+2*h*w)');

angles = dot(color_squares, ref_colors, 1) ./...
    ( sqrt(sum( color_squares.^2,1)).* sqrt(sum(ref_colors.^2, 1))  );

angles = acosd(angles);  % Return angles in degrees

end % function calc_grayscale_patch_average
