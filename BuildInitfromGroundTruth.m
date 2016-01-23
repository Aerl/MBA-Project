%% structs
global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});
global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',...
    [],'mu',[],'resolution',{}, 'subsamplingIsOn',[], 'smoothDistanceFieldIsOn',[],...
    'gaussSize',[],'gaussSigma',[]);
p(1).iterations = 40;
p(1).delta_time = 1;
p(1).propagation_weight = 1e-6;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 300;
p(1).subsamplingIsOn = 1;
p(1).smoothDistanceFieldIsOn = 0;
p(1).gaussSize = [10 10];
p(1).gaussSigma = 8;

leaveOut = 7;

close all;

% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

GTAVG = zeros(63,67,15);
GTALL = cell(5);
GTALL{1} = GTAVG;
GTALL{2} = GTAVG;
GTALL{3} = GTAVG;
GTALL{4} = GTAVG;
GTALL{5} = GTAVG;
%% Load Image (just for image data not for segmentation)
for patientID = (1:9)
    if patientID == leaveOut
        continue;
    end
    % set file path by text file
    parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
    dataset = strcat('p0',num2str(patientID));
    scan = 't1_wk';
    filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);
    
    % use dialog to select folder
    % filepath = uigetdir;
    
    % load all images in filepath
    path = getAllFiles(filepath);
    [s(1).Names,s(1).ResampledImages,s(1).OriginalImages] = loadDICOM(path);
    disp(size(s(1).OriginalImages{1}));
    %%miniTEST
    
    for v = 1:5
        % load ground truth images
        filepath = strcat(parentpath,'\','Data_Segmentation');
        filter = strcat(dataset,'_seg_l',num2str(v),'*.png');
        groundTruthFiles = dir(fullfile(filepath,filter));
        groundTruthFiles = {groundTruthFiles.name};
        
        groundTruthImages = cell(numel(groundTruthFiles),1);
        groundTruthNames = cell(numel(groundTruthFiles),1);
        for i = 1:numel(groundTruthFiles)
            groundTruthNames{i} = fullfile(filepath,groundTruthFiles{i});
            groundTruthImages{i} = imresize(imread(groundTruthNames{i}),size(GTAVG(:,:,i)));
            GTALL{v}(:,:,i) = GTALL{v}(:,:,i) + groundTruthImages{i};
        end
        
        
    end
end

for i = (1:5)
    figure;
    GTALL{i} = GTALL{i} > 8 - (leaveOut<10);

    for j = 1:15
        subplot(3,5,j); 
        imshow(GTALL{i}(:,:,j),[]);
    end
    
end
fileTO = strcat('GT_Processed/GT_', num2str(leaveOut), '.mat');
save(fileTO, 'GTALL');


%%MiniTESTEND