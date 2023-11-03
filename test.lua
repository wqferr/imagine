local im = require "imagine".partialImport {i = "I", "cconj"}

---@diagnostic disable-next-line: undefined-global
print(cexp) -- should be nil
local z1 = im(3, 4)

local z2 = -I
print(z1)
print(z2)
print()

print(z1 + z2)
print(z1 * z2)
print()

print("i*i:", I^2)
print("z * z_:", z1 * cconj(z1))
print()

print(im.sqrt(I))