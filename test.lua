local im = require "imagine".import()

local z = im(3, math.sqrt(2))
print(math.i)
local w = z:conj()
print(z + w)
print(z * w)