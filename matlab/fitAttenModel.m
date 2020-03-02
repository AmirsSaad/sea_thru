function coefs = fitAttenModel(meanH,z)
coefs=zeros(3,3);
figure;
hold on;
upper_c=min(meanH);
for i=1:3
    y=meanH(:,i);
    ft = fittype('a*exp(-b*x)+c');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = [1 1 1];
    opts.Lower = [0 0 0];
    opts.Upper = [inf inf upper_c(i)];
    f1 = fit(z,y,ft,opts);
    coefs(i,1:3)=[f1.a f1.b f1.c];
    plot(f1,z,y);
end

end