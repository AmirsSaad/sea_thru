
clrCalib=imread('ColorCalibrator.jpg');
exFixed=imread('fixed_example.png');

%%
offset=60;
step=253;
clrset=zeros(24,3);
for i=1:4
    for j=1:6
        for k=1:3
           clrSet(j+(i-1)*6,k)=mean(clrCalib(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k),'all');
           clrCalib(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k)=k;
        end
        clrSet(j+(i-1)*6,:)
    end
end

imshow(clrCalib)