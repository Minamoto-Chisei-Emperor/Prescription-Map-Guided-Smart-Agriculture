function z = levyFlight(n, m, beta)
%LEVYFLIGHT Levy flight random matrix.
% Uses randn instead of random('Normal',...) to avoid toolbox dependency.

num = gamma(1+beta) * sin(pi*beta/2);
den = gamma((1+beta)/2) * beta * 2^((beta-1)/2);
sigma_u = (num/den)^(1/beta);

u = sigma_u .* randn(n,m);
v = randn(n,m);
z = u ./ (abs(v).^(1/beta) + eps);
end
