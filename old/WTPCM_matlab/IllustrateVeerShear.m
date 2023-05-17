zh=60;
D=80;
Vh=10;
IM=imread('Unbenannt.png');
clf
set(gcf,'Position',[10         237        1220         464])
SP1=subplot(1,3,1)
image(IM)
xlim([1 320])
ylim([23 326])
axis off

SP2=subplot(1,3,2)
vShear = 0.05:0.05:0.4;
cm=colormap(jet(length(vShear)));
hold on
plot([0.4 1.4],zh*[1 1],'k--','LineWidth',2)
clear Lgd;
Lgd{1}='Hub height';
for ii=1:length(vShear)
Shear=vShear(ii)
z=zh+(-D/2:D/2);
Vz=1*(z/zh).^Shear;
hold on
plot(Vz,z,'Color',cm(ii,:),'LineWidth',2)
Lgd{end+1}=['Shear=',num2str(Shear)];
end
grid on
box on
set(gca,'FontSize',14)
xlabel('Wind speed ratio V(z)/V(Hub) [-]','FontSize',16)
ylabel('Height above ground [m]','FontSize',16)
legend(Lgd,'Location','NorthWest')
set(gcf,'Color','w')


SP3=subplot(1,3,3)
vVeer=0:5:30;
cm=colormap(jet(length(vVeer)));
hold on
plot([-30 30],zh*[1 1],'k--','LineWidth',2)
clear Lgd;
Lgd{1}='Hub height';
z=zh+(-D/2:D/2);
dPHi=linspace(-1,1,length(z))
for ii=1:length(vVeer)
hold on
plot(dPHi*vVeer(ii),z,'Color',cm(ii,:),'LineWidth',2)
Lgd{end+1}=['Veer=',num2str(round(100*vVeer(ii)/40)/100),'°/m'];
end
legend(Lgd,'Location','NorthWest')
grid on 
box on
set(gca,'FontSize',14)
xlabel({'Absolute difference in wind direction ',' with respect to hub height  [°]'},'FontSize',16)
ylabel('Height above ground [m]','FontSize',16)



set(SP1,'Position',[0.0200    0.1317    0.2900    0.785])
set(SP2,'Position',[0.3752    0.1317    0.2667    0.7819])
set(SP3,'Position',[0.6916    0.1317    0.2667    0.7819])
saveas(gcf,'IllustrateVeerShear.png')
%%
