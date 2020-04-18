function [ out_img ] = im_median( in_img, sz )
%median_filter on 3-channel image

out_img = zeros(size(in_img));
for color_idx = 1:3
    out_img(:,:,color_idx) = medfilt2(in_img(:,:,color_idx), sz);
end

end

