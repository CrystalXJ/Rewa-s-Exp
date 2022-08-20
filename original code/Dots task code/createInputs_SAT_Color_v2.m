function inputs = createInputs_SAT_Color_v2(subID,pretest)
%
% 2014.03.10 CCT
% Sequential sampling task.
% SAT session.
% CCT. 2014.03.12
%- change the pixel size
%- change the time constrain

%% pre-setting
rseed = sum(100*clock);
rand('state',rseed);

%% Seperate per-test and test session
% In pre-test session, timeLimit only contained three conditions. More and
% more difficult condition subject will encounter from block 1 to 3 and 4
% to 6 and 7 to 9.
if pretest ==1
    timeLimit=[0.7 2.1 3.5];
    % Dominanted Color. (1 = Red ; 0 = Green)
    redDomi = [1 0]';
    nTrialsPerTime = 12;
    nBlocks = 9;
    % M2L_ratio (More to Less ratio). Means proportion of red and green balls.
    M2L_ratio=repmat([0.6 0.4;0.57 0.43;0.54 0.46],nBlocks/3);
    inputfile = ['Pretest_' subID '_SAT_Color.mat'];
    if exist(inputfile,'file')
        error('input file with this subject ID already exists')
    end
    
    % In test session, timeLimit contained six conditions(1 to 6 seconds). Each
    % block used the same ratio of dominated color to sample.
elseif pretest ==0
    timeLimit=[0.7 1.4 2.1 2.8 3.5 4.2];
    nTrialsPerTime = 6;
    nBlocks = 10;
    % Dominanted Color. (1 = Red ; 0 = Green)
    redDomi = [1 0 0 1];
    % M2L_ratio (More to Less ratio). If M2L_ratio=6:4, then you need to enter [6 4]. you could
    % also enter [0.6 0.4], or [60 40] because we are going to normalize them
    % to probability anyway. Keep in mind that More can be either red or green.
    M2L_ratio=input('Pleas tell me the Ratio of red dots\n(ex~[60 40]) :');
    M2L_ratio=repmat(M2L_ratio,nBlocks);
    inputfile = ['Test_' subID '_SAT_Color.mat'];
    if exist(inputfile,'file')
        error('input file with this subject ID already exists')
    end
    
elseif pretest ==3
    timeLimit=[0.7 1.4 2.1 2.8 3.5 4.2];
    nTrialsPerTime = 6;
    nBlocks = 1;
    % Dominanted Color. (1 = Red ; 0 = Green)
    redDomi = [1 0 0 1]';
    % M2L_ratio (More to Less ratio). If M2L_ratio=6:4, then you need to enter [6 4]. you could
    % also enter [0.6 0.4], or [60 40] because we are going to normalize them
    % to probability anyway. Keep in mind that More can be either red or green.
    M2L_ratio=input('Pleas tell me the Ratio of red dots\n(ex~[60 40]) :');
    M2L_ratio=repmat(M2L_ratio,nBlocks);
    inputfile = ['Practice_' subID '_SAT_Color.mat'];
    if exist(inputfile,'file')
        error('input file with this subject ID already exists')
    end
    
end

%% parameter setting
% Sample size in a second (Hz)
sampleRate = 20;
nPointsAtOnce=sampleRate;
% The loaction of red choice .(1 = Left choice is Red ; 0 = Right choice is Red )
redLeft = [1 0]';

% number of timeLimit
n_timeLimit = length(timeLimit);
n_color = 2;
n_shift = length(redLeft);

% n trials per block
nTrialsPB = n_timeLimit*nTrialsPerTime; % 3*12 (pre-test session); 6*6 (test session)
% n dominated color per time limit
nColorDomiPertTime = (nTrialsPB/n_timeLimit)/n_color;
% n red choice located on left per block
nRedLeftPB=nTrialsPB/n_shift;

%% create a row of parameter
vect_timeLimit = reshape(repmat(timeLimit,nTrialsPerTime,1),nTrialsPB,1);
if pretest == 1
    vect_redDomi = reshape(sort(repmat(redDomi,nColorDomiPertTime,n_timeLimit)),nTrialsPB,1);
else
    vect_redDomi = reshape(repmat(redDomi,nColorDomiPertTime,n_timeLimit/2),nTrialsPB,1);
end
vect_redLeft= repmat(redLeft,nRedLeftPB,1);
show_Pair_TimeDomiShif=[vect_timeLimit vect_redDomi vect_redLeft]

%% maxmize sample size for each trial
nSamplesMax = max(timeLimit)*sampleRate;
vect_samples = zeros(1,nSamplesMax);

%% size of aperture
%according to Newsome, 1988. He puts the Random-dots in a circular
%aperture (10¢X). so we use half of 10¢X to estimate diameter
distance=60; % 60 cm from screen to eyes
ap_diameter=tan(5*pi/180)*10*distance;

for i=1:nBlocks
    inputs(i).nTrialsPB = nTrialsPB;
    inputs(i).timeLimit = timeLimit;
    inputs(i).redDomi = redDomi;
    inputs(i).sampleRate = sampleRate;
    inputs(i).redRatio = M2L_ratio(i,1);
    inputs(i).apXYD = [0 0 ap_diameter];
    % want to randomize color dominance.
    randOrder = randperm(nTrialsPB);
    randVect_redDomi = vect_redDomi(randOrder,:);
    % want to randomize time limit
    randVect_timeLimit = vect_timeLimit(randOrder);
    % randomly shift red_choice
    randVect_redLeft = vect_redLeft(randOrder,:);
    
    for j=1:nTrialsPB
        inputs(i).trial_redDomi(j,1) = randVect_redDomi(j);
        inputs(i).trial_timeLimit(j,1) = randVect_timeLimit(j);
        inputs(i).trial_redLeft(j,1) = randVect_redLeft(j);
        inputs(i).Pair_TimeDomiShif = show_Pair_TimeDomiShif;
        
        %% start drawing samples based on ratio we set
        % if dominated color is red, the redRatio is higher. (EX: 0.55)
        redCut = M2L_ratio(i,1)/sum(M2L_ratio(i,1:2));
        if inputs(i).trial_redDomi(j,1)==1
            inputs(i).trial_redRatio(j,1)=redCut;
        elseif inputs(i).trial_redDomi(j,1)==0
            inputs(i).trial_redRatio(j,1)=1-redCut;
        end
        
        % sample size for each trial(use 0 an d 1 represent green and red, -1 means no sampling)
        nSamplesThisTrial = inputs(i).trial_timeLimit(j,1)*sampleRate;
        sampleIsRed = rand(1,nSamplesThisTrial)<=inputs(i).trial_redRatio(j,1);
        vect_samples(1:nSamplesThisTrial)=sampleIsRed;
        vect_samples(nSamplesThisTrial+1:nSamplesMax)=-1;
        inputs(i).trial_samples(j,:)=vect_samples;
        inputs(i).realRED(j,1)=sum(inputs(i).trial_samples(j,1:nSamplesThisTrial))/nSamplesThisTrial;
        
        % sample location
        x_grid = -ap_diameter:5:ap_diameter;
        n_x = length(x_grid);
        y_grid = -ap_diameter:5:ap_diameter;
        n_y = length(y_grid);
        x_possible = reshape(repmat(x_grid,n_y,1),1,n_x*n_y); % repeat x_grid this matrix n_y times
        y_possible = repmat(y_grid,1,n_x); % repeat y_grid this matrix n_x times
        x_final = zeros(1,nSamplesThisTrial);
        y_final = zeros(1,nSamplesThisTrial);
        n_possible = length(x_possible);
        rand_indx_points = zeros(1,nSamplesThisTrial);
        if nSamplesThisTrial<nPointsAtOnce
            rand_indx_points(1:nSamplesThisTrial)=randsample(n_possible,nSamplesThisTrial);
            x_final=x_possible(rand_indx_points);
            y_final=y_possible(rand_indx_points);
        else
            rand_indx_points(1:nPointsAtOnce)=randsample(n_possible,nPointsAtOnce);
            
            for sampNo=1:nPointsAtOnce
                x_final(sampNo)=x_possible(rand_indx_points(sampNo));
                y_final(sampNo)=y_possible(rand_indx_points(sampNo));
            end
            % to avoid overlapping, we have to modified the location.
            for sampleNo=nPointsAtOnce+1:nSamplesThisTrial
                while 1
                    rand_indx_points_curr = randsample(n_possible,1);
                    sum_same = sum(rand_indx_points_curr == rand_indx_points(sampleNo-1:-1:sampleNo-nPointsAtOnce+1));
                    if sum_same==0
                        rand_indx_points(sampleNo)=rand_indx_points_curr;
                        x_final(sampleNo)=x_possible(rand_indx_points(sampleNo));
                        y_final(sampleNo)=y_possible(rand_indx_points(sampleNo));
                        break
                    end
                end
            end
        end
        
        randSample_x=x_final;
        randSample_y=y_final;
        vect_x(1:nSamplesThisTrial)=randSample_x;
        vect_y(1:nSamplesThisTrial)=randSample_y;
        
        x_shift(1:nSamplesThisTrial) = vect_x(1:nSamplesThisTrial);
        y_shift(1:nSamplesThisTrial) = vect_y(1:nSamplesThisTrial);
        x_shift(nSamplesThisTrial+1:nSamplesMax)=-1;
        y_shift(nSamplesThisTrial+1:nSamplesMax)=-1;
        
        inputs(i).trial_x_shift(j,:) = round(x_shift);
        inputs(i).trial_y_shift(j,:) = round(y_shift);
        
    end
end

inputs=inputs';
save(inputfile,'inputs');

