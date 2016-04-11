%% -- Workflow and Plots for Spindle Analysis -- %%

% Load EEG file
addpath('/home/borear/Documents/Research/Source/matlab_toolboxes/eeglab');

eeglab
close(gcf)
clc
clear all

maindir = '/media/borear/Projects/olfacto_spindles_detection';
cd(maindir)
load('channelsInfos.mat');

eegFolder = [maindir filesep 'eeg_files_export' filesep];
scoringFolder = [maindir filesep 'Scoring_files' filesep];
badintervalsFolder = [maindir filesep 'BadInterval_Markers' filesep];
outputeegFolder = [maindir filesep 'Output_eeg_files' filesep];

allFiles = dir([ eegFolder 'Olfacto*.dat']);

% for iFile=85%:length(allFiles)
%     
%     o_name = strsplit(allFiles(iFile).name,'_');
%     o_name = char(o_name(2));
%     out_name = ['o_' o_name '.mat'];
%     
%     eeg_name = [eegFolder allFiles(iFile).name];
%     vmrk_name = [eegFolder allFiles(iFile).name(1:end-3) 'vmrk'];
%     scoring_name = [scoringFolder 'OlfactoSleep_' o_name '_ExpRaw_Data.mat'];
%     disp(['Subject: ' num2str(iFile)])
%     disp(['Analysis: ' allFiles(iFile).name]);
%     if exist(vmrk_name,'file') && ...
%        exist([outputeegFolder out_name],'file') && ...
%        exist(scoring_name,'file')
%         
%         
%         ld_exportSpindlesAndScoring2vmrk([outputeegFolder out_name], ...
%                                      scoring_name, ...
%                                      [3 4 5], ...
%                                      'All', ...
%                                      vmrk_name);
%     else
%         disp(['Some files are missing'])
%     end
%     
% end

% test = 1

% Spindle Detection %
% ----------------- %
for iFile=1:length(allFiles)
    
    o_name = strsplit(allFiles(iFile).name,'_');
    o_name = char(o_name(2));
    out_name = ['o_' o_name '.mat'];
    
    eeg_name = [eegFolder allFiles(iFile).name];
    vhdr_name = [allFiles(iFile).name(1:end-3) 'vhdr'];
    badinterval_name = [badintervalsFolder 'OlfactoSleep_' o_name '_ExpRawData_RDI - Bad Channel Markers.Markers'];
    scoring_name = [scoringFolder 'OlfactoSleep_' o_name '_ExpRaw_Data.mat'];
    disp(['Subject: ' num2str(iFile)])
    
    if exist([outputeegFolder out_name],'file')
        disp(['Already done : ' out_name]);
    elseif ~exist(badinterval_name,'file') || ~exist(scoring_name,'file')
        disp('#########################')
        disp(allFiles(iFile).name)
        disp('Some files don''t exist')
        disp('#########################')
    else
    	try %#ok<ALIGN>
            disp(['Analysis: ' allFiles(iFile).name]);
	        EEG = pop_loadbv(eegFolder, vhdr_name);    
        
	        % Info initialization
	        Info.Recording.dataDim = size(EEG.data);
	        Info.Recording.sRate = EEG.srate;

	        % get the default settings for spindle detection
	        Info = swa_getInfoDefaults(Info, 'SS');

        	for nChan = 1:length(EEG.chanlocs) %#ok<ALIGN>
	            Ind = find(strcmp({ChanInfos.labels},EEG.chanlocs(nChan).labels));
	            if isempty(Ind)
	                currentChanInfos(1,nChan).labels = EEG.chanlocs(nChan).labels;
	            else
	                currentChanInfos(1,nChan) = ChanInfos(Ind);
	            end
            end

            Data.Raw = EEG.data;
            
            %033CR
            %Data.SSRef = Data.Raw([1 2 3 5 6 7 8 9 10],:);
            % currentChanInfos(4) = [];
            
            %309TJ
%  	        Data.SSRef = Data.Raw([1 2 3 4 5 6 8 9 10],:);
% 	        currentChanInfos(7) = [];
            
            %455CW
%  	        Data.SSRef = Data.Raw([1 3 8 9 10],:);
%             currentChanInfos(7) = [];
%             currentChanInfos(6) = [];
%             currentChanInfos(5) = [];
%             currentChanInfos(4) = [];
% 	        currentChanInfos(2) = [];
                        
            %409RD
%  	        Data.SSRef = Data.Raw([1 2 3 4 5 6 8 9 10],:);
% 	        currentChanInfos(7) = [];

            %430PL
%  	        Data.SSRef = Data.Raw([1 2 3 4 5 6 7 9 10],:);
% 	        currentChanInfos(8) = [];

            Data.SSRef = Data.Raw;
            Info.Electrodes = currentChanInfos;
            
	        [Data, Info, ~, SS_Core] = ld_swa_FindSSRef(Data, Info);
	        
	        SS_Core = ld_addSleepStage2spindles(SS_Core, Info, scoring_name, 0);
        
	        SS = ld_removeSpindlesDuringBadMarkers(SS_Core, Info, badinterval_name);

	        disp(['Save ' out_name]);
	        
	        swa_saveOutput(Data, Info, SS, [outputeegFolder out_name], 0, 0)
            clear Data EEG SS SS_Core Info Info_input Ind o_name i_marker name i_struct_marker
        catch
	        disp('#########################')		        
            disp(['Analysis: ' allFiles(iFile).name ' FAILED !!!!!!'])
	        disp('#########################')
	        clear Data EEG SS SS_Core Info Info_input Ind o_name i_marker name i_struct_marker
        end
    end
end

