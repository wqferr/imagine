local im = require "imagine".import()

for _, r in ipairs(im.roots(im.polar(1, math.pi/3), 3)) do
    print(r)
end