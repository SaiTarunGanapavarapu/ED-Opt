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
    params        = getParams()             ;
    densWater     = params.densWater        ;     % Density of Water (kg/m3)
    numCells      = params.numCells         ;
    resistBlank   = params.resistBlank      ;
    flowIn        = params.flowIn           ;
    concIn        = params.concIn           ;
    molWtNitrogen = params.molWtNitrogen    ;


    for j = 1;%:length(params.memLength)
        % Data from 0-D optimization case
        memLength    = params.memLength    (j) ; 
        memWidth     = params.memWidth     (j) ; 
        voltCellPair = params.voltCellPair (j) ;
        voltTotal    = params.voltTotal    (j) ; 
        curr         = params.curr         (j) ;
        currDens     = params.currDens     (j) ;
        feedSplit    = params.feedSplit    (j) ;
        
        % Find if the feedSplit became zero
        zeroIdx = find(params.feedSplit == 0, 1, 'first');
        % Get the last nonzero value before the zero
        lastNonZero = params.feedSplit(zeroIdx - 1);
        
        if feedSplit <10^-3
            % Set the feedSplit value as the last non zero value
            feedSplit = lastNonZero;
        end

        % Inlet flowrates to concentrate and dilute channels based on feedSplit
        flowConcIn   = flowIn*feedSplit      /numCells ; 
        flowDilIn    = flowIn*(1 - feedSplit)/numCells ; 

        concConcIn   = params.concIn                   ; 
        concDilIn    = params.concIn                   ; 
        
        equivDiaConc  = params.equivDiaConc(j)  ;     % Equivalent diameter of concentrate channel (m)
        equivDiaDil   = params.equivDiaDil (j)  ;     % Equivalent diameter of dilute      channel (m)
    
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
                   fun              = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPair, j);
                   % calling decic function for computing consistent initial conditions
                   [W0_new, D0_new] = decic(fun, 0, initCond, [1;1;1;1;0;1], D0, [0;0;0;0;0;0], opt);              
                   % updating the initial slope with new value
                   opt              = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8);
                   % solving the 1-D model with ode15i
                   [z, stateVars]   = ode15i(fun, zspan, W0_new, D0_new, opt);
    
            elseif mode == 2  % fixed I  (current)
    
                   % Residual function to equalize current calculated with desired
                   res                        = @(voltCellPairCal) getResiduals(voltCellPairCal, mode, flowConcIn, flowDilIn, j);
                   % Guess of the cell pair voltage value
                   voltCellPairGuess          = voltCellPair; 
                   convergOptions             = optimset('TolX',1e-8,'TolFun', 1e-8);
                   % Using fminsearch to find the actual value of cell pair voltage that matches the target current
                   [voltCellPairCal, fVal]    = fminsearch(res, voltCellPairGuess, convergOptions);
                   % calling getModelEqsRHS function
                   fun                        = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal, j);
                   % calling decic function for computing consistent initial conditions
                   [W0_new, D0_new]           = decic(fun,0,initCond,[1;1;1;1;0;1],D0, [0;0;0;0;0;0], opt);
                   % event function to check if current density exceeds limiting value
                   eventFcn                   = @(z,y,yp) limCurrDensCrossOver(z, y, yp, j);
                   % updating the initial slope with new value
                   opt                        = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8,'Events', eventFcn);
                   % solving the 1-D model with ode15i
                   [z, stateVars, te, ye, ie] = ode15i(fun,zspan,W0_new,D0_new,opt);
    
    
            elseif mode == 3  % fixed V  (total Voltage)
    
                   % Residual function to equalize total voltage calculated with desired
                   res                     = @(voltCellPairCal) getResiduals(voltCellPairCal, mode, flowConcIn, flowDilIn, j);
                   % Guess of the cell pair voltage value
                   voltCellPairGuess       = voltCellPair;
                   convergOptions          = optimset('TolX',1e-6,'TolFun', 1e-6);
                   % Using fminsearch to find the actual value of cell pair voltage that matches the target total voltage
                   [voltCellPairCal, fVal] = fminsearch(res,voltCellPairGuess, convergOptions);
                   % calling getModelEqsRHS function
                   fun                     = @(z, stateVar, diffVar) getModelEqsRHS(z, stateVar, diffVar, voltCellPairCal, j);
                   % calling decic function for computing consistent initial conditions
                   [W0_new, D0_new]        = decic(fun, 0, initCond, [1;1;1;1;0;1], D0, [0;0;0;0;0;0], opt);
                   % event function to check if current density exceeds limiting value
                   eventFcn                = @(z,y,yp) limCurrDensCrossOver(z, y, yp, j);
                   % updating the initial slope with new value
                   opt                     = odeset(opt,'InitialSlope', D0_new,'RelTol',1e-6,'AbsTol',1e-8,'Events', eventFcn);
                   % solving the 1-D model with ode15i
                   [z, stateVars]          = ode15i(fun,zspan,W0_new,D0_new,opt);
    
            end
    
    
            % Final profiles after integration
            concConcProfile(:,j) = stateVars(:,1)*molWtNitrogen     ; % wt% N
            concDilProfile (:,j) = stateVars(:,2)*molWtNitrogen     ; % wt% N 
            flowConcProfile(:,j) = stateVars(:,3).*numCells*24*1000 ; % L/day
            flowDilProfile (:,j) = stateVars(:,4).*numCells*24*1000 ; % L/day
            currDensProfile(:,j) = stateVars(:,5)                   ; % A/m2
            currEnd        (:,j) = stateVars(end,6)                 ; % Amps
            
            % Find average flow velocity and Reynolds numbers
            [uConc(j), uDil(j), ReConc(j), ReDil(j), ~, ~, ~, ~, ~, ~] = getDimLessNumbers(mean(flowConcProfile(:,j)/(numCells*24*1000)), mean(flowDilProfile(:,j)/(numCells*24*1000)), j);
            
            % Friction factors from Reynolds numbers
            fConc(j) = 1400/ReConc(j);
            fDil(j)  = 104.5/ReDil(j)^0.37;

            % Pressure drop 
            presDropConc(j) = 0.5*fConc(j)*densWater*uConc(j)^2*memLength/equivDiaConc;   % unit is Pa
            presDropDil (j) = 0.5*fDil (j)*densWater*uDil (j)^2*memLength/equivDiaDil ;   % unit is Pa
            
            % get the calculated cell-pair voltage
            if mode == 1
                voltCP(j) = voltCellPair;
            elseif mode == 2 || mode == 3
                   voltCP(j) = voltCellPairCal;
            end

            % compute the total voltage
            voltTot(j) = voltCP(j)*numCells + resistBlank*currEnd(j)/(memLength*memWidth);
            
            % compute power in kW (= watts from electricity needed + pumping the fluid)
            power(j) = (voltTot(j)*currEnd(j) + (presDropConc(j)*uConc(j) + presDropDil(j)*uDil(j))/((60*60)^3))/1000; 
        
        end
        
    end
    % concate results for plotting
    Array = table(concConcProfile(end,:)', concDilProfile(end,:)', flowConcProfile(end,:)', flowDilProfile(end,:)', currEnd(end,:)', power', 'VariableNames', {'concConc', 'ConcDil', 'flowConc', 'flowDil', 'current', 'power'});

    % Save results as csv to export to python for plotting
    % filename = 'simulationDataM1.xlsx';   % Uncomment for storing Mode 1 results
    % filename = 'simulationDataM2.xlsx';   % Uncomment for storing Mode 2 results
    filename = 'simulationDataM3.xlsx';
    writetable(Array, filename);
% Add a breakpoint at this end to access the computed profiles
end     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 