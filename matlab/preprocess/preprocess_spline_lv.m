function processed = preprocess_spline_lv(nevfile, matfile, binsize, threshold, offset, fn_out)
	%Preprocess both torque data and firing rate data from an .nev file and a corresponding .ns3 file.
	%Will do the following:
	%	- resample spikes and torque data into units of binsize (seconds)
	%	- extract cursor data from labview mat file during nev recording
	%	- apply a temporal offset between the two
	%	- apply a threshold on average firing rate, below which, unit is not returned
	%	- smooth torque data by fitting a cubic spline to data. Compute velocity and accel 'analytically' from the spline
	%
	%Usage:
	%	processed = preprocess_spline_lv(nevfile, binsize, threshold, offset, fn_out)
	%
	%Input:
	%		nevfile = file to process. For loading torque data, assumes that an .nsx file of the same name and location exists.
	%		matfile = labview file containing nev file info, nev time offset and cursor information
	%		binsize = (optional, default = 0.05) size of timebins over which to compute regression
	%		threshold = (optional, default = 5) threshold firing rate below which unit is ignored
	%		offset = (optional, default = 0) number of seconds to add to spike data before comparing with torque
	%		fn_out = (optional) file to output diagnostic plots to, if desired
	%		
	%Output:
	%	processed is a structure containing the following fields:
	%		binnedspikes = [nB x nU] array with spikes from all channels binned according to binsize. nB = no. bins, nU = no. units.
	%		rates = [nB x nU] array of binnedspikes multiplied by samplerate to give a per second firing rate approximation
	%		torque = [nB x 2] array of torque inputs 
	%		dtorque = [nB x 2] array of diff of torque inputs (approximation of velocity)
	%		ddtorque = [nB x 2] array of diff of diff of torque inputs (approximation of acceleration)
	%		cursor = [nB x 2] array of cursor position 
	%		dcursor = [nB x 2] array of diff of cursor position (approximation of velocity)
	%		ddcursor = [nB x 2] array of diff of diff of cursor position (approximation of acceleration)
	%		unitnames = String of the format Electrode.SortCode used to distinguish individual units from multi-unit electrode activity
	%		tspks = cell array containing spike times for each active channel
	%		binsize = binsize used
	%
	%Test code:
	%		nevfile = './testdata/20130117SpankyUtah001.nev';
	%		matfile = './testdata/Spanky_2013-01-17-1325.mat';
	%		binsize = 0.002;
	%		offset = 0.0;
	%		threshold = 5;
	%		fn_out = './worksheets/diagnostics/plots/test_spline_pre.eps';
	%		processed = preprocess_spline_lv(nevfile, matfile, binsize, threshold, offset, fn_out);
	
	%Optional arguments
	if (nargin < 3) binsize = 0.05; end
	if (nargin < 4) threshold = 5; end		
	if (nargin < 5) offset = 0; end
	if (nargin < 6) fn_out = 0; end
	%Total number of possible units recorded from
	nE = 128;
	nunits = 5; 
	nU = nE*nunits;
	samplerate = 1/binsize;
	%Make sure we can perform the sample rate conversion easily
	assert(rem(samplerate,1) == 0, 'Select a binsize corresponding to an integer sample rate.');
	ns3file = [nevfile(1:end-3) 'ns3'];

	%%%%%%%%%%%%%%%%%%%%%%
	%Process spiking data%
	%%%%%%%%%%%%%%%%%%%%%%
	display(['Opening ' nevfile])
	NEV = openNEV(nevfile);
	%Find the duration and sample rate of the nev file recording
	nevsamplerate = NEV.MetaTags.TimeRes;
	dur = NEV.MetaTags.DataDuration/nevsamplerate;
	%Convert spike times into array of binned spikes, one for each spike sorted channel
	spiketimes = double(NEV.Data.Spikes.TimeStamp)/nevsamplerate;
	elecs = cell(1,nU);
	spikemuas = struct('times', elecs);
	unitnames = cell(1,nU);
	averate = zeros(1,nU);
	isvalid = zeros(1,nU);
	for idx=1:nU
		spikemuas(idx).times = [0];    
	end
	for i=1:length(spiketimes)
		E = NEV.Data.Spikes.Electrode(i);
		unit = NEV.Data.Spikes.Unit(i);
		U = single((E-1)*nunits)+single(unit)+1;
		spikemuas(U).times = [spikemuas(U).times; spiketimes(i)];
		unitnames{U} = [num2str(E) '.' num2str(unit)];
	end
	%Check which channels are doing stuff
	for idx=1:nU
		averate(idx) = (length(spikemuas(idx).times)-1)/dur;
		if length(spikemuas(idx).times)>1
			if (spikemuas(idx).times(2)<20) & (spikemuas(idx).times(end)>(dur-20))
				isvalid(idx)=1;
			end
		end
		display(['Electrode.Unit: ' unitnames{idx} ' Spike count: ' num2str(length(spikemuas(idx).times)-1) ' Mean firing rate (Hz): ' num2str(averate(idx))]);
	end
	%Set a threshold firing rate, below which we ignore that unit
	abovethresh = (averate > threshold) & isvalid;
	%Update nU
	nU = sum(abovethresh);
	display(['Found ' num2str(nU) ' units above ' num2str(threshold) 'Hz']);
	unitnames = unitnames(abovethresh);
	spikemuas = spikemuas(abovethresh);
	averate = averate(abovethresh);
	%Bin spikes (chronux function)
	binnedspikes = binspikes(spikemuas, samplerate);
	%From this apply gaussian filter to spike train for each electrode
	for idx=1:nU
		rates(:,idx) = binnedspikes(:,idx)*samplerate;
	end
	%Return spike times for each active channel
	tspks = spikemuas;
	%%%%%%%%%%%%%%%%%%%%%
	%Process torque data%
	%%%%%%%%%%%%%%%%%%%%%
	clear torque;

	%Load from labview, also. Needed for brain control datasets
	load(matfile);
	labviewsamplerate = data.sampleRate;
	foundnev = 0;
	[pathstr,nevfilename,ext] = fileparts(nevfile);
	for idx = 1:length(data.nev)
		%Find nev structure
		[pathstr,curr_nevfilename,ext] = fileparts(data.nev(idx).nevfile);
		if strcmp(curr_nevfilename, nevfilename)
			%Find offset and duration in seconds
			nevoffset = single(data.nev(idx).Toffset(1))/60;
			nevdur = data.nev(idx).DurationSec;
			foundnev = 1;
			break
		end 
	end
	assert(foundnev == 1, 'Cannot find nev file in labview mat file, check your input files');
	%extract from stateHist.cursor the cursor position during the nev recording
	withinnev = (data.stateHist.time < nevoffset+nevdur) & (data.stateHist.time > nevoffset);
	lvtorque = data.stateHist.cursor(withinnev,:);
	lvdtorque = [diff(lvtorque); 0, 0]*labviewsamplerate;
	lvddtorque = [diff(lvdtorque); 0, 0]*labviewsamplerate;
	%Resample at desired rate
	lvtorque = resample(lvtorque, samplerate, labviewsamplerate);
	lvdtorque = resample(lvdtorque, samplerate, labviewsamplerate);
	lvddtorque = resample(lvddtorque, samplerate, labviewsamplerate);

	%If can't find NSx file then go ahead with zeros...
	if exist(ns3file, 'file')
		NS3 = openNSx(ns3file, 'read', 'c:138:139');
		nsxtorque = double(NS3.Data);
		nsxsamplerate = double(NS3.MetaTags.SamplingFreq);
		%Switch sign of FE axis for coordinate consistency
		nsxtorque(2,:)=-nsxtorque(2,:);
		nsxpts = ((1:size(nsxtorque,2))-1)/nsxsamplerate;
		pts = ((1:size(binnedspikes,1))-1)/samplerate;
	
		%Smoothing parameter
		%p = 1/(1+binsize^3/0.001);
		p = 0.9999;
		for j=1:2
			%Scale from uint16 value to proportion
			nsxtorque(j,:) = nsxtorque(j,:)/(2^15);
			%Subtract mean
			nsxtorque(j,:) = nsxtorque(j,:)-mean(nsxtorque(j,:));
			%Smooth w spline
			sp = csaps(nsxpts, nsxtorque(j,:), p);
			torque(:,j) = fnval(sp, pts);
			%Compute velocity of spline
			vel = fnder(sp);
			dtorque(:,j) = fnval(vel, pts);
			%Compute accel of spline
			accel = fnder(vel);
			ddtorque(:,j) = fnval(accel, pts);
		end
	
		if isstr(fn_out)
			%Check smoothness of spline smoothing
			clf
			subplot(2,2,1)
			hold on
			t = 220;
			unit = 18;
			dt = 2;
			plot(nsxtorque(1,(t*nsxsamplerate):(t*nsxsamplerate+dt*nsxsamplerate)), nsxtorque(2,(t*nsxsamplerate):(t*nsxsamplerate+dt*nsxsamplerate)), 'b');
			plot(torque((t*samplerate):(t*samplerate+dt*samplerate),1), torque((t*samplerate):(t*samplerate+dt*samplerate),2), 'r');
			xlabel('x'); ylabel('y');
			subplot(2,2,2)
			plot(dtorque((t*samplerate):(t*samplerate+dt*samplerate),1), dtorque((t*samplerate):(t*samplerate+dt*samplerate),2), 'r');
			xlabel('dx'); ylabel('dy');
			subplot(2,2,3)
			plot(ddtorque((t*samplerate):(t*samplerate+dt*samplerate),1), ddtorque((t*samplerate):(t*samplerate+dt*samplerate),2), 'r');
			xlabel('d^2x'); ylabel('d^2y');
			saveplot(gcf, [fn_out '_spline.eps'], 'eps', [6 6])
		end
	else
		torque = zeros(size(lvtorque));
		dtorque = zeros(size(lvdtorque));
		ddtorque = zeros(size(lvddtorque));
	end

	%Check they're the same length, and trim
	nsamp = min([size(torque,1), size(rates,1), size(lvtorque,1)]);
	torque=torque(1:nsamp,:);
	dtorque=dtorque(1:nsamp,:);
	ddtorque=ddtorque(1:nsamp,:);
	lvtorque=lvtorque(1:nsamp,:);
	lvdtorque=lvdtorque(1:nsamp,:);
	lvddtorque=lvddtorque(1:nsamp,:);
	rates = rates(1:nsamp,:);
	binnedspikes = binnedspikes(1:nsamp,:);
	%Apply offset to data
	delaysamples = round(offset*samplerate);
	if (delaysamples > 0)
		binnedspikes = binnedspikes(1+delaysamples:end,:);
		rates = rates(1+delaysamples:end,:);
		torque = torque(1:end-delaysamples,:);
		dtorque = dtorque(1:end-delaysamples,:);
		ddtorque = ddtorque(1:end-delaysamples,:);
		lvtorque = lvtorque(1:end-delaysamples,:);
		lvdtorque = lvdtorque(1:end-delaysamples,:);
		lvddtorque = lvddtorque(1:end-delaysamples,:);
	elseif (delaysamples < 0)
		binnedspikes = binnedspikes(1:end+delaysamples,:);
		rates = rates(1:end+delaysamples,:);
		torque = torque(1-delaysamples:end,:);
		dtorque = dtorque(1-delaysamples:end,:);
		ddtorque = ddtorque(1-delaysamples:end,:);
		lvtorque = lvtorque(1-delaysamples:end,:);
		lvdtorque = lvdtorque(1-delaysamples:end,:);
		lvddtorque = lvddtorque(1-delaysamples:end,:);
	end
	if isstr(fn_out)
		%Plot a bunch of preprocessing diagnostics
		figure
		subplot(2,2,1)
		t = 10;
		times = (1:(t*samplerate))*binsize;
		plot(times, torque(1:(t*samplerate),1),times, torque(1:(t*samplerate),2))
		title('Smoothed torque');		
		subplot(2,2,2)
		%Compute auto- and cross-correlation in torque and example firing rate
		maxlag = 90;
		autotorqueFE = xcov(torque(:,1),samplerate*maxlag);%, 'coeff');
		autotorqueRU = xcov(torque(:,2),samplerate*maxlag);%, 'coeff');
		covFE = xcov(rates(:,unit), torque(:,1),samplerate*maxlag,'unbiased');
		% normalize against spikes auto-covariance
		autorate = xcov(rates(:,unit),samplerate*maxlag);%, 'coeff');
		covFE = covFE / sqrt(xcov(rates(:,unit),0));
		covFE = covFE / sqrt(xcov(torque(:,1),0));
		tt = -maxlag:binsize:maxlag;
		plot(tt, covFE);
		title(['cross-corr FE, unit ' num2str(unitnames{unit})]);		
		subplot(2,2,3)
		plot(tt, autotorqueFE)
		title('auto-corr torque FE');
		subplot(2,2,4)
		plot(tt, autorate);
		title(['auto-corr rate, unit ' num2str(unitnames{unit})])
		saveplot(gcf, [fn_out '_preprocess.eps'], 'eps', [6 6]);

		%Check that labview and blackrock torque info lines up, more or less
		clf
		t = 10;
		ii = 1:(t*samplerate);
		tt = ii*binsize;
		subplot(3,1,1)
		plot(tt, -torque(ii,1),tt, -torque(ii,2), tt, lvtorque(ii,1),tt, lvtorque(ii,2))
		title('Labview and blackrock torque comparison')
		legend('Torque 1', 'Torque 2', 'Cursor 1', 'Cursor 2')
		ylabel('Torque/cursor position')
		subplot(3,1,2)
		plot(tt, -dtorque(ii,1),tt, -dtorque(ii,2), tt, lvdtorque(ii,1),tt, lvdtorque(ii,2))
		ylabel('Change in torque/cursor position')
		subplot(3,1,3)
		plot(tt, -ddtorque(ii,1),tt, -ddtorque(ii,2), tt, lvddtorque(ii,1),tt, lvddtorque(ii,2))
		ylabel('Change in change in torque/cursor position')
		xlabel('times (s)')
		saveplot(gcf, [fn_out '_lvcomp.eps'], 'eps', [9 6]);
	end

	%Return data
	processed.binnedspikes = binnedspikes;
	processed.rates = rates;
	processed.torque = torque;
	processed.dtorque = dtorque; 
	processed.ddtorque = ddtorque;
	processed.cursor = lvtorque;
	processed.dcursor = lvdtorque; 
	processed.ddcursor = lvddtorque;
	processed.unitnames = unitnames;
	processed.tspks = tspks;
	processed.binsize = binsize;
	processed.nevfile = nevfile;
	processed.labviewfile = matfile;