local im = require "imagine".import()

for _, r in ipairs(im.roots(im.one, 3)) do
    print(r)
end