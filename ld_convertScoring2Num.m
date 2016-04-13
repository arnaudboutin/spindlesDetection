function [ o_SleepStageScoring ] = ld_convertScoring2Num( i_SleepStageScoring )
%LD_CONVERTSCORING2NUM Summary of this function goes here
%   Detailed explanation goes here

o_SleepStageScoring = zeros(size(i_SleepStageScoring));

for iSc=1:length(o_SleepStageScoring)
    switch i_SleepStageScoring{iSc}
        
        case 'NREM1'
            o_SleepStageScoring(iSc) = 1;
        case 'NREM2'
            o_SleepStageScoring(iSc) = 2;
        case 'NREM3'
            o_SleepStageScoring(iSc) = 3;
        case 'movement'
            o_SleepStageScoring(iSc) = 6;
    end
end

end

