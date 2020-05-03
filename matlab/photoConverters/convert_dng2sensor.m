function [out, info] = convert_dng2sensor(filename)
read_app = 'DNG';               % 'DNG' for .dng  or  'DCRAW' for .tiff
bayer_type = 'rggb';
  
if strcmpi(read_app,'DNG')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % % % - - - - Reading DNG file from DNG Converter output - - - - % % %
    % MATLAB r2011a or later required.
    
    % - - - Reading file - - -
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
    t = Tiff(filename,'r');
    offsets = getTag(t,'SubIFD');
    setSubDirectory(t,offsets(1));
    raw = read(t);
    close(t);
    meta_info = imfinfo(filename);
    x_origin = meta_info.SubIFDs{1}.ActiveArea(2)+1;
    width = meta_info.SubIFDs{1}.DefaultCropSize(1);
    y_origin = meta_info.SubIFDs{1}.ActiveArea(1)+1;
    height = meta_info.SubIFDs{1}.DefaultCropSize(2);
    raw =double(raw(y_origin:y_origin+height-1,x_origin:x_origin+width-1));
    
    % - - - Linearize - - -
    if isfield(meta_info.SubIFDs{1},'LinearizationTable')
        ltab=meta_info.SubIFDs{1}.LinearizationTable;
        raw = ltab(raw+1);
    end
    black = meta_info.SubIFDs{1}.BlackLevel(1);
    saturation = meta_info.SubIFDs{1}.WhiteLevel;
    lin_bayer = (raw-black)/(saturation-black);
    %lin_bayer = max(0,min(lin_bayer,1));
    %clear raw
    
    % - - - White Balance - - -
    wb_multipliers = (meta_info.AsShotNeutral).^-1;
    wb_multipliers = wb_multipliers/wb_multipliers(2);
    mask = wbmask(height,width,wb_multipliers,bayer_type);
    balanced_bayer = lin_bayer .* mask;

%     balanced_bayer = lin_bayer;

    %clear lin_bayer mask
    
else
    error('Invalid Read Approach.')
end


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % - - - - - The rest of the processing chain - - - - -

% - - - Demosaicing - - -
temp = uint16(balanced_bayer*2^16);
% temp = uint16(balanced_bayer/max(balanced_bayer(:))*2^16);
lin_rgb = double(demosaic(temp,bayer_type))/65535;

out = lin_rgb;
info= meta_info;
end