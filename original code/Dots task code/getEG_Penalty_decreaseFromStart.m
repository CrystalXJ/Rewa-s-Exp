function [maxEG,t_maxEG,pC_afo_t,t_grid,EGsum_afo_t,gain_afo_t]=getEG_Penalty_decreaseFromStart(SAT_params,gain_params,t_grid,funcForm,max_time)
%
% 2013.02.28.
% update: get the maximum EG and the corresponding timing.
% Input arguments:
%    - SAT_params: parameter vector for the SAT function.
%    - gain_params: parameter for the decreasing reward schedule. 1st:
%    starting value; 2nd: decrease rate; 3rd: time the money bar starts
%    decreasing.
%
%
% compute expected value given SAT and reward schedule.
%
% YHL.2011.
% 4/1/2013. not work:try increasing reward before t_tiseFromChance.
% 2014.02 add penalty factor (EP_afo_t)
% 2014.03.18 change the function name we used in this funciton

if isempty(t_grid)
    t_grid=0:0.01:max_time;
end

nt=length(t_grid);

%% compute the SAT function: probability of correct as a function of time.
pC_afo_t = getPC_SAT_Color(SAT_params,t_grid,funcForm); % probability of correct as function of time
pW_afo_t = 1-pC_afo_t;                                  % probability of wrong as function of time
% Get parameters for the decreasing reward schedule.
gs = gain_params(1); % Start value
b  = gain_params(2); % Decrease rate
t_std = gain_params(3); % Time the money bar starts decreasing.

%% Define decreasing reward schedule
[xx,indx_t_std]=min(abs(t_grid-t_std));  % Index for t_std in t_grid
% 
for i=1:nt
    gain_afo_t(i) = gs + b*(t_grid(i));
    if gain_afo_t(i)<0
        gain_afo_t(i)=0;
    end
end
% for i=1:nt
%     if i<=indx_t_std
%         gain_afo_t(i)=gs;
%         %gain(i)=b_gain*t_grid(i);
%     else
%         gain_afo_t(i) = gs + b*(t_grid(i-indx_t_std));
%     end
%     if gain_afo_t(i)<0
%         gain_afo_t(i)=0;
%     end
% end

%% Exepcted gain (EG). 
EG_afo_t = (gain_afo_t.*pC_afo_t);    % Expected gain as function of time (gain * probability of correct)
EP_afo_t = (-gain_afo_t).*pW_afo_t;   % Expected loss = Expected gain (loss * probability of wrong)
EGsum_afo_t = EG_afo_t + EP_afo_t;    % sum of expected gain as function of time
[maxEG,indx_maxEG] = max(EGsum_afo_t);
t_maxEG = t_grid(indx_maxEG);


