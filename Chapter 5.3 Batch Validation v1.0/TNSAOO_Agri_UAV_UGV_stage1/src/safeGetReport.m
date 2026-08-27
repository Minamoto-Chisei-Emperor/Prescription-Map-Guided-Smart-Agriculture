function txt = safeGetReport(ME)
%SAFEGETREPORT Compatibility wrapper for MATLAB exception reports.

try
    txt = getReport(ME, 'extended', 'hyperlinks', 'off');
catch
    try
        txt = getReport(ME, 'extended');
    catch
        txt = sprintf('%s\n%s', ME.identifier, ME.message);
    end
end
end
