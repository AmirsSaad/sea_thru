function [Istruct,Jbstruct]= getSinglePhotoStats(I,depth,hp,resizeIM)
if resizeIM>0
    I=imresize(I,0.5);
end
depth=depth(1:2:end,1:2:end);

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
Ihp=zeros(zlen-1,3); %I5=zeros(zlen-1,3);


    for i=1:zlen-1
        
       logical=(depth>z(i) & depth<=z(i+1));
       for color=1:3   
           cI=I(:,:,color);
           if max(logical,[],'all')
            Ivar(i,color)=var(cI(logical)*255,[],'all');
            Imin(i,color)=min(cI(logical)*255,[],'all');
            Ihp(i,color)=prctile(cI(logical)*255,hp);
            %I5(i,color)=prctile(cI(logical),5);
           else
            Ivar(i,color)=Ivar(i-1,color);
            Imin(i,color)=Imin(i-1,color);
            Ihp(i,color)=Ihp(i-1,color);
           end
       end
       disp(i/zlen)
    end
    
z=(z(1:end-1)+z(2:end))/2;
z=z(:);

Istruct=struct;
Jbstruct=struct;
Istruct.data=[Ihp z Ivar];
Jbstruct.data=[Imin z];
end