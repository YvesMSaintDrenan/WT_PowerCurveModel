
Vws     = 0:0.01:30;

WT_param.TI      = 0;
WT_param.rMin    = 10;
WT_param.rMax    = 30;
WT_param.Drotor  = 80;
WT_param.Pnom    = 2000;
WT_param.CpMAX   = 0.4615;
WT_param.iModel  = NaN;
WT_param.Vcutoff = 25;
WT_param.Vcutin  = 3.5;
WT_param0=WT_param;
%%
clf
set(gcf,'Position',[ 5   391   586   315])
for iiSA=1:9
    if iiSA==1
        Vvar=40:2.5:120;
        PrmStr='Drotor';
        DescStr='Rotor diameter [m]'
        NrPlot='a)'
    elseif iiSA==2
        Vvar=1500:50:2500;
        PrmStr='Pnom';
        DescStr='Nominal power [kW]';
        NrPlot='b)'
    elseif iiSA==3
        Vvar=0:0.1:5;
        PrmStr='Vcutin';
        DescStr='Cut-in wind speed [m/s]';
        NrPlot='c)'
    elseif iiSA==4
        Vvar=20:1:30;
        PrmStr='Vcutoff';
        DescStr='Cut-off wind speed [m/s]';
        NrPlot='d)'
    elseif iiSA==5
        Vvar=0:15;
        PrmStr='rMin';
        DescStr='minimal rotation speed [rpm]'
        NrPlot='e)'
    elseif iiSA==6
        Vvar=15:40;
        PrmStr='rMax';
        DescStr='maximal rotation speed [rpm]'
        NrPlot='f)'
     elseif iiSA==7
        Vvar=1:6;
        CellSources={...
            'Slootweg et al. 2003','Heier 2009','Thongam et al. 2009',...
            'De Kooning et al.  2010','Ochieng et Manyonge 2014',...
            'Dai et al. 2016'};
        NrPlot='g)'
    elseif iiSA==8
        Vvar=0.3:0.02:0.59;
        PrmStr='CpMAX';
        DescStr='maximal Cp coefficient [-]';
        NrPlot='h)'
    elseif iiSA==9
        Vvar=0:15;
        PrmStr='TI';
        DescStr='Turbulence intensity [%]'
        NrPlot=''
    end
    if iiSA~=7
        cm=colormap(jet(length(Vvar)));
        clf;
        hold on
        for ii=1:length(Vvar)
            WT_param=WT_param0;
            WT_param.(PrmStr)=Vvar(ii);
            WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws);
            
            plot(Vws,WT_PwC.PoutTI,...
                'Color',cm(ii,:),...
                'LineWidth',2)
        end
        WT_PwC=Eval_WT_PowerCurve_v3(WT_param0,Vws)
        hhh=plot(Vws,WT_PwC.PoutTI,'k--');
        grid on
        box on
        set(gca,'FontSize',14)
        cb=colorbar;
        set(gca,'Clim',[min(Vvar) max(Vvar)])
        set(get(cb,'Ylabel'),'String',DescStr,'FontSize',18)
        xlabel('Wind speed [m/s]','FontSize',18);
        ylabel('Wind power production [kW]','FontSize',18);
        set(gcf,'Color','w')
        legend(hhh,...
            ['reference case (',PrmStr,'=',num2str(WT_param0.(PrmStr)),')'],...
            'Location','NorthEast')
        text(1,2300,NrPlot,'FontSize',32)

        ylim([0 2500])
        saveas(gcf,['PwC_SensAn_',PrmStr,'.png'])
    else
        
        cm=colormap(lines(length(CellSources)))
        clf;
        hold on
        for ii=1:length(Vvar)
            WT_param=WT_param0;
            WT_param.iModel=Vvar(ii);
            WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws);
            
            plot(Vws,WT_PwC.PoutTI,...
                'Color',cm(ii,:),...
                'LineWidth',2)
        end
        WT_PwC=Eval_WT_PowerCurve_v3(WT_param0,Vws)
        plot(Vws,WT_PwC.PoutTI,'k--')
        grid on
        box on
        set(gca,'FontSize',14)
        %set(gca,'Clim',[min(Vvar) max(Vvar)])
        %set(get(cb,'Ylabel'),'String',DescStr)
        xlabel('Wind speed [m/s]','FontSize',18);
        ylabel('Wind power production [kW]','FontSize',18);
        set(gcf,'Color','w')
        text(1,2300,NrPlot,'FontSize',32)
        CellSources{end+1}='Reference case (Dai et al. 2016)';
        legend(CellSources,'Location','SouthEast')
        saveas(gcf,['PwC_SensAn_','CpLModel','.png'])
    end
end
%%
Veer  = 0;

zhub=60; %60...100
vShear = 0.:0.01:0.5;

cm=colormap(jet(length(vShear)));

Vws     = 0:0.01:30;

WT_param.TI      = 0;
WT_param.rMin    = 10;
WT_param.rMax    = 30;
WT_param.Drotor  = 80;
WT_param.Pnom    = 2000;
WT_param.CpMAX   = 0.4615;
WT_param.iModel  = NaN;
WT_param.Vcutoff = 250;
WT_param.Vcutin  = 3.5;
WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws);



R=WT_param.Drotor/2;
zi=linspace(-R,R,200);
dz=mean(diff(zi));
xi=2*sqrt(R^2-zi.^2);
Ai=xi*dz;
A=sum(Ai);
clf
hold on
for iiSA=1:length(vShear)
    %%
    Shear=vShear(iiSA);
    mWSZHUB=Vws'*ones(size(Ai));
    mz=ones(size(Vws'))*zi;

    mWS=cosd(mz/R*Veer).*mWSZHUB.*((mz+zhub)/zhub).^Shear;
    REWS=((mWS.^3)*Ai'/A).^(1/3);

    %plot(Vws,Vws,Vws,REWS)
    %{ 
    iChk=2500;
    V=Vws(iChk)
    VertWS=mWS(iChk,:);
    VertZ=mz(iChk,:)+zhub;
    plot(VertWS.^3,VertZ,...
        Vws(iChk).^3,zhub,'o')
    mean(VertWS.^3)^(1/3)
    %} 
    
    Pout=WT_PwC.Pout;
    Pout(REWS>25)=0;
    plot(REWS,Pout,'Color',cm(iiSA,:))
end
% %
xlim([0 20])
xlim([0 30])
        grid on
        box on
        set(gca,'FontSize',14)
        %set(gca,'Clim',[min(Vvar) max(Vvar)])
        %set(get(cb,'Ylabel'),'String',DescStr)
        xlabel('Wind speed [m/s]','FontSize',18);
        ylabel('Wind power production [kW]','FontSize',18);
        set(gcf,'Color','w')
        text(1,2300,'(a)','FontSize',32)
        cb=colorbar;
set(gca,'Clim',[min(vShear) max(vShear/R)])
set(get(cb,'Ylabel'),'String','Wind shear [-]','FontSize',18)
saveas(gcf,'SensAn_WindShear.png')
%%
vVeer  = 0:30;

zhub=60; %60...100
Shear = 0;

cm=colormap(jet(length(vVeer)));

Vws     = 0:0.01:30;

WT_param.TI      = 0;
WT_param.rMin    = 10;
WT_param.rMax    = 30;
WT_param.Drotor  = 80;
WT_param.Pnom    = 2000;
WT_param.CpMAX   = 0.4615;
WT_param.iModel  = NaN;
WT_param.Vcutoff = 250;
WT_param.Vcutin  = 3.5;
WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws);



R=WT_param.Drotor/2;
zi=linspace(-R,R,200);
dz=mean(diff(zi));
xi=2*sqrt(R^2-zi.^2);
Ai=xi*dz;
A=sum(Ai);
clf
hold on
for iiSA=1:length(vVeer  )
    
    Veer  =vVeer  (iiSA);
    mWSZHUB=Vws'*ones(size(Ai));
    mz=ones(size(Vws'))*zi;

    mWS=cosd(mz/R*Veer).*mWSZHUB.*((mz+zhub)/zhub).^Shear;
    REWS=((mWS.^3)*Ai'/A).^(1/3);

    %plot(Vws,Vws,Vws,REWS)
    %{ 
    iChk=2500;
    V=Vws(iChk)
    VertWS=mWS(iChk,:);
    VertZ=mz(iChk,:)+zhub;
    plot(VertWS.^3,VertZ,...
        Vws(iChk).^3,zhub,'o')
    mean(VertWS.^3)^(1/3)
    %} 
    
    plot(REWS,WT_PwC.Pout,'Color',cm(iiSA,:))
end
xlim([0 12])
        grid on
        box on
        set(gca,'FontSize',14)
        %set(gca,'Clim',[min(Vvar) max(Vvar)])
        %set(get(cb,'Ylabel'),'String',DescStr)
        xlabel('Wind speed [m/s]','FontSize',18);
        ylabel('Wind power production [kW]','FontSize',18);
        set(gcf,'Color','w')
        text(1,2300,'(b)','FontSize',32)
        cb=colorbar;
set(gca,'Clim',[min(vVeer/R) max(vVeer/R)])
set(get(cb,'Ylabel'),'String','Wind veer [°/m]','FontSize',18)
set(gcf,'Position',[360 308 631 390])
saveas(gcf,'SensAn_WindVeer.png')