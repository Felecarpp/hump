local vector = require("vector-light")
local visible = require("visible")
local pack = require("pack-utils")
local useSegmentsInput = require("segmentsinput")
local useSegmentsFile = require("segmentsfile")

local BACKGROUND_COLOR = { .5, .5, .5 }
local SEGMENT_COLOR = { .3, .3, .3 }
local VISIBLE_POINT_COLOR = { 0, 0, 0 }
local VISIBLE_AREA_COLOR = { 1, 1, 1 }
local CAMERA_COLOR = { .8, .2, .2 }

local segments = {}
local visibles, triangles
local visibles_dirty
local function dirty() visibles_dirty = true end

-- local segmentsinput = useSegmentsInput(segments, dirty)
local segmentsfile = useSegmentsFile(segments, "segments.txt", dirty)
local camera = { 512 / 2, 512 / 2 }
local camera_pressed
local create_segment
local step = 128

local SEGMENT_WIDTH = 3
local SEGMENT_POINT_SIZE = 12
local VISIBLE_POINT_SIZE = 8
local CAMERA_SIZE = 16


local function init()
  for k, _ in pairs(segments) do segments[k] = nil end
  pack.insert(segments, {
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0
  })
  -- segmentsinput.init()
  visibles = {}
  triangles = {}
  visibles_dirty = true
  camera_pressed = false
end

function love.load()
  init()
end

function love.draw()
  -- visible areas
  love.graphics.setColor(VISIBLE_AREA_COLOR)
  for _, triangle in ipairs(triangles) do
    love.graphics.polygon("fill", triangle)
  end
  -- segmentsinput.draw()
  -- segments
  love.graphics.setColor(SEGMENT_COLOR)
  love.graphics.setLineWidth(SEGMENT_WIDTH)
  love.graphics.setPointSize(SEGMENT_POINT_SIZE)
  love.graphics.points(segments)
  for _, x, y, xg, yg in pack.ipairs(segments, 4) do
    love.graphics.line(x, y, xg, yg)
  end
  -- visible points
  love.graphics.setColor(VISIBLE_POINT_COLOR)
  love.graphics.setPointSize(VISIBLE_POINT_SIZE)
  love.graphics.points(visibles)
  for _, x, y in pack.ipairs(visibles, 2) do
    love.graphics.print(vector.str(x, y), x, y)
  end
  -- camera
  love.graphics.setColor(CAMERA_COLOR)
  love.graphics.setPointSize(CAMERA_SIZE)
  love.graphics.points(camera[1], camera[2])

  love.graphics.setBackgroundColor(BACKGROUND_COLOR)
end

function love.update(dt)
  if visibles_dirty then
    visibles = visible.polygon(segments, camera)
    triangles = love.math.triangulate(visibles)
    visibles_dirty = false
  end
  -- segmentsinput.update(dt)
end

local function round(n) return math.floor(n / step + .5) * step end

function love.keypressed(key)
  if --segmentsinput.keypressed(key) or--
  segmentsfile.keypressed(key) then
    return
  end
  if key == "q" then
    love.event.quit(0)
  elseif key == "d" then
    print("dirty")
    visibles_dirty = true
  elseif key == "s" then
    print("setup")
    init()
  elseif key == "r" then
    local x, y, xg, yg = round(math.random(512)), round(math.random(512)),
        round(math.random(512)), round(math.random(512))
    table.insert(segments, x)
    table.insert(segments, y)
    table.insert(segments, xg)
    table.insert(segments, yg)
    print("random insert", vector.str(x, y), vector.str(xg, yg))
    visibles_dirty = true
    -- segmentsinput.dirty()
  end
end

function love.keyreleased(key)
  -- segmentsinput.keyreleased(key)
end

function love.mousepressed(x, y, button)
  if button == 1 then
    -- if segmentsinput.mousepressed(x, y, button) then return end
    if vector.dist(camera[1], camera[2], x, y) <= CAMERA_SIZE then
      camera_pressed = true
    else
      create_segment = { round(x), round(y) }
    end
  elseif button == 2 then
    for i, xs, ys, xgs, ygs in pack.ipairs(segments, 4) do
      if vector.segmentcontains(xs, ys, xgs, ygs, x, y, SEGMENT_WIDTH) then
        table.remove(segments, i)
        table.remove(segments, i)
        table.remove(segments, i)
        table.remove(segments, i)
        visibles_dirty = true
        -- segmentsinput.dirty()
        break
      end
    end
  end
end

function love.mousereleased(x, y, button)
  if button == 1 then
    if camera_pressed then
      if round(x) ~= 0 and round(y) ~= 0 and round(x) ~= 512 and round(y) ~= 512 then
        camera[1] = round(x)
        camera[2] = round(y)
        camera_pressed = false
      end
    elseif create_segment ~= nil then
      table.insert(segments, create_segment[1])
      table.insert(segments, create_segment[2])
      table.insert(segments, round(x))
      table.insert(segments, round(y))
      create_segment = nil
      -- segmentsinput.dirty()
    end
  end
  visibles_dirty = true
end

function love.textinput(text)
  -- segmentsinput.textinput(text)
end
