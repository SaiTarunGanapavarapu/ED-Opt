###############################################################################
# function:     plottingScript()                                              #
# Desctiption:  script to plot comparisons of values between 0-D and 1-D      #
#                                                                             #
# Input:        -                                                             #
#                                                                             #
# Output:       - All parameters                                              #
#                                                                             #
###############################################################################
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Load 0-D data from the EDResults.xlsx file generated in 0-D optimization code
df0D   = pd.read_excel('EDResults.xlsx')
data0D = df0D.to_dict(orient='list') 

# Load 1-D data from excel sheet generated in matlab simulator
# Mode 1
df1DM1   = pd.read_excel('simulationDataM1.xlsx')
data1DM1 = df1DM1.to_dict(orient='list')

# Mode 2
df1DM2   = pd.read_excel('simulationDataM2.xlsx')
data1DM2 = df1DM2.to_dict(orient='list')

# Mode 3
df1DM3   = pd.read_excel('simulationDataM3.xlsx')
data1DM3 = df1DM3.to_dict(orient='list') 

###############################################################################

fig1, axes = plt.subplots(2, 2, figsize=(7.48*2, 10))

# 1st plot (1,1)
axes[0, 0].plot(data0D['concOutConcentrate'], np.array(data0D['concOutDilute'])/10**4, linewidth=2, label= r'0-D')
axes[0, 0].plot(data0D['concOutConcentrate'], np.array(data1DM2['ConcDil']    )/10**4, linewidth=2, label= r'1-D Fixed $I$', linestyle=':', color='red')
axes[0, 0].plot(data0D['concOutConcentrate'], np.array(data1DM1['ConcDil']    )/10**4, linewidth=2, label= r'1-D Fixed $V_{\text{cp}}$', linestyle='solid')
axes[0, 0].plot(data0D['concOutConcentrate'], np.array(data1DM3['ConcDil']    )/10**4, linewidth=2, label= r'1-D Fixed $V_{\text{tot}}$', linestyle='--')
axes[0, 0].set_xlabel('Concentrate purity (wt% N)', fontsize=17)
axes[0, 0].set_ylabel('Dilute purity (wt% N)', fontsize=17)
axes[0, 0].grid(True)
axes[0, 0].legend(fontsize=15)
axes[0, 0].tick_params(axis='both', which='major', labelsize=17)
axes[0, 0].text(-0.1, 1.05, '(A)', transform=axes[0, 0].transAxes, fontsize=16, fontweight='bold', va='top')

# 2nd plot (1,2)
axes[0, 1].plot(data0D['concOutConcentrate'], data0D['concOutConcentrate']               , linewidth=2, label= r'0-D')
axes[0, 1].plot(data0D['concOutConcentrate'], np.array(data1DM2['concConc'])/10**4, linewidth=2, label= r'1-D Fixed $I$', linestyle=':', color='red')
axes[0, 1].plot(data0D['concOutConcentrate'], np.array(data1DM1['concConc'])/10**4, linewidth=2, label= r'1-D Fixed $V_{\text{cp}}$', linestyle='solid')
axes[0, 1].plot(data0D['concOutConcentrate'], np.array(data1DM3['concConc'])/10**4, linewidth=2, label= r'1-D Fixed $V_{\text{tot}}$', linestyle='--')
axes[0, 1].set_xlabel('Concentrate purity (wt% N)', fontsize=17)
axes[0, 1].set_ylabel('Concentrate purity (wt% N)', fontsize=17)
axes[0, 1].grid(True)
axes[0, 1].legend(fontsize=15)
axes[0, 1].tick_params(axis='both', which='major', labelsize=17)
axes[0, 1].text(-0.1, 1.05, '(B)', transform=axes[0, 1].transAxes, fontsize=16, fontweight='bold', va='top')

# 3rd plot (2,1)
axes[1, 0].plot(data0D['concOutConcentrate'], np.array(data0D['totPower'])/10**3, linewidth=2, label= r'0-D')
axes[1, 0].plot(data0D['concOutConcentrate'], data1DM2['power']                 , linewidth=2, label= r'1-D Fixed $I$', linestyle=':', color='red')
axes[1, 0].plot(data0D['concOutConcentrate'], data1DM1['power']                 , linewidth=2, label= r'1-D Fixed $V_{\text{cp}}$', linestyle='solid')
axes[1, 0].plot(data0D['concOutConcentrate'], data1DM3['power']                 , linewidth=2, label= r'1-D Fixed $V_{\text{tot}}$', linestyle='--')
axes[1, 0].set_xlabel('Concentrate purity (wt% N)', fontsize=17)
axes[1, 0].set_ylabel('Power (kW)', fontsize=17)
axes[1, 0].grid(True)
axes[1, 0].legend(fontsize=15)
axes[1, 0].tick_params(axis='both', which='major', labelsize=17)
axes[1, 0].text(-0.1, 1.05, '(C)', transform=axes[1, 0].transAxes, fontsize=16, fontweight='bold', va='top')

# 4th plot (2,2)
axes[1, 1].plot(data0D['concOutConcentrate'], data0D['curr']     , linewidth=2, label= r'0-D')
axes[1, 1].plot(data0D['concOutConcentrate'], data1DM2['current'], linewidth=2, label= r'1-D Fixed $I$', linestyle=':', color='red')
axes[1, 1].plot(data0D['concOutConcentrate'], data1DM1['current'], linewidth=2, label= r'1-D Fixed $V_{\text{cp}}$', linestyle='solid')
axes[1, 1].plot(data0D['concOutConcentrate'], data1DM3['current'], linewidth=2, label= r'1-D Fixed $V_{\text{tot}}$', linestyle='--')
axes[1, 1].set_xlabel('Concentrate purity (wt% N)', fontsize=17)
axes[1, 1].set_ylabel('Current (A)', fontsize=17)
axes[1, 1].grid(True)
axes[1, 1].legend(fontsize=15)
axes[1, 1].tick_params(axis='both', which='major', labelsize=17)
axes[1, 1].text(-0.1, 1.05, '(D)', transform=axes[1, 1].transAxes, fontsize=16, fontweight='bold', va='top')

plt.tight_layout()
fig1.savefig('0D1DCompPlots.eps', dpi=1200)