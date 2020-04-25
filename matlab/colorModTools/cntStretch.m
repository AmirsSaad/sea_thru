function Iout = cntStretch(I,method)
if nargin<2
   method='biside'; %'blacks' 
end
data=rgb2gray(I);
data=reshape(data,[],1);
low=prctile(data,1);
if method=='biside'
    high=prctile(data,99);
elseif method=='blacks'
    high=max(data);
end
Iout=(I-low)./(high-low);
Iout(Iout<0)=0;
Iout(Iout>1)=1;
end
