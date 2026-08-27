function tf = dominatesIndividual(a, b)
%DOMINATESINDIVIDUAL Feasibility-aware Pareto dominance.

tol = 1e-12;

aFeas = a.violation <= tol;
bFeas = b.violation <= tol;

if aFeas && ~bFeas
    tf = true;
    return;
elseif ~aFeas && bFeas
    tf = false;
    return;
elseif ~aFeas && ~bFeas
    tf = a.violation < b.violation;
    return;
end

oa = a.objectives;
ob = b.objectives;
tf = all(oa <= ob + tol) && any(oa < ob - tol);
end
