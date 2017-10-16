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
        %IBI = IBI_levels(level);
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

    %IBI is constant throughout stimulus:
    IBI = mean(diff(beats));
    %calculate vectors: 
    Vectors = 2*pi*(beats_tap-taps')/IBI;
    %circular stats:
    meanVector = circ_r(Vectors');
    [p_Rayleigh, ~] = circ_rtest(Vectors);
    %Mean Asynchrony:
    meanAsync = mean(beats_tap-taps');
end