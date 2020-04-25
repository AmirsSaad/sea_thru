function Iout = cntStretch(I,method)

if nargin<2
   method='biside'; %'blacks' 'whites'
end

data=rgb2gray(I);
data=reshape(data,[],1);

if strcmp(method,'biside') || strcmp(method,'blacks')
    low=prctile(data,1);
elseif strcmp(method,'whites')
    low=min(data);
end

if strcmp(method,'biside') || strcmp(method,'whites')
    high=prctile(data,99);
elseif strcmp(method,'blacks')
    high=max(data);
end
Iout=(I-low)./(high-low);
Iout(Iout<0)=0;
Iout(Iout>1)=1;
end
