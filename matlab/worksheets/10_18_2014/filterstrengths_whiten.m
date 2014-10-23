%%%%%%%%%%%%%%%%%%%
%filterstrengths.m%
%%%%%%%%%%%%%%%%%%%

%Code to see how fitting performs on GLMs generated from known filters of different
%strengths, with actual stimulus data used and generated spike trains from these GLMs
%We compare the quality of the fit to the filter strength and the #of parameters of the fit model

fn_out = './worksheets/10_18_2014/data_whiten.mat';
N = 200000;
binsize = 0.002;
dur = N*binsize;
dt_sp = binsize;
dt_pos = binsize;
seed = 1000000;
const = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Make up 10 filters. They'll have a common spike history filter, and varying stimulus strengths
%Change the constant term such that they each have the same average firing rate

%Filters
nK_sp = 100;
nK_pos = 100;
nAlpha = 10;
target_nsp = 10000;
k_const_guess = -5;

%Spike history filter
t_sp = linspace(0,1,nK_sp);
k_sp = -0.1*exp(-50*t_sp);
k_sp = fliplr(k_sp);

%Base stim filter that will be scaled below
t_pos = linspace(0,1,nK_pos);
k_RU = -1.0*exp(-6*t_pos);
k_FE = 0.5*exp(-5*t_pos);

%Factors to scale stim filters by
alphas = [1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1];
k_const = zeros(nAlpha,1);

nevfile = './testdata/20130117SpankyUtah001.nev';
threshold = 5; offset = 0;
pre = preprocess(nevfile, binsize, threshold, offset);
%Truncate to only one unit
idx = 9;
pre.binnedspikes = pre.binnedspikes(:,idx);
pre.rates = pre.rates(:,idx);              
pre.unitnames = pre.unitnames(idx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate spike train data with these filters and actual stimulus data as input
%Tweak the constant term so that the average firing rate is about what is seen in the actual data sets

processed = {};
nspikes1 = zeros(nAlpha,1);
nspikes = zeros(nAlpha,1);
%Determine how to set constant rate from train with the same filters
for idx = 1:nAlpha
	idx
	alpha = alphas(idx);
	k_RU_sc = k_RU*alpha;
	k_FE_sc = k_FE*alpha;
	%Simulate GLM with filters wanted but constant term left at a guess value
	processed{idx} = generate_glm_data_torque(pre, k_const_guess, k_sp, k_RU_sc, k_FE_sc, dt_sp, dt_pos, N, binsize);
	%Count number of spikes
	nspikes1(idx) = sum(processed{idx}.binnedspikes);
	%Estimate constant to produce wanted average firing rates
	k_const(idx) = k_const_guess+log(target_nsp/nspikes1(idx));
	%Redo with estimated constant values
	processed{idx} = generate_glm_data_torque(pre, k_const(idx), k_sp, k_RU_sc, k_FE_sc, dt_sp, dt_pos, N, binsize);
	%Check that total number of spikes is around the same...
	nspikes(idx) = sum(processed{idx}.binnedspikes);
end

%Check that the average firing rate is roughly correct
plot(nspikes, '.r')
hold on
plot(nspikes1, '.b')
plot(1:length(nspikes), ones(nAlpha,1)*target_nsp)
ylim([0 1.2*max(nspikes)])
%Seems to work...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Can start from here by loading fn_out, as just saved above
fn_out = './worksheets/10_18_2014/data_whiten.mat';
save(fn_out);

fn_out = './worksheets/10_18_2014/data_whiten.mat';
load(fn_out);

%Fit filters of different lengths/resolution to this data
%Do the fitting with both glmfit and with my code
nK_poss = [2 5 10 20 50];
dt_poss = binsize*100./nK_poss;

devs_IRLS = zeros(nAlpha, length(nK_poss));
devs_SD = zeros(nAlpha, length(nK_poss));

g = figure;
for i = 1:nAlpha
	i
	figure(g);
	clf;
	alpha = alphas(i)
	for j = 1:length(nK_poss);
		%set dt_pos accordingly
		dt_pos = dt_poss(j);
		nK_pos = nK_poss(j)
		%for each resolution generate the data structure
		data = filters_sp_pos_whiten(processed{i}, nK_sp, nK_pos, dt_sp, dt_pos);
		%Takes a long time... will run later
		%model_SD = MLE_SD(data, const);
		model_IRLS = MLE_glmfit(data, const);
		%Compute the deviance
		%devs_SD(i,j) = deviance(model_SD, data);
		devs_IRLS(i,j) = deviance(model_IRLS, data);
		%Plot the filters estimated for each
		fn_out2 = ['./worksheets/10_18_2014/plots/filterstrengths_whiten_alpha_' num2str(alphas(i)) '_dtpos_' num2str(dt_pos)];
		%plot_filters(model_SD, data, processed{i}, [fn_out2 '_fminunc'])
		plot_filters(model_IRLS, data, processed{i}, [fn_out2 '_IRLS'])
		IRLS_const = model_IRLS.b_hat(1);
		figure(g);
		for k = 1:size(data.k,1)
			%Plot the estimated filters
			subplot(3,1,k)
			hold on
			name = data.k{k,1};
			filt = model_IRLS.b_hat(data.k{k,2}+1);
			%Transform filter back to unorthogonal space
			%%
			if k == 1
				dt = dt_sp;
			else
				%rescale filter because of different time scales
				dt = dt_pos;
				filt = filt*dt_sp/dt_pos;
				title(name);
			end
			plot((0:length(filt)-1)*dt, filt, 'Color', [1 0.5 0.5])  
			plot((0:length(filt)-1)*dt, filt, 'r.')  
		end
	end
	%Plot the actual filters
	subplot(3,1,1)
	title({['Fit filters. \alpha = ' num2str(alpha) '. # spikes ' num2str(sum(processed{i}.binnedspikes))];['spike history filter']})
	hold on
	plot((0:length(k_sp)-1)*binsize, k_sp, 'b', 'LineWidth', 2)
	subplot(3,1,2)
	hold on
	plot((0:length(k_RU)-1)*binsize, k_RU*alpha, 'b', 'LineWidth', 2);
	subplot(3,1,3)
	hold on
	plot((0:length(k_FE)-1)*binsize, k_FE*alpha, 'b', 'LineWidth', 2);
	xlabel('time (s)')
	fn_out3 = ['./worksheets/10_18_2014/plots/filterstrengths_whiten_alpha_' num2str(alphas(i)) '.eps'];
	saveplot(gcf, fn_out3, 'eps', [9 6]);
end
%Save the outcome of all the above
save(fn_out);
%fn_out = './worksheets/10_18_2014/data_whiten.mat';
%load(fn_out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make a plot of the deviance as a function of params
clf
imagesc(devs_IRLS)
title('Deviance')
xlabel('resolution (s)')
ylabel('alpha')
%set(gca,'XTick',1:size(S,1));
set(gca,'XTickLabel',dt_poss);
%set(gca,'YTick',1:size(S,2));
set(gca,'YTickLabel',alphas);
colorbar
saveplot(gcf, './worksheets/10_18_2014/plots/filterstrengths_whiten_dev.eps')

