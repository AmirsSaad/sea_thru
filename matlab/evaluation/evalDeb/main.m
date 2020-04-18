clear all; close all; clc;

%%% estimate results:

listing = dir(fullfile('files', '/*.tiff'));
trans_img = dir(fullfile('files', '/*.mat'));    
dataset_path = '../';
undistort_flag = 0;    

depth = fullfile('files', 'depth');
if ~exist(depth, 'dir'), mkdir(depth); end

for i_img = 1:length(listing)
    
    img_name = listing(i_img).name;
    str = strsplit(img_name, '_');
    img_name_disp = [str{1} ,'_',str{2}];
    
    disp(img_name_disp);

    img = imread (fullfile('files',img_name)); 
%   img = imread (fullfile('files','RGT_4495_output_img_orig.tiff'));    

%     %Load trans
%     load(fullfile('files', trans_img(i_img).name), 'out_trans');
%     trans=out_trans;

    % original algo
    load(fullfile('files', trans_img(i_img).name), 'trans_out');
    trans=trans_out;
    
%     trans = im2double(imread(fullfile('files', trans_img(i_img).name)));
%     load(fullfile('demo_files', 'trans.mat'), 'trans');
 
    rho(i_img) = eval_transmission(trans, img_name_disp, dataset_path, undistort_flag);
%     rho2(i_img) = eval_transmission2(trans, img_name_disp, dataset_path, undistort_flag);
    uciqe_score(i_img)=UCIQE(img);

    if ~(contains(img_name, 'RGT_3270') || contains(img_name, 'RGT_4376') || contains(img_name, 'RGT_4489')|| contains(img_name, 'RGT_5445') || contains(img_name, 'RGT_5449')) 
        [angles_color_ave(1:5,i_img),angles_ave(1:5,i_img)] = eval_color(img, img_name_disp, dataset_path, undistort_flag);
        angles_ave(6,i_img) = mean(angles_ave(1:5,i_img),'omitnan');
        angles_color_ave(6,i_img) = mean(angles_color_ave(1:5,i_img),'omitnan');

    end
    
end

rho = rho';
angles_ave=angles_ave';
angles_color_ave =angles_color_ave';
uciqe_score = uciqe_score';