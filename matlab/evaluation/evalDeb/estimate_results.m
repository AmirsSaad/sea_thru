clear all;close all; clc;

%% change this
% images_dir = 'D:/codes2compare/1-UIR_IBLA_peng_2017/results';
images_dir = 'D:/codes2compare/2-IR_GDCP_peng_2018/results';
% images_dir = 'D:/codes2compare/3-MILP_Li_2016/results';
% images_dir = 'D:/codes2compare/4-gao_fusion_2019/results';
% images_dir = 'D:/codes2compare/5-ULAP_song_2018/results';
% images_dir = 'D:/codes2compare/6-GB_UDCP_li_2016/results';
% images_dir = 'D:/final_code/results_10_11';

% images_dir = 'D:/final_code/results';
% images_dir = 'D:/runs/underwater-orig-run/results_with_mask_final';
% images_dir = 'D:/runs/underwater-orig-run/results_no_mask_final';

% images_dir = 'D:\codes2compare\0-from_dana\underwater_others\Codruta\Results\ICPR2016';
% images_dir = 'D:\codes2compare\0-from_dana\underwater_others\Codruta\Results\TIP2018';
% images_dir = 'D:\codes2compare\0-from_dana\underwater_others\Codruta\Results\ICIP2017';
% images_dir = 'D:\codes2compare\0-from_dana\underwater_others\EMBERTON';

trans_exist = 1;
undistort_flag = 0;


listing = dir(fullfile(images_dir, '/*output_img.tif*'));
dataset_path = '../';

if (trans_exist)
    params_dir = fullfile(images_dir,'params');
    trans_img = dir(fullfile(params_dir, '/*.mat'));
    %trans_img = dir(fullfile(params_dir, '/*.png'));
    depth_dir = fullfile(images_dir, 'depth');
    if ~exist(depth_dir, 'dir'), mkdir(depth_dir); end
end

%% estimate results:

for i_img = 1:length(listing)
    
    img_name = listing(i_img).name;
    str = strsplit(img_name, '_');
    img_name_disp = [str{1} ,'_',str{2}];
    
    disp(img_name_disp);
    
    img = imread (fullfile(images_dir,img_name));
    
% % %     uciqe_score(i_img)= UCIQE(img);
% % %     uiqm_score(i_img) = UIQM(img);
% % %     
% % %     if ~(contains(img_name, 'RGT_3270') || contains(img_name, 'RGT_4376') || contains(img_name, 'RGT_4489')|| contains(img_name, 'RGT_5445') || contains(img_name, 'RGT_5449'))
% % %         [angles_color_ave(1:5,i_img),angles_ave(1:5,i_img)] = eval_color(img, img_name_disp, dataset_path, undistort_flag);
% % %         angles_ave(6,i_img) = mean(angles_ave(1:5,i_img),'omitnan');
% % %         angles_color_ave(6,i_img) = mean(angles_color_ave(1:5,i_img),'omitnan');
% % %         
% % %     end
    if (trans_exist)
        %Load trans
        load(fullfile(params_dir, trans_img(i_img).name), 'out_trans');
        trans=out_trans;
        
        %     % original algo
        %     load(fullfile(images_dir, trans_img(i_img).name), 'trans_out');
        %     trans=trans_out;
        
%         trans = im2double(rgb2gray(imread(fullfile(params_dir, trans_img(i_img).name))));
        
        rho(i_img) = eval_transmission(trans, img_name_disp, dataset_path, undistort_flag, depth_dir);
        % rho2(i_img) = eval_transmission2(trans, img_name_disp, dataset_path, undistort_flag);
        
    end
end
% 3008
% 3204
% 4485
% 4491
% 5469
% 5478

%% results

% % % angles_ave=angles_ave';
% % % angles_color_ave =angles_color_ave';
% % % uciqe_score = uciqe_score';
% % % uiqm_score = uiqm_score';
% % % if (trans_exist)
% % %     rho = rho';
% % %     % rho2 = rho2';
% % % end