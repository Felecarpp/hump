local LIBRARY_PATH = (...):match("(.-)[^%.]+$")
local vector = require(LIBRARY_PATH .. "vector")
local visible = {}


local function comp(a, b, center)
  if a.start == b.start then
    if a.stop == nil then return false end
    if b.stop == nil then return true end
    return vector.alignment(a.start, a.stop, b.stop) > 0
  end
  return vector.polar_lt(a.start, b.start, center)
end

function visible.polygon(segments, center)
  -- generic visibility function
  -- return concave (frequently) polygon
  if center == nil then
    center = { x = 0, y = 0 }
  else
    center = { x = center[1], y = center[2] }
  end
  local endpoints = {}
  do
    local next_endpoints = {}
    local missing_stops = {}
    for i = 1, #segments, 4 do
      local a = vector(segments[i], segments[i + 1])
      local b = vector(segments[i + 2], segments[i + 3])
      if a ~= b then
        local align = vector.alignment(center, a, b)
        local start, stop
        if align > 0 or align == 0 and
            b:dist2(center) < a:dist2(center) then
          start, stop = b, a
        else
          start, stop = a, b
        end
        table.insert(next_endpoints, { start = start, stop = stop })
        missing_stops[stop] = true
      end
    end
    local startpoint = center + vector.fromPolar(0, 1)
    local nodes = {}
    for i, epi in ipairs(next_endpoints) do
      -- startline cut enpoints
      nodes[i] = {}
      if vector.alignment(center, startpoint, epi.start) > 0 and
          vector.alignment(center, startpoint, epi.stop) < 0 and
          vector.alignment(epi.start, epi.stop, center) < 0 then
        local intersec = vector.intersection(epi.start, epi.stop, center, startpoint)
        table.insert(nodes[i], intersec)
      end
      -- segments cut endpoints
      for j, epj in ipairs(next_endpoints) do
        if j == i then break end
        if vector.alignment(epi.start, epi.stop, epj.start)
            * vector.alignment(epi.start, epi.stop, epj.stop) <= 0 and
            vector.alignment(epj.start, epj.stop, epi.start)
            * vector.alignment(epj.start, epj.stop, epi.stop) <= 0 then
          local intersec =
          vector.intersection(epi.start, epi.stop, epj.start, epj.stop)
          if intersec ~= epi.start and intersec ~= epi.stop then
            table.insert(nodes[i], intersec)
          end
          if intersec ~= epj.start and intersec ~= epj.stop then
            table.insert(nodes[j], intersec)
          end
        end
      end
    end
    -- register endpoints inserting nodes
    for i, endpoint in ipairs(next_endpoints) do
      table.sort(nodes[i], function(a, b)
        return a:dist2(endpoint.start) < b:dist2(endpoint.start)
      end)
      missing_stops[endpoint.start] = nil
      local current_start = endpoint.start
      for _, node in ipairs(nodes[i]) do
        missing_stops[node] = nil
        table.insert(endpoints, { start = current_start, stop = node })
        current_start = node
      end
      table.insert(endpoints, { start = current_start, stop = endpoint.stop })
    end
    -- add missing stops
    for stop, _ in pairs(missing_stops) do
      table.insert(endpoints, { start = stop })
    end
  end
  table.sort(endpoints, function(a, b) return comp(a, b, center) end)
  local polygon = {}
  local current
  local function cycle(epi)
    -- if no current point, take the first
    if current == nil then
      if epi.stop ~= nil then
        current = epi
        table.insert(polygon, epi.start.x)
        table.insert(polygon, epi.start.y)
      end
      -- if endpoint is the current target
    elseif epi.start == current.stop then
      table.insert(polygon, epi.start.x)
      table.insert(polygon, epi.start.y)
      current = nil
      -- search an other endpoint behind
      for _, epj in ipairs(endpoints) do
        -- take the nearest point in radius not on previous segment
        if epj.stop ~= nil and
            vector.alignment(center, epi.start, epj.start) >= 0 and
            vector.alignment(center, epi.start, epj.stop) < 0 and
            (current == nil or
                vector.alignment(epj.start, epj.stop, current.start) > 0) then
          local intersec
          if vector.alignment(center, epi.start, epj.start) == 0 then
            -- epi.start == epj.start included here
            -- epi.stop are already sorted so no need to compare
            intersec = epj.start
          else
            intersec = vector.intersection(
              epj.start, epj.stop, center, epi.start
            )
          end
          current = { start = intersec, stop = epj.stop }
        end
      end
      if current ~= nil and current.start ~= epi.start then
        table.insert(polygon, current.start.x)
        table.insert(polygon, current.start.y)
      end
      -- if endpoint starts over the current
    elseif epi.stop ~= nil and
        vector.alignment(current.start, current.stop, epi.start) < 0 then
      local intersec = vector.intersection(
        current.start, current.stop, center, epi.start
      )
      table.insert(polygon, intersec.x)
      table.insert(polygon, intersec.y)
      table.insert(polygon, epi.start.x)
      table.insert(polygon, epi.start.y)
      current = epi
    end
  end

  for _, epi in ipairs(endpoints) do
    cycle(epi)
  end
  for _, epi in ipairs(endpoints) do
    if epi.start.y ~= center.y or epi.start.x < center.x then break end
    if epi.start.x ~= polygon[1] and epi.start == current.stop then
      table.insert(polygon, epi.start.x)
      table.insert(polygon, epi.start.y)
      break
    end
  end
  return polygon
end

return visible
