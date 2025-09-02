###############################################################################
# function:     getParams()                                                   #
# Desctiption:  Function to load all the parameters in the ED model           #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - m with all parameters                                       #
#                                                                             #
###############################################################################
import pyomo.environ as pyo

def getParams(m):
    
     m.numCells            = pyo.Param(initialize = 500)                       # Number of cell pairs in a single-ED unit
     m.daysOperation       = pyo.Param(initialize = 7*365)                     # Overall days of operation (7 years)
     m.Rg                  = pyo.Param(initialize = 8.314)                     # Gas Constant     (J/mol K)
     m.temp                = pyo.Param(initialize = 273.15 + 25)               # Temperature (K)
     m.faraday             = pyo.Param(initialize = 96485.3321)                # Fardays constant (C/mol)
     m.molweightN          = pyo.Param(initialize = 14.0067)                   # Molecular weight of Nitrogen (g/mol)
     m.molweightNH4Cl      = pyo.Param(initialize = 53.491)                    # Molecular weight of Ammonia (g/mol)
     m.flowIn              = pyo.Param(initialize = 192555/(1000*24*60*60))    # Inlet flowrate to the ED unit (m3/hr)
     m.concIn              = pyo.Param(initialize = 0.1366*10**4/m.molweightN) # Inlet concentration to the ED unit (mol/m3)
     m.concInConcentrate   = pyo.Param(initialize = m.concIn)                  # Inlet concentration to the concentrate channel (mol/m3)
     m.concInDilute        = pyo.Param(initialize = m.concIn)                  # Inlet concentration to the dilute      channel (mol/m3)
     m.thicknessCEM        = pyo.Param(initialize = 0.00011)                   # Thickness of CEM (m)
     m.thicknessAEM        = pyo.Param(initialize = 0.000105)                  # Thickness of AEM (m)
     m.permSelCEM          = pyo.Param(initialize = 0.9)                       # Permselectivity of CEM (m)
     m.permSelAEM          = pyo.Param(initialize = 0.9)                       # Permselectivity of AEM (m)
     m.transCEM            = pyo.Param(initialize = 0.95)                      # Transport number of counter ion in CEM
     m.transAEM            = pyo.Param(initialize = 0.95)                      # Transport number of counter ion in AEM
     m.transIonConc        = pyo.Param(initialize = 0.491)                     # Transport number of NH4+ in fluid channel
     m.transIonDil         = pyo.Param(initialize = 0.509)                     # Transport number of Cl-  in fluid channel
     m.saltDiffCEM         = pyo.Param(initialize = 10**-12)                   # Diffusivity coefficient of ions in CEM (m2/s)
     m.saltDiffAEM         = pyo.Param(initialize = 10**-12)                   # Diffusivity coefficient of ions in AEM (m2/s)
     m.saltDiffConc        = pyo.Param(initialize = 1.84*10**-9)               # Diffusivity coefficient of ions in concentrate channel (m2/s)
     m.saltDiffDil         = pyo.Param(initialize = 1.84*10**-9)               # Diffusivity coefficient of ions in dilute      channel (m2/s)
     m.waterPermCEM        = pyo.Param(initialize = 7.79*(10**-11)/3600)       # Water permeability constant in CEM (m3/m2 s Pa)
     m.waterPermAEM        = pyo.Param(initialize = 6.29*(10**-11)/3600)       # Water permeability constant in AEM (m3/m2 s Pa)
     m.vantHoffNumber      = pyo.Param(initialize = 2)                         # Van Hoff't coefficient (2 for NH4Cl)
     m.molweightH2O        = pyo.Param(initialize = 0.018)                     # Molecular weight of Water (kg/mol)
     m.densityH2O          = pyo.Param(initialize = 1000)                      # Density of Water (kg/m3)
     m.densityManure       = pyo.Param(initialize = 1000)                      # Density of Manure (Pa-s)
     m.viscosityManure     = pyo.Param(initialize = 1*10**-3)                  # Viscosity of Water (Pa-s)
     m.waterTransNumber    = pyo.Param(initialize = 6+8)                       # Water transport number (NH4+ = 6, Cl- = 8)  
     m.osmoticCoeff        = pyo.Param(initialize = 1)                         # Osmotic Coefficient of both concentrate and dilute streams
     m.resBlank            = pyo.Param(initialize = 2.5*10**-5)                # Blank or open-circuit resistance (ohm m2)
     m.resCEM              = pyo.Param(initialize = 2.5*10**-4)                # Resistance of CEM (ohm m2)
     m.resAEM              = pyo.Param(initialize = 1.8*10**-4)                # Resistance of AEM (ohm m2)
     m.conducConcentrate   = pyo.Param(initialize = 149.6*10**-4)              # Equivalent conductivity of Concentrate Stream (S m2/mol)
     m.conducDilute        = pyo.Param(initialize = 149.6*10**-4)              # Equivalent conductivity of Dilute      Stream (S m2/mol)
     m.costElec            = pyo.Param(initialize = 0.08147)                   # Cost of electricity ($/kWh)
     
     
     
     
     
        