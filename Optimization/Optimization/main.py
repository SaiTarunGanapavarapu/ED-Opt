###############################################################################
# function:     main()                                                        #
# Desctiption:  Main script file to generate data and create Figures          #
#                                                                             #
# Input:        -                                                             #
#                                                                             #
# Output:       - Excel sheet with various concentration targets,             #
#                 Figures of Optimization Results section in the paper        #
###############################################################################
import pyomo.environ as pyo
import numpy as np
import matplotlib.pyplot as plt

# Import functions defined for ED Optimization
from solverUtils import getSolver, solveM, getSolution
from saveResultsToExcel import saveResultsToExcel

from getVars import getVars
from getParams import getParams
from getModelEqsED import getModelEqsED
from getCostEqsED import getCostEqsED

#####################################################################################################


# Vector of concentration targets from 0.2 wt% N to 3.91 wt% N
x = np.linspace(0.2*10**4, 3.91*10**4, 100)

# Initiate dictionary to store data
fullResults = []

        
for j in range(len(x)):
    
    # Initializing the m
    m = pyo.ConcreteModel()
    
    # Get all the variables
    getVars(m, x, j)
    
    # Get all the parameters
    getParams(m)
    
    # Get all model equations
    getModelEqsED(m)
    
    # Get all cost equations
    getCostEqsED(m)
    
    # Modify concentration target 
    del m.constraint7       # Delete concentration target constraint
    
    def constraint7(m):     # Add concentration target constraint
        # concentration target of the concentrate
        return m.concOutConcentrateND - x[j]/(m.scaleFacConc*m.molweightN) == 0
    m.constraint7 = pyo.Constraint(rule = constraint7)
    
    # Get solver
    solver = getSolver('baron', tol=1e-6)

    # Solve
    results = solveM(m, solver)

    # Extract results
    resultDict = getSolution(m, results)

    # Append results for all values to print to excel
    fullResults.append(resultDict)
    
    # Delete the constructed 'm' before going to next iteration 
    del m
    
# Remove any results that BARON failed to converge on    
fullResults = [row for row in fullResults if row.get('optimalNode') != '-3']    

# Save all results to Excel
saveResultsToExcel(results = fullResults, resultsFile = "EDResults.xlsx", sheetName="Sheet1")


#####################################################################################################


# Variables to plot
concConcOut   = np.array([i['concOutConcentrate'] for i in fullResults])
eosmWaterFlux = np.array([i['eosmWaterFlux']      for i in fullResults])
osmFlux       = np.array([i['osmFlux']            for i in fullResults])
capex         = np.array([i['capex']              for i in fullResults])
opex          = np.array([i['opex']               for i in fullResults])
totalCost     = np.array([i['totalCost']          for i in fullResults])
curr          = np.array([i['curr']               for i in fullResults])
currDens      = np.array([i['currDens']           for i in fullResults])
flowSplit     = np.array([i['flowSplit']          for i in fullResults])
memArea       = np.array([i['memArea']            for i in fullResults])



# Plots to visualize the variations in different variables



fig, axs = plt.subplots(2, 2, figsize=(7.48*2, 10))

# (A) Feed Split and Membrane Area
ax1 = axs[0,0]
ax1.set_xlabel('Product Concentration (wt% N)', fontsize=17)
ax1.set_ylabel(r'Feed Split ($S_{\text{flow}}$)', fontsize=17, color='red')
ax1.plot(concConcOut, flowSplit, color='red', linewidth=2, linestyle='--')
ax1.tick_params(axis='x', labelsize=17)
ax1.tick_params(axis='y', labelcolor='red', labelsize=17)
ax1.grid(True)
ax2 = ax1.twinx()
ax2.set_ylabel(r'Membrane Area ($\text{m}^2$)', fontsize=17, color='darkblue')
ax2.plot(concConcOut, memArea, color='darkblue', linewidth=2, linestyle=':')
ax2.set_ylim(10, 120)
ax2.tick_params(axis='y', labelcolor='darkblue', labelsize=17)

# (B) Water Flux (Osmotic & Electroosmotic)
ax3 = axs[0,1]
ax3.set_xlabel('Product Concentration (wt% N)', fontsize=17)
ax3.set_ylabel(r'Water Flux (kg/s)', fontsize=16)
ax3.plot(concConcOut, osmFlux      , label='Osmotic Flux', linewidth=2, color='darkblue', linestyle='--')
ax3.plot(concConcOut, eosmWaterFlux, label='Electroosmotic Flux', linewidth=2, color='red', linestyle=':')
# ax3.set_ylim((0, 41))
ax3.tick_params(axis='x', labelsize=17)
ax3.tick_params(axis='y', labelsize=17)
ax3.legend(fontsize=17)
ax3.grid(True)

# (C) Current Density and Current
ax4 = axs[1,0]
color = 'red'
ax4.set_xlabel('Product Concentration (wt% N)', fontsize=17)
ax4.set_ylabel(r'Current Density (A/$\text{m}^2$)', color=color, fontsize=17)
ax4.plot(concConcOut, currDens, color=color, linewidth=2, linestyle='--')
ax4.tick_params(axis='x', labelsize=17)
ax4.tick_params(axis='y', labelcolor=color, labelsize=17)
ax4.grid(True)
ax5 = ax4.twinx()
color = 'darkblue'
ax5.set_ylabel('Current (A)', color=color, fontsize=17)
ax5.plot(concConcOut, curr, color=color, linewidth=2, linestyle=':')
ax5.tick_params(axis='y', labelcolor=color, labelsize=17)
ax5.set_ylim(10, 40)

# (D) Cost
ax6 = axs[1,1]
ax6.plot(concConcOut, totalCost, label='Total Cost'    , linewidth=2, linestyle='-')
ax6.plot(concConcOut, capex    , label='Capital Cost'  , linewidth=2, linestyle=':', color='red')
ax6.plot(concConcOut, opex     , label='Operating Cost', linewidth=2, linestyle='--', color='darkgreen')
ax6.set_xlabel('Product Concentration (wt% N)', fontsize=17)
ax6.set_ylabel('Cost ($/t-N)', fontsize=17)
ax6.legend(fontsize=17)
ax6.grid(True)
ax6.tick_params(axis='both', labelsize=17)
fig.tight_layout()
plt.show()

fig.savefig('optimalDesigns0D.eps', dpi=1200)