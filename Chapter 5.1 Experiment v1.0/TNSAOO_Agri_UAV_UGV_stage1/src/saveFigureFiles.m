function saveFigureFiles(figHandle, basePath, dpi)
%SAVEFIGUREFILES Save a figure as both .fig and .png.
if nargin < 3 || isempty(dpi)
    dpi = 300;
end

savefig(figHandle, [basePath, '.fig']);

try
    exportgraphics(figHandle, [basePath, '.png'], 'Resolution', dpi);
catch
    print(figHandle, [basePath, '.png'], '-dpng', sprintf('-r%d', dpi));
end
end
