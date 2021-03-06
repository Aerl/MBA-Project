function [ result, binary, i ] = levelSet( image, distance_field, gradient_field, resolution )
global p;

middle = round(size(image,3)/2);

margin = ceil(middle * p(1).differenceMargin);

% propagate distance field
for i = 1:p(1).iterations
    %     last_DF = distance_field;
    last_DF = distance_field(:,:,middle-margin:middle+margin);
    distance_field = ac_hybrid_model(image-p(1).mu, distance_field, p(1).propagation_weight,...
        p(1).gac_weight, gradient_field, p(1).delta_time, 1);
    diff_field = abs(last_DF - distance_field(:,:,middle-margin:middle+margin));
    diff = sum(sum(sum(diff_field)))/ (numel(diff_field));
    
    if (diff < p(1).convergenceThreshold)
        break
    end
    
end

if (p(1).subsamplingIsOn)
    distance_field = isoToAnisotropic(distance_field,resolution(1),resolution(2),resolution(3));
end

% get binary result
binary = (distance_field>0);

% compute countours
numer_of_slices = size(distance_field,3);
result = cell(numer_of_slices,1);
for s = 1:numer_of_slices
    result{s} = contours(distance_field(:,:,s),[0,0]);
end

end

