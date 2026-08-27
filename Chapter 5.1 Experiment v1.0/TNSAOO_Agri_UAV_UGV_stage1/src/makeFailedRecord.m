function rec = makeFailedRecord(fieldName, country, seed, runtime, ME)
%MAKEFAILEDRECORD Create a standardized failed-run record with NaN metrics.

rec = batchRecordTemplate();

rec.status = "failed";
rec.errorMessage = string(ME.message);
rec.fieldName = string(fieldName);
rec.country = string(country);
rec.seed = seed;
rec.runtime_s = runtime;

rec = standardizeBatchRecord(rec);
end
