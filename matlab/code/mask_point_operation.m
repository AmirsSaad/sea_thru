function J = mask_point_operation(I,mask,op)

rgbvec = reshape(I,[],3);
for m = 1:size(mask,3)
    rgbvec(mask(:,:,m)==1,:) = point_operation(rgbvec(mask(:,:,m)==1,:),op);
end
J = reshape(rgbvec,size(I));
