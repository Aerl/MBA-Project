function [ distanceField] = distanceFieldByGT(BoxMIN, BoxDim, vertibrae, size)
    
    EROSION = 1;
    
    GT = loadEroadedGT(vertibrae, EROSION);
    [XGT, YGT, ZGT] = ind2sub(sizeGT, find(GT));
    
    BoundingMIN = [min(XGT), min(YGT), min(ZGT)];
    BoundingMAX = [max(XGT), max(YGT), max(ZGT)];
    BoundDim = BoundingMAX - BoundingMIN;
    BoxMAX = BoxMIN + BoxDIM;
    
    distanceField = zeros(size);
    
    % Copy values from Bounding in GT to Box in Levelset
    
    sampx = (BoundingMIN(1): BoundDim(1) / BoxDim(1) : BoundindMAX(1));
    sampy = (BoundingMIN(2): BoundDim(2) / BoxDim(2) : BoundindMAX(2));
    sampz = (BoundingMIN(3): BoundDim(3) / BoxDim(3) : BoundindMAX(3));
    
    
    
    [Sx, Sy, Sz] = meshgrid(sampx, sampy, sampz);
    
    distanceField(boxMIN(1):boxMAX(1), boxMIN(2):boxMAX(2), boxMIN(3):boxMAX(3)) ...
        = interp3(GT, Sx, Sy, Sz, 'cubic');
    


end

