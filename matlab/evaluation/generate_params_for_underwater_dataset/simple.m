%clear all; close all; clc;

%%% estimate results:

listing = dir(fullfile('images', '/*.jpg'));
%trans_img = dir(fullfile('files', '/*.mat'));    
dataset_path = '../';
undistort_flag = 0;    

%depth = fullfile('files', 'depth');
%if ~exist(depth, 'dir'), mkdir(depth); end

% 
% dir_ref = '';%d:\CodeRoot\images\underwater_cc6\above_water\';
% im_name_ref = 'RGT_0154_linear_demosaiced.dng';
% %dir_utils = 'd:\github_repos\bmvc_code\utils\';
% %addpath(dir_utils);
% [im_ref_linear, im_ref_info] = convert_dng2linear([dir_ref, im_name_ref], 0);
% im_ref_linear_blurred = imgaussfilt(im_ref_linear, 15);
% ref_data.vertical = [1655, 1623, 1659, 1711, 1763, 1619, 2759, 2747, 2923, 2715, 2883, 2839, 3607, 3457, 3523, 3583, 3639, 3567];
% ref_data.horizontal = [1666, 2570, 3454, 4322, 5098, 6050, 5946, 5090, 4078, 3242, 2494, 1650, 1654, 2518, 3386, 4302, 4950, 5954];
% neutral_color = zeros(3, 6);
% for i_patch = 1:6
% neutral_color(:, i_patch) = squeeze(im_ref_linear_blurred(ref_data.vertical(i_patch), ref_data.horizontal(i_patch), :));
% end
% neutral_color = mean( neutral_color./sqrt(sum(neutral_color.^2, 1)), 2);
% im_ref_srgb = convert_linear2rgb(im_ref_linear, im_ref_info, 'Custom', neutral_color);
% im_ref_srgb_blurred = imgaussfilt(im_ref_srgb, 15);
% dgk_colors =  zeros(3, 18); % all the colors of the DGK colortools
% for i_patch = 1:18
% dgk_colors(:, i_patch) = squeeze(im_ref_srgb_blurred(ref_data.vertical(i_patch), ref_data.horizontal(i_patch), :));
% end

%%
angles_ave = nan(6, length(listing));
color_angles_ave = nan(6, length(listing));
for i_img = 1:length(listing)
    
    img_name = listing(i_img).name;
    str = strsplit(img_name, '_');
    im_name = [str{1} ,'_',str{2}];
    
    disp(im_name);

    img = imread (fullfile('images',img_name)); 
%   img = imread (fullfile('files','RGT_4495_output_img_orig.tiff'));    

%     %Load trans
%     load(fullfile('files', trans_img(i_img).name), 'out_trans');
%     trans=out_trans;

    % original algo
    %load(fullfile('files', trans_img(i_img).name), 'trans_out');
    %trans=trans_out;
    
%     trans = im2double(imread(fullfile('files', trans_img(i_img).name)));
%     load(fullfile('demo_files', 'trans.mat'), 'trans');
 
    %rho(i_img) = eval_transmission(trans, img_name_disp, dataset_path, undistort_flag);
%     rho2(i_img) = eval_transmission2(trans, img_name_disp, dataset_path, undistort_flag);
    %uciqe_score(i_img)=UCIQE(img);
%     %% Validate input
%     % Make sure the image has the right size
%     if ischar(img) && exists(img, 'file')
%         img = imread(img);
%     end
%     % The image name has to be from the dataset, as listd in the table
%     dataset_table = readtable('dive_sites_and_image_files.xlsx');
%     [cam_name, im_num] = validate_im_name(im_name);
%     if strcmp(cam_name, 'RGT')
%         idx = find(dataset_table.right_num == im_num);
%     elseif strcmp(cam_name, 'LFT')
%         idx = find(dataset_table.left_num == im_num);
%     end
%     if isempty(idx)
%        error(['Invalid image number ', num2str(im_num), ': it is not listed in the dataset table'])
%     end
%     dive_location = dataset_table.dive_location{idx};
%     % Load calibration data
%     if ~exist(dataset_path, 'dir')
%         error(['Could not find the dataset folder in this path: ', dataset_path])
%     end
%     calib_data_path = fullfile(dive_location, 'stereoParams0.5.mat');
%     load(calib_data_path, 'stereoParams');
%     [h, w, n_colors] = size(img);
%     if (h ~= 1827) || (w ~= 2737)
%         img = imresize(img, [1827, 2737]);
%     end
%     img = im2double(img);
%     if n_colors ~= 3
%         error(['The input image must have 3 color channels, currently is has ', ...
%             num2str(n_colors)]);
%     end
%     if undistort_flag == 0
%         img = undistortImage(img,stereoParams.CameraParameters2);
%     end
%     % Make sure the image name is a valid name of an image from the right camera
%     [cam_name, ~] = validate_im_name(im_name);
%     if ~strcmp(cam_name, 'RGT')
%         error('Color reproduction can only be evaluated for images from the right camera given the supplied param files');
%     end
    

    % Load params file
    % Find and load the params file for this image. The param files are stored
    % with the eval code, since they are needed for evaluation only.
    param_filepath = fullfile('param_files', [im_name(1:8), '_params.mat']);
    if ~exist(param_filepath, 'file')
        error(['Could not find params for image: ', im_name, ...
            ', is the image name correct and part of the dataset?']);
    end
    % Load param file with chart coordinates
    load(param_filepath);
    
    
    % Calculate average reproduction angular error of grayscale patches
    n_charts = length(content);
    table_angles_ave = nan(5, 1);
    table_color_angles_ave = nan(5, 1);
    if n_charts == 0   % No charts in this image
        disp(['Image ', im_name,' does not contain color charts']);
        return;
    end




    for i_chart = 1:n_charts  % Number of charts in the image
        data_this_chart = content(i_chart);
        angles = real(getErrAngles(data_this_chart, img));
        table_angles_ave(i_chart) = mean(angles);

%         color_angles = real(calc_angular_error(img, data_this_chart, 1,dgk_colors));
%         table_color_angles_ave(i_chart) = mean(color_angles);

    end
    
    
    %if ~(contains(img_name, 'RGT_3270') || contains(img_name, 'RGT_4376') || contains(img_name, 'RGT_4489')|| contains(img_name, 'RGT_5445') || contains(img_name, 'RGT_5449')) 
%         color_angles_ave(1:5,i_img)= table_color_angles_ave;
        angles_ave(1:5,i_img) = table_angles_ave;
        angles_ave(6,i_img) = mean(angles_ave(1:5,i_img),'omitnan');
%         color_angles_ave(6,i_img) = mean(color_angles_ave(1:5,i_img),'omitnan');

    %end
    
end

%rho = rho';
writematrix(angles_ave','images/results.csv') ;
median(angles_ave',1,'omitnan')
% color_angles_ave =color_angles_ave';
%uciqe_score = uciqe_score';