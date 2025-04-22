studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
contrast_names = {'FacesVsAllOthers','ToolsVsAllOthers'};
contrast_name = 'FacesVsAllOthers';
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/BalancedDiscoveryIDs.xlsx');
allSubjs = table2array(allSubjs(:,1));
searchNames = {'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};
ConvertPath= '/mnt/sml_share/HCP/derivatives/cshen2/32492_to_59412.mat';
load(ConvertPath)
for n= 1:numel(searchNames)
    searchName = searchNames{n};
    roiDatas = zeros(numel(allSubjs),3);
    parfor s = 1:length(allSubjs)
        subject = allSubjs{s};
        subjDir = [fppDir '/' subject];
        anatDir = [subjDir '/anat'];
        roitDir = [subjDir '/roi'];
        subjLPath = [anatDir '/' subject '_hemi-L_space-individual_den-32k_midthickness.surf.gii'];
        subjRPath = [anatDir '/' subject '_hemi-R_space-individual_den-32k_midthickness.surf.gii'];
        if ~exist(subjLPath,"file"),error(['no surface file ' subjLPath]);end
        if ~exist(subjRPath,"file"),error(['no surface file ' subjRPath]);end
        subjLdata = gifti(subjLPath).vertices;
        subjRdata = gifti(subjRPath).vertices;
        subjData = [subjLdata;subjRdata];
        subjData = subjData(logical(ConvertMatrix),:);
        roiPath = [roitDir '/' subject '_space-fsLR_den-32k_desc-' searchName 'workingmemoryFacesVsAllOthersSm4Top5Pct_mask.dscalar.nii']
        if ~exist(roiPath,"file"),error(['no roi file ' roiPath]);end
        roimap = fpp.util.readDataMatrix(roiPath);
        roiData = subjData(logical(roimap),:);
        roiDatas(s,:) = mean(roiData,1); 
        disp(['finish ' subject])
    end
    save(['/mnt/sml_share/HCP/derivatives/cshen2/' searchName contrast_name 'Facelocationdata.mat'],"roiDatas")
end

