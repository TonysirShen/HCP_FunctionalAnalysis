%%function to wapper through hcp subjects to fpp.func.roiExtract
allSubj = readtable([studyDir '/derivatives/cshen2/BalancedDiscoveryIDs.xlsx']);
subjects = table2array(allSubj(:,1));
subjects = subjects(1:3);
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'}
group = = 0;
ind_mask_name = 'DU15NET';
for s=1:length(subjects)
    subject = subjects{s};
    subjDir = [fppDir '/' subject];
%     anatDir = [subjDir '/anat'];
    funcDir = [subjDir '/func'];
    analysisDir = [subjDir '/analysis'];
    anatDir = [subjDir '/anat'];
%     maskPath = [funcDir '/' subject '_space-' statSpace '_desc-brainNonZero_mask' imageExt];
    searchPath = [groupDir '/ParcelsForDMN/' subjStr 'space-' searchSpace '_desc-' searchName '_mask' imageExt];
    if group
    if ~exist(searchPath,'file')
        % Hack for hand-drawn ROIs
        searchPath1 = fpp.bids.changeName(searchPath,'sub',subject);
        if ~exist(searchPath1,'file')
            % Hack for subcortical ROIs, in individual CIFTI space
            searchPath2 = [groupDir '/' subject '_space-' statSpace '_desc-' searchName '_mask' imageExt];
            if ~exist(searchPath2,'file')% hack for probalistic maps
                searchPath3 = [groupDir '/' 'space-' searchSpace '_desc-' searchName '_mask' imageExt];
                if ~exist(searchPath3,'file')
                error(['Search path does not exist: ' searchPath]);
                else
                    searchPath = searchPath3;
                end
            
            else
                searchPath = searchPath2;
            end
        else
            searchPath = searchPath1;
        end
    end
    else
        searchPath = fullfile(anatDir,)
    end

    % check whether roi already being defined
   
    defineROIDir = fpp.bids.changeName([analysisDir '/' subject '_task-'...
        defineROITask '_run-01_space-' statSpace '_Sm4_modelarma'],'desc',inputSuffix);
    pscTmp = {0,0,0,0};
    for t=1:length(tasks)
        extractResponseDir = fpp.bids.changeName([analysisDir '/' subject '_task-' tasks{t} ...
            '_run-01_space-' statSpace '_modelarma'],'desc',inputSuffix);
        try
        [pscTmp,condNamesTmp,runNames] = fpp.func.roiExtract(extractResponseDir,...
            defineROIDir,contrastName,searchPath,'roiSize',...
            roiSize,'sizeType',sizeType,'invertStats',invertStats,'overwrite',overwrite,'roiDesc',['workingmemory' contrastName 'Sm4']);
        if strcmp(tasks{t},'famvisual') % Swap order of conditions 4/5 for famvisual, to put FamPlace last
            pscTmp = pscTmp(:,[1:3 5 4]);
            condNamesTmp = condNamesTmp([1:3 5 4]);
        end
        psc{t} = [psc{t}; pscTmp];
        if s==1, condNames = [condNames; condNamesTmp]; end
        runNums{t} = [runNums{t}; cellfun(@str2num,runNames)']; 
        subNums{t} = [subNums{t}; s*ones(length(runNames),1)];
        pscBySub(s,1+lastConds(t):lastConds(t+1)) = mean(pscTmp);
        disp(['Extracted data for ' subject '_task-' tasks{t} contrastName]);
        catch ME
            fprintf(logtxt, 'Error occurred at %s\n', datetime('now'));
            fprintf(logtxt, 'Error message: %s\n', ME.message);
            fprintf(logtxt, ['SearchName:  ' searchName]);
            fprintf(logtxt, 'Stack trace:\n');
            for k = 1:length(ME.stack)
                fprintf(logtxt, '  File: %s\n', ME.stack(k).file);
                fprintf(logtxt, '  Name: %s\n', ME.stack(k).name);
                fprintf(logtxt, '  Line: %d\n', ME.stack(k).line);
            end
            fprintf(logtxt, '\n'); % Add a newline for better readability
        end
    end
end