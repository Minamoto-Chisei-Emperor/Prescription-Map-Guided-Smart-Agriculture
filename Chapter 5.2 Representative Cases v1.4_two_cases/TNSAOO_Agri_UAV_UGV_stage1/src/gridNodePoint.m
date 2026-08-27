function pt = gridNodePoint(grid, r, c)
%GRIDNODEPOINT Return XY coordinate of a grid node.
pt = [grid.X(r,c), grid.Y(r,c)];
end
