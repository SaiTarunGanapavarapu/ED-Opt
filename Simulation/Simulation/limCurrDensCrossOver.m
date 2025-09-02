%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    limCurrDensCrossOver(...)                                  %
% Description: Function to check if current density surpassed limiting    %
%               current density                                           %
%                                                                         %
% Input:       z  - spacial variable to integrate over channel length (m) %
%                                                                         %
%              y  - 6 dimensional vector of conentrate stream  %
%                                  concentration (mol/m3), dilute stream  %
%                                  concentration (mol/m3), concentrate    %
%                                  stream volumetric flowrate (m3/hr),    %
%                                  dilute stream volumetric flowrate      %
%                                  (m3/hr), current density (Amps/m2),    %
%                                  total current (Amps)                   %
%              yp - 6 dimensional vector of concentrate stream %
%                                  concentration (mol/m3), dilute stream  %
%                                  concentration (mol/m3), concentrate    %
%                                  stream volumetric flowrate (m3/hr),    %
%                                  dilute stream volumetric flowrate      %
%                                  (m3/hr), current density (Amps/m2),    %
%                                  total current (Amps)                   %
%                                                                         %
% Output:      value - condititon that is checked to reach zero           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [value,isterminal,direction] = limCurrDensCrossOver(z, y, yp, j)

    concConc  = y(1)  ;
    concDil   = y(2)  ;
    flowConc  = y(3)  ;
    flowDil   = y(4)  ;
    currDens  = y(5)  ;

    
    [~, ~, ~, ~, iLim] = getInterfaceConcs(concConc, concDil, flowConc, flowDil, currDens, j);
    
    iLimDil = min(iLim(3), iLim(4));

    value      = currDens/iLimDil - 1; % The value that we want to be zero
    isterminal = 1;  % Halt integration 
    direction  = 0;   % The zero can be approached from either direction

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%