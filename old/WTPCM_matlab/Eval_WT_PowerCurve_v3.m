function WT_PwC=Eval_WT_PowerCurve_v3(WT_param,Vws)
%% Example of use
%{
WT_param.rMin = 4;
WT_param.rMax = 13;
WT_param.Drotor  = 120;
WT_param.Pnom    = 4000;
Vws     = 0:0.01:30;

WT_PowerCurve=Eval_WT_PowerCurve_v3(WT_param,Vws);
hold on
plot(WT_PowerCurve.Vws,WT_PowerCurve.Pout)

subplot(2,1,1)
hold on
plot(WT_PowerCurve.Vws,WT_PowerCurve.Cp,WT_PowerCurve.Vws,WT_PowerCurve.Pnom./WT_PowerCurve.Pin,'--',WT_PowerCurve.Vws,WT_PowerCurve.Cp)
xlabel('wind speed at hub height [m/s]')
ylabel('Power coefficient Cp [-]')
ylim([0 1])
grid on
subplot(2,1,2)
hold on
plot(WT_PowerCurve.Vws,WT_PowerCurve.Pout)
xlabel('wind speed at hub height[m/s]')
ylabel('wind turbine output power [kW]')
grid on
%}
%%
if nargin<2
    Vws     = 0:0.001:30;
end
if isfield(WT_param,'Vcutin')
    Vcutin=WT_param.Vcutin;
else
    Vcutin=0;
end
if isfield(WT_param,'Vcutoff')
    Vcutoff=WT_param.Vcutoff;
else
    Vcutoff=25;
end
if isfield(WT_param,'AirDensity')
    AirDensity=WT_param.AirDensity;
else
    AirDensity=1.225;
end


Drotor=WT_param.Drotor;
Rrotor = Drotor/2;
Arotor = pi*Rrotor.^2;
Pnom=WT_param.Pnom;
%%
% 1) Parameterisation of the minimal and maximal rotor rotational speed as a
% function of the rotor diameter
% source: http://publications.lib.chalmers.se/records/fulltext/179591/179591.pdf
if isfield(WT_param,'rMin')
    rMin=WT_param.rMin;
else
    rMin=188.8*Drotor.^(-0.7081);   % angular speed in rpm
end
if isfield(WT_param,'rMax')
    rMax=WT_param.rMax;
else
    rMax=793.7*Drotor.^(-0.8504);   % 
end
if isfield(WT_param,'TI')
    TI=WT_param.TI;
    if isnan(TI)
        TI=0.1;   %
    end
else
    TI=0.1;   % 
end
if isfield(WT_param,'iModel')
    iModel=WT_param.iModel;
    if isnan(iModel)
        iModel=6;
    end
else
    iModel=6;
end
if isfield(WT_param,'CpMAX');
    CpMAX=WT_param.CpMAX;
else
    CpMAX=NaN;
end
VtipMin=rMin*(2*pi*Rrotor)/60;  % minimal tip speed in m/s
VtipMax=rMax*(2*pi*Rrotor)/60;  % maximal tip speed in m/s

% 2) Calculation of the tip speed as a function of the wind speed by
% assuming that:
% a) the tip speed is set to maximize the energy output (*),
%    which is achieved by setting lambda to lambdaopt, 
% b) and assuming that Vtip is always comprised between VtipMin and VtipMax (**)
% c) using an expression of cp as a function of lambda from (***) (no pitch control
% assumed (**))
% Sources:
% (*) http://mstudioblackboard.tudelft.nl/duwind/Wind%20energy%20online%20reader/Static_pages/Cp_lamda_curve.htm
% (**) http://www.mdpi.com/1996-1073/10/3/395
% (***)http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6699403

lambda=0:0.001:12;
%Cpfct=@(lambda) 0.73*(151./lambda-13.65).*exp(-18.4./lambda+0.055);
Cpfct=@(lambda) CpLambdaModels(iModel,lambda);
CpScale=1;
if ~isnan(CpMAX)
    CpScale=CpMAX/max(Cpfct(lambda));
end
lambdaOpt=lambda(Cpfct(lambda)==max(Cpfct(lambda)));
Vtip0=lambdaOpt*Vws;
Vtip=min(VtipMax,max(VtipMin,Vtip0));
%plot(Vws,Vtip)

TSR=Vtip./Vws;
Cp0=max(0,CpScale*Cpfct(TSR));

Pin=0.5*AirDensity*Arotor*Vws.^3/1000;
Cp=min(Cp0,Pnom./Pin);
Pout = Cp.*Pin;
%%
WT_PwC=WT_param;
WT_PwC.Vws=Vws;
WT_PwC.Pout=Pout;
WT_PwC.Cp=Cp;
WT_PwC.Pin=Pin;
WT_PwC.rMin=rMin;
WT_PwC.rMax=rMax;
%%
%WT_PwC.vTI=0:2.5:15;
WT_PwC.PoutTI=[];
Pout0=reshape(Pout,[],1);
Vws=reshape(Vws,[],1);
if TI>0

CoeffWS=1+linspace(-3*TI/100,3*TI/100,100);
Pout_TI=zeros(size(Pout0));
SumW=zeros(size(Pout0));
tt0=[];
tt1=[];
tt2=[];
for iiK=1:length(CoeffWS)
    varVws=CoeffWS(iiK)*Vws;
    STD=TI*Vws;
    varW=1./sqrt(2*pi*STD.^2).*exp(-0.5*((varVws-Vws)./STD).^2);
    tPout=interp1([-100;Vws;100],[0;Pout0;Pout0(end)],varVws);
    tt0=[tt0,varVws(21)];
    tt1=[tt1,varW(21)];
    tt2=[tt2,tPout(21)];
    Pout_TI=Pout_TI+varW.*tPout;
    SumW=SumW+varW;
end
WT_PwC.PoutTI=Pout_TI./SumW;
else
    WT_PwC.PoutTI=Pout;
end
%%
WT_PwC.PoutTI(WT_PwC.Vws>Vcutoff)=0;
WT_PwC.PoutTI(WT_PwC.Vws<Vcutin)=0;
WT_PwC.Pout(WT_PwC.Vws>Vcutoff)=0;
WT_PwC.Pout(WT_PwC.Vws<Vcutin)=0;
vCellSources={...
    'Slootweg et al. 2003','Heier 2009','Thongam et al. 2009',...
    'De Kooning et al.  2010','Ochieng et Manyonge 2014',...
    'Dai et al. 2016'};
WT_PwC.CpModel=vCellSources{iModel};
%%
function Cp=CpLambdaModels(iiMdl,TSR,Beta)

if nargin<3
    Beta=zeros(size(TSR));
end

c1=[0.73	0.5	0.5176	0.77	0.5	0.22];
c2=[151	116	116	151	116	120];
c3=[0.58	0.4	0.4	0	0	0.4];
c4=[0	0	0	0	0.4	0];
c5=[0.002	0	0	0	0	0];
x=[2.14	0	0	0	0	0];
c6=[13.2	5	5	13.65	5	5];
c7=[18.4	21	21	18.4	21	12.5];
c8=[0	0	0.006795	0	0	0];
c9=[-0.02	0.089	0.089	0	0.08	0.08];
c10=[0.003	0.035	0.035	0	0.035	0.035];
CellSources={...
    'Slootweg et al. 2003','Heier 2009','Thongam et al. 2009',...
    'De Kooning et al.  2010','Ochieng et Manyonge 2014',...
    'Dai et al. 2016'};

Li=1./(1./(TSR+c9(iiMdl)*Beta)-c10(iiMdl)./(Beta.^3+1));
Cp=max(0,c1(iiMdl)*(c2(iiMdl)./Li-c3(iiMdl)*Beta-c4(iiMdl)*Li.*Beta-c5(iiMdl)*Beta.^x(iiMdl)-c6(iiMdl)).*exp(-c7(iiMdl)./Li)+c8(iiMdl)*TSR);        
%max(Cp)
%plot(TSR,Cp,'LineWidth',2)
end
end