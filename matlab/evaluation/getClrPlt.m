function ClrPlt = getClrPlt(I)
disp('Crop Around Color calibration pallette')

Icrop=imcrop(I);
disp('Select 4 edges of Color Pallette: NW NE SE SW and press ENTER')
imshow(Icrop);
[x,y]=getpts
tr=fitgeotrans([x y],[[0 1500 1500 0]' [0 0 1057 1057]'],'affine')
[Iwarped,oRef]=imwarp(Icrop,tr);
ClrPlt=Iwarped((0-round(oRef.YWorldLimits(1))):(1057-round(oRef.YWorldLimits(1))), ...
               (0-round(oRef.XWorldLimits(1))):(1500-round(oRef.XWorldLimits(1))) ...
               ,:);
end