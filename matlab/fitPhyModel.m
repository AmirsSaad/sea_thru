function [JD,betaD,Binf,betaB,zOS,C,photonEQ,ratiovec,z] = fitPhyModel(strMeanHist,strLowHist,lambda,isplot)
    Istruct=importdata(strMeanHist,',');
    Jbstruct=importdata(strLowHist,',');
    %z is distances vector
    z=Istruct.data(:,5);
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); zOS=zeros(1,3); JD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    intH=zeros(1,3); ratiovec=zeros(length(z),3);
    

   
    for i=1:3 %each color independetly
        I=Istruct.data(:,i+1); %I is mean value vector
        Jb=Jbstruct.data(:,i); %Jb is lower percentile vector
        
        %bounderies
        lb=[min(I)  0 log(max(I)*0.85) 0 -inf 0      -inf 0   -inf];
        ub=[255     1 log(255)         1 inf  min(I) 0    1 0   ];
        
        fun = @(a) [I - a(1)*(1-exp(-a(2)*(z-a(5))))-exp(a(3)-(a(4)*exp(a(7)*z)+a(8)*exp(a(9)*z)).*z)-a(6), ones(size(I))*a(6)*10,ones(size(I))*a(5)*10, ...
                lambda(i)*(Jb - a(1)*(1-exp(-a(2)*(z-a(5)))))]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
        x = lsqnonlin(fun,[1 1 1 1 1 1 0.5 0.5 0.5],lb,ub);
        
        Binf(i)=x(1); betaB(i)=x(2); zOS(i)=x(5); JD(i)=exp(x(3)); betaD(:,i)=[x(4);x(7);x(8);x(9)]; C(i)=x(6);
        
        % I Emperical/Modeled Back Scatter Removed 
        Iebsr=I-Jb;
        Imbsr=I-x(1)*(1-exp(-x(2)*(z-x(5))));
        
        %ratio vector for attenuation fix
        ratiovec(:,i)=getRatioVec(Imbsr,10);
        
        if isplot
            figure(i);
            
            subplot(2,2,1);
            plot(z,x(1)*(1-exp(-x(2)*(z-x(5)))),'k');
            hold on;
            plot(z,Jb,'+');
            grid minor;
            title('Back-Scatter');
            legend('Fitted Model','Empirical lower percentile');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            
            subplot(2,2,2);
            plot(z,exp(x(3))*exp(-(x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6),'k');
            hold on;
            plot(z,Iebsr);
            plot(z,Imbsr);
            grid minor;
            title('Mean post BS removal');
            legend('Fitted Model','minus empirical','minus model');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            

            subplot(2,2,3);
            plot(z,x(1)*(1-exp(-x(2)*z))+exp(x(3))*exp(-(x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6),'k');
            hold on;
            plot(z,x(1)*(1-exp(-x(2)*z)),'k--');
            plot(z,exp(x(3))*exp(-(x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6),'b--');
            plot(z,I,'+');
            grid minor;
            title('Mean intensity per distance');
            legend('fit Model sum','fit BS term','fit Atten term','Empirical mean');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            

            subplot(2,2,4);
            plot(z,(Imbsr-x(6)).*exp((x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6));
            hold on;
            %plot(z,(I-(Jb+x(1)*(1-exp(-x(2)*(z-x(5)))))/2).*exp(x(4)*z));
            plot(z,(Iebsr-x(6)).*exp((x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6));
            %plot(z,min((Iebsr-x(6)).*exp(x(4)*z)+x(6),(Iebsr-x(6)).*exp(x(4)*z(1))+x(6)));
            %plot(z,Imbsr.*(Iebsr(2)/Iebsr));
            plot(z,(Imbsr-x(6)).*ratiovec(:,i));
            plot(z,I);
            grid minor;
            title('Fixed model');
            legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            ylabel('Mean intensity'); xlabel('z distance [m]');
            
        end
        
        %integral on the IMBSR vector for later white balance/ photonEQ
        intH(i)=sum((Imbsr-x(6)).*exp((x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z)).*z)+x(6));
        
    end
    photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
end