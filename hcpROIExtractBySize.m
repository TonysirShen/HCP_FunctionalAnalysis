
% identROIExtractBySize(defineROITask,contrastName,searchName,isCifti,varargin)
%
% Function to extract ROI responses to people vs places across a range of
% ROI sizes, from 5 to 40%.
%
% Arguments:
% - defineROITask (string): name of task used to define ROIs / extract
%       responses
% - contrastName (string): name of contrast used to define ROIs
% - searchName (string): name of search space used to define ROIs
% - isCifti (boolean): whether to use CIFTI inputs, or volumetric
% 
% Variable arguments:
% - overwrite (boolean): whether to overwrite output data and ROIs
% - invertStats (boolean, default = 0): whether to invert statistical map
% - inputSuffix (string): suffix for input modelarma directories
% - outputDir(string): name of the group Directory
% - outputoverwrite
% Outputs to save: psc, subNums, runNums

function hcpROIExtractBySize(defineROITask,contrastName,searchName,isCifti,varargin)

% Define constants
studyDir = '/mnt/sml_share/HCP';
% studyDir = '/Volumes/human_neuroimaging_research/HCP';
fppDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir '/derivatives/cshen2/FilteredParticipants.xlsx']);
subjects = table2array(allSubj(:,1));
% subjects = subjects(1:3);%debug line for individuals 
% subjects = {'sub-hcp353740'};

% Color array: colors for person/place contrasts
colorArray = {[250 95 65]/255,[96 164 208]/255};

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
roiSize = [5,10,15,20,25,30,35,40,45,50];
sizeType = 'pct';
invertStats = 0;
inputSuffix = '';
overwrite = 0;
outputDir = '';
outputOverwrite = 1;
% Edit variable arguments.  Note: optInputs checks for proper input.
varArgList = {'invertStats','inputSuffix','overwrite'};
for i=1:length(varArgList)
    argVal = fpp.util.optInputs(varargin,varArgList{i});
    if ~isempty(argVal)
        eval([varArgList{i} ' = argVal;']);
    end
end
[found,idx]  = ismember('outputDir', varargin);
if found
    outputDir = varargin{idx + 1};
end
[found,idx]  = ismember('outputOverwrite', varargin);
if found
    outputOverwrite = varargin{idx + 1};
end
% Define output suffices based on variable arguments
numSuffix = 'BySize';
if invertStats
    invertSuffix = 'Inverted';
else
    invertSuffix = '';
end

% Subject number suffix
subSuffix = ['N' num2str(length(subjects))];

% Define output path
groupDir = fullfile(fppDir,'group');
if ~exist(groupDir,'dir'), mkdir(groupDir); end
outputDesc = [searchName defineROITask inputSuffix contrastName invertSuffix numSuffix subSuffix];
outputPath = [fppDir '/' outputDir '/space-' statSpace '_desc-' outputDesc '_roiData.mat'];
outputFigurePath = [fppDir '/' outputDir '/space-' statSpace '_desc-' outputDesc '_responseplot.pdf'];
if exist(outputPath,'file') && ~outputOverwrite, return; end

% Initialize outputs
[psc,subNums,runNums] = deal([],[],[]);
pscBySub = [];

% Define domain preferences, average between 0-bk and 2-bk
switch contrastName
    case {'FacesVsAllOthers'}
        contrast = [4 -1 -1 -1 4 -1 -1 -1 ];
    case 'ToolsVsAllOthers'
        contrast = [-1 -1 4 -1 -1 -1 4 -1];
    otherwise
        error('Contrast not included!');
end

if invertStats, contrast = -contrast; end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1: Extract ROI responses across
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parfor s=1:length(subjects)
    subject = subjects{s};
    subjDir = [fppDir '/' subject];
    anatDir = [subjDir '/anat'];
    funcDir = [subjDir '/func'];
    analysisDir = [subjDir '/analysis'];
    if isCifti
        subjStr = '';
    else
        subjStr = ['sub-' subject '_'];
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
    defineROIDir = fpp.bids.changeName([analysisDir '/' subject '_task-'...
        defineROITask '_run-01_space-' statSpace '_Sm4_modelarma'],'desc',inputSuffix);
    extractResponseDir = fpp.bids.changeName([analysisDir '/' subject '_task-' defineROITask ...
            '_run-01_space-' statSpace '_modelarma'],'desc',inputSuffix);  % Extract responses from the same task
    conTmp = [];
    for r=1:length(roiSize)
        [pscTmp,~,runNames] = fpp.func.roiExtract(extractResponseDir,...
            defineROIDir,contrastName,searchPath,'roiSize',...
            roiSize(r),'sizeType',sizeType,'invertStats',invertStats,'overwrite',overwrite);
            conTmp = [conTmp pscTmp*contrast'];
    end
    runNames = {'01','02'};
    psc = [psc; conTmp];
    runNums = [runNums; cellfun(@str2num,runNames)'];
    subNums = [subNums; s*ones(length(runNames),1)];
    pscBySub(s,:) = mean(conTmp);
    
    disp(['Extracted data for ' subject]);
    
end
% Compute run-wise standard error
pscRunwiseStdErr = std(psc)/sqrt(size(psc,1));

save(outputPath,'psc','runNums','subNums','pscBySub','subjects','colorArray',...
    'pscRunwiseStdErr','invertStats');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3: Plot results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',[200 200 800 400]);
xTicks = roiSize;
linProps.col = {'g'};
if contains(contrastName,'Tools'); linProps.col = {'r'}; end
mseb(xTicks,mean(psc),pscRunwiseStdErr,linProps);
set(gca,'linewidth',2,'FontSize',16);
set(gca,'XTickLabel',xTicks,'XTick',xTicks);
set(gcf,'Color',[1 1 1]);
title([searchName '  ' contrastName])
saveas(gcf,outputFigurePath);

end
