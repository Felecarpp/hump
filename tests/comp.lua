
do
  assert(comp(0, 1, 1, 1, 0, 2, 2, 1, 0, 0))
end

do
  local t = {
    0, 2, 2, 1,
    0, 1, 1, 1,
  }
  local f = function(x1, y1, xg1, yg1, x2, y2, xg2, yg2)
    return comp(x1, y1, xg1, yg1, x2, y2, xg2, yg2, 0, 0)
  end
  local r = {
    0, 1, 1, 1,
    0, 2, 2, 1
  }
  sort_pack(t, f, 4)
  for i, v in ipairs(t) do
    assert(v == r[i], v .. " != " .. r[i] .. " (" .. i .. ")")
  end
end
