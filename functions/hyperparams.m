function [mu_x, mu_y, mu_xsd, mu_ysd, theta_width_x_optimal, ...
        noise_x_optimal, theta_width_y_optimal, noise_y_optimal, ...
         xloglikelihood_optimal, yloglikelihood_optimal, theta_signal] = ...
                    hyperparams(X, V, seg,approxMethod, ...
                                    theta_width_array, noise_array)
% HYPERPARAMS   Perform 2D Gaussian process regression with full 
% hyperparameter optimization                
% [mu_x,mu_y,~,~,~,~,~,~,~,~,~] = HYPERPARAMS(X,V,seg) outputs Gaussian
% process regression on the region indicated by seg, from the
% vector location-velocity data input given by X, V. X is assumed to be a
% 2d array in three columns in the format
% frame# | col# | row#
% specifying the 3d location of vectors, whereas V is assumed to be a 2d
% array in four columns in the format
% x-velocity | y-velocity | x-variance | y-variance
% seg is assumed to be a 2d matrix with the same dimensions as the image.
% mu_x and mu_y are the component velocities, with size(mu_x) = size(seg) =
% size(mu_y). Data from V will be used to compute theta_signal and then
% algorithm will try default theta_width seed values and default
% noise-signal ratios for noise seeds. In small neighborhoods the algorithm
% uses Matlab's feature in fitrgp to compute local optimums and will use
% the best set for final run through. All values will be printed. The
% default approximation method will be subset of data
% [mu_x,mu_y,mu_xsd,mu_ysd,theta_width_x_optimal,noise_x_optimal,...
%  theta_width_y_optimal,noise_y_optimal,xloglikelihood_optimal,...
%  yloglikelihood_optimal,theta_signal]=HYPERPARAMS(X,V,seg,...
%                               approxMethod,theta_width_array,noise_array)
% will run through hyperparameters with theta_width and noise seed array
% values, and save them in the additional outputs, using the fitting 
% approximation method specified. Prediction is always exact. Will also 
% output component standard deviations in mu_xsd, mu_ysd
%
%   Note that this function requires the Matlab Statistics and Machine
%   Learning toolbox, released in Matlab 2016

    % default hyperparameter seed values
    DEFAULT_THETA_WIDTH_VALUES = [15, 25, 40, 70, 120, 200];
    DEFAULT_NSR = [0.1, 0.25, 0.5, 1];
    DEFAULT_APPROXIMATION_METHOD = 'sr';
    
    % segment and format training set
    segRows = segTable(X(:,2:3), seg);
    X = X(segRows,:);
    V = V(segRows,:);
    
    % grab input for fitrgp function
    Xtrain = horzcat(X(:,3), X(:,2));
    vxval = V(:,1);
    vyval = V(:,2);
    
    % prepare parameters
    theta_signal = sqrt(mean(vxval.^2 + vyval.^2))
    if nargin < 6
        noise_array = theta_signal * DEFAULT_NSR;
        if nargin < 5
            theta_width_array = DEFAULT_THETA_WIDTH_VALUES;
            if nargin < 4
                approxMethod = DEFAULT_APPROXIMATION_METHOD;
            end
        end 
    end
    nXtrain = size(Xtrain,1);
    
    fprintf('Original training set size %d \n', nXtrain);



    tic
    % begin fitting 

    % fit and store
    % initialize array to store params and loglikelihoods
    nparams = numel(noise_array)*numel(theta_width_array);
    logxprobs = zeros([nparams, 1]);    
    logyprobs = zeros([nparams, 1]);
    theta_width_x_params = zeros([nparams, 1]);
    theta_width_y_params = zeros([nparams, 1]);
    noise_x_params = zeros([nparams, 1]);
    noise_y_params = zeros([nparams, 1]);
    
    fprintf('\n Fitting and computing likelilihoods with %d parameters.\n', ...
        nparams);
    % for conversion to get just noise or just theta_width
    paramDims = [numel(noise_array), numel(theta_width_array)];
    
    parfor iparam = 1:nparams
        fprintf('Fitting with seed noise %f and seed spatial %f. \n',...
            noise_array(ind2row(paramDims,iparam)),...
            theta_width_array(ind2col(paramDims,iparam)));

        % x-component parameter and loglikelihoods
        [theta_width_x_params(iparam),noise_x_params(iparam),...
            logxprobs(iparam)] = fitGPparams(Xtrain,vxval,theta_signal,...
            theta_width_array(ind2col(paramDims,iparam)),...
            noise_array(ind2row(paramDims,iparam)), approxMethod);
        % y-component parameter and loglikelihoods
        [theta_width_y_params(iparam),noise_y_params(iparam),...
            logyprobs(iparam)] = fitGPparams(Xtrain,vyval,theta_signal,...
            theta_width_array(ind2col(paramDims,iparam)),...
            noise_array(ind2row(paramDims,iparam)), approxMethod);
    end
    toc
    
    % retrieve optimal parameters and use as input into model parameters
    % for one last training session
    tic
    [~ , optimal_xId] = max(logxprobs(:));
    noise_x_optimal = noise_x_params(optimal_xId);
    theta_width_x_optimal = theta_width_x_params(optimal_xId);
    
    [~ , optimal_yId] = max(logyprobs(:));
    noise_y_optimal = noise_y_params(optimal_yId);
    theta_width_y_optimal = theta_width_y_params(optimal_yId);
    % dummy function to control what is optimized. Note that the variable
    % theta is meant to be a two element array, but only theta(2) plays a
    % role in our customized function. We have hard-coded theta_signal
    % where theta(1) normally would be, so that when fed into fitrgp, the
    % function will only optimize on theta(2), ie, the spatial kernel.
    kfcn = @(XN,XM,theta)...
        ((theta_signal)^2)*exp(-(pdist2(XN,XM).^2)/(2*(theta(2))^2));
    
    gprx = fitrgp(Xtrain, vxval, 'KernelFunction', kfcn, 'Basis', 'none', ...
            'FitMethod',approxMethod,'PredictMethod','exact','Sigma',...
            noise_x_optimal,'KernelParameters',[1 theta_width_x_optimal]);
    
    gpry = fitrgp(Xtrain, vyval, 'KernelFunction', kfcn, 'Basis', 'none', ...
            'FitMethod',approxMethod,'PredictMethod','exact','Sigma',...
            noise_y_optimal,'KernelParameters',[1 theta_width_y_optimal]);        

    toc
    % print out optimal parameters
    
    optxkernel = gprx.KernelInformation.KernelParameters;
    theta_width_x_optimal = optxkernel(2)
    noise_x_optimal = gprx.Sigma;
    xnsr_optimal = noise_x_optimal / theta_signal
    xloglikelihood_optimal = gprx.LogLikelihood;
    optykernel = gpry.KernelInformation.KernelParameters;
    theta_width_y_optimal = optykernel(2)
    noise_y_optimal = gpry.Sigma;
    ynsr_optimal = noise_y_optimal / theta_signal
    yloglikelihood_optimal = gpry.LogLikelihood;
    
    % make predictions
    tic
    % need dimension information for actual segmented target area
    [nrows, ncols] = size(seg);
    segId = find(seg == 1);
    % set desired predictors
    [Xtarget_y, Xtarget_x] = ind2sub([nrows, ncols], segId);
    Xtarget = horzcat(Xtarget_y, Xtarget_x);
    % x direction predictions
    [mu_xvals, mu_xsdvals] = predict(gprx, Xtarget);
    mu_x = zeros([nrows, ncols]);
    mu_xsd = zeros([nrows, ncols]);
    mu_x(segId) = mu_xvals;
    mu_xsd(segId) = mu_xsdvals;
    % y direction predictions
    [mu_yvals, mu_ysdvals] = predict(gpry, Xtarget);
    mu_y = zeros([nrows, ncols]);
    mu_ysd = zeros([nrows, ncols]);
    mu_y(segId) = mu_yvals;
    mu_ysd(segId) = mu_ysdvals;    
    toc
end

