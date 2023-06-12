# A Generic Wind Turbine Power Curve

A wind turbine’s power curve relates its power production to the wind speed it experiences. The typical shape of a power curve is well known and has been studied extensively; however, the power curves of individual turbine models can vary widely from one another. This is due to both the technical features of the turbine (power density, cut-in and cut-out speeds, limits on rotational speed and aerodynamic efficiency), and environmental factors (turbulence intensity, air density, wind shear and wind veer). Data on individual power curves are often proprietary and only available through commercial databases. We therefore develop an open-source model which can generate the power curve of any turbine, adapted to the specific conditions of any site. This can employ one of six parametric models advanced in the literature, and accounts for the eleven variables mentioned above.

Yves-Marie Saint-Drenan, Romain Besseau, Malte Jansen, Iain Staffell, Alberto Troccoli, Laurent Dubus, Johannes Schmidt, Katharina Gruber, Sofia G. Simões, Siegfried Heier, A parametric model for wind turbine power curves incorporating environmental conditions, Renewable Energy,Volume 157,2020,Pages 754-768,ISSN 0960-1481, https://doi.org/10.1016/j.renene.2020.04.123.

This repository contains different jupyere notebooks leveraging the work described in the above-mentioned paper. It allows estimating the power curve of a wind turbine given a very limited number of characteristics. In its simplest implementation, only the nominal power and the rotor curve are necessary, as illustrated in the example below. The model offers the possibility to give further operating characteristics such as the cut-in and cut-off wind speeds, the minimal and maximal rotation speed.. as well as to integrate a number of environmental characteristics such as the wind shear and veer, the turbulence intensity and the air density.

``` python
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['figure.figsize'] = (10, 5)
import GenericWindTurbinePowerCurve as GWTPC

Pnom    = 2000
Drotor  = 80
Vws     = np.arange(0,30,0.01)

Pwt=GWTPC.GenericWindTurbinePowerCurve(Vws,Pnom,Drotor)

plt.plot(Vws,Pwt)
plt.ylabel('wind power (kW)')
plt.xlabel('wind speed (m/s)')
plt.grid()
```

<p align="center">
<img src="https://github.com/YvesMSaintDrenan/WT_PowerCurveModel/blob/master/fig/ExampleWTPowerCurve.png" width=600px>
</p>

In comparison to the first version of the code issued at during the publication, the python code has been improved to gain robustness and readibility. In addition, different notebooks illustrating the proposed approach has been prepared.

### [1. Step-by-step explication of the modelling approach](https://github.com/YvesMSaintDrenan/WT_PowerCurveModel/blob/master/GenericWindTurbinePowerCurve_1_ModellingSteps.ipynb)

In this notebook, the different steps of the model are explained and illustrated. This notebook contains exactly the code available in the library "GenericWindTurbinePowerCurve.py" but in a sequential form to make the different steps of the calculation clear. Finally, the last section of this notebook illustrates the use of the final function <i>GenericWindTurbinePowerCurve</i> that is contain in the main python code.

### [2. Sensitivity analysis of the model to the various parameters](https://github.com/YvesMSaintDrenan/WT_PowerCurveModel/blob/master/GenericWindTurbinePowerCurve_2_SensitivityAnalysis.ipynb)

This notebook recreate the sensitivity analysis shown in the paper (the original version was implemented in matlab). It is a simple one-at -a-time sensitivity analysis where the influence of each parameters is represented graphically with respect to a reference configuration. It helps getting an insight of the importance of the different parameters. It was also very useful to verify that the model is working correctly.

### [3. Comparison with the generic wind turbine power curve model from the pywake library](https://github.com/YvesMSaintDrenan/WT_PowerCurveModel/blob/master/GenericWindTurbinePowerCurve_3_ComparisonPyWake.ipynb)

A generic wind turbine power curve model can also be found in the [pywake library](https://github.com/DTUWindEnergy/PyWake). In this notebook the two models have been compared for a number of different configurations. This comparison showed that the pywake model is slightly different from ours but the difference between the two models is very small.

### [4. Validation of the model]()

Work in progress

### [5. Example of calculation of a power curve for month averaged wind speed values](https://github.com/YvesMSaintDrenan/WT_PowerCurveModel/blob/master/GenericWindTurbinePowerCurve_5_MonthlyWindSpeed.ipynb)

### Citation: 

```
@article{SaintDrenan2020GenericWindTurbinePowerCurve,
  title={A parametric model for wind turbine power curves incorporating environmental conditions},
  author={Yves-Marie Saint-Drenan, Romain Besseau, Malte Jansen, Iain Staffell, Alberto Troccoli, Laurent Dubus, Johannes Schmidt, Katharina Gruber, Sofia G. Simões, Siegfried Heier},
  journal={Renewable Energy},
  year={2020}
}
```