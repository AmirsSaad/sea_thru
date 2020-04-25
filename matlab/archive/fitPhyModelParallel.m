function [hpJD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,Ihpf,Ilpf,Imef,Ivf] = fitPhyModelParallel(Istruct,lambda,betaBtype,DC,isplot,ver,BS,BSvar,boolBS)
    

    %z is distances vector
    z=double(Istruct.data(:,end));
    
    %init vars
    Binf=zeros(1,3); betaB=zeros(1,3); hpJD=zeros(1,3); varJD=zeros(1,3); lpJD=zeros(1,3); betaD=zeros(4,3); C=zeros(1,3);
    %intH=zeros(1,3); 
    ratiovec=zeros(length(z),3); fixedRatio=zeros(length(z),3);% zOS=zeros(1,3);
    Ihp=zeros(length(z),3); Ilp=zeros(length(z),3); Imean=zeros(length(z),3); Ivar=zeros(length(z),3);
    Jb=zeros(length(z),3);
    Ihpbsr=zeros(length(z),3); Ilpbsr=zeros(length(z),3); Imeanbsr=zeros(length(z),3); Ivarbsr=zeros(length(z),3);
    
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
        Imean(:,i)=double(Istruct.data(:,i)); %I is mean value vector
        Jb(:,i)=double(Istruct.data(:,i+3)); %Jb is lower percentile vector
        Ivar(:,i)=double(Istruct.data(:,i+9));
        Ivar(:,i)=medfilt1(Ivar(:,i),3);
        Ihp(:,i)=double(Istruct.data(:,i+6));
        Ilp(:,i)=double(Istruct.data(:,i+3));
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
    end
        lb=[]; ub=[]; x0=[];
                            %log(max(Ihp(:,i))*0.85)
        %   1         2      3                         4  5                  6    7     8     9                        10           11                       12
        for i=1:3
           Binf_lb=max(Jb(:,i))*0.5;
           Binf_ub=max(Jb(:,i));
           Binf_x0=max(Jb(:,i))*0.75;
           BSvar_lb=0;
           BSvar_ub=prctile(Ivar(:,i),5);
           BSvar_x0= 0;
        lbtemp=[Binf_lb   0     log(max(Ihp(:,i)))         0  0                  0    0   -10     log(max(Ivar(:,i))*0.85) BSvar_lb  log(max(Ilp(:,i)))       log(max(Ilp(:,i))*0.5) 1];
        lb=[lb;lbtemp];
        ubtemp=[Binf_ub   2     log(max(Ihp(:,i))*2)     inf  min(Jb(:,i))       inf  inf   0     log(max(Ivar(:,i))*2)    BSvar_ub  log(max(Ihp(:,i)))       log(max(Ilp(:,i))*2) 3];
        ub=[ub;ubtemp];
        x0temp=[Binf_x0   0.25  log(max(Ihp(:,i))*1.5)     0  0                  0    0     0     log(max(Ivar(:,i)))      BSvar_x0  log(max(Ihp(:,i)))       log(max(Ilp(:,i))) 1.1];
        x0=[x0;x0temp];
        %   Binf               betaB  log(hpJD           betaD(a)  DC  betaD(b    c    d)     varJD                     minVar    meanJD                   lpJD )      
        end
        lb=lb'; ub=ub'; x0=x0';
        
        fun = @(a) [  1 .* (Ihp  -exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      3 .* (Ilp  -exp(a(12,:)-(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      1 .* (Imean -exp(a(11,:)-(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      5 .*  sqrt(abs((Ivar -exp(a(9,:)-2.*(a(4,:)./sqrt(z+a(6,:))).*z)-a(10,:).*(1-exp(-a(2,:).*z)).^2))), ... %
                      5 .*  lambda .* (Jb - a(1,:).*(1-exp(-a(2,:).*z))), ...
                     ...%mu .* ones(size(Imean)).*(a(6,:).^2+a(7,:).^2+a(8,:).^2), ...
                     ...%1000000 * max(0, -a(4,:).*exp(a(6,:).*z)-a(7,:).*exp(a(8,:).*z)),...
                   ... %factorDC .* ones(size(Imean)).*a(5,:), ...
                    100 .* max(0,-Jb + a(1,:).*(1-exp(-a(2,:).*z))), ...
                    1000./mean(Ilp,1) .* max(0,(Ilp   - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(12,:)-(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)), ...
                  1000./mean(Imean,1) .* max(0,(Imean - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(11,:)-(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)), ...
                   1000./mean(Ihp,1) .* max(0,(Ihp   - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)) ... 
                    (Ihp  -exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                     ...(a(13,1)*(Ihp(:,1)  -exp(a(3,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Ihp(:,2)  -exp(a(3,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     ...(a(13,1)*(Ihp(:,1)  -exp(a(3,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Ihp(:,3)  -exp(a(3,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     ...%(a(13,2)*(Ihp(:,2)  -exp(a(3,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Ihp(:,3)  -exp(a(3,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     ...%(a(13,1)*(Ilp(:,1)  -exp(a(12,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Ilp(:,2)  -exp(a(12,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     ...%(a(13,1)*(Ilp(:,1)  -exp(a(12,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Ilp(:,3)  -exp(a(12,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     ...%(a(13,2)*(Ilp(:,2)  -exp(a(12,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Ilp(:,3)  -exp(a(12,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     ...%(a(13,1)*(Imean(:,1)  -exp(a(11,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Imean(:,2)  -exp(a(11,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     ...%(a(13,1)*(Imean(:,1)  -exp(a(11,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Imean(:,3)  -exp(a(11,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     ...%(a(13,2)*(Imean(:,2)  -exp(a(11,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Imean(:,3)  -exp(a(11,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z))))...
                     ]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        %,fitoptions('MaxFunctionEvaluations',3.9e4)
        %options = struct('MaxFunctionEvaluations', 39000);
        x = lsqnonlin(fun,x0,lb,ub);
        
        fun = @(a) [  0.5 .* (Ihp  -exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      0.03 .* (Ilp  -exp(a(12,:)-(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      0.01 .* (Imean -exp(a(11,:)-(a(4,:)./sqrt(z+a(6,:))).*z)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                      0.5 .*  sqrt(abs((Ivar -exp(a(9,:)-2.*(a(4,:)./sqrt(z+a(6,:))).*z)-a(10,:).*(1-exp(-a(2,:).*z)).^2))), ... %
                      0.05 .*  lambda .* (Jb - a(1,:).*(1-exp(-a(2,:).*z))), ...
                     ...%mu .* ones(size(Imean)).*(a(6,:).^2+a(7,:).^2+a(8,:).^2), ...
                     ...%1000000 * max(0, -a(4,:).*exp(a(6,:).*z)-a(7,:).*exp(a(8,:).*z)),...
                   ... %factorDC .* ones(size(Imean)).*a(5,:), ...
                     max(0,-Jb + a(1,:).*(1-exp(-a(2,:).*z))), ...
                    1./mean(Ilp,1) .* max(0,(Ilp   - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(12,:)-(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)), ...
                  1./mean(Imean,1) .* max(0,(Imean - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(11,:)-(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)), ...
                   1./mean(Ihp,1) .* max(0,(Ihp   - a(1,:).*(1-exp(-a(2,:).*z)))-exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)) ... 
                    ...%(Ihp  -exp(a(3,:) -(a(4,:)./sqrt(z+a(6,:))).*z)-a(5,:)- a(1,:).*(1-exp(-a(2,:).*z))), ... %
                     252.5./max(Ihp,[],'all')*(a(13,1)*(Ihp(:,1)  -exp(a(3,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Ihp(:,2)  -exp(a(3,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     252.5./max(Ihp,[],'all')*(a(13,1)*(Ihp(:,1)  -exp(a(3,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Ihp(:,3)  -exp(a(3,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     252.5./max(Ihp,[],'all')*(a(13,2)*(Ihp(:,2)  -exp(a(3,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Ihp(:,3)  -exp(a(3,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     252.5./max(Ilp,[],'all')*(a(13,1)*(Ilp(:,1)  -exp(a(12,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Ilp(:,2)  -exp(a(12,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     252.5./max(Ilp,[],'all')*(a(13,1)*(Ilp(:,1)  -exp(a(12,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Ilp(:,3)  -exp(a(12,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     252.5./max(Ilp,[],'all')*(a(13,2)*(Ilp(:,2)  -exp(a(12,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Ilp(:,3)  -exp(a(12,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     252.5./max(Imean,[],'all')*(a(13,1)*(Imean(:,1)  -exp(a(11,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-a(13,2)*(Imean(:,2)  -exp(a(11,2) -(a(4,2)./sqrt(z+a(6,2))).*z)-a(5,2)- a(1,2)*(1-exp(-a(2,2)*z)))),...
                     252.5./max(Imean,[],'all')*(a(13,1)*(Imean(:,1)  -exp(a(11,1) -(a(4,1)./sqrt(z+a(6,1))).*z)- a(1,1)*(1-exp(-a(2,1)*z)))-(Imean(:,3)  -exp(a(11,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z)))),...
                     252.5./max(Imean,[],'all')*(a(13,2)*(Imean(:,2)  -exp(a(11,2) -(a(4,2)./sqrt(z+a(6,2))).*z)- a(1,2)*(1-exp(-a(2,2)*z)))-(Imean(:,3)  -exp(a(11,3) -(a(4,3)./sqrt(z+a(6,3))).*z)-a(5,3)- a(1,3)*(1-exp(-a(2,3)*z))))...
                     
                     ]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        %,fitoptions('MaxFunctionEvaluations',3.9e4)
        %options = struct('MaxFunctionEvaluations', 39000);
        x = lsqnonlin(fun,x,lb,ub);
        
        %x = lsqnonlin(fun,x,lb,ub,options);
        %x = lsqnonlin(fun,[1 1 1 1 1 0.25 0.25 0.25],lb,ub);
       for i=1:3
        % for graphing
        Imean(:,i)=double(Istruct.data(:,i)); %I is mean value vector
        Jb(:,i)=double(Ibstruct.data(:,i+3)); %Jb is lower percentile vector
        Ihp(:,i)=double(Istruct.data(:,i+6));
        Ilp(:,i)=double(Istruct.data(:,i+3));
        
        
        Binf(i)=x(1,i); betaB(i)=x(2,i);  hpJD(i)=exp(x(3,i)); lpJD(i)=exp(x(12,i)); meanJD(i)=exp(x(11,i)); varJD(i)=exp(x(9,i)); betaD(:,i)=[x(4,i);x(6,i);x(7,i);x(8,i)]; C(i)=x(5,i);
        %zOS(i)=x(5);
        % I Emperical/Modeled Back Scatter Removed 
        %Iebsr=I-Jb;
        Ihpbsr(:,i)=Ihp(:,i)-x(1,i)*(1-exp(-x(2,i)*z));
        Ilpbsr(:,i)=Ilp(:,i)-x(1,i)*(1-exp(-x(2,i)*z));
        Imeanbsr(:,i)=Imean(:,i)-x(1,i)*(1-exp(-x(2,i)*z));
        Ivarbsr(:,i)=Ivar(:,i)-x(10,i)*(1-exp(-x(2,i)*z)).^2;
        %ratio vector for attenuation fix
        ratiovec(:,i)=getRatioVec(Ihpbsr(:,i),10);
        
        fixedRatio(:,i)=(Ihpbsr(:,i)-C(i)).*ratiovec(:,i);
        
        %integral on the IMBSR vector for later white balance/ photonEQ
%         if ver<=2
%         intH(i)=sum((Imeanbsr(:,i)-x(5)).*exp((x(4)*exp(x(6)*z)+x(7)*exp(x(8)*z)).*z));
%         else
%         intH(i)=mean(fixedRatio(:,i));
%         end
         %x0=[x0 x];
        end
    Imef=zeros(length(z),3); Ihpf=zeros(length(z),3); Ilpf=zeros(length(z),3); Ivf=zeros(length(z),3);
    hp=struct;
    for i=1:3
        Imef(:,i)=(Imeanbsr(:,i)-C(i)).*exp((betaD(1,i)./sqrt(z+betaD(2,i))).*z);%*photonEQ(i);
        Ihpf(:,i)=(Ihpbsr(:,i)-C(i)).*exp((betaD(1,i)./sqrt(z+betaD(2,i))).*z);%*photonEQ(i);
        Ilpf(:,i)=(Ilpbsr(:,i)-C(i)).*exp((betaD(1,i)./sqrt(z+betaD(2,i))).*z);%*photonEQ(i);
        Ivf(:,i)=Ivarbsr(:,i).*exp(2*(betaD(1,i)./sqrt(z+betaD(2,i))).*z);%*photonEQ(i);  
        [hp(i).pks,hp(i).locs]=findpeaks(Ihpf(:,i));
        
    end
    whitefactor=252.5/max(Ihpf,[],'all');
    hplocs=intersect(intersect(hp(1).locs,hp(2).locs),hp(3).locs);
    [~,maxloc]=max(vecnorm(Ihpf(hplocs,:),2,2));
    %mat=Ihpf(hplocs(maxloc),:)./Ihpf(hplocs(maxloc),2);
    
    %photonEQ=252./mat;
%     mat=[sum(Imef,1)' sum(Ihpf,1)' sum(sqrt(Ivf),1)'];
%     %mat=[meanJD'./lpJD' hpJD'./lpJD' varJD'];
%     mat=mat./mat(2,:);
     %mat=mean(mat,1);
     %mat=mat/max(mat);
     %photonEQ=(1./mat)*whitefactor;
     photonEQ=[x(13,1) x(13,2) 1]*whitefactor;
    for i=1:3
        Imef(:,i)=Imef(:,i)*photonEQ(i);
        Ihpf(:,i)=Ihpf(:,i)*photonEQ(i);
        Ilpf(:,i)=Ilpf(:,i)*photonEQ(i);
        Ivf(:,i)=Ivf(:,i)*photonEQ(i).^2;  
    end
    %photonEQ=max(intH)./intH; %normalize photonEQ RGB coefs
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
        %subplot(3,1,i);
        plot(z,hpJD(i)*exp(-(betaD(1,i)./sqrt(z+betaD(2,i))).*z)+C(i),'Color',rgb(i,:));
        hold on;
        %plot(z,Iebsr);
        plot(z,Ihpbsr(:,i),'+','Color',rgb(i,:));
        plot(z,lpJD(i)*exp(-(betaD(1,i)./sqrt(z+betaD(2,i))).*z)+C(i),'Color',rgb(i,:));
        plot(z,Ilpbsr(:,i),'.','Color',rgb(i,:));
        plot(z,meanJD(i)*exp(-(betaD(1,i)./sqrt(z+betaD(2,i))).*z)+C(i),'Color',rgb(i,:));
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
            plot(z,(Ihpbsr(:,i)-C(i)).*exp((betaD(1,i)./sqrt(z+betaD(2,i))).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
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
        plot(z,Ivar(:,i),'+','Color',rgb(i,:));
        hold on
        plot(z,varJD(i)*exp(-2*(betaD(1,i)./sqrt(z+betaD(2,i))).*z)+C(i),'--','Color',rgb(i,:));
        plot(z,Ivf(:,i),'Color',rgb(i,:));
        plot(z,varJD(i)*ones(size(Ivf(:,i))),'--','Color',rgb(i,:));
        grid minor;
        if i==3
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
            legend('Var[I_r|z]','Fitted Attenuated term',...
                   'Var[I_g|z]','Fitted Attenuated term',...
                   'Var[I_b|z]','Fitted Attenuated term',...
                   'Location','northwest','NumColumns',3);
        end
%         subplot 212
%         plot(z,Ivar(:,i).*exp(2*(betaD(1,i)./sqrt(z+betaD(2,i))).*z)*photonEQ(i),'Marker','.','Color',rgb(i,:));
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