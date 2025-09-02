%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getInterfaceConcs(...)                                     %
%                                                                         %
% Description: Compute interfacial concentrations from bulk phase values  %
%                                                                         %
% Inputs:      concConc - Bulk phase concentration of concentrate channel %
%              concDil  - Bulk phase concentration of dilute      channel %
%              flowConc - Flowrate in the concentrate channel             %
%              flowDil  - Flowrate in the concentrate channel             %
%              currDens - Current density                                 %
%                                                                         %
% Outputs:     concConcIntCEM - Conc, CEM interfacical concentration      %
%              concConcIntAEM - Conc, AEM interfacical concentration      %
%              concDilIntCEM  - Dil , CEM interfacical concentration      %
%              concDilIntAEM  - Dil , AEM interfacical concentration      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, iLim] = getInterfaceConcs(concConc, concDil, flowConc, flowDil, currDens, j)

    % Get Params structure from the getParams function
    params        = getParams();

    % Unpack parameters
    F             = params.F                ;     % Fardays constant (C/mol)
    transCEM      = params.transCEM         ;     % Transport number of counter ion in CEM 
    transAEM      = params.transAEM         ;     % Transport number of counter ion in AEM 
    transNH4      = params.transNH4         ;     % Transport number of NH4+ in fluid channel 
    transCl       = params.transCl          ;     % Transport number of Cl-  in fluid channel 
    diffConc      = params.diffConc         ;     % Diffusivity coefficient of ions in concentrate channel (m2/s)
    diffDil       = params.diffDil          ;     % Diffusivity coefficient of ions in dilute      channel (m2/s)    
    equivDiaConc  = params.equivDiaConc(j)  ;     % Equivalent diameter of concentrate channel (m)
    equivDiaDil   = params.equivDiaDil (j)  ;     % Equivalent diameter of dilute      channel (m)
    toggleIntConc = params.toggleIntConc    ;     % Boolean to turn off the interfacial concentration computations (Concentration Polarization)

    % Get Sherwood numbers
    [~, ~, ~, ~, ~, ~, ShConcCEM, ShConcAEM, ShDilCEM, ShDilAEM] = getDimLessNumbers(flowConc, flowDil, j);
    
    % Compute limiting current densties (A/m2)
    iLimConcCEM  = ShConcCEM*concConc*F*diffConc/equivDiaConc/(transCEM - transNH4) ;  
    iLimConcAEM  = ShConcAEM*concConc*F*diffConc/equivDiaConc/(transAEM - transCl ) ;
    iLimDilCEM   = ShDilCEM *concDil *F*diffDil /equivDiaDil /(transCEM - transNH4) ;
    iLimDilAEM   = ShDilAEM *concDil *F*diffDil /equivDiaDil /(transAEM - transCl ) ;

    iLim = [iLimConcCEM; iLimConcAEM; iLimDilCEM; iLimDilAEM];
    
    % Compute Interfacial concentration (mol/m^3)
    concConcIntCEM = concConc*(1 + currDens/iLimConcCEM) ; 
    concConcIntAEM = concConc*(1 + currDens/iLimConcAEM) ; 
    concDilIntCEM  = concDil *(1 - currDens/iLimDilCEM ) ; 
    concDilIntAEM  = concDil *(1 - currDens/iLimDilAEM ) ;

    % toggle to turn off the interfacial concentration computations
    if toggleIntConc == 0
        concConcIntCEM = concConc;
        concConcIntAEM = concConc;
        concDilIntCEM  = concDil;
        concDilIntAEM  = concDil;
    end
    

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 