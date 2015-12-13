function [names,images] = loadDICOM(path_name)

s = size(path_name);
numberOfImages = s(1);
names = {};
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
        save3DImage(image3d);
        clear image3d;
        vertebra = vertebra + 1;
        index = 1;
        
    end
    
    image3d(:,:,index) = data;
    pixDim = dcm.PixelSpacing;
    lastV = currentV;
    index = index + 1;
    
end

save3DImage(image3d);

function [] = save3DImage(image3d)
        image3d = double(image3d);
        image3d = anisoToIsotropic(image3d, pixDim(1), pixDim(2), dcm.SpacingBetweenSlices);
        images{vertebra} = image3d;
        names = [names lastV(end-1:end)];
end

end




