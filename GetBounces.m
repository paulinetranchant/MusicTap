function [Bounces] = GetBounces(Data,stimstart,stimend,ReflectorDim,LowpassFreq)

VelData = mctimeder(Data);%velocity data structure (first derivative)
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
