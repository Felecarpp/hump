local visible = require("visible")

local segments = {
  0, 0, 512, 0,
  512, 0, 512, 512,
  512, 512, 0, 512,
  0, 512, 0, 0,
  69, 426, 442, 436,
  386, 466, 383, 59,
  147, 458, 289, 382,
  303, 470, 218, 357,
  48, 73, 137, 285,
  130, 97, 50, 352,
  164, 142, 331, 146,
  224, 179, 281, 178,
}

local center = { 256, 256 }

local function use_visible_polygon()
  visible.polygon(segments, center)
end

local function timeit(t, f)
  local s = os.clock()
  for _ = 1, t do
    f()
  end
  return os.clock() - s
end

print("visible polygon", timeit(100000, use_visible_polygon))
