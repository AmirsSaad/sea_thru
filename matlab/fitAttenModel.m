function coefs = fitAttenModel(meanH,z)
coefs=zeros(3,3);
figure;
hold on;
upper_c=min(meanH);
rgb=['#D95319';'#77AC30';'#0072BD'];
for i=1:3
    y=meanH(:,i);
    ft = fittype('a*exp(-b*x)+c');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares');
    opts.StartPoint = [1 1 1];
    opts.Lower = [0 0 0];
    opts.Upper = [inf inf upper_c(i)];
    f1 = fit(z,y,ft,opts);
    coefs(i,1:3)=[f1.a f1.b f1.c];
    plot(z,y,'Marker','.','Color',rgb(i,:));
    plot(f1,'k');
end
grid minor
legend('R','B_{model}^R','G','B_{model}^G','B','B_{model}^B','Location','nw');
xlabel('Distance from camera (z[m])');
ylabel('Intensity (I[counts])');
title('Mean Intensity (2%)');
end