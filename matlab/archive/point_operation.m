function points = point_operation(points , type)


if strcmp(type,'red_contrast_stretch')

    rHist = imhist(points(:,1), 256);
    [lims,~]=histsmartedges(rHist);
    lims=lims/255;
    points(:,1) = imadjust(points(:,1),lims,[]);    
    
elseif strcmp(type,'red_histeq')
    points(:,1) = histeq(points(:,1));   
    
elseif strcmp(type,'norm_contrast_stretch')    
end

