function Scores = MusicBounceGetScores(Data,stimstart,stimend,beats,bouncelevel)

reflector = 41; %right knee, direction of maximal amplitude
filt = 100; %lowpass frequency in Hz            
[BounceTime] = GetBounces(Data,stimstart,stimend,reflector,filt);
BeatStart = beats(1)-0.2*(beats(2)-beats(1));% first IBI = beats(2)-beats(1),20% tolerance
BeatStop = beats(end)+0.2*(beats(end)-beats(end-1));

IncludedBounces = BounceTime(BounceTime>BeatStart);%same as tapping
IncludedBounces = IncludedBounces(IncludedBounces<BeatStop);%same as tapping
if size(IncludedBounces,2) > 1
    IncludedBounces = IncludedBounces';
end
[meanVector,p_Rayleigh,meanAsync,level] = TapStats(IncludedBounces,beats,bouncelevel);
Scores = [meanVector,p_Rayleigh,meanAsync,level];
clear IncludedBounces BounceTime
end

function [Bounces] = GetBounces(Data,stimstart,stimend,ReflectorDim,LowpassFreq)

VelData = mctimeder(Data);
VelData = VelData.data(:,ReflectorDim);
% upsample to 1000 Hz (increase accuracy & results in ms):
VelData = interp1(linspace(0,1,length(VelData)), VelData, ...
     linspace(0,1,5*length(VelData)));
VelData = VelData(stimstart:stimend); 

zc = DiscretizeBounce(VelData,LowpassFreq);
diffs = sort(diff(zc));
zcMedian = median(diffs(end-15:end));%only take last 15 beats because signal is 
%sometimes messy during first bounces

%remove zero crossings that are due to small "rebounds" in movement
%I checked within each problematic file that this piece of code was
%efficient
ii = 2;
while ii < length(zc)
    temp = zc(ii)-zc(ii-1);
    temp2 = zc(ii+1)-zc(ii);
    if (temp<0.75*zcMedian) && (temp2<0.75*zcMedian) 
        zc(ii) = 0;
        zc=nonzeros(zc);
    elseif temp<100 || temp2<100
        zc(ii) = 0;
        zc=nonzeros(zc);
    end
    ii = ii+1;
end

Bounces = zc;
end

function ZeroCrossings = DiscretizeBounce(Data,LowpassFreq)
%returns timing zero-crossings in signal

%lowpass filtering (remove noise):
DataFilt = FiltDataLowpass(Data,LowpassFreq);
% locate zero crossings in velocity data
ZeroCrossings = (find(DataFilt(1:(end-1))>0 & DataFilt(2:end)<=0));
end

function FilteredData = FiltDataLowpass(Data,Fc)
%Fc is the cut-off frequency. Butterworth filter.

Fs=1000;
[B,A] = butter(5,Fc/(Fs/2));
FilteredData = filtfilt(B,A,Data);

end
