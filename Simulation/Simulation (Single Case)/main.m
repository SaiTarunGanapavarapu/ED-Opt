%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:    main()                                                     %
% Description: Main script file for simulating 1-D ED model               %
%                                                                         %
% Input:       - NIL                                                      %
%                                                                         %
% Output:      - NIL                                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function main()

    % Get Params structure and unpack
    params        = getParams()          ;
    numCells      = params.numCells      ;
    densWater     = params.densWater     ;     % Density of Water (kg/m3)
    equivDiaConc  = params.equivDiaConc  ;     % Equivalent diameter of concentrate channel (m)
    equivDiaDil   = params.equivDiaDil   ;     % Equivalent diameter of dilute      channel (m)
    resistBlank   = params.resistBlank   ;

    % Data from 0-D optimization case
    memLength    = params.memLength   ; 
    memWidth     = params.memWidth    ; 
    voltCellPair = params.voltCellPair;
    voltTotal    = params.voltTotal   ; 
    curr         = params.curr        ;
    currDens     = params.currDens    ;
    feedSplit    = params.feedSplit   ;

   
    flowConcIn   = params.flowConcIn  ;
    flowDilIn    = params.flowDilIn   ;
    concConcIn   = params.concIn      ; 
    concDilIn    = params.concIn      ; 
    

    % Initial guess for current density
    iInitGuess   = currDens;
    % independent variable 
    zspan    = linspace(0,memLength,300);
    % Guess for initial condition of state variables
    initCond = [concConcIn; concDilIn; flowConcIn; flowDilIn; iInitGuess; 0];

    % Guess for initial condition of differential variables
    D0       = ones(6,1);    
    % odeset
    opt      = odeset('InitialSlope', D0,'RelTol',1e-6,'AbsTol',1e-8);

    % select mode (1 specs Vcp as input, 2 is I as input, 3 is Vtot as input)
    for mode = 1

        if mode == 1  % Fixed V_{cp}  (cell-pair voltage)

               % Specifying cell-pair voltage 
               voltCellPair     = voltCellPair; 
               % calling getModelEqsRHS function
               fun              = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPair);
               % calling decic function for computing consistent initial conditions
               [W0_new, D0_new] = decic(fun, 0, initCond, [1;1;1;1;0;1], D0, [0;0;0;0;0;0], opt);              
               % updating the initial slope with new value
               opt              = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8);
               % solving the 1-D model with ode15i
               [z, stateVars]   = ode15i(fun, zspan, W0_new, D0_new, opt);

        elseif mode == 2   % fixed I  (current)

               % Residual function to equalize current calculated with desired
               res                        = @(voltCellPairCal) getResiduals(voltCellPairCal, mode);
               % Guess of the cell pair voltage value
               voltCellPairGuess          = voltCellPair; 
               convergOptions             = optimset('TolX',1e-9,'TolFun', 1e-9);
               % Using fminsearch to find the actual value of cell pair voltage that matches the target current
               [voltCellPairCal, fVal]    = fminsearch(res, voltCellPairGuess, convergOptions);
               % calling getModelEqsRHS function
               fun                        = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal);
               % calling decic function for computing consistent initial conditions
               [W0_new, D0_new]           = decic(fun,0,initCond,[1;1;1;1;0;1],D0, [0;0;0;0;0;0], opt);
               % event function to check if current density exceeds limiting value
               eventFcn                   = @(z,y,yp) limCurrDensCrossOver(z, y, yp);
               % updating the initial slope with new value
               opt                        = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8,'Events', eventFcn);
               % solving the 1-D model with ode15i
               [z, stateVars, te, ye, ie] = ode15i(fun,zspan,W0_new,D0_new,opt);


        elseif mode == 3   % fixed V  (total Voltage)

               % Residual function to equalize total voltage calculated with desired
               res                     = @(voltCellPairCal) getResiduals(voltCellPairCal, mode);
               % Guess of the cell pair voltage value
               voltCellPairGuess       = voltCellPair;
               convergOptions          = optimset('TolX',1e-6,'TolFun', 1e-6);
               % Using fminsearch to find the actual value of cell pair voltage that matches the target total voltage
               [voltCellPairCal, fVal] = fminsearch(res,voltCellPairGuess, convergOptions);
               % calling getModelEqsRHS function
               fun                     = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal);
               % calling decic function for computing consistent initial conditions
               [W0_new, D0_new]        = decic(fun, 0, initCond, [1;1;1;1;0;1], D0, [0;0;0;0;0;0], opt);
               % event function to check if current density exceeds limiting value
               eventFcn                = @(z,y,yp) limCurrDensCrossOver(z, y, yp);
               % updating the initial slope with new value
               opt                     = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8,'Events', eventFcn);
               % solving the 1-D model with ode15i
               [z, stateVars]          = ode15i(fun,zspan,W0_new,D0_new,opt);

        end


        % Final profiles after integration
        concConcProfile = stateVars(:,1)           ; % mol/m3
        concDilProfile  = stateVars(:,2)           ; % mol/m3 

        flowConcProfile = stateVars(:,3).*numCells ; % m3/hr
        flowDilProfile  = stateVars(:,4).*numCells ; % m3/hr
        currDensProfile = stateVars(:,5)           ; % A/m2
        currEnd         = stateVars(end,6)         ; % Amps
        
        % Find average flow velocity and Reynolds numbers
        [uConc, uDil, ReConc, ReDil, ~, ~, ~, ~, ~, ~] = getDimLessNumbers(mean(flowConcProfile), mean(flowDilProfile));
        
        % Friction factors from Reynolds numbers
        fConc = 1400/ReConc;
        fDil  = 104.5/ReDil^0.37;

        % Pressure drop 
        presDropConc = 0.5*fConc*densWater*uConc^2*memLength/equivDiaConc;   % unit is Pa
        presDropDil  = 0.5*fDil *densWater*uDil ^2*memLength/equivDiaDil ;   % unit is Pa
        
        % get the calculated cell-pair voltage
        if mode == 1
            voltCP = voltCellPair;
        elseif mode == [2,3]
               voltCP = voltCellPairCal;
        end

        % compute the total voltage
        voltTot = voltCP*numCells + resistBlank*currEnd/(memLength*memWidth);
        
        % compute power in kW (= watts from electricity needed + pumping the fluid)
        power = (voltTot*currEnd + (presDropConc*uConc + presDropDil*uDil)/((60*60)^3))/1000; % unit is kW
 
    end
% Add a breakpoint at this end to access the computed profiles
end     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 