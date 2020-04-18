function [hpJD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,x0,Ihpf,Ilpf,Imef,Ivf] = fitPhyModel(Istruct,Jbstruct,lambda,betaBtype,factorDC,isplot,ver,x0,BS,BSvar,boolBS)
    

    %z is distances vector
    z=double(Istruct.data(:,4));
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); hpJD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    intH=zeros(1,3); ratiovec=zeros(length(z),3); fixedRatio=zeros(length(z),3);% zOS=zeros(1,3);
    Ihpbsr=zeros(length(z),3);Ihp=zeros(length(z),3);Jb=zeros(length(z),3);
    
    switch betaBtype
        case 'const'
            mu=1000000;
        case 'atten'
            mu=0;
    end
    
   
    for i=1:3 %each color independetly
        Imean(:,i)=double(Istruct.data(:,i)); %I is mean value vector
        Jb(:,i)=double(Jbstruct.data(:,i)); %Jb is lower percentile vector
        Ivar(:,i)=double(Istruct.data(:,i+4));
        %Ivar(:,i)=medfilt1(Ivar(:,i),3);
        Ihp(:,i)=double(Istruct.data(:,i+7));
        Ilp(:,i)=double(Istruct.data(:,i+10));
        %bounderies
        if boolBS
           Binf_lb=BS(i).low;
           Binf_ub=BS(i).high;
           Binf_x0=(BS(i).high+BS(i).low)/2;
           BSvar_lb=BSvar(i).low;
           BSvar_ub=BSvar(i).high;
           BSvar_x0=(BSvar(i).low+BSvar(i).high)/2;
        else
           Binf_lb=max(Jb(:,i))*0.5;
           Binf_ub=max(Jb(:,i));
           Binf_x0=max(Jb(:,i))*0.75;
           BSvar_lb=0;
           BSvar_ub=10;
           BSvar_x0= 0;
        end
        %   1         2      3                         4  5               6   7      8     9                        10           11                       12
        lb=[Binf_lb   0      log(max(Ihp(:,i))*0.85)   0  0              -10   0   -10     log(max(Ivar(:,i))*0.85) BSvar_lb  log(max(Ilp(:,i)))       log(max(Ilp(:,i))*0.5)];
        ub=[Binf_ub   2      log(255)                 inf  min(Jb(:,i))    0   inf    0     log(255)                BSvar_ub  log(max(Ihp(:,i)))       log(max(Imean(:,i))) ];
        x0=[Binf_x0   0.25   log(max(Ihp(:,i))*1.2)    0  0                0   0      0  log(max(Ivar(:,i)))        BSvar_x0  log(max(Imean(:,i)))     log(max(Ilp(:,i)))];
        %   Binf               betaB  log(hpJD           betaD(a)  DC        betaD(b    c    d)     varJD           minVar    meanJD                  lpJD )      
        
      
        fun = @(a) [0.33 * (Ihp(:,i)  -exp(a(3) -(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                    3.3 * (Ilp(:,i)  -exp(a(12)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                    3.3 * (Imean(:,i)-exp(a(11)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      10*  sqrt(abs((Ivar(:,i) -exp(a(9)-2*(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(10)))), ... %
                           lambda(i) * (Jb(:,i) - a(1)*(1-exp(-a(2)*z))), ...
                     mu * ones(size(Imean(:,i)))*(a(6)^2+a(7)^2+a(8)^2), ...
                1000000 * max(0, -a(4)*exp(a(6)*z)-a(7)*exp(a(8)*z)),...
               factorDC * ones(size(Imean(:,i)))*a(5), ...
                    100 * max(0,-Jb(:,i) + a(1)*(1-exp(-a(2)*z))), ...
                    100/mean(Ilp(:,i)) * max(0,(Ilp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(12)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)), ...
                  100/mean(Imean(:,i)) * max(0,(Imean(:,i) - a(1)*(1-exp(-a(2)*z)))-exp(a(11)-(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)), ...
                    100/mean(Ihp(:,i)) * max(0,(Ihp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(3) -(a(4)*exp(a(6)*z)+a(7)*exp(a(8)*z)).*z)-a(5)) ...
                    ]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
        x = lsqnonlin(fun,x0,lb,ub);
        %x = lsqnonlin(fun,[1 1 1 1 1 0.25 0.25 0.25],lb,ub);
        
        Binf(i)=x(1); betaB(i)=x(2);  hpJD(i)=exp(x(3)); lpJD(i)=exp(x(12)); meanJD(i)=exp(x(11)); varJD(i)=exp(x(9)); betaD(:,i)=[x(4);x(6);x(7);x(8)]; C(i)=x(5);
        %zOS(i)=x(5);
        % I Emperical/Modeled Back Scatter Removed 
        %Iebsr=I-Jb;
        Ihpbsr(:,i)=Ihp(:,i)-x(1)*(1-exp(-x(2)*z));
        Ilpbsr(:,i)=Ilp(:,i)-x(1)*(1-exp(-x(2)*z));
        Imeanbsr(:,i)=Imean(:,i)-x(1)*(1-exp(-x(2)*z));
        %ratio vector for attenuation fix
        ratiovec(:,i)=getRatioVec(Ihpbsr(:,i),10);
        
        fixedRatio(:,i)=(Ihpbsr(:,i)-C(i)).*ratiovec(:,i);
        
        %integral on the IMBSR vector for later white balance/ photonEQ
%         if ver<=2
%         intH(i)=sum((Imeanbsr(:,i)-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
%         else
%         intH(i)=mean(fixedRatio(:,i));
%         end
        x0=[x0 x];
    end
    mat=[meanJD'./lpJD' hpJD'./lpJD' varJD'];
    mat=mat./mat(2,:);
    mat=mean(mat,2);
    mat=mat/max(mat);
    photonEQ=1./mat;
    %photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
    for i=1:3
        Imef(:,i)=(Imeanbsr(:,i)-C(i)).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i);
        Ihpf(:,i)=(Ihpbsr(:,i)-C(i)).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i);
        Ilpf(:,i)=(Ilpbsr(:,i)-C(i)).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i);
        Ivf(:,i)=Ivar(:,i).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i);
        
    end
    
    if isplot
        for i=1:3
        rgb=['#D95319';'#77AC30';'#0072BD'];

        figure(1);
        plot(z,Binf(i)*(1-exp(-betaB(i)*z)),'LineStyle','--','Color',rgb(i,:));
        hold on;
        plot(z,Jb(:,i),'Marker','.','Color',rgb(i,:));
        grid minor;
        title('Back-Scatter');
        if i==3
            legend('Fitted Model','Empirical darkest percentile',...
                'Fitted Model','Empirical darkest percentile',...
                'Fitted Model','Empirical darkest percentile',...
                'Location','northwest','NumColumns',3);
        end
        %legend(,);
        ylabel('Intensity'); xlabel('z distance [m]');

        figure(2);
        subplot(3,1,i);
        plot(z,hpJD(i)*exp(-(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)+C(i),'Color',rgb(i,:));
        hold on;
        %plot(z,Iebsr);
        plot(z,Ihpbsr(:,i),'+','Color',rgb(i,:));
        plot(z,lpJD(i)*exp(-(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)+C(i),'Color',rgb(i,:));
        plot(z,Ilpbsr(:,i),'.','Color',rgb(i,:));
        plot(z,meanJD(i)*exp(-(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)+C(i),'Color',rgb(i,:));
        plot(z,Imeanbsr(:,i),'o','Color',rgb(i,:));
%         grid minor;
%         title('I max - Post BS removal');
%         if i==3
%             legend('Fitted Attenuated term','Emperical, BS removed',...
%                 'Fitted Attenuated term','Emperical, BS removed',...
%                 'Fitted Attenuated term','Emperical, BS removed',...
%                 'Location','northeast','NumColumns',3);
%         end
%         ylabel('Intensity'); xlabel('z distance [m]');
                
        %subplot(2,1,2);
        %hold on;
        %plot(z,Iebsr);

        
        title('I mean - Post BS removal');
        if i==3
            grid minor;
            legend('Fitted Attenuated term','Emperical, BS removed',...
                ...%'Fitted Attenuated term','Emperical, BS removed',...
                ...%'Fitted Attenuated term','Emperical, BS removed',...
                'Location','northeast','NumColumns',3);
        end
        ylabel('Intensity'); xlabel('z distance [m]');

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


        figure(7)
        if ver==3
            plot(z,fixedRatio(:,i)*photonEQ(i),'Color',rgb(i,:));
        else
            plot(z,(Ihpbsr(:,i)-C(i)).*exp((betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
        end
        hold on;
        %plot(z,(I-(Jb+x(1)*(1-exp(-x(2)*z)))/2).*exp(x(4)*z));
        %plot(z,(Iebsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
        %plot(z,min((Iebsr-x(6)).*exp(x(4)*z)+x(6),(Iebsr-x(6)).*exp(x(4)*z(1))+x(6)));
        %plot(z,Imbsr.*(Iebsr(2)/Iebsr));
        plot(z,Ihp(:,i),'--','Color',rgb(i,:));
        grid minor;
        title('I(z) post color correction (pre-WB)');
        if i==3
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            legend('Corrected','Original',...
                'Corrected','Original',...
                'Corrected','Original',...
                'Location','southwest','NumColumns',3);
        end
        ylabel('Intensity'); xlabel('z distance [m]');
        
        figure(3)
        
%         subplot 211
        plot(z,Ivar(:,i),'Color',rgb(i,:));
        hold on
        plot(z,varJD(i)*exp(-2*(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)+C(i),'--','Color',rgb(i,:));
        grid minor;
        if i==3
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            legend('Var[I_r|z]','Fitted Attenuated term',...
                   'Var[I_g|z]','Fitted Attenuated term',...
                   'Var[I_b|z]','Fitted Attenuated term',...
                   'Location','northwest','NumColumns',3);
        end
%         subplot 212
%         plot(z,Ivar(:,i).*exp(2*(betaD(1,i)*exp(betaD(2,i)*z)+betaD(3,i)*exp(betaD(4,i)*z)).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
%         hold on;
         title('Color Variance over distance (pre-WB)');
%         if i==3
%         %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
%             legend('Corrected','Original',...
%                 'Corrected','Original',...
%                 'Corrected','Original',...
%                 'Location','northeast','NumColumns',3);
%         end
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        %legend('fixed','original'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        ylabel('Variance'); xlabel('z distance [m]');
        
        end
    end
    
end