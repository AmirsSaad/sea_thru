function coefs = fitBSModel(meanH,lowH)
z=lowH.data(:,5);
coefs=zeros(3,2);
upper_a=meanH.data(end,2:4);
figure;
hold on;
rgb=['#D95319';'#77AC30';'#0072BD'];
for i=2:4
    y=lowH.data(:,i);
    ft = fittype('a*(1-exp(-b*(x)))');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = [1 1];
    opts.Lower = [0 0];
    opts.Upper = [upper_a(i-1) 5];
    f1 = fit(z,y,ft,opts);
    coefs(i-1,1:2)=[f1.a f1.b];
    plot(z,y,'Marker','.','Color',rgb(i-1,:));
    plot(f1,'k');

end
grid minor
legend('R','B_{model}^R','G','B_{model}^G','B','B_{model}^B','Location','nw');
xlabel('Distance from camera (z[m])');
ylabel('Intensity (I[counts])');
title('Lower Percentile Intensity (2%)');
end