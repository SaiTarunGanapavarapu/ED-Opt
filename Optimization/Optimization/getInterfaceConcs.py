###############################################################################
# function:     getInterfaceConcs()                                           #
# Desctiption:  Equations to compute limiting current density, interfacical   #
#               concentrations, averages of the interfacial concentrations    #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with interfacial concentrations added as components       #
#                                                                             #
###############################################################################

def getInterfaceConcs(m):
    
    # Average concentration in both concentrate and dilute channels
    m.avgConcConc = 0.5*(m.concOutConcentrateND*m.scaleFacConc + m.concInConcentrate)
    m.avgConcDil  = 0.5*(m.concOutDiluteND     *m.scaleFacConc + m.concInDilute     )
    
    # Limiting current density at 4 Membrane/Channel Interfaces
    m.iLimConcCEM = m.ShConcCEM*m.avgConcConc*m.faraday*m.saltDiffConc/(2*m.thicknessConcentrate*(m.transCEM - m.transIonConc))
    m.iLimDilCEM  = m.ShDilCEM *m.avgConcDil *m.faraday*m.saltDiffDil /(2*m.thicknessDilute     *(m.transCEM - m.transIonConc))
    m.iLimConcAEM = m.ShConcAEM*m.avgConcConc*m.faraday*m.saltDiffConc/(2*m.thicknessConcentrate*(m.transAEM - m.transIonDil ))
    m.iLimDilAEM  = m.ShDilAEM *m.avgConcDil *m.faraday*m.saltDiffDil /(2*m.thicknessDilute     *(m.transAEM - m.transIonDil ))
    
    # Modified inlet concentrations at 4 Membrane/Channel Interfaces
    m.concInConcentrateIntCEM    = m.concInConcentrate   *(1 + m.I/(m.memLength*m.memWidth)/m.iLimConcCEM)
    m.concInDiluteIntCEM         = m.concInDilute        *(1 - m.I/(m.memLength*m.memWidth)/m.iLimDilCEM)
    m.concInConcentrateIntAEM    = m.concInConcentrate   *(1 + m.I/(m.memLength*m.memWidth)/m.iLimConcAEM)
    m.concInDiluteIntAEM         = m.concInDilute        *(1 - m.I/(m.memLength*m.memWidth)/m.iLimDilAEM)
    
    # Modified outlet concentrations at 4 Membrane/Channel Interfaces
    m.concOutConcentrateNDIntCEM = m.concOutConcentrateND*(1 + m.I/(m.memLength*m.memWidth)/m.iLimConcCEM)
    m.concOutDiluteNDIntCEM      = m.concOutDiluteND     *(1 - m.I/(m.memLength*m.memWidth)/m.iLimDilCEM)
    m.concOutConcentrateNDIntAEM = m.concOutConcentrateND*(1 + m.I/(m.memLength*m.memWidth)/m.iLimConcAEM)
    m.concOutDiluteNDIntAEM      = m.concOutDiluteND     *(1 - m.I/(m.memLength*m.memWidth)/m.iLimDilAEM)
    
    # Average Interfacial concentrations at 4 Membrane/Channel Interfaces
    m.avgConcConcIntCEM = 0.5*(m.concOutConcentrateNDIntCEM*m.scaleFacConc + m.concInConcentrateIntCEM)
    m.avgConcDilIntCEM  = 0.5*(m.concOutDiluteNDIntCEM     *m.scaleFacConc + m.concInDiluteIntCEM     )
    m.avgConcConcIntAEM = 0.5*(m.concOutConcentrateNDIntAEM*m.scaleFacConc + m.concInConcentrateIntAEM)
    m.avgConcDilIntAEM  = 0.5*(m.concOutDiluteNDIntAEM     *m.scaleFacConc + m.concInDiluteIntAEM     )
