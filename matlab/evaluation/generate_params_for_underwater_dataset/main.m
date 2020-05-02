listing = dir(['images',filesep,'*.jpg']);
params_dir = 'param_files';
if ~exist(params_dir, 'dir'), mkdir(params_dir); end

for img_idx = 1:length(listing)
    img = imread(['images', filesep, listing(img_idx).name]);
    param_filename = [params_dir, filesep, listing(img_idx).name(1:end-4), '_params.mat'];
    %generate_params_from_jpg(img, param_filename);
    platedata=getClrPlt(img);
    s_wrapped=struct('content',platedata);
    save(param_filename, '-struct', 's_wrapped')
end