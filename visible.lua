local LIBRARY_PATH = (...):match("(.-)[^%.]+$")
local vector = require(LIBRARY_PATH .. "vector-light")
local pack = require(LIBRARY_PATH .. "pack-utils")

local visible = {}

local function segment_str(x, y, xg, yg)
  return vector.str(x, y) .. "->" .. vector.str(xg, yg)
end

local function print_segments(segments)
  pack.print(segments,
    function(x, y, xg, yg) print(segment_str(x, y, xg, yg)) end,
    4)
end

local function comp(x1, y1, xg1, yg1, x2, y2, xg2, yg2, xc, yc)
  if x1 == x2 and y1 == y2 then
    if x1 == xg1 and y1 == yg1 then return false end
    if x2 == xg2 and y2 == yg2 then return true end
    local align = vector.alignment(x1, y1, xg1, yg1, xg2, yg2)
    if align == 0 then
      return vector.dist2(x1, y1, xg1, yg1) < vector.dist2(x2, y2, xg2, yg2)
    end
    return vector.alignment(x1, y1, xg1, yg1, xg2, yg2) > 0
  end
  return vector.polar_lt(x1 - xc, y1 - yc, x2 - xc, y2 - yc)
end

local function endpoint_comp(xc, yc)
  return function(a, b)
    return comp(a.x, a.y, a.xg, a.yg, b.x, b.y, b.xg, b.yg, xc, yc)
  end
end

visible.comp = comp

local function node_comp(xc, yc)
  return function(a, b)
    return vector.dist2(a[1], a[2], xc, yc) < vector.dist2(b[1], b[2], xc, yc)
  end
end

local function insert_endpoint(t, x, y, xg, yg, xo, yo, xog, yog)
  for _, b in ipairs(t) do
    if x == b.x and y == b.y and xg == b.xg and yg == b.yg then
      return
    end
  end
  table.insert(t, {
    x = x, y = y, xg = xg, yg = yg,
    xo = xo, yo = yo, xog = xog, yog = yog
  })
end

local function parse_segments(segments, center)
  local nodes = {}
  local xc, yc = unpack(center)
  for i, x, y, xg, yg in pack.ipairs(segments, 4) do
    if nodes[i] == nil then nodes[i] = {} end
    local xstop, ystop, dstop, jstop
    local align = vector.alignment(x, y, xg, yg, xc, yc)
    if x ~= xg or y ~= yg then
      -- reverse if in bad order
      -- centerpoint cut endpoints
      if align > 0 then
        segments[i], segments[i + 1] = xg, yg
        segments[i + 2], segments[i + 3] = x, y
        x, y, xg, yg = xg, yg, x, y
      elseif align == 0 then
        pack.insert(nodes[i], { xc, yc })
      end
      -- startline cut enpoints
      if y < yc and yg > yc then
        local xinter, yinter = vector.intersection(x, y, xg, yg, xc, yc, xc + 1, yc)
        assert(yinter == yc)
        pack.insert(nodes[i], { xinter, yinter })
      end
      -- segments cut endpoints
      for j, x2, y2, xg2, yg2 in pack.ipairs(segments, 4) do
        if j <= i - 4 then
          -- segments intersection
          if vector.alignment(x, y, xg, yg, x2, y2)
              * vector.alignment(x, y, xg, yg, xg2, yg2) <= 0 and
              vector.alignment(x2, y2, xg2, yg2, x, y)
              * vector.alignment(x2, y2, xg2, yg2, xg, yg) <= 0 and
              (y - yg) * (x2 - xg2) ~= (y2 - yg2) * (x - xg) then
            local xinter, yinter =
            vector.intersection(x, y, xg, yg, x2, y2, xg2, yg2)
            if (xinter ~= x or yinter ~= y) and (xinter ~= xg or yinter ~= yg) then
              pack.insert(nodes[i], { xinter, yinter })
            end
            if (xinter ~= x2 or yinter ~= y2) and (xinter ~= xg2 or yinter ~= yg2) then
              pack.insert(nodes[j], { xinter, yinter })
            end
          end
        end
        -- segment end cut segments behind
        if vector.alignment(xc, yc, x, y, x2, y2) < 0 and
          vector.alignment(x2, y2, xg2, yg2, xg, yg) < 0 and
            vector.alignment(xc, yc, xg, yg, x2, y2) <= 0 and
            vector.alignment(xc, yc, xg, yg, xg2, yg2) >= 0 then
          print(segment_str(x2, y2, xg2, yg2), "hides", segment_str(x, y, xg, yg))
          local xinter, yinter = vector.intersection(xc, yc, xg, yg, x2, y2, xg2, yg2)
          local dinter = vector.dist2(xg, yg, xinter, yinter)
          if xstop == nil or dstop > dinter or
              xinter == xstop and yinter == ystop and
              vector.alignment(
                xinter, yinter, xg2, yg2, segments[jstop], segments[jstop + 1]
              ) then
            xstop, ystop, dstop, jstop = xinter, yinter, dinter, j
          end
        end
      end
      -- end of segment
      if xstop == nil then
        pack.insert(nodes[i], { xg, yg })
      else
        print(segment_str(x, y, xg, yg), "stop", vector.str(xstop, ystop))
        if nodes[jstop] == nil then nodes[jstop] = {} end
        pack.insert(nodes[jstop], { xstop, ystop })
      end
    end
  end
  -- register endpoints inserting nodes
  local ordereds = {}
  for i, x, y, xg, yg in pack.ipairs(segments, 4) do
    pack.sort(nodes[i], node_comp(x, y), 2)
    local xstart, ystart = x, y
    for _, xn, yn in pack.ipairs(nodes[i], 2) do
      if xn ~= xstart or yn ~= ystart then
        insert_endpoint(ordereds, xstart, ystart, xn, yn, x, y, xg, yg)
        xstart, ystart = xn, yn
      end
    end
    insert_endpoint(ordereds, xstart, ystart, xg, yg, x, y, xg, yg)
  end
  table.sort(ordereds, endpoint_comp(xc, yc))
  return ordereds
end

function visible.polygon(segments, center)
  -- generic visibility function
  -- return concave (frequently) polygon
  if center == nil then center = { 0, 0 } end
  local xc, yc = center[1], center[2]
  local ordereds = parse_segments(segments, center)
  local polygon = {}
  local current
  local function cycle(a)
    if vector.alignment(xc, yc, a.xo, a.yo, a.xog, a.yog) ~= 0 then
      print("iter " .. vector.str(a.x, a.y) .. " -> " .. vector.str(a.xg, a.yg))
      assert(a.y ~= yc or a.x ~= xc)
      if current == nil then
        table.insert(polygon, a.x)
        table.insert(polygon, a.y)
        if a.x ~= a.xg or a.y ~= a.yg then current = a end
      elseif a.x == current.xg and a.y == current.yg then
        table.insert(polygon, a.x)
        table.insert(polygon, a.y)
        if a.x == a.xg or a.y == a.yg then
          current = nil
        else current = a end
      elseif vector.alignment(xc, yc, current.xg, current.yg, a.x, a.y) == 0 then
        if a.y ~= yc or a.x < xc or a.x == current.xg then
          table.insert(polygon, a.x)
          table.insert(polygon, a.y)
          if a.x == a.xg or a.y == a.yg then
            for _, b in ipairs(ordereds) do
              if vector.alignment(a.xo, a.yo, a.xog, a.yog, b.x, b.y) > 0 and
                  vector.alignment(xc, yc, a.x, a.y, b.x, b.y) <= 0 and
                  vector.alignment(xc, yc, a.x, a.y, b.xg, b.yg) > 0 then
                local xinter, yinter = vector.intersection(
                  xc, yc, a.x, a.y, b.xo, b.yo, b.xog, b.yog
                )
                current = {
                  x = xinter, y = yinter, xg = b.xg, yg = b.yg,
                  xo = b.xo, yo = b.yo, xog = b.xog, yog = b.yog
                }
              end
            end
          else
            current = a
          end
        end
      elseif vector.alignment(xc, yc, current.xg, current.yg, a.x, a.y) > 0 then
        assert(
          vector.alignment(current.x, current.y, current.xg, current.yg, a.x, a.y) ~= 0 or
          a.x == current.x and a.y == current.y,
          vector.str(a.x, a.y) .. " on " ..
          vector.str(current.x, current.y) .. "->" .. vector.str(current.xg, current.yg)
        )
        -- endpoint start before
        if vector.alignment(current.x, current.y, current.xg, current.yg, a.x, a.y) < 0 then
          local xinter, yinter = vector.intersection(
            current.xo, current.yo, current.xog, current.yog, xc, yc, a.x, a.y
          )
          table.insert(polygon, xinter)
          table.insert(polygon, yinter)
          table.insert(polygon, a.x)
          table.insert(polygon, a.y)
          current = a
        end
      else assert(false) end
      if current ~= nil then print("current", vector.str(current.x, current.y), vector.str(current.xg, current.yg)) end
    end
  end

  for _, endpoint in ipairs(ordereds) do
    cycle(endpoint)
  end
  for _, endpoint in ipairs(ordereds) do
    if endpoint.y ~= yc or endpoint.x < xc then break end
    cycle(endpoint)
  end
  return polygon
end

return visible
