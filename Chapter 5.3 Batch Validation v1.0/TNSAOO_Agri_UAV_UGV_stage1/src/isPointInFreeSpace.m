function free = isPointInFreeSpace(pt, env)
%ISPOINTINFREESPACE True if a point is inside the obstacle-free operable region.

pt = pt(:).';
if isfield(env, 'operablePoly')
    free = isinterior(env.operablePoly, pt(1), pt(2));
else
    free = isinterior(env.field.poly, pt(1), pt(2));
    for k = 1:numel(env.obstacles)
        if isinterior(env.obstacles(k), pt(1), pt(2))
            free = false;
            return;
        end
    end
end
end
