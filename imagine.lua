---@class imagine
local M = {}
local exports = {}

-- Double floating point precision
-- If using a Lua distribution that uses floats instead of doubles,
-- or if you want more lax equality checks, set epsilon to 1e-6.
-- This can be done in the requiring library instead of editing this file.
M.epsilon = 1e-12

---@class Complex
---@field public real number real part of the complex number
---@field public imag number imaginary part of the complex number
---@operator add(Complex|number): Complex
---@operator sub(Complex|number): Complex
---@operator mul(Complex|number): Complex
---@operator div(Complex|number): Complex
---@operator pow(Complex|number): Complex
---@operator unm: Complex
local Complex = {}
local Complex__meta = {__index = Complex}

local allComplexes = {}
setmetatable(allComplexes, {__mode = "k", __index = function() return false end})


---Creates a new complex number with given real and imaginary parts
---@param real number real part of complex number
---@param imag number imaginary part of complex number
---@return Complex new new complex number with given components
local function newComplex(real, imag)
    assert(real and imag, "Both parts of the complex number must be given")
    assert(type(real) == "number", "Real part of a complex number must be a real number")
    assert(type(imag) == "number", "Imaginary part of a complex number must be a real number")
    local c = setmetatable({}, Complex__meta)
    c.real = real
    c.imag = imag
    allComplexes[c] = true
    return c
end
M.zero = newComplex(0, 0)
M.one = newComplex(1, 0)
M.i = newComplex(0, 1)
exports.i = M.i
exports.czero = M.zero
exports.cone = M.one

---Checks whether a value is a complex number
---@param z any value to be checked
---@return boolean complex whether or not the argument is a complex number
local function isComplex(z)
    return allComplexes[z]
end
M.isComplex = isComplex
exports.isComplex = isComplex

---Assures value is a complex number, if conversion is possible; is a no-op if value is a complex number
---@param value Complex|number value to be converted
---@return Complex c complex representation of the argument
local function asComplex(value)
    if isComplex(value) then
        ---@cast value Complex
        return value
    elseif type(value) == "number" then
        return newComplex(value, 0)
    else
        error(("Cannot convert %s to complex"):format(type(value)))
    end
end
M.asComplex = asComplex
exports.asComplex = asComplex

---Creates a new complex number with the same components as the given one
---@param z Complex|number number to copy
---@return Complex copy copy of the given number
local function cloneComplex(z)
    z = asComplex(z)
    return newComplex(z.real, z.imag)
end
Complex.clone = cloneComplex
M.cloneComplex = cloneComplex

---Calculates the modulus or absolute value of the number
---@param z Complex|number number whose absolute value is desired
---@return number abs absolute value of the argument
local function cabs(z)
    if type(z) == "number" then
        return math.abs(z)
    elseif isComplex(z) then
        return math.sqrt(z.real * z.real + z.imag * z.imag)
    else
        error(("Cannot calculate absolute value of %s"):format(type(z)))
    end
end
M.abs = cabs
Complex.abs = cabs
exports.cabs = cabs

---Calculates the argument (or phase) of the complex number
---@param z Complex|number number whose phase is desired
---@return number arg phase of the given number
local function carg(z)
    if type(z) == "number" then
        return 0
    elseif isComplex(z) then
        return math.atan(z.imag, z.real)
    else
        error(("Cannot calculate argument of %s"):format(type(z)))
    end
end
M.arg = carg
Complex.arg = carg
exports.carg = carg

---Cosine + i Sine function
---@param theta number
---@return Complex
local function cis(theta)
    assert(type(theta) == "number", "Angle must be a real number")
    return newComplex(math.cos(theta), math.sin(theta))
end

---Complex exponential function, calculates e^z
---@param z Complex|number point at which to calculate exponential
---@return Complex exp complex exponential at the argument
local function cexp(z)
    if type(z) == "number" then
        return newComplex(math.exp(z), 0)
    elseif isComplex(z) then
        return math.exp(z.real) * cis(z.imag)
    else
        error(("Cannot calculate complex exponential of %s"):format(type(z)))
    end
end
M.exp = cexp
exports.cexp = cexp

---Complex logarithm function, calculates ln(z)
---@param z Complex|number point at which to calculate the logarithm
---@return Complex log the complex logarithm of the argument
local function clog(z)
    if type(z) == "number" then
        return newComplex(math.log(z), 0)
    elseif isComplex(z) then
        return newComplex(math.log(z:abs()), z:arg())
    else
        error(("Cannot calculate complex logarithm of %s"):format(type(z)))
    end
end
M.log = clog
exports.clog = clog

---Complex conjugate, for a+bi returns a-bi
---@param z Complex|number value whose conjugate is desired
---@return Complex conjugate the conjugate value of the argument
local function cconj(z)
    z = asComplex(z)
    return newComplex(z.real, -z.imag)
end
M.conj = cconj
Complex.conj = cconj
exports.cconj = cconj

-- r is a power of 10 corresponding to how many decimal places should be kept
local function rround(x, r)
    return math.floor(x * r + 0.5) / r
end

---Round to the nearest Gaussian integer, or to a number of decimal places
---@param z Complex|number number to be rounded
---@param dp number? number of decimal places to keep (defualt 0)
---@return Complex rounded rounded complex number
local function cround(z, dp)
    if dp then
        assert(type(dp) == "number", "Decimal places argument must be a number")
        assert(dp % 1 == 0, "Decimal places argument must be an integer")
    end
    z = cloneComplex(z)
    local r = 10^(dp or 0)
    return newComplex(
        rround(z.real, r),
        rround(z.imag, r)
    )
end
M.round = cround
Complex.round = cround

---Creates a complex number from its polar form
---@param abs number absolute value of complex number
---@param arg number argument or phase of complex number
---@return Complex new complex number of given polar form
local function cpolar(abs, arg)
    assert(type(abs) == "number", "Absolute value must be a real number")
    assert(type(arg) == "number", "Argument must be a real number")
    return abs * cis(arg)
end
M.polar = cpolar
exports.cpolar = cpolar

---Complex square root function
---@param z Complex|number point whose square root is desired
---@return Complex|number root square root of point
local function csqrt(z)
    if type(z) == "number" then
        return math.sqrt(z)
    else
        return M.polar(math.sqrt(z:abs()), z:arg() / 2)
    end
end
M.sqrt = csqrt
exports.csqrt = csqrt

---Calculates nth roots of z
---@param z Complex|number value whose roots are desired
---@param n number index of the root
local function croots(z, n)
    assert(n > 0 and n % 1 == 0, "Index of root must be a positive integer")
    z = asComplex(z)
    local roots = {}
    local abs, arg = z:abs(), z:arg()
    local rabs = abs^(1/n)
    for i = 1, n do
        local rarg = arg + 2*(i-1)*math.pi / n
        local r = rabs * cis(rarg)
        table.insert(roots, r)
    end
    return roots
end
M.roots = croots
exports.croots = croots

---Compares two numeric values for equality, up to im.epsilon
---@param a Complex|number first number to compare
---@param b Complex|number second number to compare
---@return boolean equal whether the numbers are equal up to im.epsilon
local function eq(a, b)
    a, b = asComplex(a), asComplex(b)
    return a == b
end
M.eq = eq

--#region hyperbolic and circular trig functions

---Hyperbolic sine
---@param z Complex|number point
---@return Complex s sinh(point)
local function csinh(z)
    z = asComplex(z)
    return (cexp(z) - cexp(-z)) / 2
end
M.sinh = csinh
exports.csinh = csinh

---Hyperbolic cosine
---@param z Complex|number point
---@return Complex c cosh(point)
local function ccosh(z)
    z = asComplex(z)
    return (cexp(z) + cexp(-z)) / 2
end
M.cosh = ccosh
exports.ccosh = ccosh

---Hyperbolic tangent
---@param z Complex|number point
---@return Complex t tanh(point)
local function ctanh(z)
    z = asComplex(z)
    local z2 = 2*z
    return ((cexp(z2) - 1) / (cexp(z2) + 1))
end
M.tanh = ctanh
exports.ctanh = ctanh

---Area hyperbolic sine
---@param z Complex|number point
---@return Complex as asinh(point)
local function casinh(z)
    z = asComplex(z)
    return clog(z + csqrt(z*z + 1))
end
M.asinh = casinh
exports.casinh = casinh

---Area hyperbolic cosine
---@param z Complex|number point
---@return Complex ac acosh(point)
local function cacosh(z)
    z = asComplex(z)
    return clog(z + csqrt(z*z - 1))
end
M.acosh = cacosh
exports.cacosh = cacosh

---Area hyperbolic tangent
---@param z Complex|number point
---@return Complex at atanh(point)
local function catanh(z)
    z = asComplex(z)
    return 0.5 * clog((1 + z) / (1 - z))
end
M.atanh = catanh
exports.catanh = catanh

---Sine function
---@param z Complex|number point
---@return Complex s sin(point)
local function csin(z)
    return -M.i * csinh(M.i * z)
end
M.sin = csin
exports.csin = csin

---Cosine function
---@param z Complex|number point
---@return Complex c cos(point)
local function ccos(z)
    return ccosh(M.i * z)
end
M.cos = ccos
exports.ccos = ccos

---Tangent function
---@param z Complex|number point
---@return Complex t tan(point)
local function ctan(z)
    return -M.i * ctanh(z)
end
M.tan = ctan
exports.ctan = ctan

---Arcsine function
---@param z Complex|number point
---@return Complex as asin(point)
local function casin(z)
    z = asComplex(z)
    return -M.i * clog(csqrt(1 - z*z) + M.i*z)
end
M.asin = casin
exports.casin = casin

---Arccosine function
---@param z Complex|number point
---@return Complex ac acos(point)
local function cacos(z)
    z = asComplex(z)
    return -M.i * clog(M.i*csqrt(1 - z*z) + z)
end
M.acos = cacos
exports.cacos = cacos

---Arctangent function
---@param z Complex|number point
---@return Complex at atan(point)
local function catan(z)
    z = asComplex(z)
    return -M.i/2 * clog((M.i - z) / (M.i + z))
end
M.atan = catan
exports.catan = catan

--#endregion

---Checks if two complex numbers are close to each other
---@param x Complex first elment of comparison
---@param y Complex second elment of comparison
---@return boolean near whether the two values are close, up to im.epsilon
local function cnear(x, y)
    return (x-y):abs() <= M.epsilon
end

---Checks if two Lua numbers are close to each other
---@param x number first element of comparison
---@param y number second element of comparison
---@return boolean near whether the two values are close, up to im.epsilon
local function rnear(x, y)
    return math.abs(x-y) <= M.epsilon
end

Complex__meta.__add = function(x, y)
    x, y = asComplex(x), asComplex(y)
    return newComplex(x.real + y.real, x.imag + y.imag)
end

Complex__meta.__sub = function(x, y)
    x, y = asComplex(x), asComplex(y)
    return newComplex(x.real - y.real, x.imag - y.imag)
end

Complex__meta.__mul = function(x, y)
    x, y = asComplex(x), asComplex(y)
    local a, b, c, d = x.real, x.imag, y.real, y.imag
    return newComplex(a*c - b*d, a*d + b*c)
end

Complex__meta.__div = function(x, y)
    x, y = asComplex(x), asComplex(y)
    local a, b, c, d = x.real, x.imag, y.real, y.imag
    local ynorm2 = c*c + d*d
    return newComplex((a*c + b*d) / ynorm2, (b*c - a*d) / ynorm2)
end

Complex__meta.__pow = function(x, y)
    return cexp(y * clog(x))
end

Complex__meta.__unm = function(x)
    return newComplex(-x.real, -x.imag)
end

Complex__meta.__eq = function(x, y)
    -- x, y = asComplex(x), asComplex(y)
    -- Lua only calls __eq on values that have the same metatable.
    -- If this code is running, x and y are both Complex.
    return cnear(x, y)
end

Complex__meta.__tostring = function(x)
    local a, b = x.real, x.imag
    if rnear(a, 0) then
        a = 0
    elseif rnear(a, 1) then
        a = 1
    elseif rnear(a, -1) then
        a = -1
    end
    if rnear(b, 0) then
        b = 0
    elseif rnear(b, 1) then
        b = 1
    elseif rnear(b, -1) then
        b = -1
    end
    if b == 0 then
        return tostring(a)
    end
    if a == 0 then
        if b == 1 then
            return "i"
        elseif b == -1 then
            return "-i"
        else
            return ("%si"):format(b)
        end
    else
        if b == 1 then
            return ("%s + i"):format(a)
        elseif b == -1 then
            return ("%s - i"):format(a)
        elseif b > 0 then
            return ("%s + %si"):format(a, b)
        else
            return ("%s - %si"):format(a, -b)
        end
    end
end


---Imports commonly used functions into the global or specified namespace
---@param renames {string: string, into: table}? mapping from old names new names, with the special key "into" containing the table into which to import values
---@return imagine imagine the module itself, so that this function can be called in the same line as the require
M.import = function(renames)
    renames = renames or {}
    local into = renames.into or _G
    for k, v in pairs(exports) do
        local name = renames[k] or k
        into[name] = v
    end
    return M
end

---Imports only selected values into the global or specified namespace
---@param whichPlusRenames {string: string, into: table} mapping from old names to new names, with the special key "into" containing the table into which  to import values; if a value is not renamed, its name can be provided in the array part of the table
---@return imagine imagine the module itself, so that this function can be called in the same line as the require
M.partialImport = function(whichPlusRenames)
    assert(whichPlusRenames, "Which items are to be imported must be passed to partialImport.")
    local into = whichPlusRenames.into or _G
    for k, v in pairs(whichPlusRenames) do
        if type(k) == "number" then
            -- array part of table
            local name = v
            into[name] = exports[name]
        else
            -- map part of table
            local oldName, newName = k, v
            into[newName] = exports[oldName]
        end
    end
    return M
end

local M__meta = {}
function M__meta.__call(_, a, b)
    return newComplex(a, b)
end
setmetatable(M, M__meta)

return M