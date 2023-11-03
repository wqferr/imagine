local dir = (...):match [[(.+)%.?[^%.]*]]
return require(dir..".imagine")