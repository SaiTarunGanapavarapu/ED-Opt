###############################################################################
# function:     getResistances()                                              #
# Desctiption:  Function to compute ohmic, nonohmic resistances               #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with ohmic, nonohmic, totalOhmic, and totalNonOhmic       #
#                 resistances added as components                             #
#                                                                             #
###############################################################################
import pyomo.environ as pyo


def getResistances(m):
    
    # Constraint to add the equation of resistance in the concentrate channel
    def resConc(m):
        return m.resConcentrate*m.conducConcentrate*m.avgConcConc - m.thicknessConcentrate == 0
    m.resConc = pyo.Constraint(rule = resConc)
    
    # Constraint to add the equation of resistance in the dilute channel
    def resDil(m):
        return m.resDilute*m.conducDilute*m.avgConcDil - m.thicknessDilute == 0
    m.resDil = pyo.Constraint(rule = resDil)
    
    
    # Constraint to add the equation of Donnan potential in the CEM
    def voltNonOhmicCEMConstraint(m):
        return pyo.exp(m.voltNonOhmicCEM*m.faraday/(m.permSelCEM*m.Rg*m.temp))*m.avgConcDilIntCEM - m.avgConcConcIntCEM == 0
    m.voltNonOhmicCEMConstraint = pyo.Constraint(rule = voltNonOhmicCEMConstraint)
    
    # Constraint to add the equation of Donnan potential in the CEM
    def voltNonOhmicAEMConstraint(m):
        return pyo.exp(m.voltNonOhmicAEM*m.faraday/(m.permSelAEM*m.Rg*m.temp))*m.avgConcDilIntAEM - m.avgConcConcIntAEM == 0
    m.voltNonOhmicAEMConstraint = pyo.Constraint(rule = voltNonOhmicAEMConstraint)
    
    # Total Ohmic resistance
    m.resOhmic = m.resConcentrate + m.resDilute + m.resCEM + m.resAEM
    
    # Total Nonohmic resistance (Donnan Potential)
    m.voltNonOhmic = m.voltNonOhmicCEM + m.voltNonOhmicAEM