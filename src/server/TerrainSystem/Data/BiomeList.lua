local SS = game:GetService("ServerStorage")

local types = require(script.Parent.GenerationTypes)
local ResourceData = require(script.Parent.ResourceData)

local List: {types.BiomeLevel} = {}

	List[1] = {
		MinLevel = 0,
		Radius = 2,
		LevelParameters = {'Temperature'},
			
		Resources = {
			[ResourceData.Types.Organic] = {
				ResourceData.Resources.Wood,
				ResourceData.Resources.Fiber
			},
			[ResourceData.Types.Ore] = {
				ResourceData.Resources.Stone,
				ResourceData.Resources.Iron
			}
		},

	Biomes = {
		[1] = {
			Name = "Snow",
			SurfacePart = SS.Generation.Terrain.BiomeParts.SnowPart,
			Temperature = 0,
			BiomeResources = {
				[1] = {Resource = ResourceData.Resources.Iron, Weight = 10},
				[2] = {Resource = ResourceData.Resources.Stone, Weight = 7},
				[3] = {Resource = ResourceData.Resources.Fiber, Weight = 3},
				[4] = {Resource = ResourceData.Resources.Wood, Weight = 2},
			}
		},

		[2] = {
			Name = "Plains",
			SurfacePart = SS.Generation.Terrain.BiomeParts.PlainsPart,
			Temperature = 10,
			BiomeResources = {
				[1] = {Resource = ResourceData.Resources.Wood, Weight = 10},
				[2] = {Resource = ResourceData.Resources.Fiber, Weight = 8},
				[3] = {Resource = ResourceData.Resources.Stone, Weight = 7},
				[4] = {Resource = ResourceData.Resources.Iron, Weight = 5},
			}
		},

		[3] = {
			Name = "Desert",
			SurfacePart = SS.Generation.Terrain.BiomeParts.DesertPart,
			Temperature = 20,
			BiomeResources = {
				[1] = {Resource = ResourceData.Resources.Copper, Weight = 10},
				[2] = {Resource = ResourceData.Resources.Stone, Weight = 6},
			}
		},	
	}	
}	


-- make sure biomeresources are in the correct order
for _, Level in ipairs(List) do
	for _, Biome in ipairs(Level.Biomes) do
		table.sort(Biome.BiomeResources, function(a, b) return a.Weight > b.Weight end)
	end
end

return List

