function Iout = histshift(I,color_res,premean)
%create RGB histograms
for i=1:3
    [N,E]=histcounts(I(:,:,i),linspace(0,1,257));
    h(:,i)=smooth(N,5); 
    %edges(:,i)=[min(E) max(E)];
    [edges(:,i),satper(i)]=histsmartedges(h(:,i));
    mask(:,:,i)= (I(:,:,i)>edges(1,i)/color_res & I(:,:,i)<edges(2,i)/color_res);
end
R=h(:,1)';G=h(:,2)';B=h(:,3)';

%cleans from saturation and 0s
R([1:edges(1,1) edges(2,1):color_res])=0;
G([1:edges(1,2) edges(2,2):color_res])=0;
B([1:edges(1,3) edges(2,3):color_res])=0;

%creates triple correlation map
rgbcorr=zeros(color_res*2-2);
Bext=[zeros(1,color_res-1) B zeros(1,color_res-1)];
for i=0:color_res*2-2
    Rext=[zeros(1,i) R zeros(1,color_res*2-2-i)];
    for j=0:color_res*2-2
        Gext=[zeros(1,j) G zeros(1,color_res*2-2-j)];
        rgbcorr(i+1,j+1)=sum(Rext.*Gext.*Bext);
    end
end
%figure();
%surf(rgbcorr);

%find R G shift to B to get max correlation
[M, is]=max(rgbcorr);
[M2, maxj]=max(M);
maxi=is(maxj);
i=maxi;j=maxj;
Rext=[zeros(1,i) R zeros(1,color_res*2-2-i)];
Gext=[zeros(1,j) G zeros(1,color_res*2-2-j)];
Rshift=maxi-color_res;
Gshift=maxj-color_res;

% i=1;
% while (Rext(i)==0 && Bext(i)==0 && Gext(i)==0)
%     i=i+1;
% end
% min_index=i;
% if Rext(i)==0
%     if Gext(i)==0
%         min_color=3;
%     else
%         min_color=2;
%     end;
% else
%     min_color=1; 
% end;

% i=color_res*3-2;
% while Rext(i)==0 && Bext(i)==0 && Gext(i)==0
%     i=i-1;
% end
% max_index=i;

% if Rext(i)==0
%     if Gext(i)==0
%         max_color=3;
%     else
%         max_color=2;
%     end;
% else
%     max_color=1; 
% end;

picres=size(I); picres=picres(1:2);
if premean==-1
    premean=mean(I(mask),'all');
end
shiftmask=ones(picres)*Rshift.*mask(:,:,1)/color_res;
shiftmask(:,:,2)=ones(picres)*Gshift.*mask(:,:,2)/color_res;

I_R=I(:,:,1)+shiftmask(:,:,1);
I_G=I(:,:,2)+shiftmask(:,:,2);
I_B=I(:,:,3);
Iout=I_R; Iout(:,:,2)=I_G; Iout(:,:,3)=I_B;
postmean=mean(Iout(mask),'all');
shiftall=postmean-premean;
Iout(mask)=Iout(mask)-shiftall;
   
Iout(Iout<0)=0;
Iout(Iout>1)=1;
end