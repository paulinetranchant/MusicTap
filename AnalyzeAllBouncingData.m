load alldataMocapBouncNew
%Stimuli: 
MetroName = {'Metro476', 'Metro506'};
SpontName = {'Spont1', 'Spont2'};
beats = xlsread('SongList_BeatsTracker');

IBIMetro = [476 506];
temp_beat = 0:1:23; 
beatsMetro = [temp_beat*476+9921;temp_beat*506+10016];

%Participants' groups
GroupName = {'PS','CO'}; %PS = Poor BEat Finders, CO = Controls
NbPS = 17; NbCO = 20;%Number of participants in each group
NbPart = [NbPS NbCO]; 

currentDirectory = cd;
%ReflectorDim = 41; % right knee (side reflector) in direction of maximal amplitude

BounceResults = struct;
meanVector=NaN(10,20); pRayleigh=NaN(10,20);
meanAsync=NaN(10,20); level=NaN(10,20);
MetromeanVector=NaN(2,20); MetropRayleigh=NaN(2,20);
MetromeanAsync=NaN(2,20); Metrolevel=NaN(2,20);
Period_Spont=NaN(2,20); CV_Spont=NaN(2,20);
for group = 1:2
    for subj = 1:NbPart(group)
        SkipPart = ExcludeParticipant_mocap(group,subj);
        if SkipPart == 1
           %continue
        else
            for trial = 1:10 %Music
                name = char(strcat('MocapBouncData.',GroupName(group),num2str(subj),...
                    '.Music{',num2str(1),',',num2str(trial),'}'));
                Data = eval(name);
                [stimstart, stimend] = StimulusTiming(Data);
              
                Scores = MusicBounceGetScores(Data,stimstart,stimend,beats(trial,:),0);
                meanVector(trial,subj) = Scores(1); pRayleigh(trial,subj) = Scores(2);
                meanAsync(trial,subj) = Scores(3); level(trial,subj) = Scores(4);
                clear Scores
            end
            
            for trial = 1:2 %metronome
                name = char(strcat('MocapBouncData.',GroupName(group),num2str(subj),...
                    '.Metro{',num2str(1),',',num2str(trial),'}'));
                Data = eval(name);
                [stimstart, stimstop] = StimulusTiming(Data);

                Scores = MusicBounceGetScores(Data,stimstart,stimend,beatsMetro(trial,:),0);
                MetromeanVector(trial,subj) = Scores(1); MetropRayleigh(trial,subj) = Scores(2);
                MetromeanAsync(trial,subj) = Scores(3); Metrolevel(trial,subj) = Scores(4); 
            end                    
                %Spont: à partir de 10 000 et 24 bounces suivants, calculer
                %mean IBI et CV
            for trial = 1:2 %Spont
                name = char(strcat('MocapBouncData.',GroupName(group),num2str(subj),...
                    '.Spont{',num2str(1),',',num2str(trial),'}'));
                Data = eval(name);
                BounceTime = GetBounces(Data,1,40000,41,100);%stimstart/end = file start/end
                %Spont_nbBounce(trial,subj) = length(BounceTime);
                %Plus petit nombre de bounces chez les BFD: 24
                %Plus petit nombre de bounces chez Contrôles: 24
                IncludedBounce = BounceTime(4:24);
                ITIs = diff(IncludedBounce);
                CV_Spont(trial,subj) = std(ITIs)/mean(ITIs);
                Period_Spont(trial,subj) = mean(ITIs);
                clear ITIs
            end
        end
    end
    %Save Music results in struct:
    eval(['BounceResults.' char(GroupName(group)) 'Music.meanVector = meanVector;']);
    eval(['BounceResults.' char(GroupName(group)) 'Music.pVal = pRayleigh;']);
    eval(['BounceResults.' char(GroupName(group)) 'Music.Async = meanAsync;']);
    eval(['BounceResults.' char(GroupName(group)) 'Music.BounceLevel = level;']);
    %Save Metro results in struct:
    eval(['BounceResults.' char(GroupName(group)) 'Metro.meanVector = MetromeanVector;']);
    eval(['BounceResults.' char(GroupName(group)) 'Metro.pVal = MetropRayleigh;']);
    eval(['BounceResults.' char(GroupName(group)) 'Metro.Async = MetromeanAsync;']);
    eval(['BounceResults.' char(GroupName(group)) 'Metro.BounceLevel = Metrolevel;']);
    clear meanVector pRayleigh meanAsync level
    %Save Spont Results in struct:
    eval(['BounceResults.' char(GroupName(group)) 'Spont.Period = Period_Spont;']);
    eval(['BounceResults.' char(GroupName(group)) 'Spont.CV = CV_Spont;']);
    clear MetromeanVector MetropRayleigh MetromeanAsync Metrolevel Period_Spont CV_Spont
end

