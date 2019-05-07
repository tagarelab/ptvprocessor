function [mu_x, mu_y, mu_xsd, mu_ysd, theta_width_x_optimal, ...
        noise_x_optimal, theta_width_y_optimal, noise_y_optimal, ...
        xloglikelihood_optimal, yloglikelihood_optimal, theta_signal] = ...
        gpregressor(X, V, seg, theta_width_values, approxMethod, nsr, ...
                                        fixedWidth, fixedNoise)
 % GPREGRESSOR      Apply Gaussian Process regression without grid-based
 % hyperparameter selection
 % [mu_x,mu_y,~,~,~,~,~,~,~,~,~]=GPREGRESSOR(X,V,seg,[x_width_value,...
 % y_width_value]) outputs Gaussian process regression on the region 
 % indicated by seg, from the vector location-velocity data input given by 
 % X, V. X is assumed to be a 2d array in three columns in the format
 % frame# | col# | row#
 % specifying the 3d location of vectors, whereas V is assumed to be a 2d
 % array in four columns in the format
 % x-velocity | y-velocity | x-variance | y-variance
 % seg is assumed to be a 2d matrix with the same dimensions as the image.
 % mu_x and mu_y are the component velocities, with size(mu_x) = size(seg) =
 % size(mu_y). Data from V will be used to compute theta_signal and then
 % the inputs [x_width_value,y_width_value] will be used as theta_width for
 % the corresponding component. Fitrgp will NOT optimize for width;
 % however, using a default seed NSR of 0.5 Fitrgp will find the local
 % optimum for noise in both components using a seed NSR of 0.5
 % [mu_x,mu_y,~,~,~,~,~,~,~,~,~]=GPREGRESSOR(X,V,seg,theta_width_value)
 % where theta_width_value is a scalar will use the same value of
 % theta_width for both components.
 % [mu_x,mu_y,mu_xsd,mu_ysd,~,~,~,~,~,~,~]=GPREGRESSOR(X,V,seg,theta_width,...
 % nsr) where theta_width is either a scalar or a two-element array and nsr
 % is either a scalar or a two-element array (processed as [nsr_x,nsr_y] in
 % the latter case) will perform Gaussian process regression with given
 % seed values, by default not optimizing for theta_width in either
 % component but optimizing for noise in both components.
 % [mu_x,mu_y,mu_xsd,mu_ysd,theta_width_x_optimal,noise_x_optimal,...
 %  theta_width_y_optimal,noise_y_optimal,xloglikelihood_optimal,...
 %  yloglikelihood_optimal,theta_signal]=GPREGRESSOR(X,V,seg,theta_width)
 %  will perform Gaussian process regression and then store optimal
 %  parameter values
 %  For Gaussian process regression, see HYPERPARAMS.
 % This function uses fitrgp, which is part of the Statistics and Machine
 % Learning toolbox, released in 2016
 
    % if fixed is true, will use given spatial scales and noisevars and
    % keep them fixed
    DEFAULT_NSR = 0.5;
    DEFAULT_FIXEDNOISE = false;
    DEFAULT_FIXEDWIDTH = true;
    DEFAULT_APPROXIMATION_METHOD = 'sd';
    if nargin < 4
        error('not enough inputs');
    end
    % segment and format training set
    segRows = segTable(X(:,2:3), seg);
    X = X(segRows,:);
    V = V(segRows,:);
    
    Xtrain = horzcat(X(:,3), X(:,2));
    vxval = V(:,1);
    vyval = V(:,2);
    
    % prepare parameters
    theta_signal = sqrt(mean(vxval.^2 + vyval.^2))
    if nargin < 8
        fixedNoise = DEFAULT_FIXEDNOISE;        
        if nargin < 7
            fixedWidth = DEFAULT_FIXEDWIDTH;
            if nargin < 6
                nsr = DEFAULT_NSR;
            end
            if nargin < 5
                approxMethod = DEFAULT_APPROXIMATION_METHOD
            end
        end
    end
    
    if numel(theta_width_values > 1)
        theta_width_x_optimal = theta_width_values(1);
        theta_width_y_optimal = theta_width_values(2);
    elseif numel(theta_width_values == 1)
        theta_width_x_optimal = theta_width_values;
        theta_width_y_optimal = theta_width_values;
    end
    if numel(nsr > 1)
        noise_x_optimal = nsr(1) * theta_signal;
        noise_y_optimal = nsr(2) * theta_signal;
    else
        noise_x_optimal = nsr * theta_signal;
        noise_y_optimal = nsr * theta_signal;
    end
    % dummy functions as needed for fixed values, etc.
    if fixedWidth
        kfcnx = @(XN,XM,theta)...
        ((theta_signal)^2)*exp(-(pdist2(XN,XM).^2)/(2*(theta_width_x_optimal)^2));
    
        kfcny = @(XN,XM,theta)...
        ((theta_signal)^2)*exp(-(pdist2(XN,XM).^2)/(2*(theta_width_y_optimal)^2));
    else
        kfcnx = @(XN,XM,theta)...
        ((theta_signal)^2)*exp(-(pdist2(XN,XM).^2)/(2*(theta(2))^2));
        kfcny = kfcnx;
    end
    
    gprx = fitrgp(Xtrain, vxval, 'KernelFunction',kfcnx, 'Basis','none',...
                'FitMethod',approxMethod,'PredictMethod','exact','Sigma',...
                noise_x_optimal, 'ConstantSigma', fixedNoise, ...
                'KernelParameters',  [1 theta_width_x_optimal]);
    
    gpry = fitrgp(Xtrain, vyval, 'KernelFunction',kfcny, 'Basis','none',...
                'FitMethod',approxMethod,'PredictMethod','exact','Sigma',...
                noise_y_optimal, 'ConstantSigma', fixedNoise, ...
                'KernelParameters',  [1 theta_width_y_optimal]);
    
    % print out optimal parameters
    optxkernel = gprx.KernelInformation.KernelParameters;
    theta_width_x_optimal = optxkernel(2)
    noise_x_optimal = gprx.Sigma
    xloglikelihood_optimal = gprx.LogLikelihood;
    optykernel = gpry.KernelInformation.KernelParameters;
    theta_width_y_optimal = optykernel(2)
    noise_y_optimal = gpry.Sigma
    yloglikelihood_optimal = gpry.LogLikelihood;
    % make predictions
    tic
    % get dimensional data (in matrix form) for segmented target    
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

