function [chooseLeft,RT,buttonPress]=sampling_SAT_color(blockNo,trialNo,max_time,version)
%
% Last updated: 2013.06.10
% Modified from my_dotsX_SAT_varLength
% version = 1 => disappear one by one
% version =3 => will remain on the screen
% YHL.2012.
% CCT. 2013.09   timeBare located on the bottom of the fixation (vertical)
% CCT.2014.02.10. time circle was presented before the dots appear!
% CCT.2014.02.17. 
% -time circle keep disappering with remained time.
% -Luminance of colors is the same.
% CCT.2014.03.03
% - randomize red Location
% CCT. 2014. 03. 12
%- change the pixel size (8->4)

global inputs screenInfo xCtr yCtr white width_fix rightKey leftKey 

%% parameter setting 
green = [0 175 0];
red = [255 0 0];
black = [0 0 0];
dotSize=4;
curWindow = screenInfo.curWindow;
rseed = screenInfo.rseed;
color = [];
color1 = [];
t_circle=1;
t_b4fixation=1;
can_not_change=0;
dontclear = screenInfo.dontclear; % dontclear = 0
frames = 0;
chooseLeft=-1;
RT=-1;
endExpt=0;

% create the square for the aperture
apRect = floor(createTRect(inputs(blockNo).apXYD, screenInfo));
% apRect = [apRect(1)-4 apRect(2)-4 apRect(3)+4 apRect(4)+4];
apD=inputs(blockNo).apXYD(:,3);     
% diameter of aperture in degree.
center = repmat(screenInfo.center,size(inputs(blockNo).apXYD(:,1)));
% size of aperture in pixels
d_ppd 	= floor(apD/10 * screenInfo.ppd);	
% where you want the center of the aperture
center = [center(:,1)+inputs(blockNo).apXYD(:,1)/10*screenInfo.ppd center(:,2)-inputs(blockNo).apXYD(:,2)/10*screenInfo.ppd]; 
apRect = [apRect(1) apRect(2) apRect(3) apRect(4)];
dot_show = [inputs(blockNo).trial_x_shift(trialNo,:);inputs(blockNo).trial_y_shift(trialNo,:)];
 
% the speed of refreshing the screen
currTime=inputs(blockNo).trial_timeLimit(trialNo);
continue_show = round(currTime*screenInfo.monRefresh);
time_total = continue_show;



dTime=inputs(blockNo).trial_timeLimit(trialNo);
stim_start = Screen('Flip',curWindow);
t_stim_pass = 1/(inputs(blockNo).sampleRate*dTime);
x=1; % for dots' x-axis location
y=1; % for dots' y-axis location
count = 1;
indx = 1;
sizeAngle = 0;
choice = [1 2];
%% before sampleing show
    % show the white circle represent time constrains for each trial.
    sizeAngle_total=(360*(currTime/max_time));
    arc_range=apD*2+10;
    Screen('FrameArc',curWindow, white, [xCtr-arc_range yCtr-arc_range xCtr+arc_range yCtr+arc_range], 0,sizeAngle_total,4);
    
    % draw the choice
    dirR=170;
    radius_choice=30;
    RedisLeft=inputs(blockNo).trial_redLeft(trialNo,1) ;
%     d_dir = d_ppd/2 + 60*2 + 10*screenInfo.ppd/10; % choice circle radius
%     angle = pi*[0 180]'/180; %show 2 Answer
    dir_show = [dirR 0; -dirR 0]+repmat(center(1,:),2,1);
    if RedisLeft == 1
        Left_color=red;
        Right_color=green;
    else
        Left_color=green;
        Right_color=red;
    end
    Screen('FillOval', curWindow, Right_color, [dir_show(choice(1),1)-radius_choice, dir_show(choice(1),2)-radius_choice, dir_show(choice(1),1)+radius_choice, dir_show(choice(1),2)+radius_choice]');
    Screen('FillOval', curWindow, Left_color, [dir_show(choice(2),1)-radius_choice, dir_show(choice(2),2)-radius_choice, dir_show(choice(2),1)+radius_choice, dir_show(choice(2),2)+radius_choice]');
    t_Time=Screen(screenInfo.curWindow,'Flip');
    Screen(curWindow,'Flip',t_Time+t_circle);
    
    % fixation
    Screen(screenInfo.curWindow,'DrawLine',white,xCtr,yCtr-width_fix/2,xCtr,yCtr+width_fix/2,2);
    Screen(screenInfo.curWindow,'DrawLine',white,xCtr+width_fix/2,yCtr,xCtr-width_fix/2,yCtr,2);
    t_whiteFix=Screen(screenInfo.curWindow,'Flip');
    Screen(curWindow,'Flip',t_whiteFix+t_b4fixation);
    
    %% Begin!
start_time = GetSecs;
while continue_show
    
    if frames>=1
        [buttonPress,time,keyCode]=KbCheck;
        if can_not_change==0;
        if buttonPress
            if strcmp(KbName(keyCode),rightKey)
                chooseLeft=0;
                RT = time-start_time;
                can_not_change=1;
            elseif strcmp(KbName(keyCode),leftKey)
                chooseLeft=1;
                RT = time-start_time;
                can_not_change=1;
            elseif strcmp(KbName(keyCode),'esc')
                endExpt=1;
                break
            end
        end
        end
    end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen('Flip', curWindow,0,dontclear);
    % Flip by default will sync with vertical retrace.    
    Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    %   Screen('FillRect', curWindow, [0 0 0 255]);

    % circle that dots do show right in
    Screen('FillOval', curWindow, [0 0 0 255], apRect(1,:));

    
    Screen('BlendFunction', curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    
    if inputs(blockNo).trial_samples(trialNo,x) == 1
        color(:,count) = red';
    else
        color(:,count) = green';
    end

    
if chooseLeft==-1
    % dots stay on the screen for 2 seconds (each second has sampled 20 dots, so we will keep 40 dots on the screen after 2s)
    overlap=inputs(1).sampleRate*2 ;
    if version == 1
        Screen('DrawDots', curWindow, dot_show(:,x)', 8, color(:,x), center(1,:));
    elseif version == 2 || version==4

        if x > overlap
        Screen('DrawDots', curWindow, dot_show(:,(x-(overlap-1)):x), dotSize, color(:,(x-(overlap-1)):x), center(1,:));
        else
        Screen('DrawDots', curWindow, dot_show(:,1:x), dotSize, color(:,1:x), center(1,:));
        end

    elseif version == 3
        Screen('DrawDots', curWindow, dot_show(:,1:x), 4, color(:,1:count), center(1,:));
        %Screen('DrawDots', curWindow, dot_show(:,1:y), 4, color1(:,1:count), center(1,:));
    end
else
end
    
% draw the choice   
       if chooseLeft ==-1   
    Screen('FillOval', curWindow, Right_color, [dir_show(choice(1),1)-radius_choice, dir_show(choice(1),2)-radius_choice, dir_show(choice(1),1)+radius_choice, dir_show(choice(1),2)+radius_choice]');
    Screen('FillOval', curWindow, Left_color, [dir_show(choice(2),1)-radius_choice, dir_show(choice(2),2)-radius_choice, dir_show(choice(2),1)+radius_choice, dir_show(choice(2),2)+radius_choice]');
       elseif chooseLeft == 1
    Screen('FillOval', curWindow, black, [dir_show(choice(1),1)-radius_choice, dir_show(choice(1),2)-radius_choice, dir_show(choice(1),1)+radius_choice, dir_show(choice(1),2)+radius_choice]');       
    Screen('FillOval', curWindow, Left_color, [dir_show(choice(2),1)-radius_choice, dir_show(choice(2),2)-radius_choice, dir_show(choice(2),1)+radius_choice, dir_show(choice(2),2)+radius_choice]');
       elseif chooseLeft == 0
    Screen('FillOval', curWindow, Right_color, [dir_show(choice(1),1)-radius_choice, dir_show(choice(1),2)-radius_choice, dir_show(choice(1),1)+radius_choice, dir_show(choice(1),2)+radius_choice]');
    Screen('FillOval', curWindow, black, [dir_show(choice(2),1)-radius_choice, dir_show(choice(2),2)-radius_choice, dir_show(choice(2),1)+radius_choice, dir_show(choice(2),2)+radius_choice]');  
       end
       
       
   if version ~=4
        time_total_1 = time_total;
    else
        time_total_1 = round(max_time*screenInfo.monRefresh);
    end
    sizeAngle = sizeAngle + (360/time_total_1);
    sizeAngle_total=(360*(currTime/max_time));
   % startAngle = sizeAngle;
    Screen('FrameArc',curWindow, white, [xCtr-arc_range yCtr-arc_range xCtr+arc_range yCtr+arc_range], 0,sizeAngle_total,4);
    arc_range_K=arc_range+2;
    Screen('FrameArc',curWindow, black, [xCtr-arc_range_K yCtr-arc_range_K xCtr+arc_range_K yCtr+arc_range_K], 0,sizeAngle,10);
 
    % make sure 50ms show a dot (each second has 60 frame, each frame take 16.67ms)
    % after about 3 frames, show a dot on the screen 
    if mod(indx,round(time_total/(currTime*inputs(blockNo).sampleRate))) == 0 
       
        x = x+1;
        count = count + 1;
        t_stim_pass = t_stim_pass + (1/(inputs(blockNo).sampleRate));
    end
    frames = frames + 1;
    continue_show = continue_show - 1;
    indx = indx + 1;  
end

% present last frame of dots
Screen('Flip', curWindow,0,dontclear);
%Screen(screenInfo.curWindow,'Flip');
% if the subject does not make a response during stimulus presentation,
% then show red fixation and the subject has to respond before the red
% fixation disappears.

if chooseLeft == -1
    % fixation for forcing response
    Screen(screenInfo.curWindow,'DrawLine',red,xCtr,yCtr-width_fix/2,xCtr,yCtr+width_fix/2,2);
    Screen(screenInfo.curWindow,'DrawLine',red,xCtr+width_fix/2,yCtr,xCtr-width_fix/2,yCtr,2);
    
    
    t_fixStart=Screen(screenInfo.curWindow,'Flip');
    
    %determine the time force subj to make response 
    fixation_but=0.25; 
    while 1
        timePast=GetSecs-t_fixStart;
        if timePast>fixation_but
            break
        end
        [buttonPress,time,keyCode]=KbCheck;
        if buttonPress
            if strcmp(KbName(keyCode),rightKey)
                chooseLeft=0;
                RT=time-start_time;

                break
            elseif strcmp(KbName(keyCode),leftKey)
                chooseLeft=1;
                RT=time-start_time;

                break
            elseif strcmp(KbName(keyCode),'ESCAPE')
                endExpt=1;
                break
            end
        end
 
    end
end
if endExpt==1
    Screen('CloseAll')
end
Screen(screenInfo.curWindow,'Flip');



