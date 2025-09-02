%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getResistances(...)                                        %
%                                                                         %
% Description: Function to compute salt fluxes                            %   
%                                                                         %
% Inputs:      concConc       - Bulk concentration of conc channel        %
%              concDil        - Bulk concentration of dil channel         %
%              concConcIntCEM - Interfacial concentration (Conc/CEM)      %
%              concConcIntAEM - Interfacial concentration (Conc/AEM)      %
%              concDilIntCEM  - Interfacial concentration (Dil /CEM)      %
%              concDilIntAEM  - Interfacial concentration (Dil /AEM)      %
%                                                                         %
% Output:      resistTotal - Total Ohmic resistance (ohm m2)              %
%              nonOhm      - Total non Ohmic voltage drop (V)             %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [resistTotal, nonOhm] = getResistances(concConc, concDil, concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM, j)

    % Get Params structure from the getParams function
    params        = getParams();
    
    F             = params.F                ;     % Fardays constant (C/mol)
    temp          = params.temp             ;     % Temperature (K)
    RinJoule      = params.RinJoule         ;     % Gas Constant     (J/mol K)
    permSelCEM    = params.permSelCEM       ;     % Permselectivity of CEM 
    permSelAEM    = params.permSelAEM       ;     % Permselectivity of AEM 
    thicknessConc = params.thicknessConc(j) ;     % Thickness of concentrate channel (m)
    thicknessDil  = params.thicknessDil (j) ;     % Thickness of dilute      channel (m)
    resistCEM     = params.resistCEM        ;     % Resistance of CEM (ohm m2)
    resistAEM     = params.resistAEM        ;     % Resistance of AEM (ohm m2)

    % Get equivalent conductivity
    [equivConducConc, equivConducDil] = getEquivConduc(concConc, concDil);

    % Resistance of both channels (ohm m2) and total
    resistConc   = thicknessConc/(equivConducConc*concConc);
    resistDil    = thicknessDil/(equivConducDil*concDil);

    resistTotal = resistCEM + resistAEM + resistConc + resistDil;

    % Get activity coefficients
    [activCoeffConcCEM, activCoeffConcAEM, activCoeffDilCEM, activCoeffDilAEM] = getActivityCoeffs(concConcIntCEM, concConcIntAEM, concDilIntCEM, concDilIntAEM);

    % Non-Ohmic voltage drop across both membranes (Donnan Potential) (V)
    nonOhmCEM = permSelCEM*RinJoule*temp/F*log(activCoeffConcCEM/activCoeffDilCEM*concConcIntCEM/concDilIntCEM);
    nonOhmAEM = permSelAEM*RinJoule*temp/F*log(activCoeffConcAEM/activCoeffDilAEM*concConcIntAEM/concDilIntAEM);
    
    % Total non Ohmic voltage drop (V)
    nonOhm = nonOhmAEM + nonOhmCEM;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 