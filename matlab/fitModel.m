function out = fitModel(meanH,lowH)

eqnBS='a*(1-exp(-b*x))';
startPoints=[Binf 1]
lowerBounds=[0 0];
upperBounds=[1 5];
options= fitoptions('Lower',lowerBounds, ... 
                    'Upper',upperBounds, ...
                    'Start',startPoints);
f1 = fit(lowH(:,4),lowH(:,3),eqnBS,options);
plot(f1,x,y)
end