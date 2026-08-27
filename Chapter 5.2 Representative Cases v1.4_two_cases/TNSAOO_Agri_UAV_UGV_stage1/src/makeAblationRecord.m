function rec = makeAblationRecord(baseRec, variant, runId)
%MAKEABLATIONRECORD Add method metadata to a batch record.

rec = baseRec;
rec.runId = runId;
rec.method = string(variant.method);
rec.variantType = string(variant.type);
rec.variantDescription = string(variant.description);
end
