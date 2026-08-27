function variants = getExperimentVariants(cfg)
%GETEXPERIMENTVARIANTS Define baseline/ablation variants for v1.5.
%
% Variants:
%   FullTNSAOO   : original-AOO-adapted update + TIS + archive
%   NoTIS        : same as FullTNSAOO but disables TIS
%   SimpleAOO    : uses earlier simplified AOO-inspired update + TIS
%   Independent  : no upper-layer optimizer; fixed natural order baseline

allVariants = struct([]);

allVariants(1).method = "FullTNSAOO";
allVariants(1).type = "optimizer";
allVariants(1).useOriginalAOOUpdate = true;
allVariants(1).enableTIS = true;
allVariants(1).description = "Original-AOO-adapted TNSAOO with TIS";

allVariants(2).method = "NoTIS";
allVariants(2).type = "optimizer";
allVariants(2).useOriginalAOOUpdate = true;
allVariants(2).enableTIS = false;
allVariants(2).description = "Original-AOO-adapted TNSAOO without TIS";

allVariants(3).method = "SimpleAOO";
allVariants(3).type = "optimizer";
allVariants(3).useOriginalAOOUpdate = false;
allVariants(3).enableTIS = true;
allVariants(3).description = "Stage-1 simplified AOO-inspired update with TIS";

allVariants(4).method = "Independent";
allVariants(4).type = "baseline";
allVariants(4).useOriginalAOOUpdate = false;
allVariants(4).enableTIS = false;
allVariants(4).description = "Fixed natural UAV/UGV order and nearest active refill, without upper-layer optimization";

wanted = string(cfg.ablation.methods);
keep = false(1, numel(allVariants));
for i = 1:numel(allVariants)
    keep(i) = any(wanted == allVariants(i).method);
end

variants = allVariants(keep);
end
