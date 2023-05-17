load('Data/TheWindPowerNet_PwCDB.mat')
idxWTPC=find(...
    ismember(WT_database.Manufacturer_Name,{'Vestas','Repower','Nordex','GE Energy','Enercon'}) &...
    WT_database.IsPwC &...
    WT_database.RatedPower>1000);
ii=0
%%
Vmax=20;
idxVld=find(WT_database.Vws>0 & WT_database.Vws<Vmax);
MAE=[];
MaxAbsDiff=[];
for jj=1:length(idxWTPC)
    WT_param.Drotor  = WT_database.RotorDiameter(idxWTPC(jj));
    WT_param.Pnom    = WT_database.RatedPower(idxWTPC(jj));
    WT_PowerCurve=Eval_WT_PowerCurve_v3(WT_param,WT_database.Vws(idxVld));
    
    Diff=...
        WT_PowerCurve.PoutTI./WT_param.Pnom-...
        (WT_database.Pout(idxWTPC(jj),idxVld)/WT_param.Pnom)'*ones(1,7);
    MAE=[MAE;mean(abs(Diff))];
    MaxAbsDiff=[MaxAbsDiff;max(abs(Diff))];
end
%%
clf
plot(WT_PowerCurve.vTI,100*MaxAbsDiff','LineWidth',1)
grid on
set(gca,'FontSize',14)
xlabel('Turbulence intensity [%]','FontSize',14)
ylabel(sprintf('Maximal absolute difference between the modelled \n power curve and the database information [%%Cap]'))
set(gcf,'Position',[-1119 70.6          846.4            652])
set(gcf,'Color','w')
%%
clf
plot(WT_PowerCurve.vTI,100*MAE','LineWidth',1)
grid on
set(gca,'FontSize',14)
xlabel('Turbulence intensity [%]','FontSize',14)
ylabel(sprintf('Mean absolute difference between the modelled \n power curve and the database information [%%Cap]'))
set(gcf,'Position',[-1119 70.6          846.4            652])
%%
clf
hist(MaxAbsDiff(:,3)*100,25)
set(gca,'FontSize',14)
xlabel(sprintf('Maximal absolute difference between the modelled \n power curve and the database information [%%Cap]'),...
    'FontSize',16)
ylabel('Count [-]')
grid on
text(0.215,11.50,'TI=5%','FontSize',18)
%% 3
 ii=ii-1;
% ii=26;

if ii>length(idxWTPC)
    ii=1;
end
WT_param.Drotor  = WT_database.RotorDiameter(idxWTPC(ii));
WT_param.Pnom    = WT_database.RatedPower(idxWTPC(ii));
Vws     = 0:0.01:30;
WT_PowerCurve=Eval_WT_PowerCurve_v3(WT_param,Vws);

clf;hold on
h01=plot(WT_PowerCurve.Vws,WT_PowerCurve.Pout,'LineWidth',3,'Color',[73 83 96]/100);
h02=plot(WT_PowerCurve.Vws,WT_PowerCurve.PoutTI(:,WT_PowerCurve.vTI==2.5),'LineWidth',3,'Color',[153 255 153]/300);
h03=plot(WT_PowerCurve.Vws,WT_PowerCurve.PoutTI(:,WT_PowerCurve.vTI==5),'LineWidth',3,'Color',[255 255 50]/300);
h04=plot(WT_PowerCurve.Vws,WT_PowerCurve.PoutTI(:,WT_PowerCurve.vTI==10),'LineWidth',3,'Color',[255 153 153]/300);
h2=plot(WT_database.Vws,WT_database.Pout(idxWTPC(ii),:),'k+-');
xlim([0 20])
box on
grid on
clear BOx;
BOx{1,1}=['Manufacturer: ', WT_database.Manufacturer_Name{idxWTPC(ii)}];
BOx{2,1}=['Model name: ', WT_database.WT_name{idxWTPC(ii)}];
BOx{3,1}=['Rotor diameter: ',num2str(WT_database.RotorDiameter(idxWTPC(ii))),' m'];
BOx{4,1}=['Rated power: ',num2str(WT_database.RatedPower(idxWTPC(ii))),' kW'];

XL=get(gca,'XLim');
YL=get(gca,'YLim');
text(0.02*XL(2),0.85*YL(2),BOx,'FontSize',14,'EdgeColor',[0 0 0]);
set(gcf,'Color','w')
set(gca,'FontSize',14)
xlabel('Wind speed [m/s]','FontSize',18)
ylabel('Power [kW]','FontSize',18)
hLGD=legend(...
    [h2 h01 h02 h03 h04],...
    'Manufacturer power curve','Parameterized power curve for TI=0%','Parameterized power curve for TI=2.5%','Parameterized power curve for TI=5%','Parameterized power curve for TI=10%',...
    'Location','SouthEast');
set(hLGD,'EdgeColor','None','Color',0.95*[1 1 1])
set(gcf,'Position',[ -935.8000  208.2000  816.0000  512.8000])
disp(WT_database.Info{idxWTPC(ii)})