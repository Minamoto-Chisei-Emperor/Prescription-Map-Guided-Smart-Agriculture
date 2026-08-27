function rec = makeChapter53FailedRecord(cfg, runtime, ME)
%MAKECHAPTER53FAILEDRECORD Create a failed-run record.

rec = chapter53RecordTemplate();
rec.status = "failed";
rec.errorMessage = string(ME.message);
rec.fieldName = string(cfg.data.fieldFileName);
rec.country = string(lower(cfg.data.fieldFileName(1:min(2,end))));
rec.seed = cfg.seed;
rec.runtime_s = runtime;
rec.maxIter = cfg.alg.maxIter;
rec.popSize = cfg.alg.popSize;
end
