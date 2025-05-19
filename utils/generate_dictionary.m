function [A, dict_coor] = generate_dictionary(N, Tx_coor, lambda, min_x, step_x, max_x, min_y, step_y, max_y)
    Mx_idx = min_x:step_x:max_x;
    My_idx = min_y:step_y:max_y;

    N_x = length(Mx_idx);
    N_y = length(My_idx);

    Mxx_idx = repmat(Mx_idx, 1, N_y)';
    Myy_idx = reshape(repmat(My_idx, N_x, 1), 1, N_x*N_y)';
    xy_idx = reshape(cat(3, Mxx_idx', Myy_idx'), [], 2);
    z_coor = zeros(size(xy_idx, 1), 1);
    xy_coor = xy_idx;        
    dict_coor = cat(2, xy_coor, z_coor);

    propagation_distance = zeros(N, N_x*N_y);
    for i=1:(N_x*N_y)
        propagation_distance(:, i) = sqrt(sum((Tx_coor - dict_coor(i, :)).^2, 2));
    end
    A = exp(- 1j * 2*pi / lambda .* propagation_distance);
end