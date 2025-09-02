###############################################################################
# function:     solverUtils()                                                 #
# Desctiption:  Function to load the pyomo solver, solve the problem and      #
#               read the results from the solved model (m)                    #
#                                                                             #
# Input:        - m : Pyomo concrete model                                    #
#                                                                             #
# Output:       - solver, results, result                                     #
#                                                                             #
###############################################################################
import pyomo.environ as pyo


# Define solver to solve the optimization problem
def getSolver(solverName, tol):
    if solverName.lower() == 'ipopt':
        solver = pyo.SolverFactory('ipopt', options={'tol': tol, 'constr_viol_tol': 0.1*tol})
    elif solverName.lower() == 'baron':
        solver = pyo.SolverFactory('baron', options={'MaxTime': 50, 'EpsA': 100*tol, 'AbsConFeasTol': 1*tol, 'TDo':1}, executable = r'C:\baron\baron.exe')
    return solver

###############################################################################


# Define solve statement
def solveM(m, solver):
    results = solver.solve(m, tee = True)
    return results

###############################################################################


# Define function to extract the solution from the solved m
def getSolution(m, results):
    
    result = {}
  
    result['memLength']                  = pyo.value(m.memLength)
    result['memWidth']                   = pyo.value(m.memWidth)
    result['memArea']                    = pyo.value(m.memLength)*pyo.value(m.memWidth)*m.numCells
    result['currDens']                   = pyo.value(m.I)/(pyo.value(m.memLength)*pyo.value(m.memWidth))
    result['curr']                       = pyo.value(m.I)
    result['flowSplit']                  = pyo.value(m.flowSplit)
    result['thicknessConcentrate']       = pyo.value(m.thicknessConcentrate)
    result['thicknessDilute']            = pyo.value(m.thicknessDilute)
    result['concOutConcentrate']         = pyo.value(m.concOutConcentrateND)*m.scaleFacConc*m.molweightN/10**4
    result['concOutDilute']              = pyo.value(m.concOutDiluteND)*m.scaleFacConc*m.molweightN/10**4
    result['concOutConcentrateIntCEM']   = pyo.value(m.concOutConcentrateNDIntCEM)*m.scaleFacConc*m.molweightN/10**4
    result['concOutDiluteIntCEM']        = pyo.value(m.concOutDiluteNDIntCEM)*m.scaleFacConc*m.molweightN/10**4
    result['concOutConcentrateIntAEM']   = pyo.value(m.concOutConcentrateNDIntAEM)*m.scaleFacConc*m.molweightN/10**4
    result['concOutDiluteIntAEM']        = pyo.value(m.concOutDiluteNDIntAEM)*m.scaleFacConc*m.molweightN/10**4
    result['flowInConcentrate']          = pyo.value(m.flowInConcentrate)*(1000*24*60*60)*m.numCells
    result['flowInDilute']               = pyo.value(m.flowInDilute)*(1000*24*60*60)*m.numCells
    result['flowOutConcentrate']         = pyo.value(m.flowOutConcentrateND)*m.scaleFacFlow*m.numCells*1000*24*60*60
    result['flowOutDilute']              = pyo.value(m.flowOutDiluteND)*m.scaleFacFlow*m.numCells*1000*24*60*60
    result['voltCellPair']               = pyo.value(m.voltCellPair)
    result['voltTotal']                  = m.resBlank*pyo.value(m.I) +  pyo.value(m.voltCellPair)*m.numCells
    result['tonsNTotal']                 = pyo.value(m.tonsNTotal)
    result['recovery']                   = pyo.value(m.tonsperDay) * 1000*100/(m.flowIn*(1000*24*60*60)*m.concIn*m.molweightN*(10**(-6)))
    result['capex1']                     = pyo.value(m.capex1)/ result['tonsNTotal']
    result['capex2']                     = pyo.value(m.capex2)/ result['tonsNTotal']
    result['capex']                      = result['capex1'] + result['capex2']
    result['opex1']                      = pyo.value(m.opex1)/ result['tonsNTotal']
    result['opex2']                      = pyo.value(m.opex2)/ result['tonsNTotal']
    result['opex']                       = result['opex1'] + result['opex2']
    result['totalCost']                  = result['capex'] + result['opex']
    result['voltTotal']                  = m.resBlank*pyo.value(m.I) +  pyo.value(m.voltCellPair)*m.numCells
    result['optTotalCost']               = pyo.value(m.obj)
    result['osmFlux']                    = pyo.value(m.osmWaterFluxAEM + m.osmWaterFluxCEM)*m.numCells*m.densityH2O*pyo.value(m.memLength)*pyo.value(m.memWidth)
    result['eosmWaterFlux']              = pyo.value(m.eosmWaterFlux)*m.numCells*m.densityH2O*pyo.value(m.memLength)*pyo.value(m.memWidth)
    result['optimalNode']                = results.Problem[0]["Node opt"]
    result['totPower']                   = pyo.value(m.I)*(m.resBlank*pyo.value(m.I) +  pyo.value(m.voltCellPair)*m.numCells) + m.numCells*pyo.value((m.presDrop1*((m.flowOutConcentrateND*m.scaleFacFlow + m.flowInConcentrate)/2) + m.presDrop2*((m.flowOutDiluteND*m.scaleFacFlow + m.flowInDilute)/2)))
    result['SEC']                        = (pyo.value(m.I)*(m.resBlank*pyo.value(m.I) +  pyo.value(m.voltCellPair)*m.numCells) + m.numCells*pyo.value((m.presDrop1*((m.flowOutConcentrateND*m.scaleFacFlow + m.flowInConcentrate)/2) + m.presDrop2*((m.flowOutDiluteND*m.scaleFacFlow + m.flowInDilute)/2))))*24*0.001/(result['tonsNTotal']*1000)    

    return result