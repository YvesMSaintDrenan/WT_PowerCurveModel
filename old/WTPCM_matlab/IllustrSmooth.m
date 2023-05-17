kCl=0.3;
VWSEX=11.;
vWK=1.:2:20;
WT_param.TI      = 10;
WT_param.rMin    = 10;
WT_param.rMax    = 30;
WT_param.Drotor  = 80;
WT_param.Pnom    = 2000;
WT_param.CpMAX   = 0.4615;
WT_param.iModel  = NaN;
WT_param.Vcutoff = 25;

Vws=0:0.1:25;
WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws);

clf
subplot(3,1,1)
hold on
plot(Vws,WT_PwC.Pout,...
	'LineWidth',2,'Color','k')
text(18,650,sprintf(['a) Power curve \n corresponding \n to a turbulence \n intensity of ',num2str(0),'%%']),'FontSize',14,...
    'fontweight','Bold')
xlabel('Wind speed [m/s]','FontSize',14)
ylabel('Power production [kW]','FontSize',14)

idx0=find(Vws==VWSEX);
S=vWK(jj)*WT_param.TI/100;
S=VWSEX*WT_param.TI/100;
K0=exp(-0.5*((Vws-VWSEX)/S).^2);
idx1=find(K0>0.1 & ismember(Vws,0:0.5:25));
K0=K0/sum(K0);
plot(Vws(idx1),WT_PwC.Pout(idx1),'ko','MarkerFaceColor',0.8*[1 1 1],'MarkerSize',5)
plot(Vws(idx0),WT_PwC.Pout(idx0),'rd','LineWidth',3,'Color',[0.8 0 0])
box on

subplot(3,1,2)
hold on
vWK=1:2:20;
cm=colormap(winter(length(vWK)));
for jj=1:length(vWK)
    S=vWK(jj)*WT_param.TI/100;
    K=exp(-0.5*((Vws-vWK(jj))/S).^2);
    K=K/sum(K);
    plot(Vws,K,'Color',kCl*cm(jj,:)+(1-kCl*[1 1 1]),'LineWidth',2)
end
jj=find(vWK==VWSEX);
plot(Vws,K0,'Color',cm(jj,:),'LineWidth',2)
box on
ylim([0 0.1])
plot(Vws(idx1),K0(idx1),'ko','MarkerFaceColor',0.8*[1 1 1],'MarkerSize',5)
xlabel('Wind speed [m/s]','FontSize',14)
ylabel('Weights [-]','FontSize',14)
text(24.5,0.08,...
    sprintf('(b) Wind speed and TI \n dependant Gaussian \n smoothing  kernels'),'FontSize',14,...
    'HorizontalAlignment','Right',...
    'fontweight','Bold')

subplot(3,1,3)
hold on
plot(Vws,WT_PwC.Pout,...
	'LineWidth',2,'Color',0.8*[1 1 1])
plot(Vws,WT_PwC.PoutTI,...
	'LineWidth',2,'Color','k')
box on
text(18,650,sprintf(['a) Power curve \n corresponding \n to a turbulence \n intensity of ',num2str(WT_param.TI),'%%']),'FontSize',14,...
    'fontweight','Bold')
xlabel('Wind speed [m/s]','FontSize',14)
ylabel('Power production [kW]','FontSize',14)
plot(Vws(idx0),WT_PwC.PoutTI(idx0),'rd','LineWidth',3,'Color',[0.8 0 0])

set(gcf,'Position',[174 13 530 670])
annotation(gcf,'line',[0.533699059561129 0.534369905956112],...
    [0.880851063829787 0.422462157298613],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.518025078369906 0.517912225705328],...
    [0.878014184397163 0.440901873610669],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.502351097178683 0.502238244514105],...
    [0.879432624113475 0.459341589922726],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.486677115987461 0.486564263322884],...
    [0.880851063829787 0.480618185667407],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.470890282131661 0.470890282131661],...
    [0.862189054726369 0.490547263681592],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.456 0.456],...
    [0.850841536995873 0.479199745951095],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.439432601880878 0.439432601880878],...
    [0.833820260400128 0.46217846935535],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.424216300940439 0.424216300940439],...
    [0.815380544088071 0.443738753043294],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.408 0.408],...
    [0.795522388059702 0.423880597014925],'Color',[0.8 0.8 0.8]);

annotation(gcf,'line',[0.532915360501567 0.471786833855799],...
    [0.422695035460993 0.251063829787234],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.517241379310343 0.470219435736677],...
    [0.44113475177305 0.245390070921986],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.501567398119122 0.469435736677116],...
    [0.460992907801419 0.245390070921986],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.4858934169279 0.468652037617555],...
    [0.480851063829788 0.246808510638298],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.471003134796238 0.469435736677116],...
    [0.487943262411348 0.24822695035461],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.455329153605016 0.469435736677116],...
    [0.480851063829787 0.246808510638298],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.440438871473354 0.470219435736677],...
    [0.462411347517731 0.243971631205674],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.424764890282132 0.470219435736677],...
    [0.44113475177305 0.24822695035461],'Color',[0.8 0.8 0.8]);
annotation(gcf,'line',[0.40987460815047 0.471786833855799],...
    [0.424113475177305 0.246808510638298],'Color',[0.8 0.8 0.8]);

set(gcf,'Color','w')

saveas(gcf,'IllustrateSmoothingTI.png')