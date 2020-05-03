function [hpJD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,Ihpf,Ilpf,Imef,Ivf] = fitPhyModel(Istruct,Isingle,lambda,betaBtype,DC,isplot,ver,BS,BSvar,boolBS,lp,WBvector,statModel)
    
    if strcmp(statModel,'multip')
        singleStats=0;
        if strcmp(WBvector,'single')
           singleWB_onMultip=1;
        else
           singleWB_onMultip=0;
        end
    else
        singleStats=1;
        Isingle=Istruct;
        singleWB_onMultip=0;
    end
        
    %z is distances vector
    z=double(Istruct(:,13));
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); hpJD=zeros(1,3); varJD=zeros(1,3); lpJD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    %intH=zeros(1,3); 
    ratiovec=zeros(length(z),3); fixedRatio=zeros(length(z),3);% zOS=zeros(1,3);
    Ihp=zeros(length(z),3); Ilp=zeros(length(z),3); Imean=zeros(length(z),3); Ivar=zeros(length(z),3);
    Jb=zeros(length(z),3);
    
    if singleStats
        Ihpbsr=zeros(length(z),3); Ilpbsr=zeros(length(z),3); Imeanbsr=zeros(length(z),3); Ivarbsr=zeros(length(z),3);
    end
    
    switch betaBtype
        case 'const'
            mu=1000000;
        case 'atten'
            mu=0;
    end
    
    switch DC
        case 1
            factorDC=0;
        case 0
            factorDC=10000;
    end
   
    for i=1:3 %each color independetly
        
        if singleStats
            %clear Imean Jb Ihp Ilp Ivar z
            %z=double(Istruct(:,13));
            Imean(:,i)=vec2qconv(double(Istruct(:,i))); %I is mean value vector
            Jb(:,i)=-double(vec2qconv(-Istruct(:,i+3))); %Jb is lower percentile vector
            Ivar(:,i)=double(Istruct(:,i+9));
            Ivar(:,i)=medfilt1(Ivar(:,i),3);
            Ihp(:,i)=vec2qconv(double(Istruct(:,i+6)));
            Ilp(:,i)=vec2qconv(double(Istruct(:,i+3)));
            %deleteconvex=1;
        else
%             if singleWB_onMultip
%                 clear Imean Jb Ihp Ilp Ivar z
%             end
            %z=double(Istruct(:,13));
            Imean(:,i)=double(Istruct(:,i)); %I is mean value vector
            Jb(:,i)=double(Istruct(:,i+3)); %Jb is lower percentile vector
            Ivar(:,i)=double(Istruct(:,i+9));
            Ivar(:,i)=medfilt1(Ivar(:,i),3);
            Ihp(:,i)=double(Istruct(:,i+6));
            Ilp(:,i)=double(Istruct(:,i+3));
            %deleteconvex=0;   
        end
        
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
           BSvar_ub=prctile(Ivar(:,i),5);
           BSvar_x0= 0;
        end
                            %log(max(Ihp(:,i))*0.85)
        %   1         2      3                         4  5                  6    7     8     9                        10           11                       12
        lb=[Binf_lb   0     log(max(Ihp(:,i)))         0  0                  0    0   -10     log(max(Ivar(:,i))*0.85) BSvar_lb  log(max(Ilp(:,i)))       log(max(Ilp(:,i))*0.5)];
        ub=[Binf_ub   2     log(max(Ihp(:,i))*2)     inf  min(Jb(:,i))       1    10    0     log(max(Ivar(:,i))*2)    BSvar_ub  log(max(Ihp(:,i)))       log(max(Ilp(:,i))*2) ];
        x0=[Binf_x0   0.25  log(max(Ihp(:,i))*1.5)     0  0                  0    0     0     log(max(Ivar(:,i)))      BSvar_x0  log(max(Ihp(:,i)))       log(max(Ilp(:,i)))];
        %   Binf      betaB  log(hpJD           betaD(a)  DC  betaD(b    c    d)     varJD                     minVar    meanJD                   lpJD )      
        
        if singleStats
        fun = @(a) [  1 * (Ihp(:,i)  -exp(a(3) -(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      3 * (Ilp(:,i)  -exp(a(12)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      1 * (Imean(:,i)-exp(a(11)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      ...%5 *  sqrt(abs((Ivar(:,i) -exp(a(9)-2*(a(4)./(z.^a(6)+a(7))).*z)-a(10)*(1-exp(-a(2)*z)).^2))), ... %
                      5 *  lambda(i) * (Jb(:,i) - a(1)*(1-exp(-a(2)*z))), ...
                     mu * ones(size(Imean(:,i)))*(a(6)^2+(a(7)-1)^2+a(8)^2), ...
                     factorDC * ones(size(Imean(:,i)))*a(5) ...
                    ...%100 * max(0,-Jb(:,i) + a(1)*(1-exp(-a(2)*z))), ...
                    ...%1000/mean(Ilp(:,i)) * max(0,(Ilp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(12)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)), ...
                    ...%1000/mean(Imean(:,i)) * max(0,(Imean(:,i) - a(1)*(1-exp(-a(2)*z)))-exp(a(11)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)), ...
                    ...%1000/mean(Ihp(:,i)) * max(0,(Ihp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(3) -(a(4)./(z.^a(6)+a(7))).*z)-a(5)) ...
                    ];
        else
        fun = @(a) [  1 * (Ihp(:,i)  -exp(a(3) -(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      3 * (Ilp(:,i)  -exp(a(12)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      1 * (Imean(:,i)-exp(a(11)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)- a(1)*(1-exp(-a(2)*z))), ... %
                      5 *  sqrt(abs((Ivar(:,i) -exp(a(9)-2*(a(4)./(z.^a(6)+a(7))).*z)-a(10)*(1-exp(-a(2)*z)).^2))), ... %
                      5 *  lambda(i) * (Jb(:,i) - a(1)*(1-exp(-a(2)*z))), ...
                     mu * ones(size(Imean(:,i)))*(a(6)^2+(a(7)-1)^2+a(8)^2), ...
                     factorDC * ones(size(Imean(:,i)))*a(5), ...
                    100 * max(0,-Jb(:,i) + a(1)*(1-exp(-a(2)*z))), ...
                    1000/mean(Ilp(:,i)) * max(0,(Ilp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(12)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)), ...
                    1000/mean(Imean(:,i)) * max(0,(Imean(:,i) - a(1)*(1-exp(-a(2)*z)))-exp(a(11)-(a(4)./(z.^a(6)+a(7))).*z)-a(5)), ...
                    1000/mean(Ihp(:,i)) * max(0,(Ihp(:,i)   - a(1)*(1-exp(-a(2)*z)))-exp(a(3) -(a(4)./(z.^a(6)+a(7))).*z)-a(5)) ...
                    ];
        end
                
        x = lsqnonlin(fun,x0,lb,ub);
        %x = lsqnonlin(fun,[1 1 1 1 1 0.25 0.25 0.25],lb,ub);
        
%         % change from 
%         if singleStats || single
%             clear Imean Jb Ihp Ilp Ivar z
%             Imean(:,i)=double(Isingle(:,i)); %I is mean value vector
%             Jb(:,i)=double(Isingle(:,i+3)); %Jb is lower percentile vector
%             Ihp(:,i)=double(Isingle(:,i+6));
%             Ilp(:,i)=double(Isingle(:,i+3));
%             Ivar(:,i)=double(Isingle(:,i+9));
%             z=double(Isingle(:,13));
%         end
        
        Binf(i)=x(1); betaB(i)=x(2);  
        varBinf(i)=x(10);
        hpJD(i)=exp(x(3)); lpJD(i)=exp(x(12)); meanJD(i)=exp(x(11)); varJD(i)=exp(x(9));
        betaD(:,i)=[x(4);x(6);x(7);x(8)]; C(i)=x(5);
        %zOS(i)=x(5);
        % I Emperical/Modeled Back Scatter Removed 
        %Iebsr=I-Jb;

    end
    
    if singleWB_onMultip || singleStats %switch to single || get rid of qconv
        clear Imean Jb Ihp Ilp Ivar z
        Imean=double(Isingle(:,1:3)); %I is mean value vector
        Jb=double(Isingle(:,4:6)); %Jb is lower percentile vector
        Ihp=double(Isingle(:,7:9));
        Ilp=double(Isingle(:,4:6));
        Ivar=double(Isingle(:,10:12));
        z=double(Isingle(:,13));
    end
        
    Imef=zeros(length(z),3); Ihpf=zeros(length(z),3); Ilpf=zeros(length(z),3); Ivf=zeros(length(z),3);
    hp=struct;
    for i=1:3
        Ihpbsr(:,i)=    Ihp(:,i)  -Binf(i)*(1-exp(-betaB(i)*z));
        Ilpbsr(:,i)=    Ilp(:,i)  -Binf(i)*(1-exp(-betaB(i)*z));
        Imeanbsr(:,i)=  Imean(:,i)-Binf(i)*(1-exp(-betaB(i)*z));
        Ivarbsr(:,i)=Ivar(:,i) -varBinf(i)*(1-exp(-betaB(i)*z)).^2;
        %ratio vector for attenuation fix
        if ver==3
            ratiovec(:,i)=getRatioVec(Ihpbsr(:,i),10);
            fixedRatio(:,i)=(Ihpbsr(:,i)-C(i)).*ratiovec(:,i);
        end
                %integral on the IMBSR vector for later white balance/ photonEQ
%         if ver<=2
%         intH(i)=sum((Imeanbsr(:,i)-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
%         else
%         intH(i)=mean(fixedRatio(:,i));
%         end
         %x0=[x0 x];
        Imef(:,i)=(Imeanbsr(:,i)-C(i)).*exp((betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z);%*photonEQ(i);
        Ihpf(:,i)=(Ihpbsr(:,i)-C(i)).*exp((betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z);%*photonEQ(i);
        Ilpf(:,i)=(Ilpbsr(:,i)-C(i)).*exp((betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z);%*photonEQ(i);
        Ivf(:,i)=Ivarbsr(:,i).*exp(2*(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z);%*photonEQ(i);  
        [hp(i).pks,hp(i).locs]=findpeaks(Ihpf(:,i));
    end
    
    whitefactor=255*(1-lp)./max(Ihpf,[],'all');
    hplocs=intersect(intersect(hp(1).locs,hp(2).locs),hp(3).locs);
    if isempty(hplocs)
        [~,maxloc]=max(vecnorm(Ihpf(:,:),2,2));
        mat=Ihpf(maxloc,:)./Ihpf(maxloc,2);
    else
        [~,maxloc]=max(vecnorm(Ihpf(hplocs,:),2,2));
        maxloc=hplocs(maxloc);
        mat=Ihpf(maxloc,:)./Ihpf(maxloc,2);
    end
    
    
    %photonEQ=252./mat;
%     mat=[sum(Imef,1)' sum(Ihpf,1)' sum(sqrt(Ivf),1)'];
%     %mat=[meanJD'./lpJD' hpJD'./lpJD' varJD'];
%     mat=mat./mat(2,:);
     %mat=mean(mat,1);
     mat=mat/max(mat);
     photonEQ=(1./mat)*whitefactor;
    for i=1:3
        Imef(:,i)=Imef(:,i)*photonEQ(i);
        Ihpf(:,i)=Ihpf(:,i)*photonEQ(i);
        Ilpf(:,i)=Ilpf(:,i)*photonEQ(i);
        Ivf(:,i)=Ivf(:,i);%*photonEQ(i).^2;  
    end
    %photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
    %%
    if isplot
        for i=1:3
        rgb=['#D95319';'#77AC30';'#0072BD'];
        if i==1
            figure('Name','Backscatter');
        else
            figure(1);
        end
        plot(z,Binf(i)*(1-exp(-betaB(i)*z)),'LineStyle','--','Color',rgb(i,:));
        hold on;
        plot(z,Jb(:,i),'Marker','.','Color',rgb(i,:));
        grid minor;
        %title('Back-Scatter');
        if i==3
          ylabel('Intensity'); xlabel('z distance [m]');
          set(findall(gcf,'-property','FontSize'),'FontSize',16)
          legend('Fitted BS_r Model','I^{lp}_r(z)',...
                'Fitted BS_g Model','I^{lp}_g(z)',...
                'Fitted BS_b Model','I^{lp}_b(z)',...
                'Location','northoutside','NumColumns',3,'FontSize',12);
            xlim([min(z) max(z)]);
        end
        %legend(,);

        if i==1
            figure('Name','AL');
        else
            figure(2);
        end
        
        subplot(1,3,i);
        plot(z,hpJD(i)*exp(-(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z)+C(i),'--','Color',rgb(i,:));
        hold on;
        %plot(z,Iebsr);
        plot(z,Ihpbsr(:,i),'+','Color',rgb(i,:));
        plot(z,lpJD(i)*exp(-(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z)+C(i),'--','Color',rgb(i,:));
        plot(z,Ilpbsr(:,i),'.','Color',rgb(i,:));
        plot(z,meanJD(i)*exp(-(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z)+C(i),'--','Color',rgb(i,:));
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
        grid minor;
        ylim([0 max(Ihpbsr,[],'all')+35]);
        xlim([min(z) max(z)]);
        if i==1 
                 ylabel('Intensity','FontSize',16); %title('Red Channel'); 
               
        elseif i==2 

            xlabel('z distance [m]','FontSize',16); %title('Green Channel');
        elseif i==3
            %sgtitle('I_c^{(i)}(z), Post BS removal');
            %title('Blue Channel');
            legend('Fitted AL term','I^{hp}_c(z) - BS(z)',...
                'Fitted AL term','I^{lp}_c(z)- BS(z)',...
                'Fitted AL term','I^{mean}_c(z) - BS(z)',...
                'Location','north','FontSize',13,'NumColumns',3);
        end

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

        if i==1
            figure('Name','Iz_fixed');
        else
            figure(3);
        end
        if ver==3
            plot(z,fixedRatio(:,i)*photonEQ(i),'Color',rgb(i,:));
        else
            subplot 121
            plot(z,Ihpf(:,i)./photonEQ(i),'Color',rgb(i,:));
            hold on;
            %plot(z(maxloc),Ihpf(maxloc,i),'ok','MarkerSize',20);
            plot(z,Ilpf(:,i)./photonEQ(i),'.','MarkerSize',1,'Color',rgb(i,:));
            plot(z,Imef(:,i)./photonEQ(i),'--','Color',rgb(i,:));
            subplot 122
            plot(z,Ihpf(:,i),'Color',rgb(i,:));
            hold on;
            plot(z,Ilpf(:,i),'.','MarkerSize',1,'Color',rgb(i,:));
            plot(z,Imef(:,i),'--','Color',rgb(i,:));
        end
        
        %plot(z,(I-(Jb+x(1)*(1-exp(-x(2)*z)))/2).*exp(x(4)*z));
        %plot(z,(Iebsr-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
        %plot(z,min((Iebsr-x(6)).*exp(x(4)*z)+x(6),(Iebsr-x(6)).*exp(x(4)*z(1))+x(6)));
        %plot(z,Imbsr.*(Iebsr(2)/Iebsr));
        
        %plot(z,Ihp(:,i),'--','Color',rgb(i,:));
        
        %title('I^{i}_c(z) post color correction');
        if i==3
            subplot 121
            grid minor;
            %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            ylim([0 max(Ihpf(:,:)./photonEQ(i),[],'all')+5]);    
        
            ylabel('Intensity Pre WB'); xlabel('z distance [m]');
            set(findall(gcf,'-property','FontSize'),'FontSize',15)
%             legend('I^{hp}_c Corrected',...
%                    'I^{lp}_c Corrected',...
%                    'I^{mean}_c Corrected',...
%                    'Location','north','NumColumns',3 ,'FontSize',12);
            xlim([z(maxloc)-1 z(maxloc)+1]);
            subplot 122
            plot(z(maxloc),Ihpf(maxloc,1),'ok','MarkerSize',20)
            grid minor;
            %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            ylim([0 260]);    
%             legend('I^{hp}_c Post WB',...
%                    'I^{lp}_c Post WB',...
%                    'I^{mean}_c Post WB',...
%                    'Location','north','NumColumns',3);
            ylabel('Intensity Post WB','FontSize',15); xlabel('z distance [m]','FontSize',15);
            xlim([z(maxloc)-1 z(maxloc)+1]);
        end
        
        if i==1
            figure('Name','Variance');
        else
            figure(4);
        end
        subplot (3,1,i)
        plot(z,Ivar(:,i),'.--','Color',rgb(i,:));
        hold on
        plot(z,varJD(i)*exp(-2*(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z)+C(i),'--','Color',rgb(i,:));
        plot(z,Ivf(:,i),'.-','Color',rgb(i,:));
        plot(z,varJD(i)*ones(size(Ivf(:,i))),'Color',rgb(i,:));
        grid minor;
        if i==3
            xlabel('z distance [m]','FontSize',16);
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
%             legend('Var[I_r|z]','Fitted Attenuated term',...
%                    'Var[I_g|z]','Fitted Attenuated term',...
%                    'Var[I_b|z]','Fitted Attenuated term',...
%                    'Location','northwest','NumColumns',3);
               %sgtitle('Color Variance pre and post Correction');
        end
%         subplot 212
%         plot(z,Ivar(:,i).*exp(2*(betaD(1,i)./(z.^betaD(2,i)+betaD(3,i))).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
%         hold on;
         
%         if i==3
%         %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
%             legend('Corrected','Original',...
%                 'Corrected','Original',...
%                 'Corrected','Original',...
%                 'Location','northeast','NumColumns',3);
%         end
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        %legend('fixed','original'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        if i==2 ylabel('Variance','FontSize',16); end
        
        end
    end
%%
end