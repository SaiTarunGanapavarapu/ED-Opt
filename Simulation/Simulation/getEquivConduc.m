%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getEquivConduc(...)                                        %
%                                                                         %
% Description: Function to compute equivalent conductivities in channels  %   
%                                                                         %
% Inputs:      concConc - Bulk phase concentration of concentrate channel %
%              concDil  - Bulk phase concentration of dilute      channel %
%                                                                         %
% Outputs:     equivConducConc - Equivalent conductivity in Conc channel  %
%              equivConducDil  - Equivalent conductivity in Dil  channel  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [equivConducConc, equivConducDil] = getEquivConduc(concConc, concDil)

    % Get Params structure from the getParams function
    params        = getParams();

    % Constants for Equivalent Conductivity correlation  
    temp           = params.temp            ;     % Temperature (K)
    ionicRadius    = params.ionicRadius     ; % Ionic radius of NH4Cl in cms
    dielecConst    = params.dielecConst     ; % Dielectric Constant 
    visWater       = params.visWater        ; % Viscosity of Water (Pa-s)
    conducInfDil   = params.conducInfDil    ; % Equivalent conductivity at infinite dilution (Scm^2/mol)
    toggleEqCond   = params.toggleEqCond    ; % Boolean to turn off the equivalent conductivity correlations

    % Intermediate constants for final correlation
    BPrime         = 50.29*10^8/(dielecConst*temp)^0.5         ;
    BPrime1        = 82.5/(visWater*10*(dielecConst*temp)^0.5) ;
    BPrime2        = 8.204*10^5/(dielecConst*temp)^1.5         ;
    FPrimeConcConc = (exp(0.2929*BPrime*(concConc/1000)^0.5*ionicRadius) -1)/(0.2929*BPrime*(concConc/1000)^0.5*ionicRadius)  ;
    FPrimeConcDil  = (exp(0.2929*BPrime*(concDil/1000) ^0.5*ionicRadius) -1)/(0.2929*BPrime*(concDil/1000) ^0.5*ionicRadius)  ;


    % correlation to compute equivalent conductivity (S m2/mol)
    equivConducConc = (conducInfDil - (BPrime1*(concConc/1000)^0.5)/(1+BPrime*ionicRadius*(concConc/1000)^0.5))*(1-(BPrime2*(concConc/1000)^0.5)/(1+BPrime*ionicRadius*(concConc/1000)^0.5)*FPrimeConcConc)*10^-4;
    equivConducDil  = (conducInfDil - (BPrime1*(concDil/1000)^0.5) /(1+BPrime*ionicRadius*(concDil/1000)^0.5)) *(1-(BPrime2*(concDil/1000)^0.5) /(1+BPrime*ionicRadius*(concDil/1000)^0.5)*FPrimeConcDil)  *10^-4;

    % toggle to turn off the equivalent conductivity correlations
    if toggleEqCond == 0
       
        equivConducConc = conducInfDil;
        equivConducDil  = conducInfDil;

    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 