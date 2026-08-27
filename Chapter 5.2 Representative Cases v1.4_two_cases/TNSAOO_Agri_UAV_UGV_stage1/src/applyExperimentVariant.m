function cfgOut = applyExperimentVariant(cfgIn, variant)
%APPLYEXPERIMENTVARIANT Apply one ablation/baseline variant to cfg.

cfgOut = cfgIn;
cfgOut.alg.useOriginalAOOUpdate = variant.useOriginalAOOUpdate;
cfgOut.alg.enableTIS = variant.enableTIS;

% Keep these fields for traceability.
cfgOut.experiment.method = variant.method;
cfgOut.experiment.type = variant.type;
cfgOut.experiment.description = variant.description;
end
