function [rt_mat] = analyze_SAT_Color_pretest(subID,startBlock)
%
% 2013.06.13. SWW.
%
% 2012.12.28.SWW.Output minimum RT (min_RT). min_RT would be the
% upper bound for the rising parameter (delta) in the SAT function.
%
% analyze SAT session.
%
% YHL. 2011
%
% CCT 2014.03.18
% - coh change to [0.6 0.57 0.54]


% load input file
if ismac
    inputfile = ['../inputs/Pretest_' subID '_SAT_Color'];
    datafile = ['data/Pretest_' subID '_SAT_Color.txt'];
elseif ispc
    inputfile = ['../inputs/Pretest_' subID '_SAT_Color'];
    datafile = ['data/Pretest_' subID '_SAT_Color.txt'];
end
load(inputfile);
data = load(datafile);

%% setting to analysis
timeLimit = inputs(1).timeLimit;   % possible time limits
cohSet = [0.6 0.57 0.54];  % possible coherence levels (just 1 in this experiment).
n_coh=length(cohSet);
nTrials = size(data,1);
sum_rt=zeros(length(cohSet),length(timeLimit));
n_trials=sum_rt;
n_correct=sum_rt;
max_time=max(inputs(1).trial_timeLimit);
min_RT=max_time;
count_valid=0;

%% start to accumulate correct answer and total RT
for i=1:nTrials;
    blockNo=data(i,1);
    trialNo=data(i,2);
    
    if blockNo>=startBlock
    % if the subject did not make a response, the 8th column would be -1.
    if data(i,8)~=-1
        
        crt=data(i,5);  %current RT
        if crt<min_RT
            min_RT=crt; % to find the minmal RT
        end
        
        count_valid=count_valid+1;
        rt_vect(count_valid)=crt;
        
        time_current = inputs(blockNo).trial_timeLimit(trialNo);
        indx_time = find(timeLimit==time_current);
        coh_current =inputs(blockNo).redRatio;
        indx_coh = find(cohSet==coh_current);
        
        sum_rt(indx_coh,indx_time)=sum_rt(indx_coh,indx_time)+crt;
        
        n_trials(indx_coh,indx_time)=n_trials(indx_coh,indx_time)+1;
        
        
        if data(i,8)==1
            correct=1;
        elseif data(i,8)==0
            correct=0;
        end
        
        n_correct(indx_coh,indx_time)=n_correct(indx_coh,indx_time)+correct;
        
    end
    
    
    end
end


mu_rt = sum_rt./n_trials;   % mean RT
pHat = n_correct./n_trials;    % probability of correct

rt_mat = [sum_rt;n_correct;n_trials];
% row 1: sum of RT
% row 2: total number of correct trials
% row 3: total number of valid trials

figure(1);clf
title(['Pretest ' subID]);
hold on;

for i=1:n_coh
    subplot(1,n_coh,i);
    axis([0 max_time+0.2 0.5 1]); hold on
    plot(mu_rt(i,:),pHat(i,:),'.','markersize',20);
    hold on;
    plot(mu_rt(i,:),pHat(i,:));axis([0 max_time+0.2 0.5 1]); hold on
    title(['coh=' num2str(cohSet(i))]);
    axis square
end
% 
% resultsfile=['results_SAT_Colotpretest_' subID];
% save(resultsfile,'sum_rt','n_trials','n_correct','mu_rt','pHat','min_RT');