local types = {}

-- Global types

export type Position2D = {
	x: number,
	z: number,
}

-- Biome types

export type Biome = {
	Name: string,
	Material: Enum.Material,

	--[[
		Lists the resources in a biome and each resource's weight.
		Weight is used to have a weighted random generation using
		RNG and Alias method for efficient generation
	]]--
	BiomeResources: {[number] : {Resource: EnvironmentResource, Weight: number}}
}


--[[
	Levels are a way to have different sets of biomes based on the
	distance from the origin of the world
]]--
export type BiomeLevel = {


	--[[
		This is not used in the actual terrain implementation
		but can be used to make barriers based on player level,
		or to spawn enemies and other NPCs based on the biome's level
	]]--
	MinLevel: number,

	--[[
		In chunks, the radius of the level is the radius in which
		this level is loaded, if this is the last level in the list
		this is ignored
	]]--
	Radius: number,

	--[[
		Perlin/Fractal Noise parameters generated for every cell in the
		level to determine the cell's biome
	]]--
	LevelParameters: {string},

	--[[
		List of resources available in the level
	]]--
	Resources: {[EnvironmentResourceType]: {EnvironmentResource}},
	
	Biomes: {Biome}
}

-- Chunk sampling types

export type TerrainSample = {
	position: Position2D,
	height: number,
	biome: Biome
}

-- Contains the macroarea's each biome's object and frequency
export type BiomeFrequencyContainer = {
	AreaPosition: Position2D,
	Biomes: {[string]: {
		BiomeData: Biome,
		Frequency: number
	}},
	DominantBiome: Biome,
	DominantFrequency: number,
}


--[[
	Type used to classify a separate type of resources
]]--
export type EnvironmentResourceType = {
	Name: string,
	BaseColor: Color3 -- if differnet than nil its going to mix with Resource color
}

--[[
	Base resource type
]]--
export type EnvironmentResource = {
	Name: string,
	Type: EnvironmentResourceType,
	CellRadius: number,

	Color: Color3,
	TypeColorOverride: boolean, -- if false add color patches
	ColorTerrainMix: boolean, -- if false make terrain darker, otherwise lerp and darken

	TerrainMaterial: Enum.Material, -- if different than nil override terrain texture
	TerrainTexture: Texture -- if different than nil override terrain texture
}

export type EnvironmentSample = {
	Center: Position2D,
	Resource: EnvironmentResource
}


return types
