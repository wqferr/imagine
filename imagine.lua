local M = {}
local exports = {}

-- Double floating point precision
-- If using a Lua distribution that uses floats instead of doubles,
-- set epsilon to 1e-6
M.epsilon = 1e-12

---@class Complex
---@field real number real part of the complex number
---@field imag number imaginary part of the complex number
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
M.i = newComplex(0, 1)
exports.i = M.i
-- exports.newComplex = newComplex -- calling the module with 2 arguments has the same effect

local function isComplex(z)
    return allComplexes[z]
end
exports.isComplex = isComplex

local function asComplex(value)
    if isComplex(value) then
        return value
    elseif type(value) == "number" then
        return newComplex(value, 0)
    else
        error(("Cannot convert %q to complex"):format(type(value)))
    end
end

local function cnorm(z)
    if type(z) == "number" then
        return math.abs(z)
    elseif isComplex(z) then
        return math.sqrt(z.real * z.real + z.imag * z.imag)
    else
        error(("Cannot calculate norm of %q"):format(type(z)))
    end
end
Complex.norm = cnorm
exports.cnorm = cnorm

local function carg(z)
    if type(z) == "number" then
        return 0
    elseif isComplex(z) then
        return math.atan(z.imag, z.real)
    else
        error(("Cannot calculate argument of %q"):format(type(z)))
    end
end
Complex.arg = carg
exports.carg = carg

---Cosine + i Sine function
---@param theta number
---@return Complex
local function cis(theta)
    return newComplex(math.cos(theta), math.sin(theta))
end

---Complex exponential
---@param z Complex|number
---@return Complex
local function cexp(z)
    if type(z) == "number" then
        return newComplex(math.exp(z), 0)
    elseif isComplex(z) then
        return math.exp(z.real) * cis(z.imag)
    else
        error(("Cannot calculate complex exponential of %q"):format(z))
    end
end
exports.cexp = cexp

local function clog(z)
    return newComplex(math.log(z:norm()), z:arg())
end
exports.clog = clog

local function cconj(z)
    z = asComplex(z)
    return newComplex(z.real, -z.imag)
end
Complex.conj = cconj
exports.cconj = cconj

local function cpolar(norm, arg)
    return norm * cis(arg)
end
M.polar = cpolar
exports.cpolar = cpolar

---Complex square root function
---@param z Complex|number point whose square roots are desired
---@param bothValues boolean? whether to return one (false, default) or both (true) square roots
---@return Complex|number
---@return Complex|number?
local function csqrt(z, bothValues)
    local r
    if type(z) == "number" then
        r = math.sqrt(z)
    else
        r = z^0.5
    end
    if bothValues then
        return r, -r
    else
        return r
    end
end
M.sqrt = csqrt
exports.csqrt = csqrt

local function csinh(z)
    z = asComplex(z)
    return (cexp(z) - cexp(-z)) / 2
end
M.sinh = csinh
exports.csinh = csinh

local function ccosh(z)
    z = asComplex(z)
    return (cexp(z) + cexp(-z)) / 2
end
M.cosh = ccosh
exports.ccosh = ccosh

local function ctanh(z)
    z = asComplex(z)
    local z2 = 2*z
    return ((cexp(z2) - 1) / (cexp(z2) + 1))
end
M.tanh = ctanh
exports.ctanh = ctanh

local function casinh(z)
    z = asComplex(z)
    return clog(z + csqrt(z*z + 1))
end
M.asinh = casinh
exports.casinh = casinh

local function cacosh(z)
    z = asComplex(z)
    return clog(z + csqrt(z*z - 1))
end
M.acosh = cacosh
exports.cacosh = cacosh

local function catanh(z)
    z = asComplex(z)
    return 0.5 * clog((1 + z) / (1 - z))
end
M.atanh = catanh
exports.catanh = catanh

local function csin(z)
    return -M.i * csinh(M.i * z)
end
M.sin = csin
exports.csin = csin

local function ccos(z)
    return ccosh(M.i * z)
end
M.cos = ccos
exports.ccos = ccos

local function ctan(z)
    return -M.i * ctanh(z)
end
M.tan = ctan
exports.ctan = ctan

local function casin(z)
    z = asComplex(z)
    return -M.i * clog(csqrt(1 - z*z) + M.i*z)
end
M.asin = casin
exports.casin = casin

local function cacos(z)
    z = asComplex(z)
    return -M.i * clog(M.i*csqrt(1 - z*z) + z)
end
M.acos = cacos
exports.cacos = cacos

local function catan(z)
    z = asComplex(z)
    return -M.i/2 * clog((M.i - z) / (M.i + z))
end
M.atan = catan
exports.catan = catan

local function cnear(x, y)
    return (x-y):norm() <= M.epsilon
end

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
    x, y = asComplex(x), asComplex(y)
    return cnear(x, y)
end

Complex__meta.__tostring = function(x)
    local a, b = x.real, x.imag
    if rnear(a, 0) then
        a = 0
    end
    if rnear(b, 0) then
        b = 0
    end
    if a == 0 then
        if b == 0 then
            return "0"
        else
            return tostring(b).."i"
        end
    elseif b == 0 then
        return a
    end
    if b > 0 then
        return ("%s + %si"):format(a, b)
    else
        return ("%s - %si"):format(a, -b)
    end
end

-- renames = {oldName: newName}
M.import = function(renames, into)
    renames = renames or {}
    into = into or _G
    for k, v in pairs(exports) do
        local name = renames[k] or k
        into[name] = v
    end
    return M
end

-- whichPlusRenames: string[] U {oldName: newName}
M.partialImport = function(whichPlusRenames, into)
    assert(whichPlusRenames, "Which items are to be imported must be passed to partialImport.")
    into = into or _G
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
    if a and not b then
        return asComplex(a)
    else
        return newComplex(a, b)
    end
end
setmetatable(M, M__meta)

return M