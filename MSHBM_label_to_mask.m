%function used to convert MINST label to mask for ROI analysis
%input - MINST label(.dlabel.nii file)
%Author: Tony Shen

function MSHBM_label_to_mask(input,out_directory)
subjID = fpp.bids.checkNameValue(input,'sub')
if exist(out_directory,"dir");rmdir(out_directory,'s');disp("Folder deleted");end% only for IDs have extra files
if ~exist(out_directory,"dir");mkdir(out_directory);end
[MSHBMlabel,hdr] = fpp.util.readDataMatrix(input);
% Default groups
default_A = (MSHBMlabel >= 2) & (MSHBMlabel <= 15) + (MSHBMlabel >= 202) & (MSHBMlabel <= 215);
default_B = (MSHBMlabel >= 16) & (MSHBMlabel <= 31) + (MSHBMlabel >= 216) & (MSHBMlabel <= 226); 
default_C = (MSHBMlabel >= 32) & (MSHBMlabel <= 42) + (MSHBMlabel >= 227) & (MSHBMlabel <= 237);

% Language group
language = (MSHBMlabel >= 43) & (MSHBMlabel <= 52) + (MSHBMlabel >= 238) & (MSHBMlabel <= 245);

% Control groups
control_A = (MSHBMlabel >= 53) & (MSHBMlabel <= 64) + (MSHBMlabel >= 246) & (MSHBMlabel <= 258);
control_B = (MSHBMlabel >= 65) & (MSHBMlabel <= 76) + (MSHBMlabel >= 259) & (MSHBMlabel <= 271);
control_C = (MSHBMlabel >= 77) & (MSHBMlabel <= 85) + (MSHBMlabel >= 272) & (MSHBMlabel <= 285);

% Salience groups
salience_A = (MSHBMlabel >= 86) & (MSHBMlabel <= 96) + (MSHBMlabel >= 286) & (MSHBMlabel <= 298);
salience_B = (MSHBMlabel >= 97) & (MSHBMlabel <= 109) + (MSHBMlabel >= 299) & (MSHBMlabel <= 313);

% Dorsal Attention groups
dorsalAttention_A = (MSHBMlabel >= 110) & (MSHBMlabel <= 125) + (MSHBMlabel >= 314) & (MSHBMlabel <= 324);
dorsalAttention_B = (MSHBMlabel >= 126) & (MSHBMlabel <= 137) + (MSHBMlabel >= 325) & (MSHBMlabel <= 336);

% Auditory group
auditory = (MSHBMlabel >= 138) & (MSHBMlabel <= 147) + (MSHBMlabel >= 337) & (MSHBMlabel <= 345);

% Somatomotor groups
somatomotor_A = (MSHBMlabel >= 148) & (MSHBMlabel <= 161) + (MSHBMlabel >= 346) & (MSHBMlabel <= 358);
somatomotor_B = (MSHBMlabel >= 161) & (MSHBMlabel <= 173) + (MSHBMlabel >= 359) & (MSHBMlabel <= 369);

% Visual groups
visual_A = (MSHBMlabel >= 173) & (MSHBMlabel <= 186) + (MSHBMlabel >= 370) & (MSHBMlabel <= 384);
visual_B = (MSHBMlabel >= 186) & (MSHBMlabel <= 198) + (MSHBMlabel >= 385) & (MSHBMlabel <= 397);
visual_C = (MSHBMlabel >= 198) & (MSHBMlabel <= 201) + (MSHBMlabel >= 398) & (MSHBMlabel <= 401);

% Group arrays
group_array = {default_A, default_B, default_C,language, ...
                control_A, control_B, control_C, ...
                salience_A, salience_B, ...
                dorsalAttention_A, dorsalAttention_B, ...
                auditory, ...
                somatomotor_A, somatomotor_B, ...
                visual_A, visual_B, visual_C};

% Group names
group_names = {'defaultA', 'defaultB', 'defaultC', ...
               'language', ...
               'controlA', 'controlB', 'controlC', ...
               'salienceA', 'salienceB', ...
               'dorsalAttentionA', 'dorsalAttentionB', ...
               'auditory', ...
               'somatomotorA', 'somatomotorB', ...
               'visualA', 'visualB', 'visualC'};

parfor i = 1:length(group_array)
    group_name = group_names{i};
    data = group_array{i};
    file = [out_directory '/sub-' subjID '_space-individual_den-32k_desc-MSHBM' group_name '_mask.dscalar.nii'];
    fpp.util.writeDataMatrix(data,hdr,file);
end
disp(['Finsh create masks for' subjID])
end