local folder = script.Parent.Parent.Generation

local module = {}

module.HeightMap = require(folder.HeightMap)
module.BiomeMap = require(folder.BiomeMap)
module.Noise = require(folder.MyNoise2D)

return module
