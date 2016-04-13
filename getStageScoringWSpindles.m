function [InfoSpindles] = getStageScoringWSpindles(iSpindles, iScoring)
% 
% [InfoSpindles] = getStageScoringWSpindles(iSpindles, iScoring)
% 
% 
% 

% ex: getStageScoringWSpindles('AllSpindle.mat','cICA_cga_SleepEEG_MSL_07MG_01.vmrk.mat')

oScoring = [strrep(iScoring(1:end-4),'.','_') '_cleared.mat'];

clearVMRK(iScoring,oScoring) % Clear multiple scoring

clear iScoring % Remove old Scoring filename

load(oScoring) % Load new scoring
load(iSpindles) % Load spindles

oScoringSplit =strsplit(oScoring,'_');
sub = oScoringSplit(5); % Name of the subject
night = oScoringSplit(6); % Night

indexScoring = find(strcmp(NameEvent, 'Scoring'));
Scoring = TimeEvent{1,indexScoring}; % Get scoring Information

[mScoring, mDescription, changeScoring] =  concatenateScoring(Description{1,indexScoring},Scoring);

% Spindles selected                     
selectSpindle = AllSpindle(logical(strcmp({AllSpindle.subject},sub) & ...
                         strcmp({AllSpindle.night},night) & ...
                         ([AllSpindle.oldClassif])));
                     
MSL_CTRL = selectSpindle(1).MSL;

if MSL_CTRL
    MSL_CTRL = 'MSL';
else
    MSL_CTRL = 'CTRL';
end

% Spindles not selected                     
unSelectSpindle = AllSpindle(logical(strcmp({AllSpindle.subject},sub) & ...
                         strcmp({AllSpindle.night},night) & ...
                         (~[AllSpindle.oldClassif])));

% Initialise outputs for merged chuncks of sleep stage scoring
mergedStatsSpindles.names = {'Selected', 'UnSelected'};
mergedStatsSpindles.nb = zeros(2, length(mScoring));
mergedStatsSpindles.freq = zeros(2, length(mScoring));
mergedStatsSpindles.dur = zeros(2, length(mScoring));
mergedStatsSpindles.amp = zeros(2, length(mScoring));

% Initialise outputs for each chuncks of sleep stage scoring
chunkStatsSpindles.nb = zeros(2, length(Scoring));
chunkStatsSpindles.freq = zeros(2, length(Scoring));
chunkStatsSpindles.dur = zeros(2, length(Scoring));
chunkStatsSpindles.amp = zeros(2, length(Scoring));

interscoring = Scoring(2)-Scoring(1)-1;
for nScoring=1:length(Scoring)
    foundSelectSpindles = (Scoring(nScoring) < [selectSpindle.latency]) .* ...
        (Scoring(nScoring)+interscoring-1 > [selectSpindle.latency]);
    
    foundUnSelectSpindles = (Scoring(nScoring) < [unSelectSpindle.latency]) .* ...
        (Scoring(nScoring)+interscoring-1 > [unSelectSpindle.latency]);
    
    %   Fill Amp Dur and Freq Selected
    if ~isempty(find(foundSelectSpindles, 1))
        indexes = find(foundSelectSpindles, 1);
        currentSelectedSpindles = selectSpindle(indexes);
        chunkStatsSpindles.amp(1, nScoring) = mean([currentSelectedSpindles.amplitude]);
        chunkStatsSpindles.dur(1, nScoring) = mean([currentSelectedSpindles.duration]);
        chunkStatsSpindles.freq(1, nScoring) = mean([currentSelectedSpindles.frequency]);
    end
    
    %   Fill Amp Dur and Freq UnSelected
    if ~isempty(find(foundUnSelectSpindles, 1))
        indexes = find(foundUnSelectSpindles, 1);
        currentUnSelectedSpindles = unSelectSpindle(indexes);
        chunkStatsSpindles.amp(2, nScoring) = mean([currentUnSelectedSpindles.amplitude]);
        chunkStatsSpindles.dur(2, nScoring) = mean([currentUnSelectedSpindles.duration]);
        chunkStatsSpindles.freq(2, nScoring) = mean([currentUnSelectedSpindles.frequency]);
    end
    
    chunkStatsSpindles.nb(1, nScoring) = sum(foundSelectSpindles);
    chunkStatsSpindles.nb(2, nScoring) = sum(foundUnSelectSpindles);
end

% % % 
% Save merged sleep stages scoring

for nMScoring=1:length(changeScoring)-1
    startStage = changeScoring(nMScoring);
    endStage = changeScoring(nMScoring+1)-1;

    mergedStatsSpindles.amp(:, nMScoring) = mean(chunkStatsSpindles.amp(:, startStage:endStage),2);
    mergedStatsSpindles.dur(:, nMScoring) = mean(chunkStatsSpindles.dur(:, startStage:endStage),2);
    mergedStatsSpindles.freq(:, nMScoring) = mean(chunkStatsSpindles.freq(:, startStage:endStage),2);
    mergedStatsSpindles.nb(:, nMScoring) = sum(chunkStatsSpindles.nb(:, startStage:endStage),2);    
end

startStage = changeScoring(end);
mergedStatsSpindles.amp(:, end) = mean(chunkStatsSpindles.amp(:, startStage:end), 2);
mergedStatsSpindles.dur(:, end) = mean(chunkStatsSpindles.dur(:, startStage:end), 2);
mergedStatsSpindles.freq(:, end) = mean(chunkStatsSpindles.freq(:, startStage:end), 2);
mergedStatsSpindles.nb(:, end) = sum(chunkStatsSpindles.nb(:, startStage:end), 2);    


% % % % Fin du script


InfoSpindles.mergedStatsSpindles = mergedStatsSpindles;
InfoSpindles.chunkStatsSpindles = chunkStatsSpindles;
InfoSpindles.chunkStatsSpindles.sleepStages = Description{1, indexScoring};
InfoSpindles.mergedStatsSpindles.sleepStages = mDescription;
InfoSpindles.sub = sub;
InfoSpindles.nightOrder = night;
InfoSpindles.night = MSL_CTRL;

clearvars -except InfoSpindles

save(char(strcat('extractionSpindlesInfo_', ...
        InfoSpindles.sub, '_', ...
        InfoSpindles.nightOrder, '_', ...
        InfoSpindles.night, '.mat')),'InfoSpindles');
    
disp('File saved')


