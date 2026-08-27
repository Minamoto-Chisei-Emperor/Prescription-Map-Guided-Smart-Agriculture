function [archive, history] = tnsaooOptimizer(env, cfg)
%TNSAOOOPTIMIZER Multi-objective TNSAOO workflow.
%
% v1.4 update:
% The previous stage-1 AOO-inspired update is replaced by an update closer
% to the uploaded original AOO equations. Because the original AOO is
% single-objective and continuous, this implementation adapts it to the
% present multi-objective random-key encoding by replacing the scalar Best_X
% with a Pareto-archive elite reference solution.

fprintf('\nRunning TNSAOO optimizer...\n');

pop = initializePopulation(env, cfg);
for i = 1:numel(pop)
    pop(i) = evaluateSolution(pop(i), env, cfg);
end

archive = updateArchive([], pop, cfg);

nVar = numel(pop(1).position);
aooState = initAOOState(numel(pop), nVar);

history = struct();
history.bestMakespan = nan(cfg.alg.maxIter,1);
history.bestEnergy = nan(cfg.alg.maxIter,1);
history.bestDrift = nan(cfg.alg.maxIter,1);
history.archiveSize = nan(cfg.alg.maxIter,1);

for iter = 1:cfg.alg.maxIter
    popPositions = reshape([pop.position], nVar, []).';

    newPop = pop;

    for i = 1:numel(pop)
        elite = selectEliteFromArchive(archive);
        aooState.index = i;

        if isfield(cfg.alg, 'useOriginalAOOUpdate') && cfg.alg.useOriginalAOOUpdate
            candidatePos = aooUpdateCandidate( ...
                pop(i).position, elite.position, popPositions, aooState, ...
                iter, cfg.alg.maxIter, cfg.alg.lb, cfg.alg.ub);
        else
            candidatePos = legacyStage1Update(pop(i).position, elite.position, popPositions, iter, cfg);
        end

        if ~isfield(cfg.alg, 'enableTIS') || cfg.alg.enableTIS
            if rand() < cfg.alg.tisProbability
                candidatePos = thinkingInnovation(candidatePos, archive, iter, cfg.alg.maxIter, cfg);
            end
        end

        candidatePos = clampPosition(candidatePos, cfg.alg.lb, cfg.alg.ub);

        cand = pop(i);
        cand.position = candidatePos;
        cand.decoded = decodeSolution(candidatePos, env, cfg);
        cand = evaluateSolution(cand, env, cfg);

        if betterIndividual(cand, pop(i))
            newPop(i) = cand;
        else
            newPop(i) = pop(i);
        end
    end

    pop = newPop;
    archive = updateArchive(archive, pop, cfg);

    objMat = reshape([archive.objectives], 3, []).';
    history.bestMakespan(iter) = min(objMat(:,1));
    history.bestEnergy(iter) = min(objMat(:,2));
    history.bestDrift(iter) = min(objMat(:,3));
    history.archiveSize(iter) = numel(archive);

    fprintf('Iter %03d/%03d | archive=%d | best T=%.2f, E=%.2f, D=%.2f\n', ...
        iter, cfg.alg.maxIter, numel(archive), ...
        history.bestMakespan(iter), history.bestEnergy(iter), history.bestDrift(iter));
end
end

function elite = selectEliteFromArchive(archive)
if isempty(archive)
    error('Archive is empty when selecting elite.');
end

crowd = [archive.crowding];
if isempty(crowd) || all(~isfinite(crowd)) || all(crowd == 0)
    elite = archive(randi(numel(archive)));
    return;
end

finiteCrowd = crowd(isfinite(crowd));
if isempty(finiteCrowd)
    elite = archive(randi(numel(archive)));
    return;
end

crowd(~isfinite(crowd)) = max(finiteCrowd) + 1;
crowd = max(crowd, 0);
if sum(crowd) <= 0
    elite = archive(randi(numel(archive)));
else
    prob = crowd(:) / sum(crowd);
    idx = find(rand() <= cumsum(prob), 1, 'first');
    elite = archive(idx);
end
end

function candidatePos = legacyStage1Update(currentPos, elitePos, popPositions, iter, cfg)
% Legacy simplified update kept for ablation/debugging.

step = cfg.alg.aooStepInitial + ...
    (cfg.alg.aooStepFinal-cfg.alg.aooStepInitial) * (iter-1)/max(1,cfg.alg.maxIter-1);

center = mean(popPositions, 1);
r1 = rand(size(currentPos));
r2 = rand(size(currentPos));
wind = step * randn(size(currentPos));
roll = 0.5 * step * r1 .* (elitePos - currentPos);
eject = 0.25 * step * r2 .* (currentPos - center);
candidatePos = currentPos + wind + roll + eject;
end
