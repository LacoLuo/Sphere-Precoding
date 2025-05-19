function [scatter_coors, r] = generate_scatter_coordinates(N_s, R_s, UE_coord)
    scatter_coors = zeros(N_s, 3);
    for i = 1:N_s
        r = (R_s) * sqrt(rand);
        theta = 2 * pi * rand;
        phi = 2 * pi * rand;
        scatter_coors(i, 1) = UE_coord(1, 1) + r * sin(phi) * cos(theta);
        scatter_coors(i, 2) = UE_coord(1, 2) + r * sin(phi) * sin(theta);
        scatter_coors(i, 3) = UE_coord(1, 3) + r * cos(phi);
    end
end