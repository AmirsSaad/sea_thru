function [JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z] = fitPhyModel(strMeanHist,strLowHist,lambda,betaBtype,factorDC,isplot,ver)
    
    Istruct=importdata(strMeanHist,',');
    Jbstruct=importdata(strLowHist,',');
    %z is distances vector
    z=Istruct.data(:,4);
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); JD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    intH=zeros(1,3); ratiovec=zeros(length(z),3); fixedRatio=zeros(length(z),3);% zOS=zeros(1,3);
    Imbsr=zeros(length(z),3);I=zeros(length(z),3);Jb=zeros(length(z),3);
    switch betaBtype
        case 'const'
            mu=1000;
        case 'atten'
            mu=0;
    end
    
   
    for i=1:3 %each color independetly
        I(:,i)=Istruct.data(:,i); %I is mean value vector
        Jb(:,i)=Jbstruct.data(:,i); %Jb is lower percentile vector
        
        %bounderies
        lb=[max(Jb(:,i))*0.85  0  log(max(I(:,i))*0.85) 0  0      -10 0   -10];
        ub=[max(I(:,i))        1  log(255)         10 min(I(:,i)) 0   10 0   ];
        %   Binf      betaB  log(JD)     betaD(1)  DC   betaD(2 3 4)
        
        fun = @(a) [I(:,i) - a(1)*(1-exp(-a(2)*z))-exp(a(3)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5), ...
                    ones(size(I(:,i)))*(a(6)^2+a(7)^2+a(8)^2)*mu, ...
                    ones(size(I(:,i)))*a(5)*factorDC, ...
                    lambda(i)*(Jb(:,i) - a(1)*(1-exp(-a(2)*z)))]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
        x = lsqnonlin(fun,[max(Jb(:,i)) 0.25 log(max(I(:,i))) 0.25 1 0.25 0.25 0.25],lb,ub);
        %x = lsqnonlin(fun,[1 1 1 1 1 0.25 0.25 0.25],lb,ub);
        
        Binf(i)=x(1); betaB(i)=x(2);  JD(i)=exp(x(3)); betaD(:,i)=[x(4);x(6);x(7);x(8)]; C(i)=x(5);
        %zOS(i)=x(5);
        % I Emperical/Modeled Back Scatter Removed 
        %Iebsr=I-Jb;
        Imbsr(:,i)=I(:,i)-x(1)*(1-exp(-x(2)*z));
        
        %ratio vector for attenuation fix
        ratiovec(:,i)=getRatioVec(Imbsr(:,i),10);
        
        fixedRatio(:,i)=(Imbsr(:,i)-C(i)).*ratiovec(:,i);
        
        %integral on the IMBSR vector for later white balance/ photonEQ
        if ver<=2
        intH(i)=sum((Imbsr(:,i)-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
        else
        intH(i)=mean(fixedRatio(:,i));
        end
    end
    photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
    if isplot
        for i=1:3
        rgb=['#D95319';'#77AC30';'#0072BD'];

        figure(1);
        subplot(2,1,1);
        plot(z,Binf(i)*(1-exp(-betaB(i)*z)),'k');
        hold on;
        plot(z,Jb(:,i),'Marker','.','Color',rgb(i,:));
        grid minor;
        title('Back-Scatter');
        %legend('Fitted Model','Empirical lower percentile');
        ylabel('Mean intensity'); xlabel('z distance [m]');

        %figure(2);
        subplot(2,1,2);
        plot(z,JD(i)*exp(-(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)+C(i),'-.k');
        hold on;
        %plot(z,Iebsr);
        plot(z,Imbsr(:,i),'LineStyle','-.','Color',rgb(i,:));
        grid minor;
        title('Mean post BS removal');
        %legend('Fitted Model','minus empirical','minus model');
        ylabel('Mean intensity'); xlabel('z distance [m]');

        %subplot(2,2,3);
        %plot(z,x(1)*(1-exp(-x(2)*z))+exp(x(3))*exp(-(x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z)+x(5),'k');
        %hold on;
        %plot(z,x(1)*(1-exp(-x(2)*z)),'k--');
        %plot(z,exp(x(3))*exp(-(x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z)+x(5),'b--');
        %plot(z,I,'Color',rgb(i,:));
        %grid minor;
        %title('Mean intensity per distance');
        %legend('fit Model sum','fit BS term','fit Atten term','Empirical mean');
        %ylabel('Mean intensity'); xlabel('z distance [m]');


        figure(2)
        if ver==3
            plot(z,fixedRatio(:,i)*photonEQ(i),'Color',rgb(i,:));
        else
            plot(z,(Imbsr(:,i)-C(i)).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
        end
        hold on;
        %plot(z,(I-(Jb+x(1)*(1-exp(-x(2)*z)))/2).*exp(x(4)*z));
        %plot(z,(Iebsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
        %plot(z,min((Iebsr-x(6)).*exp(x(4)*z)+x(6),(Iebsr-x(6)).*exp(x(4)*z(1))+x(6)));
        %plot(z,Imbsr.*(Iebsr(2)/Iebsr));
        plot(z,I(:,i),'--','Color',rgb(i,:));
        grid minor;
        title('Fixed model');
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        %legend('fixed','original'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        ylabel('Mean intensity'); xlabel('z distance [m]');
        end
    end
    
end