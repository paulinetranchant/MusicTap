function [taps,nb_doubletaps] = MusicTapCut(alltaps,beats)
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