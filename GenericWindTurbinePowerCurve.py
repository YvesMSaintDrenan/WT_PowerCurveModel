# -*- coding: utf-8 -*-
"""
Created on Tue May 16 10:09:20 2023

@author: y-m.saint-drenan
"""

import numpy as np

#%% Parametric model of the power coefficient C𝑝 (λ, β)
def CpLambdaModels(Model,TSR,Beta=[]):
    
    #vSources=['Slootweg et al. 2003','Heier 2009','Thongam et al. 2009','De Kooning et al.  2010','Ochieng et Manyonge 2014','Dai et al. 2016','constant']
    
    TSR=np.maximum(0.0001,TSR)
    
    if Beta==[]:
        Beta=np.zeros(TSR.shape)
    if Model=='constant':
        Cp=np.ones(TSR.shape)*0.49
    else:
        if Model=='Slootweg et al. 2003':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.73,151,0.58,0,0.002,13.2,18.4,0,-0.02,0.003
            x=2.14
        elif  Model=='Heier 2009':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.5,116,0.4,0,0,5,21,0,0.089,0.035
            x=0
        elif  Model=='Thongam et al. 2009':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.5176,116,0.4,0,0,5,21,0.006795,0.089,0.035
            x=0
        elif  Model=='De Kooning et al. 2010':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.77,151,0,0,0,13.65,18.4,0,0,0
            x=0
        elif  Model=='Ochieng et Manyonge 2014':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.5,116,0,0.4,0,5,21,0,0.08,0.035
            x=0
        elif  Model=='Dai et al. 2016':
            c1,c2,c3,c4,c5,c6,c7,c8,c9,c10=0.22,120,0.4,0,0,5,12.5,0,0.08,0.035
            x=0

        Li=1/(1/(TSR+c9*Beta)-c10/(Beta**3+1));
        Cp=np.maximum(0,c1*(c2/Li-c3*Beta-c4*Li*Beta-c5*Beta**x-c6)*np.exp(-c7/Li)+c8*TSR);
    
    return Cp
#%% Calculation of the wind turbine curve without environmental effect
def WT_PowerCurve_raw(Vws,Pnom,Drotor,rMin=[],rMax=[],CpMax=[],Model='Dai et al. 2016',Beta=[],AirDensity=1.225,ConvEff=0.92):

    Rrotor = Drotor/2
    Arotor = np.pi*Rrotor**2

    # ********************************************************************************************
    # 1) Parameterisation of the minimal and maximal rotor rotational speed as a
    # function of the rotor diameter + calculation of VtipMin & VtipMax
    # source: http://publications.lib.chalmers.se/records/fulltext/179591/179591.pdf
    # ********************************************************************************************
    if rMin==[]:
        rMin=188.8*Drotor**(-0.7081)   # minimal angular speed in rpm
    if rMax==[]:
        rMax=793.7*Drotor**(-0.8504);      # maximal angular speed in rpm
    VtipMin=rMin*(2*np.pi*Rrotor)/60   # minimal tip speed in m/s
    VtipMax=rMax*(2*np.pi*Rrotor)/60  # maximal tip speed in m/s
    
    # ********************************************************************************************
    # 2) Calculation of the tip speed as a function of the wind speed 
    # ********************************************************************************************
    # In ths calculation step, the following assumptions are made:
    # a) the tip speed is set to maximize the energy output (*),
    #    which is achieved by setting lambda to lambdaopt, 
    # b) and assuming that Vtip is always comprised between VtipMin and VtipMax (**)
    # c) using an expression of cp as a function of lambda from (***) (no pitch control
    # assumed (**))
    # Sources:
    # (*) http://mstudioblackboard.tudelft.nl/duwind/Wind%20energy%20online%20reader/Static_pages/Cp_lamda_curve.htm
    # (**) http://www.mdpi.com/1996-1073/10/3/395
    # (***)http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6699403

    # Calculation of the optimal tip speed ratio and maximal power coefficient
    vTSR=np.arange(0,12,0.001)
    vCp=CpLambdaModels(Model,vTSR,Beta)
    TSR_Opt=np.mean(vTSR[vCp==max(vCp)])
    
    # scaling of the power coefficient function if a value is given for CpMax
    if CpMax==[]:
        CpScale=1
        CpMax=max(vCp)
    else:
        CpScale=CpMax/max(vCp)
    
    # Calculation of the tip speed and the tip speed ratio
    Vtip=np.minimum(VtipMax,np.maximum(VtipMin,TSR_Opt*Vws))
    TSR=np.zeros(Vws.shape)
    TSR[Vws>0]=Vtip[Vws>0]/Vws[Vws>0]
        
    # Calculation of the power coefficient
    Cp0=np.maximum(0,ConvEff*CpScale*CpLambdaModels(Model,TSR))

    # Calculation of the input power as a function of air density, wind speed and rotor area
    Pin=0.5*AirDensity*Arotor*(Vws**3)/1000
    Cp=np.zeros(Pin.shape)
    Cp[Pin>0]=np.minimum(Cp0[Pin>0],Pnom/Pin[Pin>0])
    Pout = Cp*Pin

    return Pout
#%% Turbulence intensity
def calcEffectTI(Vws,Pwt,TI=0.05,Vcutin=3,Vcutoff=25):
    
    #Gaussian filter over w*(1-TI):w*(1+TI), TI being the turbulence intensity
    if TI>0:
        Pwt_ti=0*np.ones(Vws.shape)
        for iws,tWS in enumerate(Vws):
            sigma=TI*tWS
            ix=np.where((Vws>(tWS-5*sigma)) & (Vws<(tWS+5*sigma)))[0]
            weight=np.exp(-0.5*(((Vws[ix]-tWS)/sigma)**2))
            if sum(weight)>0:
                Pwt_ti[iws]=sum(Pwt[ix]*weight)/sum(weight)
    else:
        Pwt_ti=Pwt

    # Setting the power production to zero below the cut-in and above the cut-off wind speeds
    Pwt_ti[Vws<Vcutin]=0
    Pwt_ti[Vws>Vcutoff]=0
    return Pwt_ti
#%% Wind shear and veer: calculation of the rotor equivalent wind speed (REWS)
def calcREWS(Vws,zhub,Drotor,Shear,Veer):
    N=10000
    dz=Drotor/N
    zi=zhub+np.linspace(-Drotor/2+dz/2,Drotor/2-dz/2,N)
    Ai=(2*np.sqrt((Drotor/2)**2-(zi-zhub)**2))*dz
    A=np.sum(Ai)
    
    CoeffShear=(zi/zhub)**Shear
    CoeffVeer=np.cos((zi-zhub)*Veer*np.pi/180)

    REWS=np.ones(Vws.shape)*np.nan
    for ii,V in enumerate(Vws):
        Vi=V*CoeffShear*CoeffVeer
        REWS[ii]=(np.sum((Vi**3)*Ai/A))**(1/3)
    
    return REWS
#%% Complete model
def GenericWindTurbinePowerCurve(Vws,Pnom,Drotor,zhub=[],Vcutin=3,Vcutoff=25,TI=0.1,Shear=0.15,Veer=0,rMin=[],rMax=[],CpMax=[],Model='Dai et al. 2016',Beta=[],AirDensity=1.225,ConvEff=[]):
    
    # conversion losses
    if ConvEff==[]:
        gear_loss_const= .01
        gear_loss_var= .014
        generator_loss= 0.03
        converter_loss= .03
        ConvEff=(1-gear_loss_const)*(1-gear_loss_var)*(1-generator_loss)*(1-converter_loss)
    
    # Estimation of the hub height based on a statistical relationship made using data from thewindpower.net
    if zhub==[]:
        zhub=10.95*Drotor+0.9205 
        
    # Calculation of the rotor equivalent wind speed
    REWS=calcREWS(Vws,zhub,Drotor,Shear,Veer)

    # Calculation of the power curve without consideration of the TI and cut-in and cut-off wind speeds
    Pout_raw=WT_PowerCurve_raw(REWS,Pnom,Drotor,rMin,rMax,CpMax,Model,Beta,AirDensity,ConvEff)

    # Calculation of the effect of the TI, cut-in and cut-off wind speeds on the power curve
    Pwt_ti=calcEffectTI(REWS,Pout_raw,TI,Vcutin,Vcutoff)
   
    return Pwt_ti