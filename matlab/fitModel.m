function coefs = fitModel(meanH,lowH)
z=lowH.data(:,5);
coefs=zeros(3,2);
upper_a=meanH.data(end,2:4);
figure;
hold on;
for i=2:4
    y=lowH.data(:,i);
    ft = fittype('a*(1-exp(-b*(x)))');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = [1 1];
    opts.Lower = [0 0];
    opts.Upper = [upper_a(i-1) 5];
    f1 = fit(z,y,ft,opts);
    coefs(i-1,:)=[f1.a f1.b];
    plot(f1,z,y);
end


end