function run_SAT_ColorPenalty(subID,blockNo,pretest)
%
% Run tradeoff experiment.
%
%
%
% SWW.2013.
% CCT.2014.02.10.remained time was added with end fixation
% CCT.2014.03.18 Decide to use version 4 as our experiment design
% CCT.2014.03.19 
% - shrinp the size of ring and choice
% - do not use "Get -30" as loss but use Loss 30 as penalty
% - the color of reward bar changes to yellow

global red yellow gap white inputs screenInfo rightKey leftKey xCtr yCtr width_fix buttonPress
%     version=(input('which version:'));
%     v=4;
%     version=(input('which version:'));
%     v=mat2str(version);
% use version 4 : show sampling result for 1 second and then disappear
version=3;

% HideCursor
% Removes the blue screen flash and minimize extraneous warnings.
Screen('Preference', 'VisualDebugLevel', 3);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1)

%%%%--------------------------------------------------------------------
%%%% setting parameters for screen and colors

% Open a onscreen window.
% whichScreen=max(Screen('Screens'));
% bkgColor = [0 0 0];
white = [255 255 255];
yellow = [255 255 0];
red = [255 0 0];
screenInfo = my_openExperiment(32,50,0);
textSize=24;Screen(screenInfo.curWindow,'TextSize',textSize);
lineHeight=1.5*textSize;
textFont='Arial';Screen(screenInfo.curWindow,'TextFont',textFont);
xCtr=screenInfo.screenRect(3)/2;
yCtr=screenInfo.screenRect(4)/2;
width_fix=16;

% Time setting
t_feedback=1.5;
t_fix_begin=1.5;
t_fix_RDM=0.5;
t_TimeBar=1;
t_fix_end=0.5;
gap = 50;



% answer setting
rightKey='j';
leftKey='f';

% reward line parameters %%%
barSize=800;
xLeft = xCtr-barSize/2;
yBar = yCtr+50;
barHeight=20;
maxSum=2000; % Set maximum sum (greater than this sum, the reward line gets reset)
pixPerDollar=barSize/maxSum;
grid_int=200;
dollarGrid=0:grid_int:maxSum;
barSizePerDollarInPix=barSize/maxSum;
dollarGridInPix=dollarGrid.*barSizePerDollarInPix;

% reward
rew_correct=60;
rew_wrong=60;
rew_tooSlow=60;
% RT_bonus=10;

%%%%--------------------------------------------------------------------
%%%% setting input and output direction

% This would load dotInfo and inputs, 2 structural arrays from inputfile.

if pretest==1
    inputfile=['inputs/Pretest_' subID '_SAT_Color.mat'];
    % Open up results file for writing subjects' behavioral results to file.
    resultsfile=['data/Pretest_' subID '_SAT_Color.txt'];
    fid=fopen(resultsfile,'a');
    
else
    inputfile=['inputs/Test_' subID '_SAT_Color.mat'];
    % Open up results file for writing subjects' behavioral results to file.
    resultsfile=['data/Test_' subID '_SAT_Color.txt'];
    fid=fopen(resultsfile,'a');
end
load(inputfile);
nTrialsPB=inputs(blockNo).nTrialsPB;
slack = Screen('GetFlipInterval',screenInfo.curWindow)/2;




% Wait for backtick signal to initiate the experiment. The MR console will send backtick signal once
% the scanning starts.
centerText(screenInfo.curWindow,['Block ' num2str(blockNo)],xCtr,yCtr,white)
centerText(screenInfo.curWindow,'Press 9 to begin',xCtr,yCtr+50,white)
Screen('Flip',screenInfo.curWindow);

while 1
    [tik,secs,keyCode]=KbCheck;
    if tik
        if strcmp(KbName(keyCode),'9(')||strcmp(KbName(keyCode),'9')
            break
        end
        while KbCheck;end
    end
end

% load output file. because want to get total_sum
% outputdir = [pwd '/data/'];
datafile = resultsfile;
data = load(datafile);
nPrevTrials=size(data,1);
if blockNo==1
    total_sum=0;
else
    total_sum= data(nPrevTrials,7);
end
rewLineTotal=mod(total_sum,maxSum);

%%%%--------------------------------------------------------------------
%%%% experiment start
Time_frame=ones(inputs(1).nTrialsPB,length(inputs(1).trial_samples(1,:))+1000)*-1;
for trialNo=1:nTrialsPB
    
    if pretest ==1
        max_time=4.2;
    elseif pretest ==0
        max_time=max(inputs(1).trial_timeLimit);
    end
    Screen('Flip',screenInfo.curWindow);
    
    % draw yello fixation to alert subjects
    Screen(screenInfo.curWindow,'DrawLine',yellow,xCtr,yCtr-width_fix/2,xCtr,yCtr+width_fix/2,2);
    Screen(screenInfo.curWindow,'DrawLine',yellow,xCtr+width_fix/2,yCtr,xCtr-width_fix/2,yCtr,2);
    
    t_fixStart=Screen(screenInfo.curWindow,'Flip');
    Screen(screenInfo.curWindow,'Flip',t_fixStart+t_fix_begin-slack);
    
    
    %%%%--------------------------------------------------------------------
    %%%% Show RDM stimulus and get response. !!!
    
    [chooseLeft,RT,buttonPress] = sampling_SAT_color(blockNo,trialNo,max_time,version);
    % chooseLeft = 1 means subject choose left option ;
    % chooseLeft = 0 means his/her answer is right one.
    
    %%%%--------------------------------------------------------------------
    %%%%%%%%%%%%%%   Judgement   %%%%%%%%%%%%%%%%%%
    redLeft=inputs(blockNo).trial_redLeft(trialNo,1) ;
    if chooseLeft ~=-1
        if chooseLeft == redLeft
            chooseR=1;
        elseif chooseLeft ~= redLeft
            chooseR=0;
        end
    else
        chooseR=-1;
    end
    
    
    % Determine if subjects made the correct response
    % (Display feedback on winning.)
    win=-1;
    if inputs(blockNo).trial_redDomi(trialNo,1) == 1
        correctIsR = 1;
    else
        correctIsR = 0;
    end
    
    if chooseR~= -1
        % if they reaction in time, chooseR=1 or 0, then we can compare
        % thier answer with direction we set in current trial.
        if abs(chooseR - correctIsR) ==0
            win=rew_correct;
            correct=1;
            centerText(screenInfo.curWindow,['Correct: Win ' num2str(win) ' points'],xCtr,yCtr-30,yellow)
        elseif abs(chooseR - correctIsR) ==1
            win=-rew_wrong;
            correct=0;
            centerText(screenInfo.curWindow,['Wrong: Loss ' num2str(rew_wrong) ' points'],xCtr,yCtr-30,white)
        end
        
    elseif chooseR==-1
        win=-rew_tooSlow;
        correct=-1;
        centerText(screenInfo.curWindow,['Too Slow! Loss ' num2str(rew_tooSlow) ' points'],xCtr,yCtr-30,white)
        
    end
    
    t_feedbackStart=Screen(screenInfo.curWindow,'Flip',[],1);
    total_sum=total_sum+win;    %cumulative winning from the start of the experiment.
    rewLineTotal=rewLineTotal+win;
    
    %%%%--------------------------------------------------------------------
    
    % Display reward line.
    if rewLineTotal>maxSum
        rewLineTotal=rewLineTotal-maxSum;
        centerText(screenInfo.curWindow,'Congratulations!! $40 just deposited to your account',xCtr,yCtr-yCtr/2,yellow)
    end
    if rewLineTotal<0
        rewLineTotalInPix=0;
    else
        rewLineTotalInPix=round(rewLineTotal*pixPerDollar);
    end
    Screen('FillRect',screenInfo.curWindow,yellow,[xLeft yBar xLeft+rewLineTotalInPix yBar+barHeight]);
    
    % Draw dollar grid line and mark dollar in number on screen
    for grid=1:length(dollarGrid)
        centerText(screenInfo.curWindow,num2str(dollarGrid(grid)),xLeft+dollarGridInPix(grid),yBar+barHeight+20,white)
        Screen('DrawLine',screenInfo.curWindow,white, xLeft+dollarGridInPix(grid), yBar+barHeight, xLeft+dollarGridInPix(grid) ,yBar+barHeight-10, 1);
    end
    
    
    
    t_feedbackStart2=Screen(screenInfo.curWindow,'Flip');
    Screen(screenInfo.curWindow,'Flip',t_feedbackStart2+t_feedback-slack,1);
    
    %%%%-------------------------------------------------------------------
    
    % Draw the fixation with remained time
    if 0 <= RT && RT<= inputs(blockNo).trial_timeLimit(trialNo,1)  %(current time add with force response time)
        t_end = t_fix_end;
    elseif RT == -1
        t_end = t_fix_end;
    else
        t_end = t_fix_end;
    end
    
    Screen(screenInfo.curWindow,'DrawLine',white,xCtr,yCtr-width_fix/2,xCtr,yCtr+width_fix/2,2);
    Screen(screenInfo.curWindow,'DrawLine',white,xCtr+width_fix/2,yCtr,xCtr-width_fix/2,yCtr,2);
    
    
    t_trial_end=Screen(screenInfo.curWindow,'Flip');
    Screen(screenInfo.curWindow,'Flip',t_trial_end+t_end-slack,1);
    
    
    % write results to file
    fprintf(fid,'%i\t %i\t %i\t %i\t %.4f\t %i\t %i\t %i\t %i\n',...
        blockNo,trialNo,buttonPress,chooseR,RT,win,total_sum,correct,chooseLeft);
    
end


Screen('CloseAll');
ShowCursor;


