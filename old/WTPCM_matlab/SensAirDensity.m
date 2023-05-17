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
WT_param.AirDensity= 1.225;
WT_param0=WT_param;

PrmStr='AirDensity';
DescStr='Air density [kg/m3]'
Vvar=1.15:0.01:1.3;

cm=colormap(jet(length(Vvar)));
        clf;
set(gcf,'Position',[ 5   391   586   315])
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
            ['refence case (',PrmStr,'=',num2str(WT_param0.(PrmStr)),')'],...
            'Location','NorthEast')
        %text(1,2300,NrPlot,'FontSize',32)

        ylim([0 2500])
        saveas(gcf,['PwC_SensAn_',PrmStr,'.png'])