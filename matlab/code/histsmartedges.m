function [sedges,inSat] = histsmartedges(h)
%This function cuts the edges till a minimum and returns the edes and the
%percentage of the pixels gone to saturation.
sedges=[1 length(h)];
i=1;
all=sum(h(2:length(h)-1));
inSat=0;
inSat_temp=0;
while ((h(i+1)<=h(i) || inSat_temp<0.01)& i<length(h)-1)
    inSat_temp=inSat_temp+h(i)/all;
    i=i+1; 
end
sedges(1)=i;
j=sedges(2);
inSat=inSat_temp+inSat;
inSat_temp=0;
while ((h(j-1)<=h(j) || inSat_temp<0.01) & j>i)
    inSat_temp=inSat_temp+h(j)/all;
    j=j-1;
end
inSat=inSat_temp+inSat;
sedges(2)=j;
end