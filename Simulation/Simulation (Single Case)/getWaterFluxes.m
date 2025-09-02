%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getWaterFluxes(...)                                        %
%                                                                         %
% Description: Function to compute water fluxes                           %   
%                                                                         %
% Inputs:      concConcIntCEM - Interfacial concentration (Conc/CEM)      %
%              concConcIntAEM - Interfacial concentration (Conc/AEM)      %
%              concDilIntCEM  - Interfacial concentration (Dil /CEM)      %
%              concDilIntAEM  - Interfacial concentration (Dil /AEM)      %
%              currDens       - Current density                           %
%                                                                         %
% Outputs:     eosmWaterFlux   - Electro-osmotic Water flux               %
%              osmWaterFluxCEM - Osmotic Water flux across CEM            %
%              osmWaterFluxAEM - Osmotic Water flux across AEM            %
%              waterFluxTotal  - Total Water flux                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eosmWaterFlux, osmWaterFluxAEM, osmWaterFluxCEM, waterFluxTotal] = getWaterFluxes(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, currDens, saltFluxTotal)

    % Get Params structure from the getParams function
    params        = getParams();

    waterTrans    = params.waterTrans    ;     % Water transport number (NH4+ = 6, Cl- = 8)  
    molWtWater    = params.molWtWater    ;     % Molecular weight of Water (kg/mol)
    densWater     = params.densWater     ;     % Density of Water (kg/m3)
    waterPermCEM  = params.waterPermCEM  ;     % Water permeability constant in CEM (m3/bar h2 m2) 
    waterPermAEM  = params.waterPermAEM  ;     % Water permeability constant in AEM (m3/bar h2 m2) 
    vantHoffCoeff = params.vantHoffCoeff ;     % Van Hoff't coefficient (2 for NH4Cl)
    temp          = params.temp          ;     % Temperature (K)
    RinBar        = params.RinBar        ;     % Gas Constant     (m3 bar/mol K)
    

    % Get osmotic coefficients
    [osmConcCEM, osmConcAEM, osmDilCEM, osmDilAEM] = getOsmoticCoeffs(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM);
    
    % Electro-osmotic Water flux (m3/m2 hr)
    eosmWaterFlux   = waterTrans*saltFluxTotal*molWtWater/densWater;  
    
    % Osmotic Water flux across AEM & CEM (m3/m2 hr)
    osmWaterFluxCEM  = waterPermCEM*vantHoffCoeff*temp*RinBar*(osmConcCEM*concConcIntCEM - osmDilAEM*concDilIntCEM);  
    osmWaterFluxAEM  = waterPermAEM*vantHoffCoeff*temp*RinBar*(osmConcAEM*concConcIntAEM - osmDilCEM*concDilIntAEM);  

    
    % Total Water flux (m3/m2 hr)
    waterFluxTotal  = eosmWaterFlux + osmWaterFluxAEM + osmWaterFluxCEM;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 