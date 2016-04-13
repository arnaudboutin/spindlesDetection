% function [ o_SS ] = ld_extractPaterns( i_SS )
%LD_EXTRACTPATERNS Summary of this function goes here
%   Detailed explanation goes here

% load('/media/Data/Seafile/project_sleep_eeg_msl_spindles/SleepEEG_MSL_07MG_01_allchannels.mat')

for nElec=1:length(Info.Electrodes)
    firstElectrode.(Info.Electrodes(nElec).labels) = [];
end

templateStringPatern = ''; % Template string to start namePatern

patern = [];
indexPatern = [];
namePatern = {};
for nSp=1:length(SS)  % Loop on spindles

    currStart = SS(nSp).Ref_Start;
    currRegion = SS(nSp).Ref_Region;
    currScoring = SS(nSp).scoring(currRegion>0);

    if all(currScoring == 3) || all(currScoring == 2)
        indRealStart = find(currStart == min(currStart(currStart>0)));
        if length(indRealStart) > 1
            currPeak2Peak = SS(nSp).Ref_Peak2Peak(indRealStart);
            maxInd = find(currPeak2Peak == max(currPeak2Peak));
            indRealStart = indRealStart(maxInd);
        end
        firstElectrode.(Info.Electrodes(indRealStart).labels)(end+1) = nSp; 
    
        if isempty(patern)
            %             

            patern(1,:) = currRegion;

            [~, indStart] = sort(currStart);
            currRegion = currRegion(indStart);
            
            indexPatern(1) = 1;
            
            currElectrodes = currRegion(currRegion>0);
            
            namePatern{1} = templateStringPatern;
            for iElec=1:length(currElectrodes)
                namePatern{1} = strcat(namePatern{1}, ...
                    '->', ...
                    Info.Electrodes(currElectrodes(iElec)).labels);
            end
        else
            [tf, index] = ismember(patern,SS(nSp).Ref_Region,'rows');
            if sum(index) == 1
                patern(find(index),:) = currRegion;
                indexPatern(find(index)) = 1 + indexPatern(find(index));
            else
                
                patern(end+1, :) = currRegion;

                [~, indStart] = sort(currStart);
                currRegion = currRegion(indStart);
                
                indexPatern(end+1) = 1;
                namePatern{end+1} = templateStringPatern;
                
                                
                currElectrodes = currRegion(currRegion>0);
                for iElec=1:length(currElectrodes)
                    namePatern{end} = strcat(namePatern{end}, ...
                    '->', ...
                    Info.Electrodes(currElectrodes(iElec)).labels);
                end
            end
        end
    end
end
