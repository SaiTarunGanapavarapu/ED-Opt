%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getSaltFluxes(...)                                         %
%                                                                         %
% Description: Function to compute salt fluxes                            %   
%                                                                         %
% Inputs:      concConcIntCEM - Interfacial concentration (Conc/CEM)      %
%              concConcIntAEM - Interfacial concentration (Conc/AEM)      %
%              concDilIntCEM  - Interfacial concentration (Dil /CEM)      %
%              concDilIntAEM  - Interfacial concentration (Dil /AEM)      %
%              currDens       - Current density                           %
%                                                                         %
% Outputs:     condFlux      - Migration flux                             %
%              diffFluxCEM   - Diffusive salt flux across CEM             %
%              diffFluxAEM   - Diffusive salt flux across AEM             %
%              saltFluxTotal -  Total salt flux                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [condFlux, diffFluxCEM, diffFluxAEM, saltFluxTotal] = getSaltFluxes(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, currDens)

    % Get Params structure from the getParams function
    params        = getParams();
    
    F             = params.F             ;     % Fardays constant (C/mol)
    transCEM      = params.transCEM      ;     % Transport number of counter ion in CEM 
    transAEM      = params.transAEM      ;     % Transport number of counter ion in AEM 
    diffCEM       = params.diffCEM       ;     % Diffusivity coefficient of ions in AEM (m2/s) 
    diffAEM       = params.diffAEM       ;     % Diffusivity coefficient of ions in CEM (m2/s)
    thicknessCEM  = params.thicknessCEM  ;     % Thickness of CEM (m)
    thicknessAEM  = params.thicknessAEM  ;     % Thickness of AEM (m)
 

    % Migration flux (mol/m2 hr)
    condFlux      = (transCEM - (1 - transAEM))*currDens/F*3600;   
    
    % Diffusive salt flux across AEM & CEM and total (mol/m2 hr)
    diffFluxCEM   = -diffCEM/thicknessAEM *(concConcIntCEM - concDilIntCEM)*3600;
    diffFluxAEM   = -diffAEM/thicknessCEM*(concConcIntAEM - concDilIntAEM)*3600;  
    
    diffFluxTotal   = diffFluxAEM + diffFluxCEM;
    
    % Total salt flux 
    saltFluxTotal = (diffFluxTotal + condFlux);  % unit is mol/m2.hr

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 