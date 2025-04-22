%% Whole Brain or Surface Analysis
% This script will perform a whole brain or whole surface analysis, by task
% type, for each HCP dataset.


%% Functional modeling: CIFTI modelArma
studyDir = '/mnt/sml_share/HCP';
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/FilteredParticipants.xlsx');
subjects = table2array(allSubjs(:,1));%done
%subjects = {'sub-hcp205826'};%,'sub-hcp206222','sub-hcp114217'};   % for troubleshooting specific participant directories; for troubleshooting specific participant directories
tasks = {'workingmemory','emotion','language','social'};
nRuns = 2;
%h = waitbar(0,' Progress') %%% all wait bar related
%nRuns = [2 2 2 2];
for s=1:length(subjects)
    subjID = subjects{s};
    logtxt = fopen('Sm4Modelinglog.txt','a');
    if logtxt == -1, error('Unable to open log txt');end
    %Output when running
    fprintf('%s\n',['CIFTI modelArma                   - ' subjID]);
   % waitbar(s/length(subjects), h, sprintf('Modeling for  %s', subjID))
    funcDir = [studyDir '/derivatives/fpp/' subjID '/func'];
    analysisDir = [studyDir '/derivatives/fpp/' subjID '/analysis'];
    for t=1:length(tasks)
        task = tasks{t};
        for r=1:nRuns
            inputPath = [funcDir '/' subjID '_task-' task '_run-' fpp.util.numPad(r,2)...
                '_space-fsLR_res-2_den-32k_desc-preproc_bold.dtseries.nii'];
            if ~exist(inputPath,'file'), fprintf(logtxt, [subjID,'   no input file']);continue; end
            eventsPath = [funcDir '/' subjID '_task-' task '_run-' fpp.util.numPad(r,2) '_events.tsv'];
            if ~exist(eventsPath,'file'), fprintf(logtxt,[subjID,'   no event file']);continue; end
            contrastMatrixPath = [studyDir '/derivatives/fpp/task-' task '_contrastmatrix.tsv'];
            modelarmaPath = [analysisDir,'/' subjID '_task-' task '_run-' fpp.util.numPad(r,2),'_space-fsLR_res-2_den-32k_modelarma']
            % avoid calling fpp function with already modeled tasks
            if exist(modelarmaPath,'dir')
                if numel(dir(modelarmaPath)) < 100
                    fprintf(logtxt,[subjID,'   insufficientmodelma folder']); 
                    continue
                end;
                continue
            end
            fpp.func.modelArma(inputPath,eventsPath,contrastMatrixPath,'outputSuffix');
            disp('Finish')
        end
    end
end


%% Functional modeling: 2nd-level, CIFTI Arma, across runs 1 and 2 for each task
studyDir = '/mnt/sml_share/HCP';
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/FilteredParticipants.xlsx');
subjects = table2array(allSubjs(51:end,1));%50/864
subjects = {'sub-hcp205826'};   % for troubleshooting specific participant directories; for troubleshooting specific participant directories
tasks = {'workingmemory','emotion','language','social'};
runList = [1 2];
emoOutputTask = 'emotion';
langOutputTask = 'language';
socOutputTask = 'social';
wmOutputTask = 'workingmemory';
emoContrastNames = {'FearVsNeut','NeutVsFear'};
langContrastNames = {'StoryVsMath','MathVsStory'};
socContrastNames = {'MentalVsRnd','RndVsMental'};
wmContrastNames = {'FacesVsAllOthers','FacesVsBody','FacesVsTools','FacesVsPlaces',...
    'BodyVsAllOthers','BodyVsFaces','BodyVsTools','BodyVsPlaces','ToolsVsAllOthers',...
    'ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools','2bkVs0bk','0bkVs2bk'};
h = waitbar(0,' Progress');
logtxt = fopen('2ndSm4Modelinglog.txt','a');
for s=1:length(subjects)
    subjID = subjects{s};
  % Output when running
    fprintf('%s\n',['2nd-level, CIFTI Arma, across runs 1 & 2                   - ' subjID]);
    waitbar(s/length(subjects), h, sprintf('2nd Level Modeling for  %s', subjID))
    analysisDir = [studyDir '/derivatives/fpp/' subjID '/analysis'];    
    for t=1:length(tasks)
        task = tasks{t};
        inputDirs = {};
        for r=runList
            if ~exist([analysisDir '/' subjID '_task-' task '_run-' fpp.util.numPad(r,2) ...
                    '_space-fsLR_res-2_den-32k_modelarma'],'dir'), fprintf(logtxt,['No file ' subjID]);continue; end
            inputDirs{end+1} = [analysisDir '/' subjID '_task-' task '_run-' ...
                fpp.util.numPad(r,2) '_space-fsLR_res-2_den-32k_modelarma'];
        end
        if isempty(inputDirs),disp(['Skip ' subjID]); continue; end
        % avoid calling fpp function with already modeled tasks
        modelarmaPath = [analysisDir '/' subjID '_task-' task '_space-fsLR_res-2_den-32k_modelarma']
        if exist(modelarmaPath,'dir')
           if numel(dir(modelarmaPath)) < 100
              fprintf(logtxt,[subjID,'   insufficientmodelma folder']); 
              continue
           end
            continue
         end
        if strcmp(task,'emotion')
            fpp.func.model2ndLevel(inputDirs,'outputTask',emoOutputTask,'contrastNames',...
                emoContrastNames);
        elseif strcmp(task,'language')
            fpp.func.model2ndLevel(inputDirs,'outputTask',langOutputTask,'contrastNames',...
                langContrastNames);
        elseif strcmp(task,'social')
            fpp.func.model2ndLevel(inputDirs,'outputTask',socOutputTask,'contrastNames',...
                socContrastNames);
        elseif strcmp(task,'workingmemory')
            fpp.func.model2ndLevel(inputDirs,'outputTask',wmOutputTask,'contrastNames',...
                wmContrastNames);
        end
        disp("Complete");
    end
end
