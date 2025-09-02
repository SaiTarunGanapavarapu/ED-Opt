%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getActivityCoeffs(...)                                     %
%                                                                         %
% Description: Function to compute activity coefficients                  %   
%                                                                         %
% Inputs:      concConcIntCEM - Interfacial concentration (Conc/CEM)      %
%              concConcIntAEM - Interfacial concentration (Conc/AEM)      %
%              concDilIntCEM  - Interfacial concentration (Dil /CEM)      %
%              concDilIntAEM  - Interfacial concentration (Dil /AEM)      %
%                                                                         %
% Outputs:     activCoeffConcCEM - Activity coefficient (Conc/CEM)        %
%              activCoeffConcAEM - Activity coefficient (Conc/AEM)        %
%              activCoeffDilCEM  - Activity coefficient (Dil /CEM)        % 
%              activCoeffDilAEM  - Activity coefficient (Dil /AEM)        %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [activCoeffConcCEM, activCoeffConcAEM, activCoeffDilCEM, activCoeffDilAEM] = getActivityCoeffs(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM)

    % Get Params structure from the getParams function
    params        = getParams();

    % Unpack parameters
    alpha         = params.alpha            ;   
    beta0         = params.beta0            ;
    beta1         = params.beta1            ;
    CPhi          = params.CPhi             ;    
    alpha         = params.alpha            ;
    bPrime        = params.bPrime           ;
    DebHuck       = params.DebHuck          ; % Debye-Huckel Constant
    toggleAct     = params.toggleAct        ; % Boolean to turn off the activity coefficient correlations

    % Compute molality from interface concentrations
    molalityConcCEM = concConcIntCEM/1000; 
    molalityConcAEM = concConcIntAEM/1000;
    molalityDilCEM  = concDilIntCEM /1000; 
    molalityDilAEM  = concDilIntAEM /1000; 
    
    % Intermediate constants for final correlation
    BConcCEM = 2*beta0 + 2*beta1*(1 - (1 + alpha*molalityConcCEM^(1/2) - molalityConcCEM/2*alpha^2)*exp(-alpha*molalityConcCEM^(1/2)))/(molalityConcCEM*alpha^2);
    BConcAEM = 2*beta0 + 2*beta1*(1 - (1 + alpha*molalityConcAEM^(1/2) - molalityConcAEM/2*alpha^2)*exp(-alpha*molalityConcAEM^(1/2)))/(molalityConcAEM*alpha^2);
    BDilCEM  = 2*beta0 + 2*beta1*(1 - (1 + alpha*molalityDilCEM^(1/2)  - molalityDilCEM/2*alpha^2) *exp(-alpha*molalityDilCEM^(1/2))) /(molalityDilCEM*alpha^2 );
    BDilAEM  = 2*beta0 + 2*beta1*(1 - (1 + alpha*molalityDilAEM^(1/2)  - molalityDilAEM/2*alpha^2) *exp(-alpha*molalityDilAEM^(1/2))) /(molalityDilAEM*alpha^2 );
    CGamma   = 3/2*CPhi;

    % Final correlation to compute osmotic coefficients
    activCoeffConcCEM = exp(-DebHuck*(molalityConcCEM^(1/2)/(1+bPrime*molalityConcCEM^(1/2)) + 2/bPrime*log(1 + bPrime*molalityConcCEM^(1/2))) + molalityConcCEM*BConcCEM + CGamma*molalityConcCEM^2);
    activCoeffConcAEM = exp(-DebHuck*(molalityConcAEM^(1/2)/(1+bPrime*molalityConcAEM^(1/2)) + 2/bPrime*log(1 + bPrime*molalityConcAEM^(1/2))) + molalityConcAEM*BConcAEM + CGamma*molalityConcAEM^2);
    activCoeffDilCEM  = exp(-DebHuck*(molalityDilCEM^(1/2) /(1+bPrime*molalityDilCEM^(1/2))  + 2/bPrime*log(1 + bPrime*molalityDilCEM^(1/2)))  + molalityDilCEM*BDilCEM   + CGamma*molalityDilCEM^2 );
    activCoeffDilAEM  = exp(-DebHuck*(molalityDilAEM^(1/2) /(1+bPrime*molalityDilAEM^(1/2))  + 2/bPrime*log(1 + bPrime*molalityDilAEM^(1/2)))  + molalityDilAEM*BDilAEM   + CGamma*molalityDilAEM^2 );
      
    % toggle to turn off the activity coefficient correlations
    if toggleAct == 0
        activCoeffConcCEM = 1;
        activCoeffConcAEM = 1;
        activCoeffDilCEM  = 1;
        activCoeffDilAEM  = 1;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 