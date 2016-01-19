function [ contours, binaryResult ] = segmentVertebra( vertebra,resampledImage,originalImage )
global p;
% select Vertebra
if (p(1).subsamplingIsOn)
    image = resampledImage;
else
    image = originalImage;
end

% compute gradient field
gradient_field = ac_gradient_map(image,1);

% set center and margin depending on image size

margin = size(image) * 0.08;
margin(3) = margin(3) * 1.5;
margin = round(margin);

[center] = computeCenter(image);

%initialize distance field
distance_field = initialize_distance_field(size(image), center, margin, 0.5);

% smooth Initialization
if (p(1).smoothDistanceFieldIsOn)
    gauss_filter = fspecial('gaussian',p(1).gaussSize,p(1).gaussSigma);  % size = [5 5] and sigma = 2
    distance_field = imfilter(distance_field,gauss_filter,'same');
end

% segment vertebra using hybrid level set
[contours, binary] = levelSet( image, distance_field, gradient_field, p(1).resolution{vertebra} );

% recalculate center of anisotropic data
if (p(1).subsamplingIsOn)
    [center] = computeCenter(originalImage);
end

% connected component analysis
labels = bwlabeln(binary);
labelOfVertebra = labels(center(1),center(2),center(3));
binaryResult = (labels==labelOfVertebra);


    function [center] = computeCenter(image)
        center = size(image);
        center = center/2;
        center(1:2) = center(1:2)*1;
        center = round(center);
    end

end

