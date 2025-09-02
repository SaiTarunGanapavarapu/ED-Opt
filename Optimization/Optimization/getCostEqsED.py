###############################################################################
# function:     getCostEqsED()                                                #
# Desctiption:  Function to compute all components of costs incurred in a     #
#               electrodialysis process (ED)                                  #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with cost equations added as components                   #
#                                                                             #
###############################################################################

import pyomo.environ as pyo

def getCostEqsED(m):
    
    
    # Capital cost of electrodes and specialized membranes 
    m.capex1 = (6800*m.memLength*m.memWidth)
    
    # Capital cost of standard ,=membranes in all cell pairs
    m.capex2 = (2*100*(m.numCells - 2)*m.memLength*m.memWidth) 
    
    # Total Capital cost
    m.capex =  m.capex1 + m.capex2
    
    ###############################################################################
    
    # Opex - Electricity
    # Defining total voltage
    voltBlank   = m.resBlank*m.I/(m.memLength*m.memWidth)
    m.voltTotal = voltBlank + m.numCells*m.voltCellPair
    
    # Operating Cost 1 - Electrical cost of operting the cell
    m.opex1 = m.costElec*(24*10**-3)*m.voltTotal*m.I*m.daysOperation
    
    ###############################################################################
    
    # Opex - Pressure Drop
    
    # Friction factor in concentrate channel
    m.fConc = 1400/m.ReConc
    
    # Pressure drop in the concentrate channel
    m.presDrop1 = m.densityManure*m.fConc*m.memLength*m.uConc**2/(4*m.thicknessConcentrate)   # Pressure drop of the stream in concentrate channel
    
    # Friction factor in the dilute channel
    m.fDil = 104.5/m.ReDil**0.37
    
    # Pressure drop in the dilute channel
    m.presDrop2 = m.densityManure*m.fDil*m.memLength*m.uDil**2/(4*m.thicknessDilute)   # Pressure drop of the stream in Dilute channel 
    
    # Operating cost 2 - Electrical cost of pumping the fluid
    m.opex2 = m.costElec*(24*10**-3)*(m.presDrop1*((m.flowOutConcentrateND*m.scaleFacFlow + m.flowInConcentrate)/2) + m.presDrop2*((m.flowOutDiluteND*m.scaleFacFlow + m.flowInDilute)/2))*m.numCells*m.daysOperation
    
    ###############################################################################
    
    # Total tons of product produced over the course of operating period
    m.tonsNTotal = (m.concOutConcentrateND*m.scaleFacConc*m.flowOutConcentrateND*m.scaleFacFlow*m.numCells*m.molweightN*(10**-6)*7*365*86400)
    
    # Tons of the product produced per day
    m.tonsperDay = (m.concOutConcentrateND*m.scaleFacConc*m.flowOutConcentrateND*m.scaleFacFlow*m.numCells*m.molweightN*(10**-6)*86400)
    
    ###############################################################################
    
    # Declaring the objective function to the optimizer (Cost normalized by total product produced)
    m.obj = pyo.Objective(rule = (m.capex + m.opex1 + m.opex2)/m.tonsNTotal)   
    