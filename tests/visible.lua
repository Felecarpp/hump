local lu = require("luaunit")
local vec = require("vector")
local vis = require("visible")


function testOrientation()
  lu.assertTrue(vec.alignment(vec(0, 0), vec(1, 0), vec(0, -1)) > 0)
  lu.assertTrue(vec.alignment(vec(0, 0), vec(1, 0), vec(0, 1)) < 0)
  lu.assertTrue(vec.alignment(vec(0, 0), vec(1, 0), vec(2, 0)) == 0)
  lu.assertTrue(vec.alignment(vec(0, 0), vec(0, -1), vec(0, 1)) == 0)
  lu.assertTrue(vec.alignment(vec(0, 1), vec(1, 1), vec(2, 1)) == 0)
end

function testIntersection()
  lu.assertEquals(
    vec.intersection(vec(2, 2), vec(2, 1), vec(0, 0), vec(1, 0)),
    vec(2, 0)
  )
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
  lu.assertEquals(#visibles, 18)
end

function TestVisibleSegments:testTwoLinesOnStart()
  lu.assertEquals(
    vis.polygon({
      1, 3, 3, -1,
      1, -1, 3, 3,
      3, 3, -1, 3,
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

os.exit(lu.LuaUnit.run())
