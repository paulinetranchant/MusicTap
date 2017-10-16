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