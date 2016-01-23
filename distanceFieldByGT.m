function [ distanceField] = distanceFieldByGT(BoxMIN, BoxDim, vertibrae, dfsize)
    
    EROSION = 1;
    
    GT = loadErodedGT(vertibrae, EROSION);
    GT = im2double(GT);
    [XGT, YGT, ZGT] = ind2sub(size(GT), find(GT));
    
    BoundingMIN = [min(XGT), min(YGT), min(ZGT)];
    BoundingMAX = [max(XGT), max(YGT), max(ZGT)];
    BoundDim = BoundingMAX - BoundingMIN;
    BoxMAX = BoxMIN + BoxDim;
    
    distanceField = zeros(dfsize);
    
    % Copy values from Bounding in GT to Box in Levelset
    
    sampx = linspace(BoundingMIN(2), BoundingMAX(2), BoxDim(2)+1);
    sampy = linspace(BoundingMIN(1), BoundingMAX(1), BoxDim(1)+1);
    sampz = linspace(BoundingMIN(3), BoundingMAX(3), BoxDim(3)+1);
    
    
    
    [Sx, Sy, Sz] = meshgrid(sampx, sampy, sampz);
    
    distanceField(BoxMIN(1):BoxMAX(1), BoxMIN(2):BoxMAX(2), BoxMIN(3):BoxMAX(3)) ...
        = interp3(GT, Sx, Sy, Sz, 'cubic');    
    
    distanceField = distanceField -0.5;

end

