function sample_coords = generate_sample_coordinates(N_c, Delta_x, R_s, UE_coord)
    K = size(UE_coord, 1);
    sample_coords = zeros(K, N_c, 3);
    for i = 1:K
        init_coord = UE_coord(i, :);
        for j = 1:N_c
            r = (Delta_x + R_s) * sqrt(rand);
            theta = 2 * pi * rand;
            phi = 2 * pi * rand;
            sample_coords(i, j, 1) = init_coord(1, 1) + r * sin(phi) * cos(theta);
            sample_coords(i, j, 2) = init_coord(1, 2) + r * sin(phi) * sin(theta);
            sample_coords(i, j, 3) = init_coord(1, 3) + r * cos(phi);
        end
    end
end