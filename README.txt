This code was written by Pauline Tranchant for the analysis of tapping data (synchronization to music). 
Ten musical stimuli (available upon request) are presented to a participant. The task consists in synchronizing finger taps with the musical beat.

Our equipment setting at BRAMS (International Laboratory for Brain, Music and Sound Research) is the following:

Taps are made on a square force sensitive resistor (3.81 cm, Interlink FSR 406), resistor is connected to an Arduino Duemilanove, timing information is transmited via the serial USB port to MAX/MSP (Cycling' 74, running on a PC HP ProDesk 600 G1, Windows 7) which also plays the stimuli.

The script MusicTapGetResults.m will output a matrix with several measures, where each line corresponds to a stimulus. We use circular statistics to analyze the data (make sure you have added the path for the CircStats Toolbox (https://www.researchgate.net/publication/228551979_The_circular_statistics_toolbox_for_Matlab)

The results are organized as follows:
 
Column 1            Column 2	     Column 3          Column 4        Column 5

mean vector         p-value for      mean asynchrony   beat level      how many double     
(on circle)         Rayleigh test    (in ms)	                       taps removed	

Stimulus are presented in a random order to a participant during the experiment and MusicTapGetResults.m reorganizes the data so that the results correspond to stimuli in alphabetical order (see SongList_BeatsTracker.xlsx)          


data files are structured as follows:

Column 1                Column 2	   Column 3       Column 4        Column 5

stimulus order		trial number       1 = tap        inter-tap-      time of tap  
(no important)				   0 = no tap	  interval        in audio file
									  (in ms)

Note that we do not keep data for the first and last seconds of the stimuli; only the taps corresponding to the 24 beats in the stimulus are included in the analysis.
