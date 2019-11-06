function [theta_width,noise,loglikelihood] = fitGPparams(Xtrain, vals, ...
                                    theta_signal,theta_width_seed,...
                                    noise_seed, approxMethod)
% FITGPPARAMS   Compute locally optimal gaussian process parameter and
% loglikelihood. 
%
% [theta_width,noise,loglikelihood]=FITGPPARAMS(X_train, vals, theta_signal, ...
% theta_width_seed, noise_seed, approxMethod) performs a single iteration of fitting
% using Matlab's fitrgp function and outputs the locally optimal
% theta_width and noise values, along with the associated loglikelihood.
% Note that this function requires Matlab's Statistics and Machine Learning
% toolbox, released in Matlab 2016. 
%   
% see also HYPERPARAMS

    % dummy function to control what is optimized. Note that the variable
    % theta is meant to be a two element array, but only theta(2) plays a
    % role in our customized function. We have hard-coded theta_signal
    % where theta(1) normally would be, so that when fed into fitrgp, the
    % function will only optimize on theta(2), ie, the spatial kernel.
    kfcn = @(XN,XM,theta)...
        ((theta_signal)^2)*exp(-(pdist2(XN,XM).^2)/(2*(theta(2))^2));
    
    % Note that theta(2) = kernelsize; note the placement of
    % theta(2) in the dummy function. theta(1) has no effect on the
    % likelihood. Using kfcn and this definition of theta forces fitrgp to
    % not optimize the signal parameter. 
    theta = [1 theta_width_seed];
    gpr = fitrgp(Xtrain,vals,'KernelFunction',kfcn,'Basis','none',...
                'Fitmethod',approxMethod,'PredictMethod','exact','Sigma', ...
                noise_seed,'KernelParameters',theta);
    
    % retrieve values for output
    loglikelihood = gpr.LogLikelihood;
    kernelparams = gpr.KernelInformation.KernelParameters;
    theta_width = kernelparams(2);
    noise = gpr.Sigma;
end

