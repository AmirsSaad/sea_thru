% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

exp_root = '../sandbox/2020_05_01_plates_multip';%'D:\sea_thru_experiments\04_21__13_48';
data = readtable(fullfile(exp_root,'data.csv'),'Format','%s%s%s');
config = parse_config(fullfile(exp_root,'config.json'));
close all
failed = {};
for i = 1:size(data,1)
    %try
    config.MeanHist=['../statistics/' data.db{i} '_0.05.v5.csv'];
    [~,name,~] = fileparts(data.dng{i});
    if config.delPalette
        load(['evaluation/param_files/' name '_params.mat']);
    else
        content=[];
    end
    [Ifixed,results] = configed_fixProcess(data.dng{i},data.depth{i},config,content);
    %[I,info] = convert_dng2sensor(data.dng{i});
    %Ifixed=convert_sensors2viewable(I,info);
    %figure(); imshow(Ifixed,[]);
    
    savepath = fullfile(exp_root,data.db{i},name);
    if ~exist(savepath,'dir'), mkdir(savepath); end
    imwrite(Ifixed,fullfile(savepath,[name '.jpg']))
    
      print(figure(1),fullfile(savepath,[name '_BS_fit.eps']),'-depsc');
      print(figure(2),fullfile(savepath,[name '_ALfit.eps']),'-depsc');
      print(figure(3),fullfile(savepath,[name '_Ifixed.eps']),'-depsc');
      print(figure(4),fullfile(savepath,[name '_Var.eps']),'-depsc');
%     saveas(figure(1),fullfile(savepath,[name '_BS_fit.png']));
%     saveas(figure(2),fullfile(savepath,[name '_ALfit.png']));
%     saveas(figure(3),fullfile(savepath,[name '_Ifixed.png']));
%     saveas(figure(4),fullfile(savepath,[name '_Var.png']));
    
    save(fullfile(savepath,'results.mat'),'results')
    close all;
    %catch
    %    failed = [failed , [data.db{i} '_' name]];
    %end
    %disp(failed)
end



function config = parse_config(config_file)
    fid = fopen(config_file); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    config = jsondecode(str);
    config.lambda=ones(1,3)*2;
end
