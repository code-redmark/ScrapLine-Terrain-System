local module = {}

local Noise = require(game.ServerScriptService.Server.TerrainSystem.Generation.MyNoise2D)
local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local hmOctaves = variables.HM_OCTAVES
local hmPersistence = variables.HM_PERSISTENCE
local hmLacunarity = variables.HM_LACUNARITY
local hmScale = variables.HM_SCALE
local hmAmplitude = variables.HM_AMPLITUDE

function module.GetHeight(worldX: number, worldZ: number, HmOffset: types.Position2D)
	local noise = Noise.Fractal(
		hmOctaves,
		worldX + HmOffset.x,
		worldZ + HmOffset.z,
		hmPersistence,
		hmLacunarity,
		hmScale
	)

	return ((noise + 1) / 2) * hmAmplitude
end

return module
