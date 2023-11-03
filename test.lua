local im = require "imagine".partialImport {i = "I", "cconj"}
print(cexp)
local z1 = im(3, 4)
local z2 = -I
print(z1)
print(z2)
print()

print(z1 + z2)
print(z1 * z2)

print("i*i:", I^2)

print("z * z_:", z1 * cconj(z1))