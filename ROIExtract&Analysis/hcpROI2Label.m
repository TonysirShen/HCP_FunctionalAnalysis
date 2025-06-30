
% Script to generate surface label files containing search spaces and ROIs
% from IDENT ROI analysis.
%Author: Ben Deen, Chencheng Shen

studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir '/derivatives/cshen2/FilteredParticipants']);
subjects = table2array(allSubj(:,1));
subjects = subjects([1]);
space = 'fsLR'; % ROI space
den = '32k';    % ROI surface density
searchNames = cell(4,1);
% Define ROI descriptions
% Search space names for DMN
searchNames{1} = {'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTH','mmpApexRTH','mmpApexLTPJ','mmpApexRTPJ'};
% Search space names for Visual network
searchNames{2} = {'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'};
% Search space names for TP/PRC
searchNames{3} = {'handDrawnLTPThrP6','handDrawnRTPThrP6'};
searchNames{4} = {'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};
% All search spaces
searchNamesAll = unique(horzcat(searchNames{:}));
taskContrasts = {'workingmemoryFacesVsAllOthers'};
roiColors = {[172,0,0],[204 102 119],[253 131 0],[253 131 0],[255 255 0]};   % Label colors by ROI type ...
% Social:[136 34 85],visual[[204 102 119],TP[194 77 175],PRC[
roiStr = 'Top5Pct';
smStr = 'Sm4';

for sub=1:length(subjects)
    subject = subjects{sub};
    
    % Directories and names
    subjDir = [fppDir '/' subject];
    roiDir = [subjDir '/roi'];
    funcDir = [subjDir '/func'];
    anatDir = [subjDir '/anat'];
    
    roiDescs = cell(length(searchNames),1);
    for s=1:length(searchNames)
        roiDescs{s} = cell(length(searchNames{s}),1);
        for r=1:length(searchNames{s})
            roiDescs{s}{r} = [searchNames{s}{r} taskContrasts{1} smStr roiStr];
        end
    end
    
    % Midthickness surface paths
    hemis = {'L','R'};
    for h=1:2
        surfacePaths{h} = [anatDir '/' fpp.bids.changeName('',{'hemi','space','den'},...
            {hemis{h},'individual',den},'midthickness','.surf.gii')];
    end
    
    % Loop through ROIs, generate label surface
    for s=1:length(searchNames)
        for r=1:length(searchNames{s})
%             roiPath = [roiDir '/' subject '_' fpp.bids.changeName('',{'space','den','desc'},...
%                 {space,den,roiDescs{s}{r}},'mask','.dscalar.nii')];
              roiPath = ['/mnt/sml_share/HCP/derivatives/fpp/group/MMPParcels/space-fsLR_den-32k_desc-'...
                searchNames{s}{r} '_mask.dscalar.nii'];
            roiLabelPath = fpp.bids.changeName(roiPath,[],[],'dseg','.dlabel.nii');
%             if exist(roiLabelPath,'file'), continue; end
            % Import label text file
%             txtPath = [roiDir '/tmpLabel20395823.txt'];
            txtPath = [fppDir '/tmpLabel20395823.txt'];
            fid = fopen(txtPath,'w');
            fprintf(fid,'%s\n',roiDescs{s}{r});
            fprintf(fid,'%d %d %d %d %d\n',[1 roiColors{s} 255]);
            fclose(fid);
            fpp.wb.command('cifti-label-import',roiPath,txtPath,roiLabelPath);
            fpp.util.system(['rm -rf ' txtPath]);
            
            disp(roiLabelPath);
        end
    end
    
    % Loop through search spaces, generate label surface
    for s=1:length(searchNamesAll)
        roiPath = [anatDir '/' fpp.bids.changeName('',{'space','den','desc'},...
            {space,den,searchNamesAll{s}},'mask','.dscalar.nii')];
        roiLabelPath = fpp.bids.changeName(roiPath,[],[],'dseg','.dlabel.nii');
        if exist(roiLabelPath,'file'), continue; end
        
        % Import label text file
        txtPath = [roiDir '/tmpLabel20395823.txt'];
        fid = fopen(txtPath,'w');
        fprintf(fid,'%s\n',searchNamesAll{s});
        fprintf(fid,'%d %d %d %d %d\n',[1 0 0 0 255]);
        fclose(fid);
        fpp.wb.command('cifti-label-import',roiPath,txtPath,roiLabelPath);
        fpp.util.system(['rm -rf ' txtPath]);
        
        % Convert to CIFTI
        disp(roiLabelPath);
        
        % Convert to border
        roiBorderPaths{1} = fpp.bids.changeName(roiLabelPath,'hemi','L',[],'.border');
        roiBorderPaths{2} = fpp.bids.changeName(roiLabelPath,'hemi','R',[],'.border');
        fpp.wb.command('cifti-label-to-border',roiLabelPath,[],[],['-border ' surfacePaths{1}...
            ' ' roiBorderPath ' -border ' surfacePath ' ' roiBorderPaths{2}]);
    end
end

