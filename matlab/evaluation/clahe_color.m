function [ out ] = clahe_color( RGB , method, num_tiles, clip_limit)
%Contrast-limited adaptive histogram equalization (CLAHE) on RGB images
%   actual contrast is done in Lab color-space

if nargin <2, method = 'lab'; end;
if nargin < 3, num_tiles = [36,36]; end
if nargin < 4, clip_limit = 0.005; end

if strcmp(method,'lab')
    % Convert the RGB image into the L*a*b* color space.
    cform2lab = makecform('srgb2lab');
    LAB = applycform(RGB, cform2lab);
    
    % Scale values to range from 0 to 1.
    L = LAB(:,:,1)/100;
    
    % Perform CLAHE.
    LAB(:,:,1) = adapthisteq(L,'NumTiles', num_tiles, 'ClipLimit', clip_limit)*100;
    
    % Convert the resultant image back into the RGB color space.
    cform2srgb = makecform('lab2srgb');
    out = applycform(LAB, cform2srgb);
    
elseif strcmp(method,'rgb')
    
    out = zeros(size(RGB));
    for ii = 1:3
        out(:,:,ii)= adapthisteq(RGB(:,:,ii),'NumTiles',num_tiles, 'ClipLimit', clip_limit);
    end
end

% Display the original image and result.
% figure, imshow(im2uint8(RGB));
% figure, imshow(im2uint8(out));

end

