local pack = require("pack-utils")

return function(segments, filename, dirty)
  local active = false
  local function write()
    local text = ''
    for _, xs, ys, xgs, ygs in pack.ipairs(segments, 4) do
      text = text .. string.format('%d %d %d %d\n', xs, ys, xgs, ygs)
    end
    local success, message = love.filesystem.write(filename, text)
    if not success then error(message) end
  end

  local function read()
    do
      local content, message = love.filesystem.read(filename)
      if content == nil then error(message) end
      local exp = {}
      for value in string.gmatch(content, "%d+") do
        table.insert(exp, tonumber(value))
      end
      if #segments % 4 == 0 then
        for k, _ in pairs(segments) do segments[k] = nil end
        for _, value in ipairs(exp) do
          table.insert(segments, value)
        end
      end
    end
    dirty()
    write()
  end

  local segmentsfile = {}
  function segmentsfile.keypressed(key)
    if active then
      if key == "r" then read()
      elseif key == "w" then write() end
      active = false
      return true
    end
    if key == "f" then active = true return true end
    return false
  end

  return segmentsfile
end
