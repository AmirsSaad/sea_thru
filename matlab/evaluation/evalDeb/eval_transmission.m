function rho = eval_transmission(trans, im_name, dataset_path,undistort_flag, depth_dir)
%Evaluate the Pearson correlation between the logarithm of the estimated 
%transmisison and the true distances in the scene (calculated from stereo).
%   Arguments:
%   trans - A H*W float array with the transmission map
%   im_name - The name of the image for which the trans was estimated.
%             E.g. RGT_3008
%   dataset_path - Path to the root of the dataset
%   undistort_flag - indicates if your result is undistorted(1) or not(0)

%% Validate input
% The trans has to be evaluated at the the resolution in which the
% calibration was performed.
[h, w] = size(trans);
if (h ~= 1827) || (w ~= 2737)
    trans = imresize(trans, [1827, 2737]);
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
image_set = dataset_table.image_set(idx);

% Load calibration data
if ~exist(dataset_path, 'dir')
    error(['Could not find the dataset folder in this path: ', dataset_path])
end
calib_data_path = fullfile(dive_location, 'stereoParams0.5.mat');
load(calib_data_path, 'stereoParams');

% Load true distances
dist_path = fullfile(dive_location, ['image_set_', num2str(image_set, '%02d')], 'distanceFromCamera.mat');
load(dist_path, 'dist_map_r', 'dist_map_l');

% Extract the relevant data based on the camera used
if strcmp(cam_name, 'RGT')
    camera_params = stereoParams.CameraParameters2;
    distance = dist_map_r;
elseif strcmp(cam_name, 'LFT')
    camera_params = stereoParams.CameraParameters1;
    distance = dist_map_l;
end

%% Calculate Pearson correlation coefficient between the logarithm of the transmission estimation and the true distance
if undistort_flag == 0
    trans_undistorted = undistortImage(trans, camera_params);
else
    trans_undistorted = trans;
end
trans_undistorted(trans_undistorted==0) = NaN;  % can't estimate distances there

dist_valid = ~isnan(distance) & ~isnan(trans_undistorted);

% Calc correlation coefficient
corr_matrix = real(corrcoef(distance(dist_valid), -log(trans_undistorted(dist_valid))));
rho = corr_matrix(1, 2);

%%% print GT & undistorted trans

mycolormap= jet(256);
mycolormap(1,:)=zeros(1,3);

tmp = distance;
tmp(~dist_valid)=NaN;
% disp(max(max(tmp)))   

tmp = (tmp-min(min(tmp)))/( max(max(tmp))-min(min(tmp)));

tmp=1-tmp;
tmp(~dist_valid)= 0;
%figure; imshow (im2uint8(tmp), mycolormap);
imwrite(im2uint8(tmp), mycolormap,fullfile(depth_dir,[im_name, '_GT.png']));

tmp2 = -log(trans_undistorted);

tmp3 = (tmp2-min(min(tmp2)))/( max(max(tmp2))-min(min(tmp2)));
tmp3=1-tmp3;
imwrite(im2uint8(tmp3), mycolormap,fullfile(depth_dir,[im_name, '_full_depth_undistorted.png']));

tmp2(~dist_valid)=NaN;
tmp2 = (tmp2-min(min(tmp2)))/( max(max(tmp2))-min(min(tmp2)));
tmp2=1-tmp2;
tmp2(~dist_valid)=0;
%figure; imshow (im2uint8(tmp2), mycolormap);
imwrite(im2uint8(tmp2), mycolormap,fullfile(depth_dir,[im_name, '_depth_undistorted.png']));


