%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    getResiduals(...)                                          %
% Description: Function to compute residuals for current and              %
%              total voltage modes                                        %
%                                                                         %
% Inputs:      voltCellPairCal - CellPair voltage to match target current %
%                                or total voltage based on mode number    %
%              mode            - 2 for equal current mode                 % 
%                                3 for equal total voltage mode           % 
%                                                                         %
% Output:      res  - function value for fmincon solver                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = getResiduals(voltCellPairCal, mode)

    % Get Params structure and unpack
    params       = getParams()        ;
    memLength    = params.memLength   ; 
    memWidth     = params.memWidth    ; 
    numCells     = params.numCells    ;
    flowConcIn   = params.flowConcIn  ;
    flowDilIn    = params.flowDilIn   ;
    concConcIn   = params.concIn      ; 
    concDilIn    = params.concIn      ; 
    
    resistBlank  = params.resistBlank ;  
    AreaBlank    = memLength*memWidth ;


    voltTotalDesired    = params.voltTotal  ; 
    currDesired         = params.curr       ;
    currDensDesired     = params.currDens   ;
    


    if mode == 2

       % calling getModelEqsRHS function
       fun                        = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal);
       % Guess for initial condition of state variables
       initCond                   = [concConcIn; concDilIn; flowConcIn; flowDilIn; currDensDesired; 0];  
       % Guess for initial condition of differential variables
       D0                         = ones(6, 1);  
       % independent variable 
       zspan                      = linspace(0, memLength, 300);              
       % odeset
       opt                        = odeset('InitialSlope', D0,'RelTol',1e-6,'AbsTol',1e-8);
       % calling decic function for computing consistent initial conditions
       [W0_new, D0_new]           = decic(fun, 0, initCond, [1;1;1;1;0;1], D0, zeros(6, 1), opt); 
       % event function to check if current density exceeds limiting value 
       eventFcn                   = @(z, y, yp) limCurrDensCrossOver(z, y, yp);
       % updating the initial slope with new value
       opt                        = odeset(opt,'InitialSlope', D0_new,'RelTol', 1e-6,'AbsTol', 1e-8, 'Events', eventFcn);
       % solving the 1-D model to find the final current value
       [z, stateVars, te, ye, ie] = ode15i(fun, zspan, W0_new, D0_new, opt);
       % Residual equation to equalize computed and desired current
       res                        = (stateVars(end, 6) - currDesired)^2;

    elseif mode == 3
       
       % calling getModelEqsRHS function
       fun              = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal);
       % Guess for initial condition of state variables
       initCond         = [concConcIn; concDilIn; flowConcIn; flowDilIn; currDensDesired; 0];  
       % Guess for initial condition of differential variables
       D0               = ones(6,1);  
       % independent variable 
       zspan            = linspace(0,memLength,300);      
       % odeset
       opt              = odeset('InitialSlope', D0,'RelTol',1e-6,'AbsTol',1e-8);
       % calling decic function for computing consistent initial conditions
       [W0_new, D0_new] = decic(fun,0,initCond,[1;1;1;1;0;1],D0,zeros(6,1),opt); 
       % updating the initial slope with new value
       opt = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8);
       % solving the 1-D model to find the final current value
       [z, stateVars]   = ode15i(fun,zspan,W0_new,D0_new,opt);
       % computing the total voltage from current
       I                = stateVars(end,6);
       voltTotal        = voltCellPairCal*numCells + resistBlank*I/AreaBlank;
       % Residual equation to equalize computed and desired total voltage
       res              = (voltTotal - voltTotalDesired)^2;
       
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%