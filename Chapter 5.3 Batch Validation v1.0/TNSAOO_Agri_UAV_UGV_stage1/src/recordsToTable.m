function T = recordsToTable(records)
%RECORDSTOTABLE Convert batch record struct array to table robustly.
%
% MATLAB treats a scalar struct differently from a struct array unless
% 'AsArray' is true. This helper keeps single-run and multi-run batch
% outputs consistent.

if isempty(records)
    T = struct2table(repmat(batchRecordTemplate(), 0, 1), 'AsArray', true);
else
    T = struct2table(records, 'AsArray', true);
end
end
