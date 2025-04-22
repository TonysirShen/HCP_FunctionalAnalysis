
% hcpROIExtract(defineROITask,contrastName,searchName,isCifti,varargin)
%
% Function to extract ROI responses across all task conditions in HCP
% dataset, with ROIs defined based on a specific task, contrast, and search
% space.
%
% Arguments:
% - defineROITask (string): name of task used to define ROIs
% - contrastName (string): name of contrast used to define ROIs
% - searchName (string): name of search space used to define ROIs
% - isCifti (boolean): whether to use CIFTI inputs, or volumetric
% 
% Variable arguments:
% - overwrite (boolean): whether to overwrite output data and ROIs
% - roiSize (scalar): size of ROI, in % or # of coords in a search space
% - sizeType ('pct' or 'num'): whether size is measured in # or % of coords
% - invertStats (boolean, default = 0): whether to invert statistical map
% - inputSuffix (string): suffix for input modelarma directories
%
% Outputs to save: psc, condNames, subNums, runNums
%
% NOTE: Conditions 4-5 (FamPlace, UnfamPlace) of famvisual are switched in
% order in the outputs, so that FamPlace is the last condition.

function hcpSm4ROIExtract_Analysis(defineROITask,contrastName,searchName,isCifti,varargin)

% Define constants
studyDir = '/mnt/sml_share/HCP';
% studyDir = '/Volumes/human_neuroimaging_research/HCP';
fppDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir '/derivatives/cshen2/BalancedReplicationIDs.xlsx']);
subjects = table2array(allSubj(:,1));
%subjects = {'sub-hcp205826'};%debug line for individuals 
logtxt = fopen([studyDir,'/derivatives/cshen2/logs/ROIExtractlog.txt'],'a');
tasks = {'emotion','language','social','workingmemory'};
nConds = [2 2 2 8];
lastConds = [0 cumsum(nConds)];
gapInd = lastConds(2:end-1);    % Positions of gaps between bars in graph (between tasks)
% Color array for bar plot, across all 18 conditions
colorArray = {[252 164 134]/255,[252 201 184]/255,[177 224 170]/255,[205 233 252]/255,[181 209 227]/255,...
    [250 95 65]/255,[105 188 107]/255,[96 164 208]/255,...
    [217 40 34]/255,[43 153 74]/255,[43 119 181]/255,...
    [253 219 207]/255,[210 248 204]/255,[230 243 252]/255,...
    [1 .5882 0],[1 .7843 .4745],...
    [1 1 0],[1 1 .8431]};

% % Linear mixed effects model info
% % lmeInfo: T x 3 matrix. Each row specifies task, condition A, and condition B, to test if A > B.
% lmeInfo = [1 1 5; 1 1 3; 1 1 2; 1 5 1; 1 5 3; 1 5 4;... % famvisual, all
%             2 1 3; 2 1 2; 2 3 1; 2 3 2;...  % famsemantic, social/spatial
%             3 1 3; 3 1 2; 3 3 1; 3 3 2;...  % famepisodic, social/spatial
%             4 1 3; 4 1 2; 4 3 1; 4 3 2;...  % DyLoc
%             5 1 2; 6 1 2;...                % ToMLoc, LangLoc
%             1 3 1; 1 3 5; 2 2 1; 2 2 3;...  % Object contrasts
%             3 2 1; 3 2 3; 4 2 1; 4 2 3];
% lmeNames = {'famvisualPersonVsPlace','famvisualPersonVsObject','famvisualFamVsUnfamPerson',...
%     'famvisualPersonVsPlaceInverted','famvisualPlaceVsObject','famvisualFamVsUnfamPlace',...
%     'famsemanticPersonVsPlace','famsemanticPersonVsObject',...
%     'famsemanticPersonVsPlaceInverted','famsemanticPlaceVsObject',...
%     'famepisodicPersonVsPlace','famepisodicPersonVsObject',...
%     'famepisodicPersonVsPlaceInverted','famepisodicPlaceVsObject',...
%     'dylocPersonVsPlace','dylocPersonVsObject',...
%     'dylocPersonVsPlaceInverted','dylocPlaceVsObject',...
%     'tomloc2BeliefVsPhoto','langlocSentencesVsNonwords',...
%     'famvisualPersonVsObjectInverted','famvisualPlaceVsObjectInverted',...
%     'famsemanticPersonVsObjectInverted','famsemanticPlaceVsObjectInverted',...
%     'famepisodicPersonVsObjectInverted','famepisodicPlaceVsObjectInverted',...
%     'dylocPersonVsObjectInverted','dylocPlaceVsObjectInverted'};

if ~exist('isCifti','var') || isempty(isCifti)
    isCifti = 1;
end
if isCifti
    searchSpace = 'fsLR_den-32k';
    statSpace = 'fsLR_res-2_den-32k';
    imageExt = '.dscalar.nii';
else
    searchSpace = 'session';
    statSpace = 'session';
    imageExt = '.nii.gz';
end

% Variable argument defaults
roiSize = 5;
sizeType = 'pct';
invertStats = 0;
inputSuffix = '';
overwrite = 1;

% Edit variable arguments.  Note: optInputs checks for proper input.
varArgList = {'roiSize','sizeType','invertStats','inputSuffix','overwrite'};
for i=1:length(varArgList)
    argVal = fpp.util.optInputs(varargin,varArgList{i});
    if ~isempty(argVal)
        eval([varArgList{i} ' = argVal;']);
    end
end

% Define output suffices based on variable arguments
if strcmpi(sizeType,'num')
    roiSize = round(roiSize);
    numSuffix = ['Top' num2str(roiSize)];
else
    numSuffix = ['Top' num2str(roiSize) 'Pct'];
end
if invertStats
    invertSuffix = 'Inverted';
else
    invertSuffix = '';
end

% Subject number suffix
subSuffix = ['N' num2str(length(subjects))];

% Define output path
groupDir = [fppDir '/group'];
if ~exist(groupDir,'dir'), mkdir(groupDir); end
outputDesc = [searchName defineROITask inputSuffix contrastName invertSuffix numSuffix subSuffix 'Sm4Replication'];
outputPath = [groupDir '/space-' statSpace '_desc-' outputDesc '_roiData.mat'];
outputFigurePath = [groupDir '/space-' statSpace '_desc-' outputDesc '_barplot.png'];
%if exist(outputPath,'file') && ~overwrite, return; end

% Initialize outputs

condNames = {};
pscBySub = zeros(length(subjects),lastConds(end));
for t=1:length(tasks)
    [psc{t},subNums{t},runNums{t}] = deal([],[],[]);
end
% % Which statistical comparisons to plot significance stars for
% statsToPlot = [];
% if ismember(contrastName,{'FacesVsAllOthers'}) && invertStats==0
%     statsToPlot = [1:3 7 8 11 12 15 16 19 20];
% elseif ismember(contrastName,{'PersonVsPlace','FacesVsScenes'}) && invertStats==1
%     statsToPlot = [4:6 9 10 13 14 17 18 19 20];
% elseif ismember(contrastName,{'PlaceVsObject','PersonVsObject','FacesVsObjects',...
%         'ScenesVsObjects'}) && invertStats==1
%     statsToPlot = 19:28;
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1: Extract ROI responses across tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for s=1:length(subjects)
    subject = subjects{s};
    subjDir = [fppDir '/' subject];
%     anatDir = [subjDir '/anat'];
    funcDir = [subjDir '/func'];
    analysisDir = [subjDir '/analysis'];
%     maskPath = [funcDir '/' subject '_space-' statSpace '_desc-brainNonZero_mask' imageExt];
    if isCifti
        subjStr = '';
    else
        subjStr = [subject '_'];
    end
    searchPath = [groupDir '/ParcelsForDMN/' subjStr 'space-' searchSpace '_desc-' searchName '_mask' imageExt];
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
% Compute run-wise standard error
pscRunwiseStdErr = [];
for t=1:length(tasks)
    pscRunwiseStdErr = [pscRunwiseStdErr std(psc{t})/sqrt(size(psc{t},1))];
end

save(outputPath,'psc','condNames','runNums','subNums','pscBySub','subjects',...
    'tasks','nConds','colorArray','gapInd','pscRunwiseStdErr',...
    'nConds','lastConds');
% removed variable 'statsToPlot' following 'pscRunwiseStdErr' for the time
% being.



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% STEP 2: Run statistics
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('\n');
% disp(['Statistics for ROI ' outputDesc '...']);
% for i=1:length(lmeNames)
%     % Fit random-intercept linear mixed-effects model
%     t = lmeInfo(i,1);  % task index
%     lmeContrasts{i} = zeros(1,nConds(t));
%     lmeContrasts{i}(lmeInfo(i,2:3)) = [1 -1];
%     y{i} = psc{t}*lmeContrasts{i}';
%     lmeTable{i} = table(y{i},categorical(subNums{t}),'VariableNames',{'y','subj'});
%     lmeResults{i} = fitlme(lmeTable{i},'y~1+(1|subj)');
%     lmeOneTailedP{i} = min(1,2*(1-tcdf(lmeResults{i}.Coefficients.tStat,lmeResults{i}.Coefficients.DF)));
%     disp([lmeNames{i} ': t(' num2str(lmeResults{i}.Coefficients.DF) ') = '...
%         num2str(lmeResults{i}.Coefficients.tStat) ', P = ' num2str(lmeOneTailedP{i})]);
% end
% 
% save(outputPath,'-append','lmeInfo','lmeNames','lmeContrasts','lmeTable','lmeResults','lmeOneTailedP');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Plot results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%['fear','neut','story','math','mental','rnd','2bk_faces','2bk_body','2bk_tools','2bk_places','0bk_faces','0bk_body','0bk_tools','0bk_places']
figure('Position',[200 200 1200 400]);
[b,~,e,barInd] = fpp.util.barColor(pscBySub,colorArray,pscRunwiseStdErr,gapInd,0);
gca = gcf().CurrentAxes;
gca.XColor = [0,0,0];
gca.XTick = [1,2,4,5,7,8,10:17];
gca.XTickLabel = condNames;
gca.FontSize = 12;
% % Plot significance stars
% starGroups = {}; starP = [];
% for i=statsToPlot
%     starGroups{end+1} = barInd(lmeInfo(i,2:3)+lastConds(lmeInfo(i,1)));
%     starP(end+1) = lmeOneTailedP{i};
% end
% indKeep = find(starP<.0071);
% starGroups = starGroups(indKeep);
% starP = starP(indKeep);
% ss = identSigStarSmallPlot(starGroups,starP);
saveas(gcf,outputFigurePath);
% 
end