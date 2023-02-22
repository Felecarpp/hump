local pack = require("pack-utils")
local utf8 = require("utf8")

KEYPRESSED_DT = .1

local function rect_collides(rect)
  return function(x, y)
    return x >= rect.x and y >= rect.y and
        x <= rect.x + rect.w and y <= rect.y + rect.h
  end
end

return function(segments, set_dirty)
  local rect = { x = 16, y = 16, w = 128, h = 256 }
  local colors = {
    background = { .8, .8, .8, .5 },
    border = { .2, .2, .2, .5 },
    text = { .2, .2, .2 }
  }

  local text, cursor
  local active, visible, dirty
  local keypressed, keypressed_timer

  local function import()
    text = ''
    for _, xs, ys, xgs, ygs in pack.ipairs(segments, 4) do
      text = text .. string.format('%d %d %d %d\n', xs, ys, xgs, ygs)
    end
    cursor = utf8.offset(text, -1)
  end

  local function open()
    active = true
  end

  local function close()
    active = false
    do
      local exp = {}
      for value in string.gmatch(text, "%d+") do
        table.insert(exp, tonumber(value))
      end
      if #segments % 4 == 0 then
        for k, _ in pairs(segments) do
          segments[k] = nil
        end
        for _, value in ipairs(exp) do
          table.insert(segments, value)
        end
      end
    end
    import()
    set_dirty()
  end

  local function write(t)
    text = string.sub(text, 0, cursor - 1) .. t .. string.sub(text, cursor)
    cursor = cursor + #t
  end

  local function movecursor(xmove, ymove)
    cursor = cursor + xmove + ymove * 8
  end

  local segmentsinput = {}
  function segmentsinput.init()
    import()
    active = false
    visible = true
    dirty = false
  end

  function segmentsinput.draw()
    if visible then
      love.graphics.setColor(colors.background)
      love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
      if active then
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
      end
      love.graphics.setColor(colors.text)
      local draw_text = string.sub(text, 0, cursor - 1) .. "|" .. string.sub(text, cursor)
      love.graphics.printf(draw_text, rect.x, rect.y, rect.w, "left")
    end
  end

  function segmentsinput.update(dt)
    if dirty then import() dirty = false end
    if keypressed_timer ~= nil then
      keypressed_timer = keypressed_timer + dt
      if keypressed_timer >= KEYPRESSED_DT then
        if keypressed == "left" then movecursor(-1, 0)
        elseif keypressed == "right" then movecursor(1, 0)
        elseif keypressed == "up" then movecursor(0, -1)
        elseif keypressed == "down" then movecursor(0, 1)
        elseif keypressed == "backspace" then
          -- delete char
          local byteoffset = utf8.offset(text, cursor)
          if byteoffset then
            text = string.sub(text, 1, byteoffset - 2) ..
                string.sub(text, byteoffset)
            cursor = cursor - 1
          end
        elseif keypressed == "escape" then close()
        elseif keypressed == "kpenter" then write("\n")
        end
        keypressed_timer = keypressed_timer - KEYPRESSED_DT
      end
    end
  end

  function segmentsinput.keypressed(key)
    if active then
      if key == "v" and love.keyboard.isDown("lctrl") then
        write(love.system.getClipboardText())
      else
        if key == "kpenter" then write("\n") end
        keypressed = key
        keypressed_timer = 0
      end
      return true
    end
    return false
  end

  function segmentsinput.keyreleased(key)
    if keypressed == key then keypressed = nil end
  end

  function segmentsinput.mousepressed(x, y, button)
    if button == 1 then
      if rect_collides(rect)(x, y) then open() return true end
      if active then
        active = false
        close()
      end
      return false
    end
  end

  function segmentsinput.textinput(t)
    if active then write(t) end
  end

  function segmentsinput.dirty() dirty = true end

  return segmentsinput
end
