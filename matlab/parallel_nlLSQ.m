Istruct=importdata('mean_hist_0.01.csv',',');
Jbstruct=importdata('bs_0.01.csv',',');
z=Istruct.data(:,5);
I=Istruct.data(:,4);
Jb=Jbstruct.data(:,4);
lb=[0 0 0 0];
ub=[255 1 log(255) 1];
lambda=1;
fun = @(a) [I - a(1)*(1-exp(-a(2)*z))-exp(a(3)-a(4)*z), ...
            lambda*(Jb - a(1)*(1-exp(-a(2)*z)))]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
[x,resnorm,residual,exitflag,output] = lsqnonlin(fun,[1 1 1 1],lb,ub);
x
figure;
subplot(2,2,1);
plot(z,x(1)*(1-exp(-x(2)*z)),'k');
hold on;
plot(z,Jb,'+');
subplot(2,2,2);
plot(z,x(3)-x(4)*z,'k');
hold on;
plot(z,log(I-Jb),'+');
subplot(2,2,3);
plot(z,x(1)*(1-exp(-x(2)*z))+exp(x(3))*exp(-x(4)*z),'k');
hold on;
plot(z,x(1)*(1-exp(-x(2)*z)),'k--');
plot(z,exp(x(3))*exp(-x(4)*z),'b--');

plot(z,I,'+');