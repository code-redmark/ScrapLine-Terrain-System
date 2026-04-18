local types = {}

-- Global types

export type Position2D = {
	x: number,
	z: number,
}

-- Biome types

export type Biome = {
	Name: string,
	SurfacePart: Part,
	BiomeResources: {[number] : {Resource: EnvironmentResource, Weight: number}}
}

export type BiomeLevel = {
	MinLevel: number,
	Radius: number,
	LevelParameters: {string}, -- Values mapped to generate biomes
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

export type EnvironmentResourceType = {
	Name: string,
	BaseColor: Color3 -- if differnet than nil its going to mix with Resource color
}

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
