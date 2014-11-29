function [Lambda, T] = compensator(model, data)
	%Forms compensator for a model and set of spikes that can be used in the time-rescaling theorem to
	%test if spike train was generated by a given GLM. The compensator has the form:
	%
	%	Lambda(t) = \int_0^t \lambda(t')dt'
	%	
	%	or
	%
	%	Lambda(k) = \sum_{j=0}^k \lambda(j|H_j) \Delta t
	%
	%Usage:
	%	Lambda = compensator(model, data)
	%     
	%Input:
	%	model = a structure of fit coefficients from MLE_glmfit
	%	data = a structure of stimulus and spike history data from ./models directory
	%   
	%Output:
	%	Lambda = cell array containing list of rescaled spike times for each unit
	%	T = (no. units)x1 array containing total time of trial after rescaling
	%  
	%Test code:
	%	%Load test preprocessed data
	%	pre = load('./testdata/test_preprocess_spline_short.mat');
	%	const = 'on';
	%	nK_sp = 50; 
	%	nK_pos = 10;
	%	dt_sp = 0.002;
	%	dt_pos = 0.05;
	%	data = filters_sp_pos(pre.processed, nK_sp, nK_pos, dt_sp, dt_pos);
	%	model = MLE_glmfit(data, const);
	%	scaledspks = compensator(model, data);

	nU = size(data.X,1);
	N = size(data.X,2);
	comptime = zeros(N, nU);
	T = zeros(1,nU);
	Lambda = {};

	%for each unit
	for i = 1:nU
		%extract all the unit's filters
		b_hat = model.b_hat(i,:);
		%compute the component of mu = e^eta that comes from the remaining filters used
		mu = glmval(b_hat', squeeze(data.X(i,:,:)), 'log');
		%rescale time according to firing rate
		comptime(:,i) = cumsum(mu);
		spbins = data.y(i,:)==1;
		Lambda{i} = comptime(spbins, i);
		T(i) = comptime(end,i);
	end