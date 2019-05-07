function jetMod = customJetColor
% CUSTOMJETCOLOR    Modifies jet to make a colormap customized for
% PTVProcessor.
% jetMod = customJetColor returns a colormap similar to jet, but with fewer
% dark blue colors. Uses a step size of approximately 1/21 instead of 1/16
    
    nSteps = 18;
    nTotalColors = 64;
    
    stepSize = 1/nSteps;
    stepArr = stepSize * [1:nSteps]';
    
    jetMod = zeros([64 3]);
    jetMod(1:nSteps,2) = stepArr;
    jetMod(1:nSteps,3) = 1;
    jetMod(nSteps+1:2*nSteps, 1) = stepArr;
    jetMod(nSteps+1:2*nSteps,2) = 1;
    jetMod(nSteps+1:2*nSteps,3) = stepArr(nSteps:-1:1);
    jetMod(2*nSteps+1:3*nSteps,1) = 1;
    jetMod(2*nSteps+1:3*nSteps,2) = stepArr(nSteps:-1:1);
    
    nRemaining = nTotalColors - 3*nSteps;
    nfill = nSteps - nRemaining;
    jetMod(3*nSteps+1:end,1) = stepArr(nSteps:-1:nfill+1);


end

