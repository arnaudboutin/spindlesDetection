function oColor = ld_getColorFromSleepStage(iStage)

iStage = char(strrep(iStage,' ',''));

switch iStage
    case 'wake'
        oColor = 'k';
    case 'NREM1'
        oColor = 'g';
    case 'NREM2'
        oColor = 'b';
    case 'NREM3'
        oColor = 'r';
    case 'movement'
        oColor = 'm';
    otherwise
        oColor = 'c';
end