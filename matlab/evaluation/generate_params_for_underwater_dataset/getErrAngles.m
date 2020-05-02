function allangles=getErrAngles(locations,I)
plates=length(locations);
allangles=zeros(plates,6);

for n=1:plates
    x=locations(n).relx; y=locations(n).rely; rect=locations(n).rect;
    tr=fitgeotrans([x y],[[0 1500 1500 0]' [0 0 1057 1057]'],'affine');
    Icrop=imcrop(I,rect);
    [Iwarped,oRef]=imwarp(Icrop,tr);
    ClrPlt=Iwarped((0-round(oRef.YWorldLimits(1))):(1057-round(oRef.YWorldLimits(1))), ...
                   (0-round(oRef.XWorldLimits(1))):(1500-round(oRef.XWorldLimits(1))) ...
                   ,:);
    offset=63;
    step=250;
    exClrSet=zeros(24,3);

    % filter chart to suppress noise
    %filt_size = [5,5];
    %ClrPlt = im_median(ClrPlt,filt_size);
    %Iwarped2=ClrPlt;
    for i=1:4
        for j=1:6
            for k=1:3
               exClrSet(j+(i-1)*6,k) = median( ClrPlt(30+step*(i-1)+offset:30+step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k),'all');
               %Iwarped2(30+step*(i-1)+offset:30+step*(i)-offset,step*(j-1)+offset:step*(j)-offset,k)=0;
            end
            %exClrSet(j+(i-1)*6,:)
        end
    end
    %imshow(Iwarped2);
    color_squares=(([exClrSet(1:6,1:3)+exClrSet(7:12,1:3)])/2/255);
    angles = dot(color_squares, ones(size(color_squares)), 2) ./...
        ( sqrt(sum( color_squares.^2,2)).* sqrt(3));

    allangles(n,1:6) = acosd(angles);  % Return angles in degrees
end

end



