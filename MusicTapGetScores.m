function Scores = MusicTapGetScores(data,taplevel)
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
    
Scores = [meanVector,pRayleigh,meanAsync,level,double_tap];
end

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
end

