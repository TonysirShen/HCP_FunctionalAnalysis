% is is the warrper function to call fpp.wb.command('cifti-smoothing',' 
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/FilteredParticipants.xlsx');
fppDir = '/mnt/sml_share/HCP/derivatives/fpp';
tasks = {'emotion','language','social','workingmemory'};
runList = 2;
outputSuffix = '_bold.dtseries.nii';
allSubjs = table2cell(allSubjs(:,1));
allSubjs = {'sub-hcp205826'}
subjectlen = numel(allSubjs);
tasks = {'emotion','language','social','workingmemory'};
for t = 1:numel(tasks)
    h = waitbar(0,[tasks{t},' Progress']);
    for i=1:subjectlen
        %path declear
            % inputpath
        subDir = [fppDir,'/',allSubjs{i}];
        funcDir = [subDir, '/func'];
        anatDir = [subDir,'/anat'];
        leftSurface = [anatDir,'/',allSubjs{i},'_hemi-L_space-individual_den-32k_midthickness.surf.gii'];
        rightSurface =[anatDir,'/',allSubjs{i},'_hemi-R_space-individual_den-32k_midthickness.surf.gii'];
        for r = 1:runList
            %output path
            outputPrefix = [funcDir,'/',allSubjs{i},'_task-',tasks{t},'_run-',fpp.util.numPad(r,2),'_space-fsLR_res-2_den-32k_'];
            inputPath = [outputPrefix,'desc-preproc',outputSuffix]; %the origion fMRI scan data
            if ~exist(inputPath,'file'), disp([allSubjs{i},' ',tasks{t},'   input not exist']);continue; end
            outputDesc = ['desc-',fpp.bids.checkNameValue(inputPath,'desc')];
            outputPath = [outputPrefix,outputDesc,'_Sm4',outputSuffix];
             %call fpp.wb.command
            if ~exist(outputPath,'file')
                fpp.wb.command('cifti-smoothing',inputPath,'4 4 COLUMN',outputPath,['-left-surface ',leftSurface,' -right-surface ',rightSurface]);
            end
        end
        waitbar(i/subjectlen,h)
    end
end


% specify input arguments
% inputPath = [funcDir,'/sub-hcp100206_task-workingmemory_run-01_space-fsLR_res-2_den-32k_desc-preproc_bold.dtseries.nii'];%the origion fMRI scan data
% inputDesc = ['desc-',fpp.bids.checkNameValue(inputPath,'desc')];
% inputPrefix = [funcDir,'/sub-hcp100206_task-workingmemory_run-01_space-fsLR_res-2_den-32k_'];
% inputSuffix = '_bold.dtseries.nii';
% inputText = '/mnt/local_share/HCP/derivatives/cshen2/Sm4Auguments.txt';
% outputPath = [inputPrefix,inputDesc,'_Sm4',inputSuffix];
%     left and right surface data
% leftSurface = [anatDir,'/sub-hcp100206_hemi-L_space-individual_den-32k_midthickness.surf.gii'];
% rightSurface =[anatDir,'/sub-hcp100206_hemi-R_space-individual_den-32k_midthickness.surf.gii'];
% call fpp.wb.command
% fpp.wb.command('cifti-smoothing',inputPath,['4 4 COLUMN'],outputPath,['-left-surface ',leftSurface,' -right-surface ',rightSurface])
% end