function [Tx_coords, D] = generate_Tx_coordinates(lambda, N_h, N_v, ant_spacing, BS_height)
    d = ant_spacing * lambda; % Spacing between antenna elements (meter)

    My_idx = 0:1:N_h-1;
    Mz_idx = 0:1:N_v-1;
    Myy_idx = repmat(My_idx, 1, N_v)';
    Mzz_idx = reshape(repmat(Mz_idx, N_h, 1), 1, N_h*N_v)';
    yz_idx = reshape(cat(3, Myy_idx', Mzz_idx'), [], 2);
    x_coords = zeros(size(yz_idx, 1), 1);
    yz_coords = (yz_idx - [(N_h-1)/2, (N_v-1)/2]) * d + [0, BS_height];

    Tx_coords = cat(2, x_coords, yz_coords);
    D = max([ max(yz_coords(:, 1))-min(yz_coords(:, 1)), max(yz_coords(:, 2))-min(yz_coords(:, 2)) ]); % Largest dimension of antenna array
end