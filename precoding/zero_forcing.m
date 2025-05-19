function ZF_F = zero_forcing(channel)
    precoding_vector = channel / (channel' * channel);
    ZF_F = precoding_vector ./ vecnorm(precoding_vector);
end