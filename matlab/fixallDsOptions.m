close all;

for D=[3 5]
folder = ['../sandbox/D' num2str(D) '/'];
savepath = ['../sandbox/D' num2str(D) '/fixed/'];
strMeanHist=['../statistics/mean_hist_D' num2str(D) '_unnormalized.csv'];
strBSHist=['../statistics/bs_D' num2str(D) '_0.05_unnormalized.csv'];
dngs = dir([folder,'*.dng']);
deps = dir([folder,'*.tif']);
files=length(dngs);
for file = 1:files
    
    strDNG = [folder,dngs(file).name];
    strDepth = [folder,deps(file).name];
    
    blur_red=1; sigma_red=5;
    blur_depth=1; sigma_depth=1;
    for option = [2 3]
        if option==1
            attenFixVer=1;
            lambda=ones(1,3)*4; betaBtype='const'; DC=1; WB=0;
            contStr=1; fix_non_depth=1;
        elseif option==2
            attenFixVer=1;
            lambda=ones(1,3)*2; betaBtype='const'; DC=0; WB=3;
            contStr=1; fix_non_depth=1;
        elseif option==3
            attenFixVer=1;
            lambda=ones(1,3)*2; betaBtype='atten'; DC=0; WB=3;
            contStr=1; fix_non_depth=1;
        elseif option==4
            attenFixVer=3;
            lambda=ones(1,3)*2; betaBtype='atten'; DC=0; WB=3;
            contStr=1; fix_non_depth=1;
        end
        
        Ifixed = fixProcess(strDNG,strDepth,strMeanHist,strBSHist,attenFixVer,lambda,betaBtype,DC,WB,contStr,fix_non_depth,blur_red,sigma_red,blur_depth,sigma_depth);
        imshow(Ifixed)
        saveas(gcf,[savepath,strrep(dngs(file).name,'.dng',['_op' num2str(option) '.png'])])
        
    end
end
end