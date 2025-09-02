###############################################################################
# function:     getVars()                                                     #
# Desctiption:  Function to define variables in the optimization problem      #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with variables added as components                        #
#                                                                             #
###############################################################################

import pyomo.environ as pyo


def getVars(m, x):

    # Defining all the variables in the model    
    m.I                        = pyo.Var(initialize = 30         , within = pyo.NonNegativeReals, bounds = (10**-3, 10**3))
    m.flowSplit                = pyo.Var(initialize = 0.01       , within = pyo.NonNegativeReals, bounds= (0,1)           )
    m.memLength                = pyo.Var(initialize = 1          , within = pyo.NonNegativeReals, bounds= (0.01,100)      )
    m.memWidth                 = pyo.Var(initialize = 1          , within = pyo.NonNegativeReals, bounds= (0.01,1000)     )
    m.thicknessConcentrate     = pyo.Var(initialize = 0.001      , within = pyo.NonNegativeReals, bounds= (0.001,1)       )
    m.thicknessDilute          = pyo.Var(initialize = 0.001      , within = pyo.NonNegativeReals, bounds= (0.001,1)       )
    m.flowOutConcentrateND     = pyo.Var(initialize = 1          , within = pyo.NonNegativeReals, bounds= (10**-6,100)    )
    m.flowOutDiluteND          = pyo.Var(initialize = 1          , within = pyo.NonNegativeReals, bounds= (10**-6,100)    )
    m.concOutConcentrateND     = pyo.Var(initialize = x/1366  , within = pyo.NonNegativeReals, bounds= (10**-6,100)    )
    m.concOutDiluteND          = pyo.Var(initialize = 400/1366   , within = pyo.NonNegativeReals, bounds= (10**-6,100)    )
    m.voltCellPair             = pyo.Var(initialize = 0.5        , within = pyo.NonNegativeReals, bounds= (0,10)          )
    m.resConcentrate           = pyo.Var(initialize = 10**-5     , within = pyo.NonNegativeReals, bounds= (10**-8,1)      )
    m.resDilute                = pyo.Var(initialize = 10**-5     , within = pyo.NonNegativeReals, bounds= (10**-8,1)      )
    m.voltNonOhmicCEM          = pyo.Var(initialize = 10**-2     , within = pyo.NonNegativeReals, bounds= (10**-7,1)      )
    m.voltNonOhmicAEM          = pyo.Var(initialize = 10**-2     , within = pyo.NonNegativeReals, bounds= (10**-7,1)      )
    
