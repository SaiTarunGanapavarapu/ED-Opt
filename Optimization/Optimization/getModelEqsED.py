###############################################################################
# function:     getModelEqsED()                                               #
# Desctiption:  Function to define ED model equations                         #
#               Material balances, component balances, voltage algebraic eq   #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with all model equations                                  #
#                                                                             #
###############################################################################

import pyomo.environ as pyo
from getDimLessNumbers import getDimLessNumbers
from getInterfaceConcs import getInterfaceConcs
from getSaltFluxes import getSaltFluxes
from getWaterFluxes import getWaterFluxes
from getResistances import getResistances

###############################################################################


def getModelEqsED(m):
    
    # Modifying inlet flowrate with the flowSplit variable
    m.flowInConcentrate    = pyo.Expression(expr = m.flowSplit*m.flowIn/m.numCells)
    m.flowInDilute         = pyo.Expression(expr = (1 - m.flowSplit)*m.flowIn/m.numCells)
    
    # Scaling factors for better numerical convergences
    m.scaleFacFlow = 192555/(1000*24*60*60)/m.numCells
    m.scaleFacConc = 1366/m.molweightN
    
    
    # Get the dimensional less numbers from the function
    getDimLessNumbers(m)
    
    # Get interfacial concentrations and their averages
    getInterfaceConcs(m)
    
    # Get salt fluxes
    getSaltFluxes(m)
    
    # Get water fluxes
    getWaterFluxes(m)
    
    # Get Resistances
    getResistances(m) 
    
    def constraint1(m):        # mass balance of the concentrate channel
        return m.flowOutConcentrateND - (m.flowInConcentrate/m.scaleFacFlow) - (m.fluxWaterTotal*m.memLength*m.memWidth/m.scaleFacFlow) - ((m.molweightNH4Cl*0.001/m.densityH2O)*m.fluxIonsTotal*m.memLength*m.memWidth/m.scaleFacFlow) == 0
    m.constraint1 = pyo.Constraint(rule = constraint1)
    
    def constraint2(m):        # mass balance of the dilute channel        
        return m.flowOutDiluteND - (m.flowInDilute/m.scaleFacFlow) + (m.fluxWaterTotal*m.memLength*m.memWidth/m.scaleFacFlow) + ((m.molweightNH4Cl*0.001/m.densityH2O)*m.fluxIonsTotal*m.memLength*m.memWidth/m.scaleFacFlow) == 0
    m.constraint2 = pyo.Constraint(rule = constraint2)
    
    def constraint3(m):        # component balance of concentrate channel        
        return (m.flowOutConcentrateND*m.concOutConcentrateND) - (m.flowInConcentrate*m.concInConcentrate)/(m.scaleFacFlow*m.scaleFacConc) - m.fluxIonsTotal*m.memLength*m.memWidth/(m.scaleFacFlow*m.scaleFacConc) == 0
    m.constraint3 = pyo.Constraint(rule = constraint3)
    
    def constraint4(m):        # component balance of dilute channel        
        return (m.flowOutDiluteND*m.concOutDiluteND) - (m.flowInDilute*m.concInDilute)/(m.scaleFacFlow*m.scaleFacConc) + m.fluxIonsTotal*m.memLength*m.memWidth/(m.scaleFacFlow*m.scaleFacConc) == 0
    m.constraint4 = pyo.Constraint(rule = constraint4)
    
    def constraint5(m):        # Electrical equation for a single cell pair        
        return m.voltCellPair - m.voltNonOhmic - m.resOhmic*(m.I/(m.memLength*m.memWidth)) == 0
    m.constraint5 = pyo.Constraint(rule = constraint5)
     
    def constraint6(m):        # concentration target of the Dilute        
        return m.concOutDiluteND - 0.04*10**4/(m.scaleFacConc*m.molweightN) == 0
    m.constraint6 = pyo.Constraint(rule = constraint6)
    
    def constraint7(m):        # concentration target of the concentrate        
        return m.concOutConcentrateND - 3*10**4/(m.scaleFacConc*m.molweightN) == 0
    m.constraint7 = pyo.Constraint(rule = constraint7)
    
    def constraint8(m):        # Current density should be less than limiting current density         
       return m.I/(m.memLength*m.memWidth*m.iLimDilCEM) - 1 <= 0
    m.constraint8 = pyo.Constraint(rule = constraint8)
    
    
    