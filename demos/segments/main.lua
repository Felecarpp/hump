local pack = require("pack-utils")

local segments = {
  0, 0, 512, 0,
  512, 0, 512, 512,
  512, 512, 0, 512,
  0, 512, 0, 0,
  128, 256, 512, 128,
  128, 256, 128, 256,
  256, 128, 256, 256,
  256, 256, 384, 128,
  256, 384, 128, 128,
  256, 128, 256, 384,
  256, 128, 256, 128,
  256, 256, 512, 384,
  128, 384, 256, 128,
  128, 384, 384, 128,
  256, 384, 256, 256,
  256, 128, 384, 512
}

function love.draw()
  for _, x, y, xg, yg in pack.ipairs(segments, 4) do
    love.graphics.line(x, y, xg, yg)
  end
end
