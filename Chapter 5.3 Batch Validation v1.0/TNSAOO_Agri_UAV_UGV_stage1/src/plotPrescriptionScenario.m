function handles = plotPrescriptionScenario(env, cfg)
%PLOTPRESCRIPTIONSCENARIO Backward-compatible wrapper.
handles = plotScenarioPanel(env, cfg, sprintf('Synthetic prescription scenario: %s', env.field.name), true);
end
