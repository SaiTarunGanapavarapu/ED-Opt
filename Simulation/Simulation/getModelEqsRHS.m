%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getModelEqsRHS(...)                                        %
% Description: RHS function for differential and algebraic equation       %
%                  system from Campione et al. (2019)                     %
%                                                                         %
% Input:       z             - spacial variable to integrate over         %
%                                  channel length (m)                     %
%              stateVar      - 6 dimensional vector of conentrate stream  %
%                                  concentration (mol/m3), dilute stream  %
%                                  concentration (mol/m3), concentrate    %
%                                  stream volumetric flowrate (m3/hr),    %
%                                  dilute stream volumetric flowrate      %
%                                  (m3/hr), current density (Amps/m2),    %
%                                  total current (Amps)                   %
%              diffVar       - 6 dimensional vector of concentrate stream %
%                                  concentration (mol/m3), dilute stream  %
%                                  concentration (mol/m3), concentrate    %
%                                  stream volumetric flowrate (m3/hr),    %
%                                  dilute stream volumetric flowrate      %
%                                  (m3/hr), current density (Amps/m2),    %
%                                  total current (Amps)                   %
%              algVar        - 1 algebraic variable: cell-pair voltage    %
%                                                                         %
% Output:      RHS           - function value for integrator solver       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [RHS] = getModelEqsRHS(z, stateVar, diffVar, algVar, j)

    % Pre-defining the size of RHS vector
    RHS = zeros(6,1);

    % All state variables
    concConc  = stateVar(1);
    concDil   = stateVar(2);
    flowConc  = stateVar(3);
    flowDil   = stateVar(4);
    currDens  = stateVar(5);
    curr      = stateVar(6);

    % All differential variables
    dconcConc = diffVar(1);
    dconcDil  = diffVar(2);
    dflowConc = diffVar(3);
    dflowDil  = diffVar(4);
    dcurrDens = diffVar(5);
    dcurr     = diffVar(6);

    % All algebraic variables
    voltCellPair      = algVar; 
    
    % Get Params structure and unpack
    params        = getParams()          ;
    memWidth      = params.memWidth(j)   ;     % Membrane Width  (m)
    molWtAmmonia  = params.molWtAmmonia  ;
    densWater     = params.densWater     ;     % Density of Water (kg/m3)

    % Get Interfacial concentrations 
    [concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, ~] = getInterfaceConcs(concConc, concDil, flowConc, flowDil, currDens, j);

    % Get total salt flux
    [~, ~, ~, saltFluxTotal] = getSaltFluxes(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, currDens);
    
    % Get total water flux
    [~, ~, ~, waterFluxTotal] = getWaterFluxes(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, currDens, saltFluxTotal);
    
    % Get total Ohmic resistance and total non-Ohmic Voltage drop
    [resistTotal, nonOhm] = getResistances(concConc, concDil, concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, j);
    
    % Total mass balance on concentrate channel
    RHS(1) = dflowConc - memWidth*waterFluxTotal - memWidth*molWtAmmonia*saltFluxTotal/densWater ;

    % Total mass balance on dilute channel
    RHS(2) = dflowDil + memWidth*waterFluxTotal + memWidth*molWtAmmonia*saltFluxTotal/densWater ;

    % Salt balance on concentrate channel
    % RHS(3) = (dconcConc*flowConc - ( memWidth*saltFluxTotal - concConc*dflowConc));
    RHS(3) = (dconcConc - ( memWidth*saltFluxTotal - concConc*dflowConc)/flowConc);

    % Salt balance on concentrate channel
    % RHS(4) = (dconcDil*flowDil - (-memWidth*saltFluxTotal - concDil*dflowDil));
    RHS(4) = (dconcDil - (-memWidth*saltFluxTotal - concDil*dflowDil)/flowDil);

    % Algebraic equation to compute cell-pair voltage
    RHS(5) = voltCellPair - nonOhm - resistTotal*currDens;

    % Computation of total current from current density (i(x))
    RHS(6) = dcurr - currDens*memWidth;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
