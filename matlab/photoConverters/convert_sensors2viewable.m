function nl_srgb = convert_sensors2viewable(lin_rgb,meta_info)
srgb2xyz = [0.4124564 0.3575761 0.1804375;
    0.2126729 0.7151522 0.0721750;
    0.0193339 0.1191920 0.9503041];
    % - - - Color Correction Matrix from DNG Info - - -
    temp = meta_info.ColorMatrix2;
    xyz2cam = reshape(temp,3,3)';
% - - - Color Space Conversion - - -
rgb2cam = xyz2cam * srgb2xyz;
rgb2cam = rgb2cam ./ repmat(sum(rgb2cam,2),1,3);
cam2rgb = rgb2cam^-1;

lin_srgb = apply_cmatrix(lin_rgb,cam2rgb);
lin_srgb = max(0,min(lin_srgb,1));
%clear lin_rgb
%histRGB(lin_srgb)
% - - - Brightness and Gamma - - -
grayim = rgb2gray(lin_srgb);
grayscale = 0.25/mean(grayim(:));
bright_srgb = min(1,lin_srgb*grayscale);
%bright_srgb = lin_srgb*grayscale;
%clear lin_srgb grayim

nl_srgb = bright_srgb.^(1/2.2);
%histRGB(nl_srgb)
% - - - Display output - - -
%histRGB(nl_srgb)

end