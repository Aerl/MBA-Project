function [ jaccardIndex, diceIndex ] = similarity2D( segmentation, groundTruth, sizeIMG )

    jaccardIndex = 1:15;
    diceIndex = 1:15;

    slice = 1:15;
    for i = 1:length(slice)
        
        gT = imresize(groundTruth{i},sizeIMG);
        seg = imresize(segmentation(:,:,slice(i)),sizeIMG);
        
        nIntersection = nnz(gT.*seg);
        nUnion = nnz(gT+seg);
        nGroundTruth = nnz(gT);
        nSegmentation = nnz(seg);
        
        jaccardIndex(i) = nIntersection / nUnion;
        diceIndex(i) = 2*nIntersection / (nGroundTruth + nSegmentation);
        
    end
    
end

