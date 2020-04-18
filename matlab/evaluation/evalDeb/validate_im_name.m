function [cam_name, im_num] = validate_im_name(im_name)
%Make sure the image name has the right structure and return its
%components.

% Split to components
im_num = str2num(im_name(5:end));
cam_name = im_name(1:3);

if ~(strcmp(cam_name, 'RGT') || strcmp(cam_name, 'LFT'))
    error('Invalid image name: im_name should start with either RGT or LFT')
end
if ~strcmp(im_name, [cam_name, '_', num2str(im_num)])
   error('Invalid image name: im_name should be of the form: XXX_???? where ? is one of the digitd 0-9, and XXX stand for either LFT or RGT')
end
end
