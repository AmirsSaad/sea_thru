function [table_color_angles_ave,table_angles_ave] = eval_color(img, im_name,dataset_path,undistort_flag)
%The average reproduction angular error in RGB space between the 
%gray-scale patches and a pure gray color.
%Note: Only images from the right camera can be evaluted, since the
%location of the color chart in the image plane is only available for the
%right camera.
%
%   Arguments:
%   img - A H*W*3 array of an image from the underwater dataset.
%   im_name - The name of the image for which the trans was estimated.
%             E.g. RGT_3008
%   undistort_flag - indicates if your result is undistorted(1) or not(0)

%% Validate input
% Make sure the image has the right size
if ischar(img) && exists(img, 'file')
    img = imread(img);
end
% The image name has to be from the dataset, as listd in the table
dataset_table = readtable('dive_sites_and_image_files.xlsx');
[cam_name, im_num] = validate_im_name(im_name);
if strcmp(cam_name, 'RGT')
    idx = find(dataset_table.right_num == im_num);
elseif strcmp(cam_name, 'LFT')
    idx = find(dataset_table.left_num == im_num);
end
if isempty(idx)
   error(['Invalid image number ', num2str(im_num), ': it is not listed in the dataset table'])
end
dive_location = dataset_table.dive_location{idx};
% Load calibration data
if ~exist(dataset_path, 'dir')
    error(['Could not find the dataset folder in this path: ', dataset_path])
end
calib_data_path = fullfile(dive_location, 'stereoParams0.5.mat');
load(calib_data_path, 'stereoParams');
[h, w, n_colors] = size(img);
if (h ~= 1827) || (w ~= 2737)
    img = imresize(img, [1827, 2737]);
end
img = im2double(img);
if n_colors ~= 3
    error(['The input image must have 3 color channels, currently is has ', ...
        num2str(n_colors)]);
end
if undistort_flag == 0
    img = undistortImage(img,stereoParams.CameraParameters2);
end
% Make sure the image name is a valid name of an image from the right camera
[cam_name, ~] = validate_im_name(im_name);
if ~strcmp(cam_name, 'RGT')
    error('Color reproduction can only be evaluated for images from the right camera given the supplied param files');
end

%% Load params file
% Find and load the params file for this image. The param files are stored
% with the eval code, since they are needed for evaluation only.
param_filepath = fullfile('param_files_undistort', [im_name, '_params.mat']);
if ~exist(param_filepath, 'file')
    error(['Could not find params for image: ', im_name, ...
        ', is the image name correct and part of the dataset?']);
end
% Load param file with chart coordinates
load(param_filepath, 'data');

%% Calculate average reproduction angular error of grayscale patches
n_charts = length(data);
table_angles_ave = nan(5, 1);
table_color_angles_ave = nan(5, 1);
if n_charts == 0   % No charts in this image
    disp(['Image ', im_name,' does not contain color charts']);
    return;
end

% Reference image above water
dir_ref = '';%d:\CodeRoot\images\underwater_cc6\above_water\';
im_name_ref = 'RGT_0154_linear_demosaiced.dng';
%dir_utils = 'd:\github_repos\bmvc_code\utils\';
%addpath(dir_utils);
[im_ref_linear, im_ref_info] = convert_dng2linear([dir_ref, im_name_ref], 0);
im_ref_linear_blurred = imgaussfilt(im_ref_linear, 15);
ref_data.vertical = [1655, 1623, 1659, 1711, 1763, 1619, 2759, 2747, 2923, 2715, 2883, 2839, 3607, 3457, 3523, 3583, 3639, 3567];
ref_data.horizontal = [1666, 2570, 3454, 4322, 5098, 6050, 5946, 5090, 4078, 3242, 2494, 1650, 1654, 2518, 3386, 4302, 4950, 5954];
neutral_color = zeros(3, 6);
for i_patch = 1:6
neutral_color(:, i_patch) = squeeze(im_ref_linear_blurred(ref_data.vertical(i_patch), ref_data.horizontal(i_patch), :));
end
neutral_color = mean( neutral_color./sqrt(sum(neutral_color.^2, 1)), 2);
im_ref_srgb = convert_linear2rgb(im_ref_linear, im_ref_info, 'Custom', neutral_color);
im_ref_srgb_blurred = imgaussfilt(im_ref_srgb, 15);
dgk_colors =  zeros(3, 18); % all the colors of the DGK colortools
for i_patch = 1:18
dgk_colors(:, i_patch) = squeeze(im_ref_srgb_blurred(ref_data.vertical(i_patch), ref_data.horizontal(i_patch), :));
end

for i_chart = 1:n_charts  % Number of charts in the image
    data_this_chart = data(i_chart);
    angles = real(calc_grayscale_patch_average(img, data_this_chart, 1));
    table_angles_ave(i_chart) = mean(angles);
    
    color_angles = real(calc_angular_error(img, data_this_chart, 1,dgk_colors));
    table_color_angles_ave(i_chart) = mean(color_angles);
    
end
