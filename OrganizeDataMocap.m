GroupName = {'PS','CO'}; %PS = Poor BEat Finders, CO = Controls
NbPS = 17; NbCO = 20; %Number of participants in each group
NbPart = [NbPS NbCO];
MusicName = {'B','BN','DS','PA','SY','SH','S','TF','TFL','WA'}; %music stimulus ID
MetroName = {'Metro476', 'Metro506'};%metronome stimuli, IOI = 476ms and 506ms
SpontName = {'Spont1', 'Spont2'};

currentDirectory = cd;
MocapBouncData = struct;

for group = 1:2 %group 1 is Poor Synchronizers, group 2 is Controls
    if group == 1
        Prefix2 = 7; %because PS have their ID starting like PS71, PS72 etc
        Prefix1 = []; 
    else
        Prefix2 = []; Prefix1 = 'C';%control participants have their ID starting with C (e.g. CPS1)
    end
    for s = 1:NbPart(group)
        SkipPart = ExcludeParticipant_mocap(group,s);%excluded from final sample
        if SkipPart == 1
            %continue
        else
        datadirname = strcat('Data/',char(GroupName(group)),'/', Prefix1,'PS',...
        num2str(Prefix2),num2str(s));
        data_dir = fullfile(currentDirectory,datadirname);
        
            for trial = 1:10 %musics
                datafilename = strcat(Prefix1, 'PS', num2str(Prefix2),num2str(s),...
                    '_',char(MusicName(trial)),'.mat');
                dataloc = fullfile(data_dir,datafilename);
                data = mcread(dataloc);

                eval(['MocapBouncData.' char(GroupName(group)) num2str(s)...
                   '.Music{' num2str(trial) '} = data;']);
                clear data
            end

            for trial = 1:2 %metronome
                datafilename = strcat(Prefix1, 'PS', num2str(Prefix2),num2str(s),...
                    '_',char(MetroName(trial)),'.mat');
                dataloc = fullfile(data_dir,datafilename);
                data = mcread(dataloc);

                eval(['MocapBouncData.' char(GroupName(group)) num2str(s)...
                   '.Metro{' num2str(trial) '} = data;']);
                clear data
            end   
            
            for trial = 1:2 %SpontBouncing
                datafilename = strcat(Prefix1, 'PS', num2str(Prefix2),num2str(s),...
                    '_',char(SpontName(trial)),'.mat');
                dataloc = fullfile(data_dir,datafilename);
                data = mcread(dataloc);

                eval(['MocapBouncData.' char(GroupName(group)) num2str(s)...
                   '.Spont{' num2str(trial) '} = data;']);
            end
        end
    end
end
save 'alldataMocapBouncNew' MocapBouncData

