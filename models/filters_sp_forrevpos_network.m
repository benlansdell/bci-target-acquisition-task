function data = filters_sp_forrevpos_network(processed, nK_sp, nK_pos, dt_sp, dt_pos)
	%Prepare spike and torque data for GLM which includes spike history and cursor position (x_1, x_2) filters:
	%
	%	y(i) ~ Pn(g(eta_i))
	%
	%where
	%
	%	eta_i = \sum y(i-j) k_sp(i) + \sum x_1(i+j) k_1(j) + \sum x_2(i+j) k_2(j)
	%
	%Usage:
	%	data = filters_sp_pos_network(processed, unit, nK_sp, nK_pos, dt_sp, dt_pos)
	%     
	%Input:
	%	processed = structure output from one of the preprocess functions.
	%	unit = index of unit to compute data matrix for. Large matrix sizes suggest we compute one unit at 
	%		a time
	%	nK_sp = number of timebins used for spike history filter for all units
	%	nK_pos = number of timebins used for cursor trajectory filters (on in x and y axis)
	%	dt_sp = (optional, default = binsize in processed structure) step size of spike history filters
	%		in seconds. Must be a multiple of the data's binsize.
	%	dt_pos = (optional, default = binsize in processed structure) step size of position filter in
	%		seconds. Must be a multiple of the data's binsize
	%   
	%Output:
	%	data is a structure containing the following fields:
	%		y = [nU x nB] array where y_ij is the number of spikes at time bin j for unit i.
	%		X = [nB x nK] array where X_ijk is the value of covariate k, at time bin j, for unit i
	%			Note: nK = nU*nK_sp + 2*nK_pos
	%		k = Names of each filter, a [n x 2] cell array in which each row is of the form ['filter j name', [idxj1 idxj2 ...]]
	%			Note: The second column lists indices in 1:nK to which the label applies
	%		torque = torque data trimmed in the same way X and y are. 
	%			Note: truncated at start and end because spike and cursor trajectory are not defined for first 
	%			and last nK_sp and nK_pos timebins respectively.
	%		dtorque = trimmed dtorque
	%		ddtorque = trimmed ddtorque
	%  
	%Test code:
	%	%Load test preprocessed data
	%	pre = load('./testdata/test_preprocess_spline_60hz_short24.mat');
	%	nK_sp = 6; 
	%	nK_pos = 6;
	%	dt_sp = 1/60;
	%	dt_pos = 1/60;
	%	data = filters_sp_forrevpos_network(pre.processed, nK_sp, nK_pos, dt_sp, dt_pos);

	if (nargin < 5) dt_sp = processed.binsize; end
	if (nargin < 6) dt_pos = processed.binsize; end

	%Check dt's specified are valid
	assert(rem(dt_sp,processed.binsize)==0, 'Invalid dt_sp. Must be a multiple of binsize');
	assert(rem(dt_pos,processed.binsize)==0, 'Invalid dt_pos. Must be a multiple of binsize');
	steps_sp = dt_sp/processed.binsize;
	steps_pos = dt_pos/processed.binsize;

	nU = size(processed.binnedspikes,2);
	nB = size(processed.binnedspikes,1);
	nKs = (2*nK_pos-1);

	nK = nU*nK_sp + 2*nKs;

	data.X = zeros(nB, nK);
	data.k = cell(nU+2,3);
	for i = 1:nU
		data.k{i,1} = ['spike unit' num2str(i)]; 
		data.k{i,2} = (i-1)*nK_sp + (1:nK_sp);
		data.k{i,3} = dt_sp;
	end
	data.k{nU+1,1} = 'RU pos'; 
	data.k{nU+1,2} = (1:nKs) + nU*nK_sp;
	data.k{nU+1,3} = dt_pos;
	data.k{nU+2,1} = 'FE pos'; 
	data.k{nU+2,2} = (1:nKs) + nU*nK_sp + nKs;
	data.k{nU+2,3} = dt_pos;
	%Record specifically which indices are spike history indices for model simulation
	%data.sp_hist = data.k{1,2};

	%For each unit, add data to X array
	%Make stimulus vector at each timebin
	strpt = 1+max(nK_sp*steps_sp,nK_pos*steps_pos);
	endpt = nB-nK_pos*steps_pos;
	for j = strpt:endpt
		shist = zeros(nK_sp*nU,1);
		for idx=1:nU 
			%(past) spike history
			shist(((idx-1)*nK_sp+1):(idx*nK_sp)) = processed.binnedspikes(j-nK_sp*steps_sp:steps_sp:j-steps_sp, idx);
		end
		%(past and future) torque trajectory
		torqueRU = processed.torque(j-(nK_pos-1)*steps_pos:steps_pos:j+(nK_pos-1)*steps_pos,1);
		torqueFE = processed.torque(j-(nK_pos-1)*steps_pos:steps_pos:j+(nK_pos-1)*steps_pos,2);
		%Form stim vector
		data.X(j,:) = [shist' torqueRU' torqueFE'];
	end
	%Truncate to exclude start and end of recording where spike history 
	%and cursor trajectory aren't well defined
	data.X = data.X((strpt):(endpt),:); %(nkt+1:end-nkt,:);
	data.y = processed.binnedspikes((strpt):(endpt), :)';
	%Truncate other data for comparison, too
	data.torque = processed.torque((strpt):(endpt),:); 
	data.dtorque = processed.dtorque((strpt):(endpt),:);
	data.ddtorque = processed.ddtorque((strpt):(endpt),:);