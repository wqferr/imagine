local im = require "imagine"

local z = im(3, math.sqrt(2))
local w = z:conj()
print(z + w)
print(z * w)