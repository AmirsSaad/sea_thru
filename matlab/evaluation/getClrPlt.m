function [locations] = getClrPlt(I)
locations=struct;
exClrSet=1; n=1;
while ~isempty(exClrSet)
disp('Crop Around Color calibration pallette')
[Icrop,rect2]=imcrop(I);
close
if isempty(Icrop)
    exClrSet=[];
else
    disp('Select 4 edges (on black) from WHITE corner clockwise and press ENTER')
    imshow(Icrop);
    [x,y]=getpts;
    close
%     tr=fitgeotrans([x y],[[0 1500 1500 0]' [0 0 1057 1057]'],'affine');
%     [Iwarped,oRef]=imwarp(Icrop,tr);
%     ClrPlt=Iwarped((0-round(oRef.YWorldLimits(1))):(1057-round(oRef.YWorldLimits(1))), ...
%                    (0-round(oRef.XWorldLimits(1))):(1500-round(oRef.XWorldLimits(1))) ...
%                    ,:);
    x1=rect2(1)+x;
    y1=rect2(2)+y;
%     offset=61;
%     step=253;
%     exClrSet=zeros(24,3);
% 
%     % filter chart to suppress noise
%     filt_size = [5,5];
%     ClrPlt = im_median(ClrPlt,filt_size);
% 
%     for i=1:4
%         for j=1:6
%             for k=1:3
%                exClrSet(j+(i-1)*6,k) = median( ClrPlt(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k),'all');
%                %exFixed(step*(i-1)+offset:step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k)=0;
%             end
%             %exClrSet(j+(i-1)*6,:)
%         end
%     end
%     color_squares=((exClrSet(1:6,1:3)+exClrSet(7:12,1:3))/2/255);
%     angles = dot(color_squares, ones(size(color_squares)), 2) ./...
%         ( sqrt(sum( color_squares.^2,2)).* sqrt(3));

    %imagedata(n).angles = acosd(angles);  % Return angles in degrees
    locations(n).x = x1;
    locations(n).y = y1;
    locations(n).rect= rect2;
    locations(n).relx = x;
    locations(n).rely = y;
    n=n+1;
end

end

end


