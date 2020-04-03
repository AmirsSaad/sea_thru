function [diffVec,a]= evaluateColorFix(Ifixed)
% a function for color correction evaluation
exFixed=getClrPlt(Ifixed);
%clrCalib=imread('ColorCalibrator.jpg');
%exFixed=imread('fixed_example.png');

load('clrSet.mat');
%%
offset=61;
step=253;
exClrSet=zeros(24,3);
for i=1:4
    for j=1:6
        for k=1:3
           exClrSet(j+(i-1)*6,k) = mean( exFixed(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k),'all');
           exFixed(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k)=0;
        end
        %exClrSet(j+(i-1)*6,:)
    end
end

imshow(exFixed)

%%
close all;
%exClrSet=exClrSet*255;
scatter3(clrSet(:,1),clrSet(:,2),clrSet(:,3),'o')
hold on;
for i=1:3
A=exClrSet(:,i); B=clrSet(:,i);
h(i)=(A'*B)/(A'*A);
  
end
h=mean(h)
scatter3(h*exClrSet(:,1),h*exClrSet(:,2),h*exClrSet(:,3),'+')
%%
plot((vecnorm(h*exClrSet-clrSet,2,2)))