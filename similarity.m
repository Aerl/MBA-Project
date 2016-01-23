function [ jaccardIndex, diceIndex ] = similarity( segmentation, groundTruth, sizeIMG )

    sumIntersection = 0;
    sumUnion = 0;
    sumGroundTruth = 0;
    sumSegmentation = 0;
    
    slice = 1:15;
    for i = 1:length(slice)
        gT = imresize(groundTruth{i},sizeIMG);
        seg = imresize(segmentation(:,:,slice(i)),sizeIMG);
        
        nIntersection = nnz(gT.*seg);
        nUnion = nnz(gT+seg);
        nGroundTruth = nnz(gT);
        nSegmentation = nnz(seg);
        
        sumIntersection = sumIntersection + nIntersection;
        sumUnion = sumUnion + nUnion;
        sumGroundTruth = sumGroundTruth + nGroundTruth;
        sumSegmentation = sumSegmentation + nSegmentation;
    end

    jaccardIndex = sumIntersection / sumUnion;
    diceIndex = 2*sumIntersection / (sumGroundTruth + sumSegmentation);
    
end

