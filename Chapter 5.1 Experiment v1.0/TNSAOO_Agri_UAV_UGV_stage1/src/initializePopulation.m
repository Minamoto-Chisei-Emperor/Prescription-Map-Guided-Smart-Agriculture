function pop = initializePopulation(env, cfg)
%INITIALIZEPOPULATION Create random-key encoded population.

nVar = cfg.env.nSprayTasks + cfg.env.nFertTasks + cfg.env.nRefillCandidates;
pop = repmat(emptyIndividual(nVar), cfg.alg.popSize, 1);

for i = 1:cfg.alg.popSize
    pop(i).position = cfg.alg.lb + (cfg.alg.ub-cfg.alg.lb)*rand(1,nVar);
    pop(i).decoded = decodeSolution(pop(i).position, env, cfg);
end
end

function ind = emptyIndividual(nVar)
ind = struct();
ind.position = zeros(1,nVar);
ind.decoded = [];
ind.objectives = [Inf, Inf, Inf];
ind.violation = Inf;
ind.metrics = struct();
ind.details = struct();
ind.rank = Inf;
ind.crowding = 0;
end
