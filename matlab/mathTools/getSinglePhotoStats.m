function [Istruct,Jbstruct]= getSinglePhotoStats(I,depth,hp,lp,resizeIM)
if resizeIM>0
    I=imresize(I,0.5,'method','nearest');
end
depth=depth(1:2:end,1:2:end);
%Igray=rgb2gray(I);
%mnGrayI=Igray>prctile(Igray,30,'all') & Igray<prctile(Igray,70,'all');

depthmax = max(depth,[],'all');
depthmin = min(depth(depth>0),[],'all');
step=0.1; %10cm
if resizeIM>0
    z=depthmin:step:depthmax*0.9;
    z(end)=depthmax*0.9;
else
    z=depthmin:step:depthmax;
    z(end)=depthmax;
end
zlen=length(z);

Ivar=zeros(zlen-1,3); Imin=zeros(zlen-1,3);
Ihp=zeros(zlen-1,3); Ilp=zeros(zlen-1,3); Imean=zeros(zlen-1,3);


    for i=1:zlen-1
        
       logical=(depth>z(i) & depth<=z(i+1));
       for color=1:3   
           cI=I(:,:,color);
           if max(logical,[],'all')
            Ivar(i,color)=var(cI(logical)*255,[],'all');
            Imin(i,color)=min(cI(logical)*255,[],'all');
            %Imin(i,color)=prctile(cI(logical)*255,0.5);
            %if max(logical & mnGrayI,[],'all')
            Imean(i,color)=mean(cI(logical)*255,'all');%prctile(cI(logical)*255,50);%
            %else
            %    Imean(i,color)=mean(cI(logical & mnGrayI)*255,[],'all');
            %end
            Ihp(i,color)=prctile(cI(logical)*255,hp);
            Ilp(i,color)=prctile(cI(logical)*255,lp);
            %I5(i,color)=prctile(cI(logical),5);
            %Ilambda(i,color) = poissfit(cI(logical)*255-Imin(i,color));
           else
            Ivar(i,color)=Ivar(i-1,color);
            Imin(i,color)=Imin(i-1,color);
            Imean(i,color)=Imean(i-1,color);
            Ihp(i,color)=Ihp(i-1,color);
            %Ilambda(i,color)=lambdahat(i-1,color);
           end
       end
       disp(i/zlen)
    end
    
z=(z(1:end-1)+z(2:end))/2;
z=z(:);

Istruct=struct;
Jbstruct=struct;
Istruct.data=[Imean z Ivar Ihp Ilp];% Ilambda];
Jbstruct.data=[Ilp z];
end