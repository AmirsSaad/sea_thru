exp_root = 'D:\sea_thru_experiments\04_20__00_57';
data = readtable(fullfile(exp_root,'data.csv'),'Format','%s%s%s');
config = parse_config(fullfile(exp_root,'config.json'));

failed = {};
for i = 1:size(data,1)
    try
    [Ifixed,results] = fixProcess(data.dng{i},data.depth{i},config);
    imshow(Ifixed,[]);
    
    [~,name,~] = fileparts(data.dng{i});
    savepath = fullfile(exp_root,data.db{i},name);
    if ~exist(savepath,'dir'), mkdir(savepath); end
    imwrite(Ifixed,fullfile(savepath,[name '.jpg']))
    saveas(figure(1),fullfile(savepath,'01_BS_fit.png'));
    saveas(figure(2),fullfile(savepath,'02_fix.png'));
    save(fullfile(savepath,'results.mat'),'results')
    close all;
    catch
        failed = [failed , [data.db{i} '_' name]];
    end
    disp(failed)
end



function config = parse_config(config_file)
    fid = fopen(config_file); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    config = jsondecode(str);
    config.lambda=ones(1,3)*2;
end
