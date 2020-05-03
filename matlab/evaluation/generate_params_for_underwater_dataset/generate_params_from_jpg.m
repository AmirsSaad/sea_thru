function [] = generate_params_from_jpg(img, param_filename)
color_chart = {};
%h1 = figure('Name','Select airlight area (top left and bottom right corners)');
%img = im2double(img);
%imshow(adjust(img,1,1),[]);
%[xA,yA] = ginput(2);
%x1 = round(yA(1)); x2 = round(yA(2));
%y1 = round(xA(1)); y2 = round(xA(2));
%save(param_filename, 'x1', 'x2', 'y1', 'y2');

%scsz = get(0,'ScreenSize');

% An image with multiple color chart of type DKG-color-tools
num_charts = 6;
for iter = 1:num_charts, data(iter).init = 0; end
%close(h1)
for iter = 1:num_charts  % upto six different charts
    % mark all color chart corners
    h1 = figure('Name',['Iter #',num2str(iter),': Select color charts (all corners, from top left, clockwise)']);
    imshow(im2uint8(adjust(im2double(img))));
    h1.Position = scsz;
    [xC,yC] = ginput(4);
    if isempty(xC), break; end %no more chart to mark
    xC = round(xC); yC = round(yC);
    data(iter).locations = [xC,yC];
    chart_h = round(min( norm( [xC(1), yC(1)] - [xC(4), yC(4)]), norm( [xC(2), yC(2)] - [xC(3), yC(3)])));
    chart_w = round(min( norm( [xC(1), yC(1)] - [xC(2), yC(2)]), norm( [xC(4), yC(4)] - [xC(3), yC(3)])));
    close(h1);
    % mark transform of color chart to straight
    fixedPoints = [1, 1; chart_w, 1; chart_w, chart_h; 1, chart_h];
    movingPoints = [xC,yC];
    data(iter).tform = fitgeotrans(movingPoints,fixedPoints,'affine');
    img_chart = img(min(yC):max(yC), min(xC):max(xC),:);
    Jregistered = imwarp(img_chart,data(iter).tform,'FillValues',0.5);
    h1 = figure('Name',['Color chart should be aligned, mark the top left and bottom right corners']);
    imshow(adjust(Jregistered,1,1),[]);
    [xC2,yC2] = ginput(2);
    close(h1);
    xC2 = round(xC2); yC2 = round(yC2);
    yC2(1) = max(yC2(1), 1); yC2(2) = min(yC2(2), size(Jregistered,1));
    xC2(1) = max(xC2(1), 1); xC2(2) = min(xC2(2), size(Jregistered,2));
    if numel(xC2)==2 && numel(yC2)==2
        data(iter).locations2 = [xC2, yC2];
    end
    
    % Mark a point in the center of each color square
    img_chart = img(min(yC):max(yC), min(xC):max(xC), :);
    filt_size = [3, 3];
    h1 = figure('Name',['Mark a point in the center of each patch, start with white']);
    imshow(adjust(im_median(img_chart,filt_size),1,1),[]);
    [x_colors,y_colors] = ginput(18);
    close(h1);
    x_colors = round(x_colors);
    y_colors = round(y_colors);
    data(iter).horizontal = x_colors + min(xC) - 1;
    data(iter).vertical = y_colors + min(yC) - 1;
    data(iter).init = 1;
end % iterate over color charts
is_init = @(x) x.init;
idx_to_keep = arrayfun(is_init,data);
data = data(logical(idx_to_keep));
save(param_filename,'data','-append')

close all;
end %function generate_params
