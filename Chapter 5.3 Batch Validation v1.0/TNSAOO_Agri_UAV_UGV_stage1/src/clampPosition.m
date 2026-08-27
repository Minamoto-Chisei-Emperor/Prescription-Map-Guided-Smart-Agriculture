function x = clampPosition(x, lb, ub)
%CLAMPPOSITION Bound repair for continuous random-key vector.

x = min(max(x, lb), ub);
end
