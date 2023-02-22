local function sort_pack(t, f, l)
  for i = 1, #t, l do
    for j = i - l, 1, -l do
      local argsa = {}
      for k = 0, l - 1 do table.insert(argsa, t[i + k]) end
      local argsb = {}
      for k = 0, l - 1 do table.insert(argsb, t[j + k]) end
      if f(argsa, argsb) then
        if j == 1 then
          for k = 0, l - 1 do
            table.insert(t, j + k, t[i + k])
            table.remove(t, i + k + 1)
          end
          break
        end
      elseif j ~= i - l then
        for k = 0, l - 1 do
          table.insert(t, j + k + l, t[i + k])
          table.remove(t, i + k + 1)
        end
        break
      else break end
    end
  end
end

local function insert_pack(t, v)
  for _, value in ipairs(v) do table.insert(t, value) end
end


local function insert_sort_pack(t, v, f)
  if #t > 0 then
    for i = 1, #t, #v do
      local values = {}
      for k = 0, #v - 1 do table.insert(values, t[i + k]) end
      -- print(v[1].." < "..values[1].." ?")
      if f(v, values) then
        -- print(v[1].." index "..i)
        for k = 1, #v do table.insert(t, i + k - 1, v[k]) end
        return
      end
    end
  end
  -- print(v[1].." at end")
  for k = 1, #v do table.insert(t, v[k]) end
end

-- do
--   local t = {}
--   local f = function(a, b) return a[1] < b[1] end
--   insert_pack(t, {3, 5, 1}, f)
--   insert_pack(t, {1, 3, 1}, f)
--   insert_pack(t, {4, 6, 1}, f)
--   insert_pack(t, {2, 4, 1}, f)
--   require("luaunit").assertEquals(
--     t,
--     {1, 3, 1, 2, 4, 1, 3, 5, 1, 4, 6, 1}
--   )
--   print("success")
-- end

local function ipairs_pack(t, l, max)
  local index = 1 - l
  local count = max or #t
  return function()
    index = index + l
    if index <= count then
      local values = {}
      for k = 0, l - 1 do
        table.insert(values, t[index + k])
      end
      return index, unpack(values)
    end
  end
end

local function print_pack(t, f, l)
  for i = 1, #t - l + 1, l do
    local values = {}
    for k = 1, l do
      table.insert(values, t[i + k - 1])
    end
    (f or print)(unpack(values))
  end
end

-- do
--   local t = { 1, 1, 0, 0, 2, 2, 2, 1 }
--   local f = function(a, b, c, d) return a + b < c + d end
--   local r = { 0, 0, 1, 1, 2, 1, 2, 2 }
--   sort_pack(t, f, 2)
--   for i, v in ipairs(t) do
--     assert(v == r[i], v .. " != " .. r[i] .. " (" .. i .. ")")
--   end
-- end

-- do
--   local t = {
--     1, 1, 0,
--     2, 4, 2,
--     2, 2, 5,
--     2, 0, 5
--   }
--   local f = function(a1, b1, c1, a2, b2, c2)
--         return a1 + b1 + c1 < a2 + b2 + c2
--             end
--   local r = {
--     1, 1, 0,
--     2, 0, 5,
--     2, 4, 2,
--     2, 2, 5
--   }
--   sort_pack(t, f, 3)
--   for i, v in ipairs(t) do
--     assert(v == r[i], v .. " != " .. r[i] .. " (" .. i .. ")")
--   end
-- end

return {
  sort = sort_pack,
  ipairs = ipairs_pack,
  print = print_pack,
  insert = insert_pack,
  insert_sort = insert_sort_pack
}
