#######################################################################################
# function:     getWaterFluxes()                                                      #
# Desctiption:  Function to compute osmotic, electroosmotic, and total water fluxes   #
#                                                                                     #
# Input:        - m : Pyomo concrete model                                            #
#                                                                                     #
# Output:       - m with osmotic, electroosmotic, and total water fluxes added        #
#                                                                                     #
#######################################################################################

def getWaterFluxes(m):
    
    # Osmotic water flux across both CEM and AEM membranes (unit is m3/m2s)
    m.osmWaterFluxAEM = m.waterPermAEM*m.vantHoffNumber*m.Rg*m.temp*(m.osmoticCoeff*m.avgConcConcIntAEM - m.osmoticCoeff*m.avgConcDilIntAEM)
    m.osmWaterFluxCEM = m.waterPermCEM*m.vantHoffNumber*m.Rg*m.temp*(m.osmoticCoeff*m.avgConcConcIntCEM - m.osmoticCoeff*m.avgConcDilIntCEM)
    
    # Electro-osmotic water flux (unit is m3/m2s)
    m.eosmWaterFlux = m.waterTransNumber*m.fluxIonsTotal*m.molweightH2O/m.densityH2O
    
    # Total water flux (unit is m3/m2s)
    m.fluxWaterTotal = m.osmWaterFluxAEM + m.osmWaterFluxCEM + m.eosmWaterFlux