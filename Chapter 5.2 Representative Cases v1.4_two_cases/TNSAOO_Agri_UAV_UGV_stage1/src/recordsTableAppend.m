function T = recordsTableAppend(T, rec)
%RECORDSTABLEAPPEND Append one struct record to a table robustly.

Trec = struct2table(rec, 'AsArray', true);

if isempty(T)
    T = Trec;
else
    % Add missing variables on either side if future records have extra metadata.
    varsT = T.Properties.VariableNames;
    varsR = Trec.Properties.VariableNames;

    missingInT = setdiff(varsR, varsT);
    for i = 1:numel(missingInT)
        T.(missingInT{i}) = missingValueLike(Trec.(missingInT{i}), height(T));
    end

    missingInR = setdiff(varsT, varsR);
    for i = 1:numel(missingInR)
        Trec.(missingInR{i}) = missingValueLike(T.(missingInR{i}), height(Trec));
    end

    Trec = Trec(:, T.Properties.VariableNames);
    T = [T; Trec];
end
end

function v = missingValueLike(example, n)
if isnumeric(example)
    v = NaN(n,1);
elseif isstring(example)
    v = strings(n,1);
elseif iscell(example)
    v = cell(n,1);
else
    v = repmat(missing, n, 1);
end
end
