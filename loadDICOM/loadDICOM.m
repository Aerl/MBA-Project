function [name,image3d] = loadDICOM(path_name)

sze = size(path_name);
nrSlices = sze(1);
% CAUTION! Number of slices may vary between different datasets!
% Number of all dataset divided by the number of slices per dataset.
name = {};
for j = 1:nrSlices
    
    dcm = dicominfo(path_name{1});
    data = dicomread(dcm);
    
    data(:,:) = fliplr(data(:,:));
    
    image3d(:,:,j) = data;
    
    pixDim = dcm.PixelSpacing;
    
end

name = [name ; dcm.PatientName.FamilyName];

end


