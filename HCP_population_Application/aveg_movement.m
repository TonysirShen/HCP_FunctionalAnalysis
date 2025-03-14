% TODO modify ths funtion calculate individual partcipant's average
% movement across all time points. 
function average_f_d = aveg_movement(confoundPath)

% check propertyies of initial seedpath
nRuns = 1;
subjID = fpp.bids.checkNameValue(confoundPath,'sub');
seedDesc = fpp.bids.checkNameValue(confoundPath,'desc');
seedDen = fpp.bids.checkNameValue(confoundPath,'den');


% Loop across runs, compute correlations
for r=1:nRuns
    
    %load data and calculate new framewosedata
    confoundtable = readtable(confoundPath,"FileType","text");
    transdata = zeros(size(confoundtable{:,1:3}));
    transdata(2:end,:) = diff(confoundtable{:,1:3});
    rotdata = zeros(size(confoundtable,1),3);
    rotdata(2:end,:)= diff(confoundtable{:,4:6});%
    rotdata = (rotdata * pi / 180); %convert to radian
    transCutoff=0.35;% resolution * 0.5
    rotCutoff=0.07; %filp angle *0.5
    tptsAfter=0;
    %TODO: compute framewise displacement, since the origin is not valid

    %calculate framewise translation,rotation
    confoundtable.framewise_translation = sqrt(sum(transdata(:, 1:3).^2, 2));
    confoundtable.framewise_rotation = acos((cos(rotdata(:,1)).*cos(rotdata(:,2)) + cos(rotdata(:,1)).*cos(rotdata(:,3)) + ...
        cos(rotdata(:,2)).*cos(rotdata(:,3)) + sin(rotdata(:,1)).*sin(rotdata(:,2)).*sin(rotdata(:,3)) - 1)/2);
    %calculate frame_wise displacment
    rotMM =50*rotdata(:,:);
    confoundtable.framewise_displacement = sum(abs(rotMM),2) + sum(abs(transdata),2);
    average_f_d = sum(confoundtable.framewise_displacement)/numel(confoundtable.framewise_displacement);
end
end
%     ... origion code fpp.func.preproc.estimateHeadMotion
    
    %TODO 
% calculate outstanding TPS
%  OutlierTPs = find(abs(confoundtable.framewise_translation)>transCutoff | abs(confoundtable.framewise_rotation)>rotCutoff ...
%         | abs(confoundtable.framewise_displacement) > transCutoff);
%     restMat(OutlierTPs,:) = [];
%     confoundtable(OutlierTPs,:) =[];
%     nTpts = length(restMat);
%     
%     Load resting data, concatenate with prior runs
%     restMat = fpp.util.readDataMatrix(restPath);
%     restMat = zscore(restMat,0,2)/sqrt(nTpts-1); % Mean zero,for outlier data
%     seedSeries = zscore(mean(restMat(seedMat==1,:)));  %/sqrt(nTpts-1);
%     corrMat(:,r) = restMat*seedSeries';
% 
%     debug statements
%     fprintf('subID:%s\nSeedDesc:%s\nSeedDen:%s\nNumber of outliers: %d\n',subjID, seedDesc, seedDen,length(OutlierTPs));%test variables
% end
% Write output
% outputDir = ['/mnt/local_share/HCP/derivatives/cshen2/restconn/sub-' subjID '_task-rest' spaceStr '_funcconn' ]  
% [analysisDir '/sub-' subjID '_task-rest' spaceStr '_funcconn' 'test']; %remove "test"
% if ~exist(outputDir,'dir'), mkdir(outputDir); end
% outputPath = [outputDir '/sub-' subjID '_task-rest_ROI-' spaceStr '_desc-' inputDesc...
%     'Seed' seedDesc '_rstat.dscalar.nii'];
% fpp.util.writeDataMatrix(corrMat,hdr,outputPath);
% 
% 
% 
%     Remove high-movement time points(OutlierTPs) from restMat
%    