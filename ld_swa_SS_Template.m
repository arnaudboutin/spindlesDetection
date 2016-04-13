%% -- Workflow and Plots for Spindle Analysis -- %%
% Basic processing script for the automatic detection of spindles using the swa toolbox...

% Importing Data %
% -------------- %
% if you have scored the data
% [fileName, filePath] = uigetfile('*.set');
% load(fullfile(filePath, fileName), '-mat');
% keep_samples = EEG.swa_scoring.stages == 2;
% keep_samples(EEG.swa_scoring.arousals) = false;
% EEG = swa_selectStagesEEGLAB(EEG, keep_samples);
% 
% % for eeglab files
% [Data, Info] = swa_convertFromEEGLAB();
% 
% % or if you have previously analysed some data
% [Data, Info, SS] = swa_load_previous();
% 
% % Check for 'N2' name and call it 'Raw'...
% if isfield(Data, 'N2')
%     Data.Raw = Data.N2;
%     Data = rmfield(Data, 'N2');
% end

% Load EEG file
maindir = 'C:\Users\labdoyon01\Documents\GitHub\spindlesDetection';
cd(maindir)
% addpath('C:\Users\labdoyon01\Documents\MATLAB\eeglab13_5_4b');

% savepath([maindir, filesep, 'pathdef.m']);

eeglab
close(gcf)
% clc
% clear all

EEG = pop_loadbv();
Data.Raw = EEG.data;

% Info initialization
Info.Recording.dataDim = size(EEG.data);
Info.Recording.sRate = EEG.srate;

% Spindle Detection %
% ----------------- %
% get the default settings for spindle detection
Info = swa_getInfoDefaults(Info, 'SS');

load('channelsInfos.mat');

for nChan = 1:length(EEG.chanlocs)
    Ind = find(strcmp({ChanInfos.labels},EEG.chanlocs(nChan).labels));
    if isempty(Ind)
        currentChanInfos(1,nChan).labels = EEG.chanlocs(nChan).labels;
    else
        currentChanInfos(1,nChan) = ChanInfos(Ind);
    end
end

Info.Electrodes = currentChanInfos;

% calculate the canonical / reference / prototypical / representative / model / illustrative wave
% [Data.SSRef, Info]  = swa_CalculateReference(Data.Raw, Info, 1);

% uniqueStages = {EEG.chanlocs.labels};
%    
% [s,v] = listdlg('PromptString','Select midline:',...
%                     'SelectionMode','multiple',...
%                     'ListString',uniqueStages);
% 
% if length(s)~=3 && ~v
%     printf('error')
% end
%                 
% for i=1:length(s)
%     chanIndex(i) = find(strcmp({EEG.chanlocs.labels},uniqueStages{s(i)}));
%     disp(['Channel: ' uniqueStages{s(i)}]);
% end

% Get Index of channels for spindle detection
%Data.SSRef = zeros(3,size(Data.Raw,2));
Data.SSRef = Data.Raw;
% Data.SSRef(1,:) = Data.Raw(chanIndex(1),:);
% Data.SSRef(2,:) = Data.Raw(chanIndex(2),:);
% Data.SSRef(3,:) = Data.Raw(chanIndex(3),:);

% find the spindles in the reference
[Data, Info, ~, SS_Core] = ld_swa_FindSSRef(Data, Info);

% find the waves in all channels
%[Data, Info, SS] = swa_FindSSChannels(Data, Info, SS);
[markers, hdr, sleepStageFile] = ld_readVMRK('SleepEEG_MSL_07MG_01_62ch.vmrk',true);
SS_Core = ld_removeSpindlesDuringBadMarkers(SS_Core, Info, markers);

% Filter spindles depending on stage scoring
SS = ld_addSleepStage2spindles(SS_Core, Info, sleepStageFile, 0);

% save the data
swa_saveOutput(Data, Info, SS, [], 0, 0)



