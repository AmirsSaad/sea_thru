function [JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z] = fitPhyModel(strMeanHist,strLowHist,lambda,betaBtype,factorDC,isplot)
    Istruct=importdata(strMeanHist,',');
    Jbstruct=importdata(strLowHist,',');
    %z is distances vector
    z=Istruct.data(:,4);
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); JD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    intH=zeros(1,3); ratiovec=zeros(length(z),3); % zOS=zeros(1,3);
    
    switch betaBtype
        case 'const'
            mu=1000;
        case 'atten'
            mu=0;
    end
    
   
    for i=1:3 %each color independetly
        I=Istruct.data(:,i); %I is mean value vector
        Jb=Jbstruct.data(:,i); %Jb is lower percentile vector
        
        %bounderies
        lb=[min(I)  0 log(max(I)*0.85) 0  0      -10 0   -10];
        ub=[255     1 log(255)         10 min(I) 0   10 0   ];
        
        fun = @(a) [I - a(1)*(1-exp(-a(2)*z))-exp(a(3)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5), ones(size(I))*(a(6)^2+a(7)^2+a(8)^2)*mu,ones(size(I))*a(5)*factorDC, ...
                lambda(i)*(Jb - a(1)*(1-exp(-a(2)*z)))]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
        x = lsqnonlin(fun,[1 1 1 1 1 0.5 0.5 0.5],lb,ub);
        
        Binf(i)=x(1); betaB(i)=x(2);  JD(i)=exp(x(3)); betaD(:,i)=[x(4);x(6);x(7);x(8)]; C(i)=x(5);
        %zOS(i)=x(5);
        % I Emperical/Modeled Back Scatter Removed 
        Iebsr=I-Jb;
        Imbsr=I-x(1)*(1-exp(-x(2)*z));
        
        %ratio vector for attenuation fix
        ratiovec(:,i)=getRatioVec(Imbsr,10);
        
        if isplot
            figure(i);
            
            subplot(2,2,1);
            plot(z,x(1)*(1-exp(-x(2)*z)),'k');
            hold on;
            plot(z,Jb,'+');
            grid minor;
            title('Back-Scatter');
            legend('Fitted Model','Empirical lower percentile');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            
            subplot(2,2,2);
            plot(z,exp(x(3))*exp(-(x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z)+x(5),'k');
            hold on;
            plot(z,Iebsr);
            plot(z,Imbsr);
            grid minor;
            title('Mean post BS removal');
            legend('Fitted Model','minus empirical','minus model');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            

            subplot(2,2,3);
            plot(z,x(1)*(1-exp(-x(2)*z))+exp(x(3))*exp(-(x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z)+x(5),'k');
            hold on;
            plot(z,x(1)*(1-exp(-x(2)*z)),'k--');
            plot(z,exp(x(3))*exp(-(x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z)+x(5),'b--');
            plot(z,I,'+');
            grid minor;
            title('Mean intensity per distance');
            legend('fit Model sum','fit BS term','fit Atten term','Empirical mean');
            ylabel('Mean intensity'); xlabel('z distance [m]');
            

            subplot(2,2,4);
            plot(z,(Imbsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
            hold on;
            %plot(z,(I-(Jb+x(1)*(1-exp(-x(2)*z)))/2).*exp(x(4)*z));
            plot(z,(Iebsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
            %plot(z,min((Iebsr-x(6)).*exp(x(4)*z)+x(6),(Iebsr-x(6)).*exp(x(4)*z(1))+x(6)));
            %plot(z,Imbsr.*(Iebsr(2)/Iebsr));
            plot(z,(Imbsr-x(5)).*ratiovec(:,i));
            plot(z,I);
            grid minor;
            title('Fixed model');
            legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            ylabel('Mean intensity'); xlabel('z distance [m]');
            
        end
        
        %integral on the IMBSR vector for later white balance/ photonEQ
        intH(i)=sum((Imbsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
        
    end
    photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
end