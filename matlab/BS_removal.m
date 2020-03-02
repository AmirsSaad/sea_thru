

meanH=importdata('mean_hist_0.02.csv',',');
lowH=importdata('bs_0.02.csv',',');

coefs = fitBSModel(meanH,lowH);
modeledBShist=coefs(:,1)'.*(1-exp(-((meanH.data(:,5))*coefs(:,2)')));
meanHpostBS=meanH.data(:,2:4)-modeledBShist;
AttenCoeffs=

folder = 'sandbox/D5/';
savepath = 'sandbox/D5/pairs/';
dngs = dir([folder,'*.dng']);
deps = dir([folder,'*.tif']);
files=length(dngs);
for file = 1:files
file_path = [folder,dngs(file).name];
[I,info] = convert_dng2sensor(file_path);
file_path = [folder,deps(file).name];
depth=imread(file_path);
[IremBS,BS] = removeBS(I*255,depth,coefs);

IpostBS = convert_sensors2viewable(IremBS/255,info);
Ipre = convert_sensors2viewable(I,info);
figure();
imshowpair(Ipre,IpostBS,'montage');
%BS =convert_sensors2viewable(BS/255,info);

saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])
close;
end
