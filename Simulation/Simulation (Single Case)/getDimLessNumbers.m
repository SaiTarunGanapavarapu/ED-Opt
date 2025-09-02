%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getDimLessNumbers(...)                                     %
%                                                                         %  
% Description: Compute DimensionLess numbers in the Electrodialysis cell  %
%                                                                         %
% Input:       flowConc - State Variable: Flowrate in concentrate channel % 
%              flowDil  - State Variable: Flowrate in concentrate channel %
%                                                                         %
% Output:      ReConc    - Reynolds Number in concentrate channel         %
%              ReDil     - Reynolds Number in dilute      channel         %
%              ScConc    - Schmidt Number  in concentrate channel         %
%              ScDil     - Schmidt Number  in dilute      channel         %
%              ShConcCEM - Sherwood Number in concentrate, CEM interface  %
%              ShConcAEM - Sherwood Number in concentrate, AEM interface  %
%              ShDilCEM  - Sherwood Number in dilute     , CEM interface  %
%              ShDilAEM  - Sherwood Number in dilute     , AEM interface  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uConc, uDil, ReConc, ReDil, ScConc, ScDil, ShConcCEM, ShConcAEM, ShDilCEM, ShDilAEM] = getDimLessNumbers(flowConc, flowDil)

    % Get Params structure from the getParams function
    params        = getParams();

    % Unpack parameters
    densWater     = params.densWater     ;     % Density of Water (kg/m3)
    visWater      = params.visWater      ;     % Viscosity of Water (Pa-s)
    memWidth      = params.memWidth      ;     % Membrane Width  (m)
    diffConc      = params.diffConc      ;     % Diffusivity coefficient of ions in concentrate channel (m2/s)
    diffDil       = params.diffDil       ;     % Diffusivity coefficient of ions in dilute      channel (m2/s) 
    thicknessConc = params.thicknessConc ;     % Thickness of concentrate channel (m)
    thicknessDil  = params.thicknessDil  ;     % Thickness of dilute      channel (m)
    
    % Flow velocity in the concentrate and dilute channel
    uConc = flowConc/memWidth/thicknessConc/3600;
    uDil  = flowDil /memWidth/thicknessDil /3600;

    % Reynolds numbers in the concentrate and dilute channel
    ReConc = 2*densWater* flowConc/memWidth/visWater/3600;   % 3600 is used because flow is in m3/hr
    ReDil  = 2*densWater* flowDil /memWidth/visWater/3600;   % 3600 is used because flow is in m3/hr
    
    % Schmidt numbers in the concentrate and dilute channel
    ScConc = visWater/(densWater*diffConc);
    ScDil  = visWater/(densWater*diffDil );
    
    % Sherwood numbers in the interfaces of both membranes and fluids
    ShConcCEM = 0.29 * (ScConc^0.33 * ReConc^0.5);
    ShConcAEM = 0.29 * (ScConc^0.33 * ReConc^0.5);
    ShDilCEM  = 0.29 * (ScDil ^0.33 * ReDil ^0.5);
    ShDilAEM  = 0.29 * (ScDil ^0.33 * ReDil ^0.5);
    
    if ShConcAEM < 1
        ShConcAEM = 1;
        ShConcCEM = 1;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 