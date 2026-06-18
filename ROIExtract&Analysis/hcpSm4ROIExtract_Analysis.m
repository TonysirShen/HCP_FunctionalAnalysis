% hcpSm4ROIExtract_Analysis(defineROITask,contrastName,searchName,isCifti,varargin)
%
% Function to extract ROI responses across all task conditions in HCP
% dataset, with ROIs defined based on a specific task, contrast, and search
% space.
%
% Main arguments:
% - defineROITask (string): name of task used to define ROIs
% - contrastName (string): name of contrast used to define ROIs
% - searchName (string): name of search space used to define ROIs
% - isCifti (boolean): whether to use CIFTI inputs, or volumetric
%
% Common name-value options:
% - 'allSubPath'      : full path to subject list file (.xlsx/.xls/.csv/.tsv/.txt/.mat)
% - 'allSubColumn'    : column index or column name containing subject IDs; default = 1
% - 'searchPathInput' : full path, folder, cell array, string array, or template for ROI/search mask
%                       Templates can use tokens:
%                       {subject}, {subjStr}, {searchSpace}, {statSpace},
%                       {searchName}, {imageExt}, {groupDir}
% - 'studyDir'        : HCP study directory; default = '/mnt/sml_share/HCP'
% - 'fppDir'          : fpp derivative directory; default = [studyDir '/derivatives/fpp']
% - 'groupDir'        : group output/search directory; default = [fppDir '/group']
% - 'logPath'         : log file path; default = [studyDir '/derivatives/cshen2/logs/ROIExtractlog.txt']
% - 'overwrite'       : whether to overwrite output data and ROIs; default = 1
% - 'roiSize'         : size of ROI, in % or # of coords in a search space; default = 5
% - 'sizeType'        : 'pct' or 'num'; default = 'pct'
% - 'invertStats'     : whether to invert statistical map; default = 0
% - 'inputSuffix'     : suffix for input modelarma directories; default = ''
%
% Examples:
% hcpSm4ROIExtract_Analysis('workingmemory','FacesVsAllOthers','MyROI',1, ...
%     'allSubPath','/path/to/subjects.xlsx', ...
%     'searchPathInput','/path/to/group_mask.dscalar.nii');
%
% Per-subject template example:
% hcpSm4ROIExtract_Analysis('workingmemory','FacesVsAllOthers','MyROI',1, ...
%     'allSubPath','/path/to/subjects.xlsx', ...
%     'searchPathInput','/path/to/masks/{subject}_space-{statSpace}_desc-{searchName}_mask{imageExt}');

function hcpSm4ROIExtract_Analysis(defineROITask,contrastName,searchName,isCifti,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 0: User-configurable paths/options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define constants / path defaults.
studyDir = getOption(varargin,'studyDir','/mnt/sml_share/HCP');
% studyDir = '/Volumes/human_neuroimaging_research/HCP';
fppDir = getOption(varargin,'fppDir',[studyDir '/derivatives/fpp']);
groupDir = getOption(varargin,'groupDir',[fppDir '/group']);

% User-writable subject list path.  Aliases are included so either
% 'allSubPath', 'allSubjPath', or 'allSub' will work.
allSubPath = getOption(varargin,'allSubPath',[studyDir '/derivatives/cshen2/BalancedReplicationIDs.xlsx']);
allSubPath = getOption(varargin,'allSubjPath',allSubPath);
allSubPath = getOption(varargin,'allSub',allSubPath);
allSubColumn = getOption(varargin,'allSubColumn',1);

% User-writable search mask path.  Aliases are included so either
% 'searchPathInput' or 'searchPath' will work.
searchPathInput = getOption(varargin,'searchPathInput','');
searchPathInput = getOption(varargin,'searchPath',searchPathInput);

% Other variable argument defaults.
roiSize = getOption(varargin,'roiSize',5);
sizeType = getOption(varargin,'sizeType','pct');
invertStats = getOption(varargin,'invertStats',0);
inputSuffix = getOption(varargin,'inputSuffix','');
overwrite = getOption(varargin,'overwrite',1);
logPath = getOption(varargin,'logPath',[studyDir '/derivatives/cshen2/logs/ROIExtractlog.txt']);

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

% Read subject list from user-defined path.
subjects = readSubjectList(allSubPath,allSubColumn){1};

if ~exist(groupDir,'dir'), mkdir(groupDir); end
logDir = fileparts(logPath);
if ~isempty(logDir) && ~exist(logDir,'dir'), mkdir(logDir); end
logtxt = fopen(logPath,'a');
if logtxt < 0
    warning('Could not open log file: %s. Logging to command window instead.', logPath);
    logtxt = 1;
end
cleanupObj = onCleanup(@() closeLogFile(logtxt)); %#ok<NASGU>

tasks = {'emotion','language','social','workingmemory'};
nConds = [2 2 2 8];
lastConds = [0 cumsum(nConds)];
gapInd = lastConds(2:end-1);    % Positions of gaps between bars in graph.

% Color array for bar plot, across all 14 task conditions here.
colorArray = {[252 164 134]/255,[252 201 184]/255,[177 224 170]/255,[205 233 252]/255,[181 209 227]/255,...
    [250 95 65]/255,[105 188 107]/255,[96 164 208]/255,...
    [217 40 34]/255,[43 153 74]/255,[43 119 181]/255,...
    [253 219 207]/255,[210 248 204]/255,[230 243 252]/255,...
    [1 .5882 0],[1 .7843 .4745],...
    [1 1 0],[1 1 .8431]};

% Define output suffices based on variable arguments.
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

% Subject number suffix.
subSuffix = ['N' num2str(length(subjects))];

% Define output path.
outputDesc = [searchName defineROITask inputSuffix contrastName invertSuffix numSuffix subSuffix 'Sm4Replication'];
outputPath = [groupDir '/space-' statSpace '_desc-' outputDesc '_roiData.mat'];
outputFigurePath = [groupDir '/space-' statSpace '_desc-' outputDesc '_barplot.png'];
% if exist(outputPath,'file') && ~overwrite, return; end

% Initialize outputs.
condNames = {};
pscBySub = zeros(length(subjects),lastConds(end));
for t=1:length(tasks)
    [psc{t},subNums{t},runNums{t}] = deal([],[],[]); %#ok<AGROW>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1: Extract ROI responses across tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for s=1:length(subjects)
    subject = subjects{s};
    subjDir = [fppDir '/' subject];
    analysisDir = [subjDir '/analysis'];

    % Resolve ROI/search mask path. If searchPathInput is empty, the original
    % automatic search path and fallback logic are used. If searchPathInput is
    % supplied, that user path/folder/template is used directly.
    searchPath = resolveSearchPath(searchPathInput,subject,s,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti);

    defineROIDir = fpp.bids.changeName([analysisDir '/' subject '_task-'...
        defineROITask '_run-01_space-' statSpace '_Sm4_modelarma'],'desc',inputSuffix);

    for t=1:length(tasks)
        extractResponseDir = fpp.bids.changeName([analysisDir '/' subject '_task-' tasks{t} ...
            '_run-01_space-' statSpace '_modelarma'],'desc',inputSuffix);
        try
            [pscTmp,condNamesTmp,runNames] = fpp.func.roiExtract(extractResponseDir,...
                defineROIDir,contrastName,searchPath,'roiSize',...
                roiSize,'sizeType',sizeType,'invertStats',invertStats,'overwrite',overwrite,...
                'roiDesc',['workingmemory' contrastName 'Sm4']);

            if strcmp(tasks{t},'famvisual') % Kept from original script.
                pscTmp = pscTmp(:,[1:3 5 4]);
                condNamesTmp = condNamesTmp([1:3 5 4]);
            end
            psc{t} = [psc{t}; pscTmp]; %#ok<AGROW>
            if s==1, condNames = [condNames; condNamesTmp]; end %#ok<AGROW>
            runNums{t} = [runNums{t}; cellfun(@str2num,runNames)']; %#ok<ST2NM,AGROW>
            subNums{t} = [subNums{t}; s*ones(length(runNames),1)]; %#ok<AGROW>
            pscBySub(s,1+lastConds(t):lastConds(t+1)) = mean(pscTmp);
            disp(['Extracted data for ' subject '_task-' tasks{t} '_' contrastName]);
        catch ME
            fprintf(logtxt, 'Error occurred at %s\n', datestr(now));
            fprintf(logtxt, 'Subject: %s\n', subject);
            fprintf(logtxt, 'Task: %s\n', tasks{t});
            fprintf(logtxt, 'SearchName: %s\n', searchName);
            fprintf(logtxt, 'SearchPath: %s\n', searchPath);
            fprintf(logtxt, 'Error message: %s\n', ME.message);
            fprintf(logtxt, 'Stack trace:\n');
            for k = 1:length(ME.stack)
                fprintf(logtxt, '  File: %s\n', ME.stack(k).file);
                fprintf(logtxt, '  Name: %s\n', ME.stack(k).name);
                fprintf(logtxt, '  Line: %d\n', ME.stack(k).line);
            end
            fprintf(logtxt, '\n');
        end
    end
end

% Compute run-wise standard error.
pscRunwiseStdErr = [];
for t=1:length(tasks)
    pscRunwiseStdErr = [pscRunwiseStdErr std(psc{t})/sqrt(size(psc{t},1))]; %#ok<AGROW>
end

save(outputPath,'psc','condNames','runNums','subNums','pscBySub','subjects',...
    'tasks','nConds','colorArray','gapInd','pscRunwiseStdErr',...
    'nConds','lastConds','allSubPath','searchPathInput');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Plot results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',[200 200 1200 400]);
[b,~,e,barInd] = fpp.util.barColor(pscBySub,colorArray,pscRunwiseStdErr,gapInd,0); %#ok<ASGLU>
gca = gcf().CurrentAxes;
gca.XColor = [0,0,0];
gca.XTick = [1,2,4,5,7,8,10:17];
gca.XTickLabel = condNames;
gca.FontSize = 12;
saveas(gcf,outputFigurePath);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = getOption(args,name,defaultVal)
%GETOPTION Small name-value parser, independent of fpp.util.optInputs.
val = defaultVal;
for ii = 1:2:numel(args)
    key = args{ii};
    if isTextScalar(key) && strcmpi(char(key),name)
        if ii == numel(args)
            error('Missing value for option: %s', name);
        end
        val = args{ii+1};
        return;
    end
end
end

function tf = isTextScalar(x)
tf = ischar(x) || (isstring(x) && isscalar(x));
end

function subjects = readSubjectList(allSubPath,allSubColumn)
%READSUBJECTLIST Read subject IDs from a path or a provided cell/string array.
if iscell(allSubPath) || (isstring(allSubPath) && numel(allSubPath) > 1)
    subjects = normalizeSubjectList(allSubPath);
    return;
end

allSubPath = char(allSubPath);
if ~exist(allSubPath,'file')
    error('Subject list path does not exist: %s', allSubPath);
end

[~,~,ext] = fileparts(allSubPath);
ext = lower(ext);

switch ext
    case {'.xlsx','.xls','.csv'}
        T = readtable(allSubPath);
        vals = getTableColumn(T,allSubColumn);
    case '.tsv'
        T = readtable(allSubPath,'FileType','text','Delimiter','\t');
        vals = getTableColumn(T,allSubColumn);
    case '.txt'
        T = readtable(allSubPath,'FileType','text','ReadVariableNames',false);
        vals = getTableColumn(T,allSubColumn);
    case '.mat'
        S = load(allSubPath);
        if isfield(S,'subjects')
            vals = S.subjects;
        elseif isfield(S,'allSubj')
            if istable(S.allSubj)
                vals = getTableColumn(S.allSubj,allSubColumn);
            else
                vals = S.allSubj;
            end
        elseif isfield(S,'allSub')
            vals = S.allSub;
        else
            error('MAT file must contain variable named subjects, allSubj, or allSub.');
        end
    otherwise
        error('Unsupported subject list file extension: %s', ext);
end

subjects = normalizeSubjectList(vals);
end

function vals = getTableColumn(T,col)
if isnumeric(col)
    vals = T{:,col};
elseif isTextScalar(col)
    vals = T.(char(col));
else
    error('allSubColumn must be a column index or column name.');
end
end

function subjects = normalizeSubjectList(vals)
if istable(vals)
    vals = vals{:,1};
end

if iscell(vals)
    if all(cellfun(@ischar,vals(:)))
        subjects = vals(:);
    else
        subjects = cellstr(string(vals(:)));
    end
elseif isstring(vals)
    subjects = cellstr(vals(:));
elseif isnumeric(vals)
    subjects = cellstr(string(vals(:)));
elseif iscategorical(vals)
    subjects = cellstr(vals(:));
elseif ischar(vals)
    subjects = cellstr(vals);
else
    error('Could not convert subject list to cell array of character vectors.');
end

subjects = subjects(:);
subjects = subjects(~cellfun(@isempty,subjects));
end

function searchPath = resolveSearchPath(searchPathInput,subject,s,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti)
%RESOLVESEARCHPATH Resolve user-provided path/folder/template or original default.
if isempty(searchPathInput)
    searchPath = resolveDefaultSearchPath(subject,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti);
    return;
end

rawPath = selectSearchPathInput(searchPathInput,s);
rawPath = expandSearchTemplate(rawPath,subject,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti);

if exist(rawPath,'file')
    searchPath = rawPath;
    return;
end

if exist(rawPath,'dir')
    searchPath = resolveSearchPathFromFolder(rawPath,subject,searchSpace,statSpace,searchName,imageExt,isCifti);
    return;
end

error('User-defined searchPath does not exist after template expansion: %s', rawPath);
end

function rawPath = selectSearchPathInput(searchPathInput,s)
if iscell(searchPathInput)
    if numel(searchPathInput) == 1
        rawPath = searchPathInput{1};
    else
        rawPath = searchPathInput{s};
    end
elseif isstring(searchPathInput) && numel(searchPathInput) > 1
    rawPath = searchPathInput(s);
else
    rawPath = searchPathInput;
end
rawPath = char(rawPath);
end

function outPath = expandSearchTemplate(inPath,subject,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti)
if isCifti
    subjStr = '';
else
    subjStr = [subject '_'];
end
outPath = char(inPath);
outPath = strrep(outPath,'{subject}',subject);
outPath = strrep(outPath,'{subjStr}',subjStr);
outPath = strrep(outPath,'{groupDir}',groupDir);
outPath = strrep(outPath,'{searchSpace}',searchSpace);
outPath = strrep(outPath,'{statSpace}',statSpace);
outPath = strrep(outPath,'{searchName}',searchName);
outPath = strrep(outPath,'{imageExt}',imageExt);
end

function searchPath = resolveSearchPathFromFolder(folderPath,subject,searchSpace,statSpace,searchName,imageExt,isCifti)
if isCifti
    subjStr = '';
else
    subjStr = [subject '_'];
end

candidatePaths = {
    fullfile(folderPath,[subjStr 'space-' searchSpace '_desc-' searchName '_mask' imageExt]);
    fullfile(folderPath,[subject '_space-' statSpace '_desc-' searchName '_mask' imageExt]);
    fullfile(folderPath,['space-' searchSpace '_desc-' searchName '_mask' imageExt])
    };

for i = 1:numel(candidatePaths)
    if exist(candidatePaths{i},'file')
        searchPath = candidatePaths{i};
        return;
    end
end

error('Could not find search mask in folder: %s', folderPath);
end

function searchPath = resolveDefaultSearchPath(subject,groupDir,searchSpace,statSpace,searchName,imageExt,isCifti)
% Original search path logic, kept as fallback when searchPathInput is empty.
if isCifti
    subjStr = '';
else
    subjStr = [subject '_'];
end

searchPath = [groupDir '/ParcelsForDMN/' subjStr 'space-' searchSpace '_desc-' searchName '_mask' imageExt];
if ~exist(searchPath,'file')
    % Hack for hand-drawn ROIs.
    searchPath1 = fpp.bids.changeName(searchPath,'sub',subject);
    if ~exist(searchPath1,'file')
        % Hack for subcortical ROIs, in individual CIFTI space.
        searchPath2 = [groupDir '/' subject '_space-' statSpace '_desc-' searchName '_mask' imageExt];
        if ~exist(searchPath2,'file')
            % Hack for probabilistic maps.
            searchPath3 = [groupDir '/' 'space-' searchSpace '_desc-' searchName '_mask' imageExt];
            if ~exist(searchPath3,'file')
                error('Search path does not exist: %s', searchPath);
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
end

function closeLogFile(fid)
if fid > 2
    fclose(fid);
end
end
