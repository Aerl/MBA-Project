function [name,images] = loadDICOM(path_name)

s = size(path_name);
numberOfImages = s(1);
% CAUTION! Number of slices may vary between different datasets!
% Number of all dataset divided by the number of slices per dataset.
name = {};
vertebra = 1;
lastV = '';
images = {};
image3d = [];
index = 1;
for j = 1:numberOfImages
    dcm = dicominfo(path_name{j});
    currentV = dcm.Filename(1:end-10);
    data = dicomread(dcm);
    
    data(:,:) = fliplr(data(:,:));
    if (j > 1 && ~strcmp(lastV,currentV))
        images{vertebra} = image3d;
        name = [name ; currentV(end-1:end)];
        clear image3d;
        vertebra = vertebra + 1;
        index = 1;
        
    end
    
    image3d(:,:,index) = data;
    pixDim = dcm.PixelSpacing;
    lastV = currentV;
    index = index + 1;
    
end



end


