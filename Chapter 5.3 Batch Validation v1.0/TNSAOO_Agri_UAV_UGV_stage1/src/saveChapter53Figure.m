function saveChapter53Figure(fig, figDir, baseName)
%SAVECHAPTER53FIGURE Save figure as FIG, PNG and PDF.

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

figPath = fullfile(figDir, [baseName, '.fig']);
pngPath = fullfile(figDir, [baseName, '.png']);
pdfPath = fullfile(figDir, [baseName, '.pdf']);

try
    savefig(fig, figPath);
catch
    saveas(fig, figPath);
end

try
    exportgraphics(fig, pngPath, 'Resolution', 600);
catch
    print(fig, pngPath, '-dpng', '-r600');
end

try
    exportgraphics(fig, pdfPath, 'ContentType','vector');
catch
    print(fig, pdfPath, '-dpdf', '-painters');
end
end
