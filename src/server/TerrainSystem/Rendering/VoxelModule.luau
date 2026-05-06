
local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)

local BiomeList = require(game.ServerScriptService.Server.TerrainSystem.Data.BiomeList)

-- Preload all materials to know what materials to replace when creating a resource
local existing_materials = {}

for i, level in BiomeList do
	for j, biome in level.Biomes do 
		table.insert(existing_materials, biome.Material)
	end
end

local CellsPerChunkSide
if sharedVars.PRELOADED then
	CellsPerChunkSide = sharedVars.PRELOAD_CELLS_PER_CHUNKSIDE
else
	CellsPerChunkSide = sharedVars.CELLS_PER_CHUNKSIDE
end

local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local EngineTerrain = game.Workspace:FindFirstChildOfClass('Terrain')

local Voxel = {}

--[[
	Loads the chunk's terrain following a TerrainMap's
	biome and height specified per voxel
]]--
function Voxel.RenderChunkTerrain(ChunkPosition: types.Position2D, TerrainMap: {types.TerrainSample})

	--local t0 = os.clock()

	local batchSize = variables.T_RENDER_BATCH_SIZE
	local processed = 0
	
	local resolution = 4
	local CELL_SIZE = sharedVars.CELL_SIZE

	local size = CellsPerChunkSide
	local sizeStuds = size * CELL_SIZE

	local baseX = ChunkPosition.x * sizeStuds
	local baseZ = ChunkPosition.z * sizeStuds

	-- IMPORTANT: Y size must be consistent with terrain limits
	local heightStuds = variables.ChunkHeight

	local region = Region3.new(
		Vector3.new(baseX, 0, baseZ),
		Vector3.new(baseX + sizeStuds, heightStuds, baseZ + sizeStuds)
	)

	local sizeX = math.ceil(region.Size.X / resolution)
	local sizeY = math.ceil(region.Size.Y / resolution)
	local sizeZ = math.ceil(region.Size.Z / resolution)

	-- Preallocate materials and occupancy tables
	local materials = table.create(sizeX)
	local occupancy = table.create(sizeX)
	for x = 1, sizeX do
		materials[x] = table.create(sizeY)
		occupancy[x] = table.create(sizeY)
		local materialColumn = materials[x]
		local occupancyColumn = occupancy[x]
		for y = 1, sizeY do
			materialColumn[y] = table.create(sizeZ)
			occupancyColumn[y] = table.create(sizeZ)
		end
	end

	for x = 1, sizeX do
		local materialColumn = materials[x]
		local occupancyColumn = occupancy[x]
		for z = 1, sizeZ do
			local sampleIndex = sizeZ * (x - 1) + z
			local sample = TerrainMap[sampleIndex]
			local mat, h
			if sample then
				mat = sample.biome.Material
				h = math.floor(sample.height / resolution)
				if h < 1 then h = 1 end
				if h > sizeY then print('hit height limit'); h = sizeY end
			else
				mat = Enum.Material.Air
				h = 0
			end
			for y = 1, sizeY do
				if y <= h then
					materialColumn[y][z] = mat
					occupancyColumn[y][z] = 1
				else
					materialColumn[y][z] = Enum.Material.Air
					occupancyColumn[y][z] = 0
				end
			end
			if processed >= batchSize then task.wait(); processed = 0
			else processed += 1 end
		end
	end
	

	task.synchronize()

	EngineTerrain:WriteVoxels(region:ExpandToGrid(resolution), resolution, materials, occupancy)

	task.desynchronize()
end

function Voxel.RenderChunkEnvironment(ChunkPosition: types.Position2D, EnvironmentMap: {types.EnvironmentSample})

	local batchSize = variables.E_RENDER_BATCH_SIZE
	
	
	local resolution = 4
	local CELL_SIZE = sharedVars.CELL_SIZE

	local WorldChunkTlCorner: types.Position2D = {
		x = ChunkPosition.x * CellsPerChunkSide * CELL_SIZE,
		z = ChunkPosition.z * CellsPerChunkSide * CELL_SIZE
	}

	-- IMPORTANT: Y size must be consistent with terrain limits
	local heightStuds = variables.ChunkHeight


	local processed = 0

	for key, sample: {Center: types.Position2D, Resource: types.EnvironmentResource } in EnvironmentMap do
		
		if sample.Resource.Name == nil then continue end

		print(sample.Resource.Name.." passed")

		-- position of the macro area relative to the chunk in studs
		local studMacroAreaX = math.floor(((key - 1) / variables.MACROAREAS_PER_CHUNKSIDE)) * CELL_SIZE * variables.CELLS_PER_MACROAREA_SIDE
		local studMacroAreaZ = ((key - 1) % variables.MACROAREAS_PER_CHUNKSIDE) * CELL_SIZE * variables.CELLS_PER_MACROAREA_SIDE

		-- position of the center relative to the macro area in studs
		local studCenterX = sample.Center.x * CELL_SIZE
		local studCenterZ = sample.Center.z * CELL_SIZE

		--[[ 
		   we sum it all up and get the world position of the top left of the 
			square containing all the cells in the resource's radius
		]]--

		print(sample.Resource.Name, sample.Resource.CellRadius)
		local studRadius = sample.Resource.CellRadius * CELL_SIZE

		local ResourceSquareTopLeft: Vector3 = Vector3.new(
			WorldChunkTlCorner.x + studMacroAreaX + (studCenterX - studRadius),
			0,
			WorldChunkTlCorner.z + studMacroAreaZ + (studCenterZ - studRadius)
		)

		local region = Region3.new(
			Vector3.new(ResourceSquareTopLeft.X, 0, ResourceSquareTopLeft.Z),
			Vector3.new(ResourceSquareTopLeft.X + (sample.Resource.CellRadius * 2), heightStuds, ResourceSquareTopLeft.Z + (sample.Resource.CellRadius * 2))
		)


		if processed >= batchSize then task.wait(); processed = 0
		else processed += 1 end

		task.synchronize()
		--[[
			Just for testing we use replace material which is going to make a square sized resource,
			this might be changed to make some more natural patches or circles
		]]--
		for _, material in existing_materials do

			if material ~= nil or material ~= sample.Resource.TerrainMaterial then
				EngineTerrain:ReplaceMaterial(region:ExpandToGrid(resolution), resolution, material, sample.Resource.TerrainMaterial or material)			
			end

			end
		task.desynchronize()

	end
	
end

function Voxel.RenderChunkArea(ChunkPosition: types.Position2D, areaIndex: number)

end

function Voxel.UnloadChunk(ChunkPos: types.Position2D)

    local region = Region3.new(
        Vector3.new(ChunkPos.x * sharedVars.CELL_SIZE  * CellsPerChunkSide, 0, ChunkPos.z * sharedVars.CELL_SIZE  * CellsPerChunkSide),
        Vector3.new((ChunkPos.x + 1) * sharedVars.CELL_SIZE  * CellsPerChunkSide, variables.ChunkHeight, (ChunkPos.z + 1) * sharedVars.CELL_SIZE  * CellsPerChunkSide)
    )
	workspace.Terrain:FillRegion(region:ExpandToGrid(4), 4, Enum.Material.Air)
end



return Voxel
