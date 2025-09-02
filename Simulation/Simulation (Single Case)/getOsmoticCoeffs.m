%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getOsmoticCoeffs(...)                                      %
%                                                                         %
% Description: Function to compute osmotic coefficients                   %   
%                                                                         %
% Inputs:      concConcIntCEM - Interfacial concentration (Conc/CEM)      %
%              concConcIntAEM - Interfacial concentration (Conc/AEM)      %
%              concDilIntCEM  - Interfacial concentration (Dil /CEM)      %
%              concDilIntAEM  - Interfacial concentration (Dil /AEM)      %
%                                                                         %
% Outputs:     osmConcCEM - Osmotic coefficient at CEM/Conc interface     %
%              osmConcAEM - Osmotic coefficient at AEM/Conc interface     %
%              osmDilCEM  - Osmotic coefficient at CEM/Dil  interface     %
%              osmDilAEM  - Osmotic coefficient at AEM/Dil  interface     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [osmConcCEM, osmConcAEM, osmDilCEM, osmDilAEM] = getOsmoticCoeffs(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM)

    % Get Params structure from the getParams function
    params        = getParams();

    % Unpack parameters
    % Constants for Osmotic coefficient correlation  
    alpha         = params.alpha            ;   
    beta0         = params.beta0            ;
    beta1         = params.beta1            ;
    CPhi          = params.CPhi             ;
    bPrime        = params.bPrime           ;
    DebHuck       = params.DebHuck          ; % Debye-Huckel Constant
    toggleOsm     = params.toggleOsm        ; % Boolean to turn off the osmotic coefficient correlations
    

    % Compute molality from interface concentrations
    molalityConcCEM = concConcIntCEM/1000; 
    molalityConcAEM = concConcIntAEM/1000;
    molalityDilCEM  = concDilIntCEM /1000; 
    molalityDilAEM  = concDilIntAEM /1000; 
    
    % Intermediate constants for final correlation
    BphiConcCEM = beta0 + beta1*exp(-alpha)*molalityConcCEM^(1/2); 
    BphiConcAEM = beta0 + beta1*exp(-alpha)*molalityConcAEM^(1/2); 
    BphiDilCEM  = beta0 + beta1*exp(-alpha)*molalityDilCEM ^(1/2); 
    BphiDilAEM  = beta0 + beta1*exp(-alpha)*molalityDilAEM ^(1/2); 
    
    % Final correlation to compute osmotic coefficients
    osmConcCEM = 1 - DebHuck*(molalityConcCEM^(1/2)/(1 + bPrime*molalityConcCEM^(1/2))) + molalityConcCEM*BphiConcCEM + molalityConcCEM^2*CPhi; 
    osmConcAEM = 1 - DebHuck*(molalityConcAEM^(1/2)/(1 + bPrime*molalityConcAEM^(1/2))) + molalityConcAEM*BphiConcAEM + molalityConcAEM^2*CPhi; 
    osmDilCEM  = 1 - DebHuck*(molalityDilCEM^(1/2) /(1 + bPrime*molalityDilCEM^(1/2) )) + molalityDilCEM* BphiDilCEM  + molalityDilCEM^2*CPhi ;
    osmDilAEM  = 1 - DebHuck*(molalityDilAEM^(1/2) /(1 + bPrime*molalityDilAEM^(1/2) )) + molalityDilAEM* BphiDilAEM  + molalityDilAEM^2*CPhi ;

    % Using toggle to turn off the osmotic coefficient correlations
    if toggleOsm == 0
        osmConcCEM = 1;
        osmConcAEM = 1;
        osmDilCEM  = 1;
        osmDilAEM  = 1;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 