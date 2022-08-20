function [norm_slope,finalist,pC_hat]=getMoneyParams_Colorpain_lottery(subID,funcForm,max_probC,lottery)
%
% Generate decreasing reward schedule. In this version, just the slope
% (normalized) of the decrease. You will need norm_slope when you create
% input file for the reward session.
%
% You need to see the SAT of the subject first. This is imporant for
% adjusting the values in pC_benchMark. Basically, you want to pick the
% values within the range with the sharpest change in performance.
%
% ------------------------ History ------------------------------
% SWU.2013.06.12.
% - change sv to 1.
% - funcForm: functional form of the SAT function.
% - norm_slope: normalized slope.
% - finalist: a matrix containing information about how good the schedules
% are.

% YHL.2012.
% 2014.02.14
% - add penalty and the loss = gain at different time

% CCT 2014.03.18
% modified "getMoneyParams_pain.m"


global t_riseFromChance

% This is to get mean RT data and minimal RT in order to perform SAT
% analysis.
if ismac
    inputfile = ['inputs/Test_' subID '_SAT_Color'];
elseif ispc
    inputfile = ['inputs/Test_' subID '_SAT_Color'];
end
load(inputfile);

%[rt_mat_SAT,min_RT,max_time] =analyze_SAT_Color_whole(subID);    % Analyze whole blocks.
[rt_mat_SAT,min_RT,max_time] =analyze_sat_coherence(subID)
% [rt_mat_SAT,min_RT,max_time] =analyze_SAT_Color_part(subID);   % Analyze some blocks you interesting in.
% rt_mat
% row 1: sum of RT
% row 2: total number of correct trials
% row 3: total number of valid trials

% This is to estimate the parameters for the SAT function.
[paramsHat,pC_hat] = getMLE_SAT_Color_lottery(rt_mat_SAT,min_RT,subID,funcForm,max_time);
% paramsHat :delta_guess and lambda_guess in cumulative Weibull distribution.
% pC_hat    : Prediction for Probability of correct

if funcForm==2
    t_riseFromChance = paramsHat(2); % delta (paramsHat(2) is lambda)
elseif funcForm==1
    t_riseFromChance = paramsHat(1); % delta (paramsHat(1) is beta)
end

% This is the probability of correct (pC) benchmark. We want to first find
% The time points corresponding to these values based on the subject's SAT.
min_pC = 0.55;       % start from 55% probability of correct
max_pC = max_probC;  % you have to adjust this number based on subject's performance. Make sure to look at both SAT (form 1 and 2)
n_grids= 6;          % how many benchmark you want to use?
pC_int = (max_pC-min_pC)/(n_grids-1);  
pC_benchMark = min_pC:pC_int:min_pC+pC_int*(n_grids-1);
nDecreaseSchedules = length(pC_benchMark);

% in the lottery version, max time they have is 20s
if lottery ==1
    max_time =20;
end

% sv: starting value
sv = 1;

% setting for finding out Decrease rate
dec_start = -3; dec_interval=0.001; dec_end=-0.001;

% Define grid in search for decrease rate we want.
dec_grid = dec_start:dec_interval:dec_end;     % all the possible slope
n_dec    = length(dec_grid);                   % # of possible slopes

% Time grid.(Based on Decrease rate, each time was paired with one magnitude of reward.)
t_grid   = 0:0.01:max_time; 

% For each possible decreasing rate specified in dec_grid,
% Find the maximum EG and its timing.
for j=1:n_dec
    gain_params(1)= sv;                    % start value
    gain_params(2)= dec_grid(j);           % decrease rate
    gain_params(3)= t_riseFromChance+0.01; % time when value starts decreasing
    
    [maxEG(j,1),t_maxEG(j,1),pC_afo_t,t_grid,EGsum_afo_t(:,j),gain_afo_t(:,j)] = getEG_Penalty_decreaseFromStart(paramsHat,gain_params,t_grid,funcForm,max_time);
    %[maxEG(j,1),t_maxEG(j,1),pC_afo_t,t_grid,EGsum_afo_t(:,j),gain_afo_t(:,j)]=getEG_20130228_v2(paramsHat,gain_params,t_grid,funcForm);
    % pC is a vector containing information about the probability of correct as a function of time. getEG will
    % compute pC according to the SAT parameter (paramsHat), t_grid, and
    % functional form of the SAT function.
    % maxEG      :
    % t_maxEG    :
    % pC_afo_t   :
    % EGsum_afo_t: sum of expected gain as function of time(Expected gain + expected loss)
    % gain_afo_t :
end

% Once we have information about pC, we will be able to find the time that
% corresponds to our pC benchmark we set, for this particular subject.
% Given pC's benchmark, compute optimal Time benchmark (optT_benchMark).
for i=1:nDecreaseSchedules
    [mp,indx]=min(abs(pC_afo_t-pC_benchMark(i)));
    optT_benchMark(i)=t_grid(indx);
end

% Find the decrease schedule that has the closest maxEG timing to the
% optimal time benchmark.
for m=1:nDecreaseSchedules
    [deltaT,indx]           = min(abs(t_maxEG-optT_benchMark(m)));
    finalist(m,:)           = [indx dec_grid(indx) t_maxEG(indx) optT_benchMark(m) deltaT maxEG(indx)];
    finalist_EG_afo_t(:,m)  = EGsum_afo_t(:,indx);
    finalist_gain_afo_t(:,m)= gain_afo_t(:,indx);
end

norm_slope=finalist(:,2)./sv;

%% save to file.
if lottery == 1
    filename=['rewSchedule_' subID '_ForLottery'];
else
filename=['rewSchedule_' subID '_panelty'];
end
save(filename,'finalist','norm_slope','finalist_EG_afo_t','finalist_gain_afo_t','pC_hat','pC_afo_t','t_grid');

%% plotting
figure(5);clf
plot(t_grid,pC_afo_t,'linewidth',3);
hold on;
plot(t_grid,finalist_gain_afo_t,'g','linewidth',3);
xlabel('time (sec)');
title(subID);

figure(6);clf
plot(t_grid,finalist_EG_afo_t,'k','linewidth',3);
hold on;
plot(finalist(:,3),finalist(:,6),'r.','markersize',20)
axis square;
axis([0 max_time+0.2 0 1]);
xlabel('time (sec)')
title(subID)




