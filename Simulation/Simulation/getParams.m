%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getParamas()                                               %
% Description: Function to create a Parameter sctructure                  % 
%              with all parameters                                        %
%                                                                         %
% Input:       -                                                          % 
%                                                                         %
% Output:      params - Structre                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [params] = getParams()

    load("data0D.mat")
    
    % Parameters from the 0-D optimization study (primary input to the simulation)
    params.memWidth      = data0D.memWidth             ;      % Membrane Width  (m) 
    params.memLength     = data0D.memLength            ;      % Membrane Length (m) 
    params.thicknessConc = data0D.thicknessConcentrate ;      % Thickness of concentrate channel (m)
    params.thicknessDil  = data0D.thicknessDilute      ;      % Thickness of dilute      channel (m)  
    params.feedSplit     = data0D.flowSplit            ;      % Feed split deciding flow to both channels
    params.voltCellPair  = data0D.voltCellPair         ;      % Cell-Pair voltage specification (V)
    params.voltTotal     = data0D.voltTotal            ;      % Total voltage specification (V)
    params.currDens      = data0D.currDens             ;      % Current Density (A/m2)
    params.curr          = data0D.curr                 ;      % Current (A)

    % Constants
    params.F             = 96485       ;     % Fardays constant (C/mol)
    params.RinJoule      = 8.314       ;     % Gas Constant     (J/mol K)
    params.RinBar        = 8.314*10^-5 ;     % Gas Constant     (m3 bar/mol K)
    params.vantHoffCoeff = 2           ;     % Van Hoff't coefficient (2 for NH4Cl)

    % Membrane Properties
    params.transCEM      = 0.95        ;      % Transport number of counter ion in CEM 
    params.transAEM      = 0.95        ;      % Transport number of counter ion in AEM 
    params.diffCEM       = 1E-12       ;      % Diffusivity coefficient of ions in CEM (m2/s) 
    params.diffAEM       = 1E-12       ;      % Diffusivity coefficient of ions in AEM (m2/s) 
    params.thicknessCEM  = 0.00011     ;      % Thickness of CEM (m)
    params.thicknessAEM  = 0.000105    ;      % Thickness of AEM (m)
    params.waterPermCEM  = 7.776E-6    ;      % Water permeability constant in CEM (m3/bar h2 m2) 
    params.waterPermAEM  = 6.30E-6     ;      % Water permeability constant in AEM (m3/bar h2 m2)
    params.permSelCEM    = 0.9         ;      % Permselectivity of CEM (m)
    params.permSelAEM    = 0.9         ;      % Permselectivity of AEM (m) 
    params.resistCEM     = 2.5*10^-4   ;      % Resistance of CEM (ohm m2)
    params.resistAEM     = 1.8*10^-4   ;      % Resistance of CEM (ohm m2)
    params.resistBlank   = 2*10^-5     ;      % Blank or open-circuit resistance (ohm m2)

    % Channel Properties
    params.transNH4      = 0.491                  ;  % Transport number of NH4+ in fluid channel 
    params.transCl       = 0.509                  ;  % Transport number of Cl-  in fluid channel 
    params.waterTrans    = 6 + 8                  ;  % Water transport number (NH4+ = 6, Cl- = 8)  
    params.diffConc      = 1.84E-9                ;  % Diffusivity coefficient of ions in concentrate channel (m2/s)
    params.diffDil       = 1.84E-9                ;  % Diffusivity coefficient of ions in dilute      channel (m2/s)
    params.equivDiaConc  = 2*params.thicknessConc ;  % Equivalent diameter of concentrate channel (m)
    params.equivDiaDil   = 2*params.thicknessDil  ;  % Equivalent diameter of dilute      channel (m)
    params.conducConc    = 149.6*10^-4            ;  % Equivalent conductivity of Concentrate Stream (S m2/mol)
    params.conducDil     = 149.6*10^-4            ;  % Equivalent conductivity of Dilute      Stream (S m2/mol)


    % Process Conditions and general fluid properties
    params.temp          = 273.15+25      ;      % Temperature (K)
    params.molWtNitrogen = 14.0067        ;      % Molecular weight of Nitrogen (g/mol)
    params.molWtAmmoniaG = 53.491         ;      % Molecular weight of Ammonia (g/mol)
    params.molWtAmmonia  = 53.491*10^-3   ;      % Molecular weight of Ammonia (kg/mol)
    params.molWtWater    = 0.018          ;      % Molecular weight of Water (kg/mol)
    params.densWater     = 1000           ;      % Density of Water (kg/m3)
    params.visWater      = 1E-3           ;      % Viscosity of Water (Pa-s)
    params.numCells      = 500            ;      % Number of cell pairs in a single-ED unit
    params.flowIn        = 192555/1000/24 ;      % Inlet flowrate to the ED unit (m3/hr)
    params.concIn        = 1366/14.0067   ;      % Inlet concentration to the ED unit (mol/m3)

    % Constants for Osmotic coefficient correlation  
    params.beta0       = 0.0522    ;
    params.beta1       = 0.1918    ;
    params.CPhi        = -0.003    ;

    % Constants for Acitivity coefficient correlation    
    params.alpha       = 2         ;   
    params.bPrime      = 1.2       ;
    params.DebHuck     = 0.3915    ;  % Debye-Huckel Constant
   
    % Constants for Equivalent Conductivity correlation  
    params.ionicRadius    = 4.35*1e-8    ; % Ionic radius of NH4Cl in cm
    params.dielecConst    = 78.4         ; % Dielectric Constant     
    params.conducInfDil   = 149.6        ; % Equivalent conductivity at infinite dilution (Scm^2/mol)

    % Booleans to turn on/off the correlations (1 for on, 0 for off)
    params.toggleOsm      = 1  ; % Boolean to turn off the osmotic coefficient correlations
    params.toggleAct      = 1  ; % Boolean to turn off the activity coefficient correlations
    params.toggleEqCond   = 1  ; % Boolean to turn off the equivalent conductivity correlations
    params.toggleIntConc  = 1  ; % Boolean to turn off the interfacial concentration computations (Concentration Polarization)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%