function rec = standardizeBatchRecord(rec, template)
%STANDARDIZEBATCHRECORD Ensure the record has exactly the template fields.

if nargin < 2
    template = batchRecordTemplate();
end

templateFields = fieldnames(template);
recFields = fieldnames(rec);

% Add missing fields.
for i = 1:numel(templateFields)
    fn = templateFields{i};
    if ~isfield(rec, fn)
        rec.(fn) = template.(fn);
    end
end

% Remove extra fields to keep all records table-compatible.
extraFields = setdiff(recFields, templateFields);
for i = 1:numel(extraFields)
    rec = rmfield(rec, extraFields{i});
end

rec = orderfields(rec, template);
end
