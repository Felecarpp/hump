local lu = require("luaunit")
local vec = require("vector-light")
local vis = require("visible")
local pack = require("pack-utils")


function testOrientation()
  lu.assertTrue(vec.alignment(0, 0, 1, 0, 0, -1) > 0)
  lu.assertTrue(vec.alignment(0, 0, 1, 0, 0, 1) < 0)
  lu.assertTrue(vec.alignment(0, 0, 1, 0, 2, 0) == 0)
  lu.assertTrue(vec.alignment(0, 0, 0, -1, 0, 1) == 0)
  lu.assertTrue(vec.alignment(0, 1, 1, 1, 2, 1) == 0)
end

function testIntersection()
  lu.assertEquals(
    { vec.intersection(2, 2, 2, 1, 0, 0, 1, 0) }, { 2, 0 }
  )
end

function testPolarLt()
  lu.assertFalse(vec.polar_lt(0, 1, 1, 3))
end

function testComp()
  local t = {
    1, 0, 1, 1,
    3, 2, 2, 3,
    3, 2, 3, 3,
    1, 1, 0, 1,
    1, 3, -1, 3,
    0, 1, vis.nogoal, vis.nogoal,
    -1, -1, 3, -1,
    3, -1, 3, 0,
  }
  local r = {
    1, 0, 1, 1,
    3, 2, 2, 3,
    3, 2, 3, 3,
    1, 1, 0, 1,
    1, 3, -1, 3,
    0, 1, vis.nogoal, vis.nogoal,
    -1, -1, 3, -1,
    3, -1, 3, 0,
  }
  local f = function(a, b)
    return vis.comp(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4], 0, 0)
  end
  pack.sort(t, f, 4)
  lu.assertEquals(t, r)
end

function testComp2()
  local t = {
    1, 1, 0, 1,
    1, 1, 1, 3,
    3, 2, 2, 3,
    1, 3, -1, 3,
    3, 2, 3, 3,
    -1, 3, -1, -1,
    -1, -1, 3, -1,
    3, 1, 1, 1,
    1, 0, 1, 1,
    3, 3, 2, 3,
    2, 3, 1, 3,
    3, -1, 3, 0,
    3, 0, 3, 1,
    3, 1, 3, 2,
    0, 1, vis.nogoal, vis.nogoal,
  }
  local r = {
    1, 0, 1, 1,
    3, 0, 3, 1,
    3, 1, 1, 1,
    3, 1, 3, 2,
    3, 2, 2, 3,
    3, 2, 3, 3,
    1, 1, 0, 1,
    1, 1, 1, 3,
    3, 3, 2, 3,
    2, 3, 1, 3,
    1, 3, -1, 3,
    0, 1, vis.nogoal, vis.nogoal,
    -1, 3, -1, -1,
    -1, -1, 3, -1,
    3, -1, 3, 0,
  }
  pack.sort(t, function(a, b)
    return vis.comp(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4], 0, 0)
  end, 4)
  lu.assertEquals(t, r)
  lu.assertEquals(#t, #r)
end

TestVisibleSegments = {}

function TestVisibleSegments:testHideOneSideOnStart()
  lu.assertEquals(
    vis.polygon({
      1, 1, 1, 0,
      2, 2, 2, -2,
      3, 3, -3, 3,
      -3, 3, -3, -3,
      -3, -3, 3, -3,
      3, -3, 3, 3
    }),
    { 1, 0, 1, 1, 3, 3, -3, 3, -3, -3, 3, -3, 2, -2, 2, 0 }
  )
end

function TestVisibleSegments:testHideMiddle()
  lu.assertEquals(
    vis.polygon({
      1, 1, 3, 1,
      0, 0, 4, 0,
      4, 0, 4, 4,
      4, 4, 0, 4,
      0, 4, 0, 0
    }, { 2, 2 }),
    { 4, 2, 4, 4, 0, 4, 0, 0, 1, 1, 3, 1, 4, 0 }
  )
end

function TestVisibleSegments:testStartOnMiddle()
  lu.assertEquals(
    vis.polygon({
      1, 2, 2, 1,
      2, 2, 2, -1,
      2, 2, -1, 2,
      -1, -1, -1, 2,
      -1, -1, 2, -1
    }),
    { 2, 0, 2, 1, 1, 2, -1, 2, -1, -1, 2, -1 }
  )
end

function TestVisibleSegments:testStartOnEnd()
  lu.assertEquals(
    vis.polygon({
      1, 0, 0, 1,
      0, 1, 1, 2,
      2, 0, 2, 2,
      0, 2, 2, 2,
      0, 2, 0, 0,
      2, 0, 0, 0
    }, { 1, 1 }),
    { 2, 1, 2, 2, 1, 2, 0, 1, 1, 0, 2, 0 }
  )
end

function TestVisibleSegments:testStartBehindAndCross()
  lu.assertEquals(
    vis.polygon({
      -2, -3, -2, 3,
      -3, 1, -1, -1,
      2, -3, 2, 3,
      -2, -3, 2, -3,
      -2, 3, 2, 3
    }),
    { 2, 0, 2, 3, -2, 3, -2, 0, -1, -1, -2, -2, -2, -3, 2, -3 }
  )
end

function TestVisibleSegments:testFloatingValues()
  local visibles = vis.polygon({
    4, 2, 4, 8,
    2, 4, 8, 5,
    -1, 10, 10, 10,
    10, -1, 10, 10,
    -1, 10, -1, -1,
    10, -1, -1, -1
  })
  lu.assertEquals(visibles, {})
end

function TestVisibleSegments:testTwoLinesOnStart()
  lu.assertEquals(
    vis.polygon({
      1, 3, 3, -1,
      1, -1, 3, 3,
      3, 3, -1, 3,
      -1, 3, -1, -1,
      -1, -1, 3, -1
    }), { 1.5, 0, 2, 1, 1, 3, -1, 3, -1, -1, 1, -1 }
  )
end

function TestVisibleSegments:testCrossWithWallBehind()
  lu.assertEquals(
    vis.polygon({
      0, 1, 3, 1,
      1, 0, 1, 3,
      3, 2, 2, 3,
      3, 3, -1, 3,
      3, 3, 3, -1,
      -1, -1, -1, 3,
      -1, -1, 3, -1
    }),
    { 1, 0, 1, 1, 0, 1, 0, 3, -1, 3, -1, -1, 3, -1, 3, 0 }
  )
end

function TestVisibleSegments:testRealBlank()
  local visibles = vis.polygon({
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    358, 97, 141, 73,
    322, 58, 196, 106,
  }, { 256, 256 })
  lu.assertEquals(#visibles, 24)
end

function TestVisibleSegments:testCrossStartLine()
  local visibles = vis.polygon({
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    420, 307, 347, 123,
    350, 292, 407, 147,
  }, { 256, 256 })
  lu.assertEquals(#visibles, 18)
end

function TestVisibleSegments:testTriangle()
  local visibles = vis.polygon({
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    153, 79, 361, 87,
    182, 54, 299, 178,
    318, 54, 227, 173
  }, { 256, 256 })
  lu.assertEquals(#visibles, 28)
end

function TestVisibleSegments:testTwoCalls()
  local segments = {
    0, 0, 8, 0,
    8, 0, 8, 8,
    8, 8, 0, 8,
    0, 8, 0, 0
  }
  local r = { 8, 4, 8, 8, 0, 8, 0, 0, 8, 0 }
  local poly1 = vis.polygon(segments, { 4, 4 })
  lu.assertEquals(poly1, r)
  local poly2 = vis.polygon(segments, { 4, 4 })
  lu.assertEquals(poly2, r)
end

function TestVisibleSegments:testSimpleReal()
  local segments = {
    8, 0, 8, 8,
    8, 8, 0, 8,
    0, 8, 0, 0,
    0, 0, 8, 0,
    3, 2, 6, 3,
  }
  local r = {
    8, 4, 8, 8,
    0, 8, 0, 0,
    2, 0, 3, 2,
    6, 3, 8, 2
  }
  local poly = vis.polygon(segments, { 4, 4 })
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlankTwo()
  local segments = {
    512, 128, 512, 256,
    384, 128, 384, 192,
    512, 256, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    0, 0, 512, 0,
    512, 0, 512, 128,
    384, 64, 384, 128,
  }
  local r = { 384, 128, 384, 192, 512, 256, 512, 512, 0, 512, 0, 0, 512, 0, 384, 64 }
  local poly = vis.polygon(segments, { 256, 128 })
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testStopOnCamera()
  local segments = {
    0, 0, 2, 0,
    2, 0, 2, 2,
    2, 2, 0, 2,
    0, 2, 0, 0,
    0, 0, 1, 1
  }
  local r = { 2, 1, 2, 2, 0, 2, 0, 0, 2, 0 }
  local poly = vis.polygon(segments, { 1, 1 })
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank2()
  local segments = {
    512, 128, 512, 512,
    512, 512, 0, 512,
    256, 256, 0, 0,
    0, 512, 0, 0,
    0, 0, 512, 0,
    512, 0, 512, 128,
    512, 384, 128, 512,
  }
  local poly = vis.polygon(segments, { 256, 128 })
  local r = { 512, 128, 512, 384, 256, 469 + 1 / 3, 256, 256, 0, 0, 512, 0 }
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank3()
  local segments = {
    298 + 2 / 3, 128, 384, 384,
    512, 128, 512, 512,
    512, 512, 0, 512,
    256, 384, 128, 0,
    0, 512, 0, 0,
    0, 0, 128, 0,
    128, 0, 256, 0,
    256, 0, 298 + 2 / 3, 128,
    256, 0, 512, 0,
    512, 0, 512, 128,
  }
  local poly = vis.polygon(segments, { 256, 128 })
  local r = { 298 + 2/3, 128, 384, 384, 448, 512, 256, 512, 256, 384, 128, 0, 256, 0 }
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank4()
  local segments = {
    341 + 1 / 3, 128, 256, 384,
    512, 128, 512, 512,
    512, 512, 0, 512,
    128, 384, 128, 0,
    0, 512, 0, 0,
    0, 0, 128, 0,
    128, 0, 384, 0,
    384, 0, 341 + 1 / 3, 128,
    384, 0, 512, 0,
    512, 0, 512, 128
  }
  local poly = vis.polygon(segments, { 256, 128 })
  local r = { 341 + 1/3, 128, 256, 384, 256, 512, 64, 512, 128, 384, 128, 0, 384, 0 }
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank5()
  local segments = {
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    384, 384, 256, 384,
    128, 384, 0, 384,
    256, 256, 0, 0,
    512, 384, 128, 512,
    256, 384, 128, 128,
    256, 384, 256, 128,
    256, 128, 384, 128,
    384, 256, 0, 384,
    384, 384, 0, 384,
    128, 128, 512, 128,
    0, 128, 512, 0,
    256, 0, 384, 384,
    256, 384, 128, 0
  }
  local poly = vis.polygon(segments, { 256, 256 })
  local r = {
    341 + 1 / 3, 256,
    345.6, 268.8,
    256, 298 + 2/3,
    230.4, 307.2,
    192, 192,
    170 + 2/3, 128,
    256, 128,
    298 + 2/3, 128 }
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank6()
  local camera = { 256, 256 }
  local segments = {
    0, 0, 512, 0,
    512, 0, 512, 512,
    512, 512, 0, 512,
    0, 512, 0, 0,
    512, 128, 128, 384,
    384, 512, 128, 0,
    384, 512, 128, 128,
    128, 256, 384, 128,
  }
  local poly = vis.polygon(segments, camera)
  local r = {
    320, 256,
    272, 288,
    3200/13, 3968/13,
    192, 224,
    230.4, 204.8,
    384, 128,
    512, 0,
    512, 128,
  }
  lu.assertEquals(poly, r)
end

function TestVisibleSegments:testRealBlank7()
  local camera = { 256, 256 }
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
    256, 128, 384, 512,
  }
  local poly = vis.polygon(segments, camera)
  local r = {
    298 + 2/3, 256,
    307.2, 281.6,
    384, 512,
    256, 512,
    256, 384,
    213 + 1/3, 298 + 2/3,
    192, 256,
    204.8, 230.4,
    307, 282,
  }
  lu.assertEquals(poly, r)
end

os.exit(lu.LuaUnit.run())
