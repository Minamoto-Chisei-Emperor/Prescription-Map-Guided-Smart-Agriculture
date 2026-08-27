function records = appendBatchRecord(records, rec)
%APPENDBATCHRECORD Append a batch record with standardized field layout.

template = batchRecordTemplate();
rec = standardizeBatchRecord(rec, template);

if isempty(records)
    records = rec;
else
    rec = orderfields(rec, records);
    records(end+1) = rec;
end
end
