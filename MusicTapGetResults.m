function TapResults = MusicTapGetResults(data,taplevel)
%TapResults gives a matrix with each line corresponding to a stimulus
%Outcomes: mean vector in first column, p value for the Rayleigh test
%in second column, mean asynchrony in third column, chosen beat level in fourth
%column and number of double taps in last column.
%taplevel is a vector with taplevels for each trias
%a taplevel shoud be set to 0 for level closest
%to the mean ITI
%taplevel should be set to 1or 2 if we want to force the beat level 
%1 = beat level, 2 = two-beat level (twice faster)
%e.g.: [0 0 0 0 1 0 2 0 0 0]

nb_stim = 10;
%beat locations in stimulus:
beats = xlsread('SongList_BeatsTracker');

[taps_allstim_temp] = GetTap(data);
%gives matrix with taps,one row per stimulus
%stimuli are ordered in alphabetical order, as for the Beat
%Tracker files

meanVector= NaN(nb_stim,1); pRayleigh= NaN(nb_stim,1);
meanAsync= NaN(nb_stim,1); level = NaN(nb_stim,1);
double_tap = NaN(nb_stim,1);
       
% calculate output for all stim
for stim = 1: nb_stim
    %select taps corresponding to the 24 analyzed beats, double taps, and
    %delay due to equipment:
    [taps, nb_double] = CutTaps(taps_allstim_temp(stim,:),beats(stim,:));
    double_tap(stim) = nb_double;%nb of double taps before processing (second tap is removed)
    taplevel_stim = taplevel(stim);
    [meanVector(stim),pRayleigh(stim),meanAsync(stim),level(stim)] = TapStats(taps,beats(stim,:),taplevel_stim);
end
    
TapResults = [meanVector,pRayleigh,meanAsync,level,double_tap];


function [taps_allstim] = GetTap(file)
%This function extract taps from a data file 
%The output is a matrix with 10 rows (one per stimulus, organized in alphabetical order)
%(zero-padding at the end of each line because number of taps differ
%between stimuli)

nb_Stim = 10;
%to later reorder stimuli 
order = [3 7 4 2 5 10 1 9 6 8];

%%Stimulus delimitation
trial_nb = file(:,2);
stimstart = NaN(1,length(nb_Stim)-1); stimstop = NaN(1,length(nb_Stim)-1);
for ii = 1:nb_Stim-1
    stimstart(ii) = find(trial_nb==ii,1);
    stimstop(ii) = find(trial_nb==ii+1,1)-1;
end
stimstart(nb_Stim) = stimstop(nb_Stim-1)+1; stimstop(nb_Stim)=length(file(:,1));
    
allstim = zeros(10,100);
for stim = 1:nb_Stim
    datastim = file(stimstart(stim):stimstop(stim),:);
    taps = datastim(:,5);
    taps = taps(datastim(:,3)==1);
    %reorder:
    stimorder = file(stimstart(stim)+50,1); %+50 because first row of stimulus can be messy
    allstim(order(stimorder),1:length(taps)) = taps;
    clear datastim taps ITIs stimorder
end
taps_allstim = allstim;

function [meanVector,p_Rayleigh,meanAsync,level] = TapStats(taps,beats,taplevel)
%taplevel shoud be set to 0 if we want the script to decide which beat level (stimulus)
%is closest to mean ITI (taps)
%taplevel should be set to 1 or 2 if we want to force the script 
%to apply a pre-specified beat level 
%1 = beat level, 2 = two-beat level (twice faster)
%Pauline Tranchant, 2017

%create vector of beats at the two-beat level (twice faster):
beats_two = NaN(1,47);
beats_two(1:2:end)=beats;
A = 0.5 * (beats(1:end-1) + beats(2:end));
beats_two(2:2:end-1) = A;

%create vectors of beats at the half-beat level (twice slower)
%need two vectors, on for "up-beat" and one for "down-beat"
beats_half = [beats(1:2:end-1);beats(2:2:end)];

%we stop if no data (will output NaN) or less than 6 taps (will output 999)
if isempty(taps)
    meanVector = NaN; p_Rayleigh= NaN; meanAsync = NaN; level = NaN;
elseif length(taps) < 6
    meanVector = 999; p_Rayleigh= 999; meanAsync = 999; level = 999; 
else
    if taplevel == 0 
        %the script must find which level the participant produced 
        %and create a vector of stimulus beats accordingly
        %find beat level:
        ITI = median(diff(taps))*ones(1,3); %inter-tap-iterval
        IBI = mean(diff(beats)); %inter-beat-interval
        IBI_levels = [IBI,0.5*IBI,2*IBI];% [beat level,twice faster,twice slower]
        [~,level] = min(abs(ITI-IBI_levels));%find beat level
        IBI = IBI_levels(level);
        % if twice slower we need to find whether the participant did tap
        % up- or down-beat, and we do it by finding which case gives
        % smaller asynchronies (distance between beat and tap)
        if level == 3 
            beats_tap_temp = NaN(2,length(taps));
            Asyn_temp = NaN(1,2);% 
            for ii = 1:2
                jj = 1;
                while jj < length(taps)+1
                    tap_temp = taps(jj)*ones(1,length(beats_half(ii,:)));
                    dist = abs(beats_half(ii,:)-tap_temp);
                    [~,ind] = min(dist);
                    beats_tap_temp(ii,jj) = beats_half(ii,ind);
                    clear ind tap_temp dist
                    jj = jj+1;
                end
                Asyn_temp(ii) = mean(abs(beats_tap_temp(ii,:)-taps'));
                clear beats_tap
            end
            [~,ind] = min(Asyn_temp);
            beats = beats_half(ind,:);
            clear ind
        elseif level == 2 %Twice faster
            beats = beats_two;
        end
    %cases where the beat-level is pre-specified    
    elseif taplevel == 2
        beats = beats_two;
        level = 2;
    elseif taplevel == 1
        level = 1;
    end

    %now that we have the vector of stimulus beats with right level,
    %we associate each tap to a beat:
    jj = 1;
    beats_tap = NaN(1,length(taps));
    while jj < length(taps)+1
        tap_temp = taps(jj)*ones(1,length(beats));
        dist = abs(beats-tap_temp);
        [~,ind] = min(dist);
        beats_tap(jj) = beats(ind);
        clear ind
        jj = jj+1;
    end

    %calculate vectors (circular stats)
    IBI = mean(diff(beats));
    Vectors = 2*pi*(beats_tap-taps')/IBI;

    %IBI vary with beat locations:
    %Wrong! needs to calculate inter_beat based on beats only
    % inter_beat = [0 diff(beats_tap)];%we add a "zero" position
    % no_interval = find(inter_beat == 0);%possible given how beats_tap is calculated
    % inter_beat(no_interval) = median(nonzeros(inter_beat));
    % Vectors = 2*pi*(beats_tap-taps')./inter_beat;

    meanVector = circ_r(Vectors');
    [p_Rayleigh, ~] = circ_rtest(Vectors);
    meanAsync = mean(beats_tap-taps');
end

function [taps,nb_doubletaps] = CutTaps(alltaps,beats)
%trim taps to keep those corresponding to the 24 beats in the middle of
%each stimulus
%remove double taps (ITI<180ms)  
%remove delay due to equipment (8ms)
%Pauline Tranchant, 2017

%Find first and last beat we want to include
BeatStart = beats(1)-0.2*(beats(2)-beats(1));% first IBI = beats(2)-beats(1),20% tolerance
BeatStop = beats(end)+0.2*(beats(end)-beats(end-1));
%Cut data to keep 24 beats:
taps = nonzeros(alltaps); %remove zero-padding
taps = taps(taps > BeatStart);
taps = taps(taps < BeatStop);

%remove double taps:
ITIs = diff(taps);
index_doubletap = find(ITIs <= 180);
nb_doubletaps = length(index_doubletap);
taps(index_doubletap+1) = 0;
taps = nonzeros(taps);

%remove delay:
taps = taps-8;






    



