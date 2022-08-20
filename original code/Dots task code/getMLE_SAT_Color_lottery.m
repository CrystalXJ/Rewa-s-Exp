function [paramsHat,pC_hat] = getMLE_SAT_Color_lottery(rt_mat,min_RT,subID,funcForm,max_time)
%
% 2012.12.28. SWW.
% - Call nLogLike_SAT_v2. 
% - input argument includes min_RT 
%
% Get Maximum Likelihood Estimates of parameter values for SAT function.
%
% YLL. 2011.

% Set parameter guess.
%     datafile = ['../data/Test_' subID '_SAT_Color.txt'];
%     answer=load(datafile);
%     answer=answer(:,8);
if funcForm==1
    delta_guess  = 0.3;  % ??? in cumulative Weibull distribution.
    lambda_guess = 0.75; % ??? in cumulative Weibull distribution.
    params = [delta_guess lambda_guess];
elseif funcForm==2
    delta_guess  = 0.3;
    lambda_guess = 0.75;
    beta_guess   = 1;
    params = [beta_guess delta_guess lambda_guess];
elseif funcForm==3
    delta_guess=0.9;
    alpha_guess=0.75;
    beta_guess=1;
    params = [delta_guess alpha_guess beta_guess];
end

mu_RT = rt_mat(1,:)./rt_mat(3,:);
% max_timeLimit=max(inputs(1).trial_timeLimit);
nCorrect = rt_mat(2,:);
nTotal = rt_mat(3,:);
data = [mu_RT' nCorrect' nTotal'];

% Find MLE parameter estimate by caling nLogLike_SAT
paramsHat = fminsearch('nLogLike_SAT_v3_20130228',params,[],data,funcForm);
if funcForm==1
    tHat_riseFromChance = paramsHat(1); % delta (paramsHat(2) is lambda)
elseif funcForm==2
    tHat_riseFromChance = paramsHat(2); % delta (paramsHat(1) is beta)
end

%% for Lottery session
lb_rt=min_RT;
rt=0:.01:max_time; % to find the time point that pC increases to 1.
pC_hat = getPC_SAT_Color(paramsHat,rt,funcForm);


% Plot SAT function.
hold on;
figure(1);clf
plot(rt,pC_hat,'k','linewidth',1);
axis([-0.04 max_time 0.4 1.1])
axis square;
hold on;
plot([lb_rt lb_rt],[0.4 1.1],'k')
plot([tHat_riseFromChance tHat_riseFromChance],[0.4 1.1],'b');
pCorrect = data(:,2)./data(:,3);
n_Cor=data(:,2);
n_Wrong=data(:,3)-data(:,2);

% Color_SHOW=['b','g','r','m','k','c'];
Color_SHOW=['k','k','k','k','k','k'];
for nPlot=1:length(data(:,3));
stdCorrect=std([ones(n_Cor(nPlot),1);zeros(n_Wrong(nPlot),1)])/data(nPlot,3)^0.5;
plot([mu_RT(nPlot) mu_RT(nPlot)],[pCorrect(nPlot) pCorrect(nPlot)+stdCorrect],Color_SHOW(nPlot),'linewidth',4);
plot([mu_RT(nPlot) mu_RT(nPlot)],[pCorrect(nPlot) pCorrect(nPlot)-stdCorrect],Color_SHOW(nPlot),'linewidth',4);
plot(mu_RT(nPlot),pCorrect(nPlot),'o', 'MarkerFaceColor', Color_SHOW(nPlot),'markersize',20 );
end
% plot(mu_RT(2),pCorrect(2),'.','markersize',40);
% plot(mu_RT(3),pCorrect(3),'r.','markersize',40);
% plot(mu_RT(4),pCorrect(4),'m.','markersize',40);
% plot(mu_RT(5),pCorrect(5),'k.','markersize',40);
% plot(mu_RT(6),pCorrect(6),'c.','markersize',40);
plot(rt,pC_hat,'k','linewidth',3);

set(gca,'fontsize',16);
xhand=get(gca,'xlabel');
set(xhand,'string','time (sec)','fontsize',20);
yhand=get(gca,'ylabel');
set(yhand,'string','probability of correct','fontsize',20);
thand=get(gca,'title');
set(thand,'string',subID,'fontsize',20);
%figName = ['figures/SAT_v3_' subID];
%saveas(h,figName,'fig');
%saveas(h,figName,'eps');
xlabel('time')
ylabel('probability of correct');


