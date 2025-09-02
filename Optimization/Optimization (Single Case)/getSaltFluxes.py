###############################################################################
# function:     getSaltFluxes()                                               #
# Desctiption:  Function to compute molar, diffusive, and total salt fluxes   #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with molar, diffusive and total salt fluxes added         #
#                                                                             #
###############################################################################

def getSaltFluxes(m):
    
    # Conductive flux of ions (unit is mol/m2s)
    m.condFlux = (m.transCEM - (1 - m.transAEM))*(m.I/(m.memLength*m.memWidth*m.faraday))
    
    # Diffusive flux of ions across both CEM and AEM membranes (unit is mol/m2s)
    m.diffFluxAEM = -(m.saltDiffAEM/m.thicknessAEM)*(m.avgConcConcIntAEM - m.avgConcDilIntAEM)
    m.diffFluxCEM = -(m.saltDiffCEM/m.thicknessCEM)*(m.avgConcConcIntCEM - m.avgConcDilIntCEM)
    
    # total flux of ions (unit is mol/m2s)
    m.fluxIonsTotal = m.condFlux + m.diffFluxAEM + m.diffFluxCEM