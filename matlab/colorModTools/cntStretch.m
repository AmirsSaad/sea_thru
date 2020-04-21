function Iout = cntStretch(I)
data=reshape(I,[],1);
low=prctile(data,1);
high=prctile(data,99);
Iout=(I-low)./(high-low);
Iout(Iout<0)=0;
Iout(Iout>1)=1;
end
