###############################################################################
# function:     main()                                                        #
# Desctiption:  Function to load all the parameters in the ED model           #
#                                                                             #
# Input:        -                                                             #
#                                                                             #
# Output:       - All parameters                                              #
#                                                                             #
###############################################################################
import pyomo.environ as pyo

from solverUtils import getSolver, solveM, getSolution

from getVars import getVars
from getParams import getParams
from getModelEqsED import getModelEqsED
from getCostEqsED import getCostEqsED



# Modify this to change the concentration target 
x = 0.2*10**4
    
# Initializing the model
m = pyo.ConcreteModel()

# Get all the variables
getVars(m, x)

# Get all the parameters
getParams(m)

# Get all model equations
getModelEqsED(m)

# Get all cost equations
getCostEqsED(m)


# Modify concentrate concentration target 
del m.constraint7       # Delete concentration target constraint

def constraint7(m):     # Add concentration target constraint
    # concentration target of the concentrate
    return m.concOutConcentrateND - x/(m.scaleFacConc*m.molweightN) == 0
m.constraint7 = pyo.Constraint(rule = constraint7)

# # Modify dilute concentration target 
# del m.constraint6       # Delete concentration target constraint

# def constraint6(m):        # concentration target of the Dilute        
#     return m.concOutDiluteND - 0.04*10**4/(m.scaleFacConc*m.molweightN) == 0
# m.constraint6 = pyo.Constraint(rule = constraint6)

# Get solver
# solver = getSolver('ipopt', tol=1e-6)   # Uncomment for using ipopt as the solver if baron is not available
solver = getSolver('baron', tol=1e-6)

# Solve
results = solveM(m, solver)

# Extract results
resultDict = getSolution(m, results)

