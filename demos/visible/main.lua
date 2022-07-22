local vector = require("vector")
local visible = require("visible")


local BACKGROUND_COLOR = { .5, .5, .5 }
local SEGMENT_WIDTH = 3
local SEGMENT_COLOR = { .3, .3, .3 }
local SEGMENT_POINT_SIZE = 12
local VISIBLE_POINT_COLOR = { 0, 0, 0 }
local VISIBLE_POINT_SIZE = 8
local VISIBLE_AREA_COLOR = { 1, 1, 1 }
local CAMERA_COLOR = { .8, .2, .2 }
local CAMERA_SIZE = 16

local segments
local visibles, triangles
local visibles_dirty
local camera
local camera_pressed
local create_segment

local function print_info()
  print("camera")
  print("{", camera.x, ",", camera.y, "}")
  print("segments")
  print("{")
  for i = 1, #segments, 4 do
    print(segments[i], ",", segments[i + 1], ",", segments[i + 2], ",", segments[i + 3], ",")
  end
  print("}")
end

local function init()
  segments = {
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0
  }
  visibles = {}
  triangles = {}
  visibles_dirty = true
  camera = vector.new(256, 256)
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
  -- segments
  love.graphics.setColor(SEGMENT_COLOR)
  love.graphics.setLineWidth(SEGMENT_WIDTH)
  love.graphics.setPointSize(SEGMENT_POINT_SIZE)
  love.graphics.points(segments)
  for i = 1, #segments, 4 do
    love.graphics.line(segments[i], segments[i + 1], segments[i + 2], segments[i + 3])
  end
  -- visible points
  love.graphics.setColor(VISIBLE_POINT_COLOR)
  love.graphics.setPointSize(VISIBLE_POINT_SIZE)
  love.graphics.points(visibles)
  -- camera
  love.graphics.setColor(CAMERA_COLOR)
  love.graphics.setPointSize(CAMERA_SIZE)
  love.graphics.points(camera.x, camera.y)

  love.graphics.setBackgroundColor(BACKGROUND_COLOR)
end

function love.update()
  if visibles_dirty then
    visibles = visible.polygon(segments, camera)
    triangles = love.math.triangulate(visibles)
    visibles_dirty = false
  end
end

function love.keypressed(key)
  if key == "q" then
    love.event.quit(0)
  elseif key == "d" then
    print("dirty")
    visibles_dirty = true
  elseif key == "s" then
    print("setup")
    init()
  elseif key == "p" then
    print_info()
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    if camera:dist({ x = x, y = y }) <= CAMERA_SIZE then
      camera_pressed = true
    else
      create_segment = { x, y }
    end
  end
end

function love.mousereleased(x, y, button)
  if button == 1 then
    if camera_pressed then
      camera.x = x
      camera.y = y
      camera_pressed = false
    elseif create_segment ~= nil then
      table.insert(segments, create_segment[1])
      table.insert(segments, create_segment[2])
      table.insert(segments, x)
      table.insert(segments, y)
      create_segment = nil
    end
  end
  visibles_dirty = true
end
