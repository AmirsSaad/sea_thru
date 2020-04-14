function [m,n,A] = statisticalWBfit(Imf,Ivf,z,isplot)
    

    for i=1:3 %each color independetly

        %bounderies
        lb=[-10 mean(Imf,'all')/2  0.5 0.5];
        ub=[ 10 mean(Imf,'all')*2 10   2  ];
        x0=[  0 mean(Imf,'all')    1.5 1  ];
        %   Binf      betaB  log(JD)     betaD(1)  DC   betaD(2 3 4)
        
        fun = @(a) [(Imf(:,1)+Imf(:,1)+Imf(:,1)-3*(a(1)*z+a(2))),...
                    (Imf(:,1)-(a(1)*z+a(2)))*a(3)-(Imf(:,2)-(a(1)*z+a(2)))*a(4),...
                    (Imf(:,1)-(a(1)*z+a(2)))*a(3)-(Imf(:,3)-(a(1)*z+a(2))),...
                    (Imf(:,2)-(a(1)*z+a(2)))*a(4)-(Imf(:,3)-(a(1)*z+a(2))),...
                    (Ivf(:,1)*a(3)-Ivf(:,2)*a(4))*0.5,...
                    (Ivf(:,1)*a(3)-Ivf(:,3))*0.5,...
                    (Ivf(:,2)*a(4)-Ivf(:,3))*0.5...
                    ]; %lambda*(log(I-Jb) - (a(3)-a(4)*z))
        
        x = lsqnonlin(fun,x0,lb,ub);
    end
    m=x(1); n=x(2); A=[x(3) x(4) 1];
    
    if isplot
        for i=1:3
        rgb=['#D95319';'#77AC30';'#0072BD'];

        figure(5)

        plot(z,(Imf(:,i)-(m*z+n))*A(i)+n,'Marker','.','Color',rgb(i,:));
        hold on;
        plot(z,Imf(:,i),'--','Color',rgb(i,:));
        plot(z,(m*z+n),'--k');
        plot(z,(ones(size(z))*n),'.-k');
        grid minor;
        title('Statistical White Balance - Maximal Intensity');
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        %legend('fixed','original'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        ylabel('Maximal Intensity'); xlabel('z distance [m]');
        
        figure(6)
        plot(z,Ivf(:,i)*A(i),'Marker','.','Color',rgb(i,:));
        hold on;
        plot(z,Ivf(:,i),'--','Color',rgb(i,:));
        grid minor;
        title('Statistical White Balance - Color Variance');
        %legend('minus BSmodel, times exp','minus empBS, times exp','minus BSmodel, times ratio','pre-fix'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        %legend('fixed','original'); %,'I_{mbsr}.*(I_{ebsr}^{(1)}/I_{ebsr}'
        ylabel('Variance'); xlabel('z distance [m]');
        
        end
    end
    
end