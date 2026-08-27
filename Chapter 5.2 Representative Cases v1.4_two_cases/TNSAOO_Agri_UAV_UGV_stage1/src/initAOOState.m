function state = initAOOState(popSize, dim)
%INITAOOSTATE Initialize internal coefficients used by the original AOO update.

state.x = 3 * rand(1, popSize) / dim;
state.m = 0.5 * rand(1, popSize) / dim;
state.L = popSize / dim * rand(1, popSize);
state.e = state.m;
state.g = 9.8 / dim;
state.index = 1;
end
