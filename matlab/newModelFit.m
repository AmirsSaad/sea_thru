
close all;
strmeanHist='mean_hist_0.02.csv';
strBSHist='bs_0.02.csv';

[JD,betaD,Binf,betaB,zOS,C,photonEQ] = fitPhyModel('mean_hist_0.02.csv','bs_0.02.csv',[0.5 0.5 0.5],1);

close all;
folder = 'sandbox/D3/';
savepath = 'sandbox/D3/pairsAtten/';
dngs = dir([folder,'*.dng']);
deps = dir([folder,'*.tif']);
files=length(dngs);
for file = 1:files
file_path = [folder,dngs(file).name];
[I,info] = convert_dng2sensor(file_path);
file_path = [folder,deps(file).name];
depth=imread(file_path);
[IremBS,BS] = removeBS(I*255,depth,[Binf' betaB' zOS']);
IremBS=AttenFix(IremBS,depth,[JD' betaD' C'],1);
for i=1:3;
    IremBS(:,:,i)=IremBS(:,:,i)*photonEQ(i);
end
IpostBS = convert_sensors2viewable(IremBS/255,info);
Ipre = convert_sensors2viewable(I,info);
figure();
imshowpair(Ipre,IpostBS,'montage');
%BS =convert_sensors2viewable(BS/255,info);

saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
close all;