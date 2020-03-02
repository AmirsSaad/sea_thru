function coefs = fitAttenModel(meanH,lowH)
z=lowH.data(:,5);
coefs=zeros(3,3);
figure;
hold on;
for i=2:4
    y=meanH.data(:,i);
    ft = fittype('a*exp(-b*x)+c');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = [1 1 1];
    opts.Lower = [0 0 0];
    opts.Upper = [inf inf inf];
    f1 = fit(z,y,ft,opts);
    coefs(i-1,1:3)=[f1.a f1.b f1.c];
    plot(f1,z,y);
    


end

end