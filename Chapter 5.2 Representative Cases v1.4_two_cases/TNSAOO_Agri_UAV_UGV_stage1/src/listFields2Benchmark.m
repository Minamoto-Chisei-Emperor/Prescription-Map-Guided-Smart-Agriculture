function fields = listFields2Benchmark(cfg, varargin)
%LISTFIELDS2BENCHMARK List Fields2Benchmark WKT files.
%
% fields = listFields2Benchmark(cfg)
% fields = listFields2Benchmark(cfg, 'country', 'ee', 'maxFields', 10, 'shuffle', true)

p = inputParser;
addParameter(p, 'country', cfg.batch.countryFilter);
addParameter(p, 'maxFields', cfg.batch.numFields);
addParameter(p, 'shuffle', cfg.batch.shuffleFields);
parse(p, varargin{:});

country = lower(string(p.Results.country));
maxFields = p.Results.maxFields;
doShuffle = p.Results.shuffle;

if ~exist(cfg.paths.wktDir, 'dir')
    if exist(cfg.paths.wktZip, 'file')
        unzip(cfg.paths.wktZip, cfg.paths.dataDir);
    else
        error('WKT data not found. Put wkt.zip in %s', cfg.paths.dataDir);
    end
end

listing = dir(fullfile(cfg.paths.wktDir, '*.wkt'));
if isempty(listing)
    error('No WKT files found in %s', cfg.paths.wktDir);
end

names = {listing.name}';
countries = cellfun(@(s) lower(string(s(1:min(2,end)))), names, 'UniformOutput', false);
countries = string(countries);

keep = true(numel(names),1);
if strlength(country) > 0
    keep = countries == country;
end

names = names(keep);
countries = countries(keep);
listing = listing(keep);

if doShuffle
    order = randperm(numel(names));
else
    order = 1:numel(names);
end

if ~isempty(maxFields) && maxFields > 0
    order = order(1:min(maxFields, numel(order)));
end

names = names(order);
countries = countries(order);
listing = listing(order);

fullPaths = strings(numel(names),1);
for i = 1:numel(names)
    fullPaths(i) = string(fullfile(listing(i).folder, listing(i).name));
end

fields = table(string(names), countries, fullPaths, ...
    'VariableNames', {'fileName','country','fullPath'});
end
