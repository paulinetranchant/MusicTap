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