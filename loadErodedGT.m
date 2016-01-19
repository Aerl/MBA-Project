function [ GT ] = loadErodedGT(vertIndex, erosiondiameter  )

GTs = load('GroundTruthPerVertibrae.mat');
GT = GTs.GTALL{vertIndex};

se = strel('disk', erosiondiameter);
GT = imerode(GT, se);


end

