function X = boundaryRecall(X, lb, ub)
%BOUNDARYRECALL Boundary repair by random recall, following the TIS/AOO style.

if isscalar(lb)
    lb = lb .* ones(size(X));
end
if isscalar(ub)
    ub = ub .* ones(size(X));
end

maskHigh = X > ub;
maskLow  = X < lb;

if any(maskHigh(:))
    X(maskHigh) = rand(1, nnz(maskHigh)) .* (ub(maskHigh) - lb(maskHigh)) + lb(maskHigh);
end
if any(maskLow(:))
    X(maskLow) = rand(1, nnz(maskLow)) .* (ub(maskLow) - lb(maskLow)) + lb(maskLow);
end
end
