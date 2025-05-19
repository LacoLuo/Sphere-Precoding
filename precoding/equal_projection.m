function equal_proj_F = equal_projection(N, K, C)
    equal_proj_F = zeros(N, K);
    for i = 1:K
        C_k = squeeze(C(i, :, :));
        [U_k, ~, ~] = svd(C_k);
        rank_k = rank(C_k, 1e-3);

        A = U_k(:, 1:rank_k);

        one_vector = ones(size(A, 2), 1);

        cvx_begin quiet
         variable f(N, 1) complex
         obj = norm(A'*f - (N^0.5)*one_vector);
         minimize(obj);
         
         subject to
            norm(f) <= 1;
        cvx_end

        equal_proj_F(:, i) = f ./ vecnorm(f);
    end
end