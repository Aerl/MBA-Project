function [ GT ] = loadErodedGT(vertIndex, erosiondiameter, leftOut  )

if nargin <3
    path = 'GT_Processed/GroundTruthPerVertibrae.mat';
    GTs = load(path);
    GT = GTs.GTALL{vertIndex};

    se = strel('disk', erosiondiameter);
    GT = imerode(GT, se);
else
    assert(leftOut < 10, 'leftOut out of range');
    path = strcat('GT_Processed/GT_', num2str(leftOut), '.mat')
    GTs = load(path);
    GT = GTs.GTALL{vertIndex};

    se = strel('disk', erosiondiameter);
    GT = imerode(GT, se);
end

end

