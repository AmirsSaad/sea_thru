% output_folder_half = 'half_res_undistort';
% if ~exist(output_folder_half, 'dir'), mkdir(output_folder_half); end
% resolution_factor_half = 0.5;
output_folder_quarter = 'quarter_res_undistort';
resolution_factor_quarter = 0.25;
if ~exist(output_folder_quarter, 'dir'), mkdir(output_folder_quarter); end

% Input folder: full res
%input_folder_full_res = 'full_res';
%input_folder_half_res = 'half_res';

% input_folder_full_res = 'D:/codes2compare/1-UIR_IBLA_peng_2017/results';
% input_folder_full_res = 'D:/codes2compare/2-IR_GDCP_peng_2018/results';
% input_folder_full_res = 'D:/codes2compare/3-MILP_Li_2016/results';
% input_folder_full_res = 'D:/codes2compare/4-gao_fusion_2019/results';
% input_folder_full_res = 'D:/codes2compare/5-ULAP_song_2018/results';
% input_folder_full_res = 'D:/codes2compare/6-GB_UDCP_li_2016/results';

% input_folder_full_res = 'D:/final_code/results_10_11';
% input_folder_full_res = 'D:/runs/underwater-orig-run/results_with_mask_final';
% input_folder_full_res ='D:/codes2compare/INPUT';
 input_folder_full_res = 'D:/final_code/results_10_11/nice';

dataset_path = '../';

% Undistort full res images and transmission maps, save both as half res
% and as quarter res
% files_full_res = dir([input_folder_full_res, '/*output_img.tif*']);
files_full_res = dir([input_folder_full_res, '/*.tif*']);

for ii = 1:length(files_full_res)
    disp(['*** File: ', files_full_res(ii).name, ' ***']);
    img_name = files_full_res(ii).name(1:8);
    img = imread([files_full_res(ii).folder, '/', files_full_res(ii).name]);
%     %load([input_folder_full_res, '/', 'stereoParams0.5_', image_name_to_dive_name(img_name), '.mat']);
%     %%%%%%%
%     % The image name has to be from the dataset, as listd in the table
%     dataset_table = readtable('dive_sites_and_image_files.xlsx');
%     [cam_name, im_num] = validate_im_name(img_name);
%     if strcmp(cam_name, 'RGT')
%         idx = find(dataset_table.right_num == im_num);
%     elseif strcmp(cam_name, 'LFT')
%         idx = find(dataset_table.left_num == im_num);
%     end
%     if isempty(idx)
%         error(['Invalid image number ', num2str(im_num), ': it is not listed in the dataset table'])
%     end
%     dive_location = dataset_table.dive_location{idx};
%     image_set = dataset_table.image_set(idx);
%     
%     % Load calibration data
%     if ~exist(dataset_path, 'dir')
%         error(['Could not find the dataset folder in this path: ', dataset_path])
%     end
%     calib_data_path = fullfile(dive_location, 'stereoParams0.5.mat');
%     load(calib_data_path, 'stereoParams');
%     %%%%%
%     img_undistort = undistortImage(img, stereoParams.CameraParameters2);
% %     reduce_res_and_save(img_undistort, resolution_factor_half, output_folder_half, files_full_res(ii).name);
% %     reduce_res_and_save(img_undistort, resolution_factor_quarter, output_folder_quarter, files_full_res(ii).name);
% % img_small = imresize(img_undistort, resolution_factor_half);
% % imwrite(img_small, [output_folder_half, '\', strrep(files_full_res(ii).name, '.tif', '') ,'.png']);
% img_small = imresize(img_undistort, resolution_factor_quarter);
% imwrite(img_small, [output_folder_quarter, '\', strrep(files_full_res(ii).name, '.tif', '') ,'.png']);
img_small = imresize(img, resolution_factor_quarter);
imwrite(img_small, [output_folder_quarter, '\', strrep(files_full_res(ii).name, '.tif', '') ,'.png']);

end

%% Undistort half res images and transmission maps, save both as half res
% and as quarter res
% files_half_res = cat(1, dir([input_folder_half_res, '/*.png']), ...
%     dir([input_folder_half_res, '/*.jpg']));
files_half_res = dir([input_folder_half_res, '/*_emberton_trans_rho0-*.jpg']);

for ii = 1:length(files_half_res)
    disp(['*** File: ', files_half_res(ii).name, ' ***']);
    img = imread([files_half_res(ii).folder, '/', files_half_res(ii).name]);
    % Load Stereo params
    if strcmp(files_half_res(ii).name(1:4), 'RGT_')
        img_name = files_half_res(ii).name(1:8);
        load([input_folder_full_res, '/', 'stereoParams0.5_', image_name_to_dive_name(img_name), '.mat']);
    else
        dive_site = regexprep(strtok(files_half_res(ii).name, '_'), '\d+(?:_(?=\d))?', '');
        dive_site = [upper(dive_site(1)), dive_site(2:end)];
        load([input_folder_full_res, '/', 'stereoParams0.5_', dive_site, '.mat']);
    end
    img_high_res = imresize(img, 2);
    img_undistort = undistortImage(img_high_res, stereoParams.CameraParameters2);
    reduce_res_and_save(img_undistort, resolution_factor_half, output_folder_half, files_half_res(ii).name);
    reduce_res_and_save(img_undistort, resolution_factor_quarter, output_folder_quarter, files_half_res(ii).name);
end

%% Reduce resolution of depth maps
files_depth_maps = dir([input_folder_full_res, '/*_depthMap.jpg']);
for ii = 1:length(files_depth_maps)
    disp(['*** File: ', files_depth_maps(ii).name, ' ***']);
    img = imread([files_depth_maps(ii).folder, '/', files_depth_maps(ii).name]);
    reduce_res_and_save(img, resolution_factor_half, output_folder_half, files_depth_maps(ii).name);
    reduce_res_and_save(img, resolution_factor_quarter, output_folder_quarter, files_depth_maps(ii).name);

end

%%
function [] = reduce_res_and_save(img, scale_factor, output_folder, output_name)
img_small = imresize(img, scale_factor);
% Save temporary PNG, and then convert it to JPG using Guetzli
output_name = strrep(strrep(output_name, '.tif', ''), '.jpg', '');
tmp_img_path = [output_folder, '\', output_name ,'_tmp.png'];
final_img_path = [output_folder, '\', output_name ,'.jpg'];
imwrite(img_small, tmp_img_path);
command = ['guetzli_windows_x86-64.exe --quality 85 ', tmp_img_path, ' ', final_img_path];
status = system(command);
disp(['Gueztli status: ', num2str(status)]);
command2 = ['del ', tmp_img_path];
status = system(command2);
disp(['Delete status: ', num2str(status)]);
end

