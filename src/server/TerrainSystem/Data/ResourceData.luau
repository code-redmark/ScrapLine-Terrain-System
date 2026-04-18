local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local Resources = {} :: {Types: {[string] : types.EnvironmentResourceType}, Resources: {[string] : types.EnvironmentResource}}

	Resources.Types = {
		Organic = {
			Name = 'Organic',
			BaseColor = Color3.fromHSV(0.3, 0.9, 0.5)
		},
		Ore = {
			Name = 'Ore',
			BaseColor = Color3.fromHSV(0.5, 0.03, 0.3)
		}
	}

	Resources.Resources = {
		Wood = {
			Name = 'Wood',
			Type = Resources.Types.Organic,
			CellRadius = 5,
			
			Color = Color3.fromHSV(0.25, 1, 0.67),
			TypeColorOverride = false,
			ColorTerrainMix = false,
			TerrainMaterial = nil,
			TerrainTexture = nil
		},
		Fiber = {
			Name = 'Fiber',
			Type = Resources.Types.Organic,
			CellRadius = 3,

			Color = Color3.fromHSV(0.166667, 1, 0.670588),
			TypeColorOverride = false,
			ColorTerrainMix = false,
			TerrainMaterial = nil,
			TerrainTexture = nil
		},
		Stone = {
			Name = 'Stone',
			Type = Resources.Types.Ore,
			CellRadius = 5,
			
			Color = Color3.fromHSV(0.5, 0.03, 0.3),
			TypeColorOverride = false,
			ColorTerrainMix = false,
			TerrainMaterial = nil,
			TerrainTexture = nil
		},
		Iron = {
			Name = 'Iron',
			Type = Resources.Types.Ore,
			CellRadius = 2,
			
			Color = Color3.fromHSV(0.253972, 0.0985885, 0.835294),
			TypeColorOverride = false,
			ColorTerrainMix = false,
			TerrainMaterial = nil,
			TerrainTexture = nil
		},
		Copper = {
			Name = 'Copper',
			Type = Resources.Types.Ore,
			CellRadius = 2,

			Color = Color3.fromHSV(0.1, 0.8, 0.6),
			TypeColorOverride = false,
			ColorTerrainMix = false,
			TerrainMaterial = nil,
			TerrainTexture = nil
		}
	}

	
	

return Resources
