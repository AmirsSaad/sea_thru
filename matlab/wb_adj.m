function [adj, img_color_out] = wb_adj(img_in)

mask1 = img_in(:,:,1)>0.75 & img_in(:,:,2)>0.75;
mask2 = img_in(:,:,1)>0.75 & img_in(:,:,3)>0.75;
mask3 = img_in(:,:,2)>0.75 & img_in(:,:,3)>0.75;
mask=~(mask1|mask2|mask3);

adj_orig=max(max(img_in.*(repmat(mask,1,1,3))));

tmp1=img_in(:,:,1);
tmp2=img_in(:,:,2);
tmp3=img_in(:,:,3);

lim(:,:,1)=prctile(tmp1(:),99);
lim(:,:,2)=prctile(tmp2(:),99);
lim(:,:,3)=prctile(tmp3(:),99);

adj=max(adj_orig,lim);
img_color=img_in./adj;

c1 = img_color(:,:,1);
c2 = img_color(:,:,2);
c3 = img_color(:,:,3);
maxc=max(img_color,[],3);
c1(maxc>1)=c1(maxc>1)./maxc(maxc>1);
c2(maxc>1)=c2(maxc>1)./maxc(maxc>1);
c3(maxc>1)=c3(maxc>1)./maxc(maxc>1);

img_color_out(:,:,1)=c1;
img_color_out(:,:,2)=c2;
img_color_out(:,:,3)=c3;

mask4 = img_in(:,:,1)>0.9;
img_color_out(repmat(mask4,1,1,3))= img_in(repmat(mask4,1,1,3));

end
