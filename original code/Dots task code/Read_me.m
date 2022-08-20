function Read_me
%
%
% The main function is "getMoneyParams_Colorpain_lottery.m"
% getMoneyParams_Colorpain_lottery(subID,funcForm,max_probC,lottery)
%   - subID    : subject's ID     
%   - funcForm : please set it as 1
%   - max_probC: When first time you analyze data, set 1, and then adjust this number based on subject's performance.
%
% "inputs" foledr : the parameters for session 1 (pre-test session)
% "data"   folder : outcomes from the experiments
%
% In the input fodler, there are 16 subjects' mat files, each file is 10*1
% structures (10 blocks). There are 36 trials/block. 
%
% ------------------------------------------------------------------------
% ----------------------- Introduction for variables ---------------------
%
% nTrialsPB         : number of tiral per block
% timeLimit         : duration for showing sampled-dots and making response (s)  
% redDomi           : the dominated color is red or not (1 = red dominated)
% sampleRate        : the frequency of showing sampled dots (Hz) (20Hz = 50ms/dots)
% redRatio          : ratio = red : green (each block used the same number)
% apXYD             : the size of aperture (degree) 
% trial_redDomi     : the dominated color is red or not (1 = red dominated)for 36 trials.
% trial_timeLimit   : the duration for showing dots and making response for 36 trials.
% trial_redLeft     : the location of two color options (1 = red located on left) for 36 trials.
% Pair_TimeDomiShif : how to pair Time and Dominated color and location of options
% trial_redRatio    : supposed red is dominated color, ratio = red : green, for 36 trials
% trial_samples     : trials*dots = 36*70, because maximun dots is 84 dots (4.2s * 20Hz), for 36 trials.
% 1 = red, 0 = green, -1 = no sampling
% realRED           : red:green, computed from sampling  
% trial_x_shift     : defined the coordinate for dots (x-axis)
% trial_y_shift     : defined the coordinate for dots (y-axis)
%
% ------------------------------------------------------------------------
% ----------------------- Introduction for outcome -----------------------
%
% Column 1       2          3           4     5   6        7        8          9       
%     blockNo, trialNo, buttonPress, chooseR, RT, win, total_sum, correct, chooseLeft