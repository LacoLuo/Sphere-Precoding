function sphere_F = sphere_precoding(N, K, C)
    sphere_F = zeros(N, K);
    for i = 1:K
        C_k = squeeze(C(i, :, :));
        [U_k, ~, ~] = svd(C_k);
        rank_k = rank(C_k, 1e-3);

        A = U_k(:, 1:rank_k);
        
        B = {};
        for j = 1:K
            if j ~= i
                C_j = squeeze(C(j, :, :));
                [U_j, ~, ~] = svd(C_j);
                rank_j = rank(C_j, 1e-3);
                B_j = U_j(:, 1:rank_j);
                B{end+1} = B_j;
            end
        end
        B = cat(2, B{:});

        one_vector = ones(size(A, 2), 1);

        cvx_begin quiet
         variable f(N, 1) complex
         obj = norm(A'*f - (N^0.5)*one_vector);
         minimize(obj);
         
         subject to
            norm(B'*f) <= (1 * 1e-3);
            norm(f) <= 1;
        cvx_end

        sphere_F(:, i) = f ./ vecnorm(f);
    end
end