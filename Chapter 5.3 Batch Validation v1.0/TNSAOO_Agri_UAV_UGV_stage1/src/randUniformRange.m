function X = randUniformRange(lb, ub, n, m)
%RANDUNIFORMRANGE Uniform random values between element-wise bounds.
% This avoids unifrnd so the code does not require Statistics Toolbox.

if isscalar(lb)
    lb = lb .* ones(1,m);
end
if isscalar(ub)
    ub = ub .* ones(1,m);
end

X = repmat(lb, n, 1) + rand(n,m) .* repmat((ub-lb), n, 1);
end
