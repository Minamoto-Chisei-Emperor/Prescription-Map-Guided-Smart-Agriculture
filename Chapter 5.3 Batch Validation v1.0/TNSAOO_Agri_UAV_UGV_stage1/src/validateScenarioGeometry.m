function geo = validateScenarioGeometry(env, cfg)
%VALIDATESCENARIOGEOMETRY Validate obstacle and same-type overlap consistency.

geo = struct();
geo.sprayObstacleOverlap = zonesObstacleOverlap(env.sprayTasks, env.obstacles);
geo.fertObstacleOverlap = zonesObstacleOverlap(env.fertTasks, env.obstacles);
geo.spraySameTypeOverlap = sameTypeOverlap(env.sprayTasks);
geo.fertSameTypeOverlap = sameTypeOverlap(env.fertTasks);
geo.refillObstacleViolations = pointObstacleViolations(reshape([env.refillStations.center],2,[]).', env.obstacles);
geo.depotObstacleViolation = pointObstacleViolations(env.depot, env.obstacles);

tol = cfg.env.sameTypeOverlapToleranceArea;
geo.isValid = geo.sprayObstacleOverlap < 1e-6 && ...
              geo.fertObstacleOverlap < 1e-6 && ...
              geo.spraySameTypeOverlap <= tol + 1e-6 && ...
              geo.fertSameTypeOverlap <= tol + 1e-6 && ...
              geo.refillObstacleViolations == 0 && ...
              geo.depotObstacleViolation == 0;
end

function a = zonesObstacleOverlap(tasks, obstacles)
a = 0;
for i = 1:numel(tasks)
    for j = 1:numel(obstacles)
        a = a + area(intersect(tasks(i).zone, obstacles(j)));
    end
end
end

function a = sameTypeOverlap(tasks)
a = 0;
for i = 1:numel(tasks)
    for j = i+1:numel(tasks)
        a = a + area(intersect(tasks(i).zone, tasks(j).zone));
    end
end
end

function n = pointObstacleViolations(points, obstacles)
if isempty(points)
    n = 0;
    return;
end
if size(points,2) ~= 2
    points = points(:).';
end
n = 0;
for i = 1:size(points,1)
    for j = 1:numel(obstacles)
        if isinterior(obstacles(j), points(i,1), points(i,2))
            n = n + 1;
        end
    end
end
end
