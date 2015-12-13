function [ distance_field ] = initialize_distance_field( size, center, margin, value)

distance_field = zeros(size); 
distance_field(center(1)-margin(1):center(1)+margin(1),...
    center(2)-margin(2):center(2)+margin(2),...
    center(3)-margin(3):center(3)+margin(3)) = value*2;
distance_field = distance_field - value;

end

