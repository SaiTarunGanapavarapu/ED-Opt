###############################################################################
# function:     getDimLessNumbers()                                           #
# Desctiption:  Equations to compute velocity, Reynolds Number, Schmidt       #
#               Number in both concentrate and dilute channels                #
#               Sherwood Numbers at (CEM/Concentrate), (AEM/Concentrate),     #
#               (CEM/Dilute), and (AEM/Dilute) interfaces                     #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with Dimension-less numbers added as components           #
#                                                                             #
###############################################################################

def getDimLessNumbers(m): 
        
    # Velocity of the streams in concentrate and dilute channels
    m.uConc  = 0.5*(m.flowOutConcentrateND*m.scaleFacFlow + m.flowInConcentrate)/(m.memWidth*m.thicknessConcentrate)   
    m.uDil   = 0.5*(m.flowOutDiluteND*m.scaleFacFlow + m.flowInDilute)/(m.memWidth*m.thicknessDilute)  
    
    # Reynolds Numbers of the streams in concentrate and dilute channels
    m.ReConc = m.densityManure*m.uConc*(2*m.thicknessConcentrate)/m.viscosityManure       
    m.ReDil  = m.densityManure*m.uDil*(2*m.thicknessDilute)/m.viscosityManure   
    
    # Schmidt Numbers of the streams in concentrate and dilute channels
    m.ScConc = m.viscosityManure/(m.densityManure*m.saltDiffConc)
    m.ScDil  = m.viscosityManure/(m.densityManure*m.saltDiffDil )
    
    # Sherwood number of 4 Membrane/Channel Interfaces
    m.ShConcCEM = 0.29*(m.ReConc**0.5)*(m.ScConc**0.33)
    m.ShDilCEM  = 0.29*(m.ReDil **0.5)*(m.ScDil **0.33)
    m.ShConcAEM = 0.29*(m.ReConc**0.5)*(m.ScConc**0.33)
    m.ShDilAEM  = 0.29*(m.ReDil **0.5)*(m.ScDil **0.33)
    