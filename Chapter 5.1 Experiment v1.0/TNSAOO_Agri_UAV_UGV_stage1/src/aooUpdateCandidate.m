function candidatePos = aooUpdateCandidate(currentPos, elitePos, popPositions, aooState, iter, maxIter, lb, ub)
%AOOUPDATECANDIDATE Original-AOO-formula-adapted update for random-key vectors.
%
% This function adapts the original continuous AOO update equations to the
% present multi-objective random-key scheduling problem. The scalar Best_X
% in the original single-objective AOO is replaced by a Pareto-archive elite
% reference solution.

dim = numel(currentPos);
popSize = size(popPositions, 1);

ubVec = ub .* ones(1, dim);
lbVec = lb .* ones(1, dim);

i = aooState.index;
theta = pi * rand();
c = (1 - iter / maxIter)^3;
P = levyFlight(1, dim, 1.5);

% Read AOO internal coefficients.
x = aooState.x(i);
m = max(aooState.m(i), eps);
L = aooState.L(i);
e = aooState.e(i);
g = aooState.g;

if rand > 0.5
    % Original AOO branch: W = c/pi*(2*rand-1).*ub
    W = c/pi * (2 * rand(1, dim) - 1) .* ubVec;

    block = max(1, round(popSize / 10));
    if mod(i, block) == 0
        candidatePos = mean(popPositions, 1) + W;
    elseif mod(i, block) == 1
        candidatePos = elitePos + W;
    else
        candidatePos = currentPos + W;
    end
else
    if rand > 0.5
        % Original AOO branch using R.
        A = ubVec - abs(ubVec * iter * sin(2*pi*rand) / maxIter);
        R = (m * e + L^2) / dim .* randUniformRange(-A, A, 1, dim);
        candidatePos = elitePos + R + c * P .* elitePos;
    else
        % Original AOO branch using J.
        k = 0.5 + 0.5 * rand;
        B = ubVec - abs(ubVec * iter * cos(2*pi*rand) / maxIter);
        alpha = 1/pi * exp(randi([0, iter]) / maxIter);
        J = 2 * k * x^2 * sin(2*theta) / m / g * (1-alpha) / dim .* ...
            randUniformRange(-B, B, 1, dim);
        candidatePos = elitePos + J + c * P .* elitePos;
    end
end

candidatePos = boundaryRecall(candidatePos, lbVec, ubVec);
end
