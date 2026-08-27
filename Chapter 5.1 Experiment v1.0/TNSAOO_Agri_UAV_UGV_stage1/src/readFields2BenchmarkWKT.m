function field = readFields2BenchmarkWKT(cfg)
%READFIELDS2BENCHMARKWKT Read a WKT field boundary and convert it to meters.

if ~exist(cfg.paths.wktDir, 'dir')
    if exist(cfg.paths.wktZip, 'file')
        fprintf('Unzipping WKT data from %s ...\n', cfg.paths.wktZip);
        unzip(cfg.paths.wktZip, cfg.paths.dataDir);
    else
        error(['WKT data not found. Put Fields2Benchmark wkt.zip in: ', cfg.paths.wktZip]);
    end
end

wktPath = fullfile(cfg.paths.wktDir, cfg.data.fieldFileName);
if ~exist(wktPath, 'file')
    if cfg.data.autoPickIfMissing
        listing = dir(fullfile(cfg.paths.wktDir, '*.wkt'));
        if isempty(listing)
            error('No .wkt files found in %s', cfg.paths.wktDir);
        end
        wktPath = fullfile(listing(1).folder, listing(1).name);
        warning('Requested field missing. Auto-picked: %s', listing(1).name);
    else
        error('Requested WKT file not found: %s', wktPath);
    end
end

[lon, lat] = readWKTPolygon(wktPath);
[x, y, origin] = lonLatToLocalXY(lon, lat);

poly = polyshape(x, y, 'Simplify', true);
if area(poly) <= 0
    error('Invalid or zero-area polygon: %s', wktPath);
end

field = struct();
field.file = wktPath;
[~, name, ext] = fileparts(wktPath);
field.name = [name, ext];
field.lonlat = [lon(:), lat(:)];
field.xy = [x(:), y(:)];
field.origin = origin;
field.poly = poly;
field.area = area(poly);
field.bbox = [min(x), max(x), min(y), max(y)];
field.width = field.bbox(2) - field.bbox(1);
field.height = field.bbox(4) - field.bbox(3);

fprintf('Loaded field %s | area = %.1f m^2 | bbox = %.1f x %.1f m\n', ...
    field.name, field.area, field.width, field.height);
end
