function fronts = nonDominatedSort(pop)
%NONDOMINATEDSORT Fast non-dominated sorting for struct individuals.

N = numel(pop);
S = cell(N,1);
n = zeros(N,1);
rank = zeros(N,1);
fronts = {};

F1 = [];
for p = 1:N
    S{p} = [];
    n(p) = 0;
    for q = 1:N
        if p == q
            continue;
        end
        if dominatesIndividual(pop(p), pop(q))
            S{p}(end+1) = q; %#ok<AGROW>
        elseif dominatesIndividual(pop(q), pop(p))
            n(p) = n(p) + 1;
        end
    end
    if n(p) == 0
        rank(p) = 1;
        F1(end+1) = p; %#ok<AGROW>
    end
end

fronts{1} = F1;
i = 1;
while ~isempty(fronts{i})
    Q = [];
    for p = fronts{i}
        for q = S{p}
            n(q) = n(q) - 1;
            if n(q) == 0
                rank(q) = i + 1;
                Q(end+1) = q; %#ok<AGROW>
            end
        end
    end
    i = i + 1;
    fronts{i} = Q; %#ok<AGROW>
end

if isempty(fronts{end})
    fronts(end) = [];
end
end
