function decoded = decodeSolution(position, env, cfg)
%DECODESOLUTION Decode random keys into task sequences and refill activation.

nU = cfg.env.nSprayTasks;
nG = cfg.env.nFertTasks;
nR = cfg.env.nRefillCandidates;

if numel(position) ~= nU+nG+nR
    error('Position dimension mismatch.');
end

uGenes = position(1:nU);
gGenes = position(nU+1:nU+nG);
rGenes = position(nU+nG+1:end);

[~, uSeq] = sort(uGenes, 'ascend');
[~, gSeq] = sort(gGenes, 'ascend');

prob = 1 ./ (1 + exp(-rGenes));
active = prob >= cfg.alg.sigmoidThreshold;

if cfg.alg.minActiveRefill > 0 && sum(active) < cfg.alg.minActiveRefill
    [~, idx] = max(prob);
    active(idx) = true;
end

decoded = struct();
decoded.uavSeq = uSeq(:)';
decoded.ugvSeq = gSeq(:)';
decoded.refillActive = active(:)';
decoded.refillProb = prob(:)';
decoded.activeRefillIds = find(active);
end
