%I=im2double(imread('../data/T_S04857.jpg'));
Iout=zeros(size(im));
Iout2=zeros(size(im));
premean=mean(im,'all');
for i=1:size(M,3)
    Iout=Iout+histshift(bsxfun(@times,im,M(:,:,i)),256,-1);
    Iout2=Iout2+histshift(bsxfun(@times,im,M(:,:,i)),256,premean);
end
figure()
imshowpair(Iout2,Iout,'montage');

%%
figure;
for i=1:10
    subplot(5,2,i);
    imshow(bsxfun(@times,im,M(:,:,i)));
end

%%
figure;
for i=1:7
    subplot(1,7,i);
    imshow(M(:,:,i));
end