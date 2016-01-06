function [ result ] = levelSet( image, distance_field, gradient_field, resolution )
global p;

for i = 1:p(1).iterations
    distance_field = ac_hybrid_model(image-p(1).mu, distance_field, p(1).propagation_weight,...
        p(1).gac_weight, gradient_field, p(1).delta_time, 1);
end
    distance_field = isoToAnisotropic(distance_field,resolution(1),resolution(2),resolution(3));
    
    numer_of_slices = size(distance_field,3);
    result = cell(numer_of_slices,1);

for i = 1:numer_of_slices
    result{i} = contours(distance_field(:,:,i),[0,0]);
end

end

