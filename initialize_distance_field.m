function [ distance_field ] = initialize_distance_field( size, center, margin)

distance_field = zeros(size); 
distance_field(center(1)-margin(1):center(1)+margin(1),...
    center(2)-margin(2):center(2)+margin(2),...
    center(3)-margin(3):center(3)+margin(3)) = 1;
distance_field = distance_field - 0.5;

end

