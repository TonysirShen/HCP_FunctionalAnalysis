% Function to compute CIFTI-based resting-state functional connectivity map
% from a seed ROI input.
%
% Arguments:
% - seedPath (string): path to seed ROI CIFTI file

%author:Deen Benjanming
%modifier: TS

%InutSample
%inputPath = '/mnt/sml_share/HCP/derivatives/fpp/sub-hcp100206/roi/sub-hcp100206_space-fsLR_den-32k_desc-handDrawnLTPThrP6workingmemoryFacesVsAllOthersSm4Top5PctLORO01_mask.dscalar.nii';
%fpprestConntestt(inputPath);

function hcpRestConnMap(seedPath)

% check propertyies of initial seedpath
bidsDir = fpp.bids.checkBidsDir(seedPath); % basepath before sub's dictnory
spaceStr = '_space-fsLR_res-2_den-32k'; % space for seed & rest 
nRuns = 4;
inputDesc = 'fixdenoised'; %desc for the rest file
subjID = fpp.bids.checkNameValue(seedPath,'sub'); 
seedDesc = fpp.bids.checkNameValue(seedPath,'desc');
seedDen = fpp.bids.checkNameValue(seedPath,'den');
logtext = fopen('/mnt/sml_share/HCP/derivatives/cshen2/logs/Sm4RestConnlog.txt','a');
if ~strcmp(seedDen,'32k'), error('Seed must be defined in 32k fsLR space.'); end
outputDir = ['/mnt/sml_share/HCP/derivatives/cshen2/Sm4restconn/sub-' subjID '_Sm4_task-rest' spaceStr '_funcconn' ];
outputPath = [outputDir '/sub-' subjID '_task-rest_ROI-' spaceStr '_desc-' inputDesc...
    'Seed' seedDesc '_rstat.dscalar.nii'];
overwrite = 1;
if exist(outputPath,'file') && ~overwrite
    fprintf(logtext, [subjID, seedDesc, ' RestConnectMap Already Exist\n']);
    disp([subjID, seedDesc, ' RestConnectMap Already Exist\n']);
    return
end

% Define paths used inside function
% read subject directory based on the seed path
subjDir = [bidsDir '/sub-' subjID];

% read two function Dirs inside the subject Dir
funcDir = [subjDir '/func'];
analysisDir = [subjDir '/analysis'];


% Load seed
seedMat = fpp.util.readDataMatrix(seedPath);
missed_runs = 0;
% Loop across runs, compute correlations
for r=1:nRuns
    % Load data (this will be the full path tp the resting data.nii)
    restPath = [funcDir '/sub-' subjID '_task-rest_run-' fpp.util.numPad(r,2)...
        spaceStr '_desc-' inputDesc '_bold.dtseries.nii'];
    if ~exist(restPath,"file");
        missed_runs = missed_runs + 1;
        continue
    end
    if missed_runs >= nRuns;error([subjID ' did not find anu resting state runs']);end
    [restMat,hdr] = fpp.util.readDataMatrix(restPath);
    
    % If seed doesn't have subcortical CIFTI components, zero-pad
    if r==1 && size(restMat,1)>size(seedMat,1)
        seedMat = [seedMat; zeros(size(restMat,1)-size(seedMat,1),1)];
    end
    
    %find outlier path & Define outlier volumes
%     confoundPath = fpp.bids.changeName(restPath,{'task','space','res','den','desc'},{'workingmemory','','','',''},'confounds','.tsv');
%     confoundtable = readtable(confoundPath,"FileType","text");
%     transdata = zeros(size(confoundtable{:,1:3}));
%     transdata(2:end,:) = diff(confoundtable{:,1:3});
%     rotdata = zeros(size(confoundtable,1),3);
%     rotdata(2:end,:)= diff(confoundtable{:,4:6});%origin not diff???
%     rotdata = (rotdata * pi / 180); %convert to radian
%     transCutoff=0.35;% resolution * 0.5
%     rotCutoff=0.07; %filp angle *0.5
%     tptsAfter=0;
%     %TODO: compute framewise displacement, since the origin is not valid
%  
%     %calculate framewise translation,rotation
%     confoundtable.framewise_translation = sqrt(sum(transdata(:, 1:3).^2, 2));
%     confoundtable.framewise_rotation = acos((cos(rotdata(:,1)).*cos(rotdata(:,2)) + cos(rotdata(:,1)).*cos(rotdata(:,3)) + ...
%         cos(rotdata(:,2)).*cos(rotdata(:,3)) + sin(rotdata(:,1)).*sin(rotdata(:,2)).*sin(rotdata(:,3)) - 1)/2);
% 
%     %calculate frame_wise displacment
%     rotMM =50*rotdata(:,:);
%     confoundtable.framewise_displacement = sum(abs(rotMM),2) + sum(abs(transdata),2);
%     %... origion code fpp.func.preproc.estimateHeadMotion
% 
%     % Remove high-movement time points(OutlierTPs) from restMat
%     OutlierTPs = find(abs(confoundtable.framewise_translation)>transCutoff | abs(confoundtable.framewise_rotation)>rotCutoff ...
%         | abs(confoundtable.framewise_displacement) > transCutoff);
%     restMat(OutlierTPs,:) = [];
%     confoundtable(OutlierTPs,:) =[];
    nTpts = size(restMat,2);
    
    % Load resting data, concatenate with prior runs
    restMat = zscore(restMat,0,2)/sqrt(nTpts-1); % Mean zero,for outlier data
    seedSeries = zscore(mean(restMat(seedMat==1,:)))/sqrt(nTpts-1);
    corrMat(:,r) = restMat*seedSeries';

    % debug statements
    %fprintf('subID:%s\nSeedDesc:%s\nSeedDen:%s\nNumber of outliers: %d\n',subjID, seedDesc, seedDen,length(OutlierTPs));%test variables
end
corrMat = mean(corrMat,2);
% Write output
%[analysisDir '/sub-' subjID '_task-rest' spaceStr '_funcconn' 'test']; %remove "test"
if ~exist(outputDir,'dir'), mkdir(outputDir); end
fpp.util.writeDataMatrix(corrMat,hdr,outputPath);
disp(['Finsihed running restconn for ' subjID ' ' seedDesc]);end

