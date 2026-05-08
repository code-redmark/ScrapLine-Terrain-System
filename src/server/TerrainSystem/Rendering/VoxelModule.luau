local vars = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local EngineTerrain = game.Workspace:FindFirstChildOfClass('Terrain')

local Voxel = {}

--[[
	Loads the chunk's terrain following a TerrainMap's
	biome and height specified per voxel
]]--
function Voxel.RenderChunkTerrain(ChunkPosition: types.Position2D, TerrainMap: {types.TerrainSample})

	local batchSize = vars.T_RENDER_BATCH_SIZE
	local resolution = vars.VOXEL_RESOLUTION

	local WorldChunkX = ChunkPosition.x * vars.worldChunkSize
	local WorldChunkZ = ChunkPosition.z * vars.worldChunkSize

	local heightStuds = vars.studChunkHeight

	local region = Region3.new(
		Vector3.new(WorldChunkX, 0, WorldChunkZ),
		Vector3.new(WorldChunkX + vars.worldChunkSize, heightStuds, WorldChunkZ + vars.worldChunkSize)
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

	local processed = 0

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

	local batchSize = vars.E_RENDER_BATCH_SIZE
	
	local resolution = 4
	local CELL_SIZE = sharedVars.CELL_SIZE

	local WorldChunkTlCorner: types.Position2D = {
		x = ChunkPosition.x * vars.worldChunkSize,
		z = ChunkPosition.z * vars.worldChunkSize
	}

	-- IMPORTANT: Y size must be consistent with terrain limits
	local heightStuds = vars.studChunkHeight

	local processed = 0

	for key, sample: {Center: types.Position2D, Resource: types.EnvironmentResource } in EnvironmentMap do
		
		if sample.Resource.Name == nil then continue end

		-- position of the macro area relative to the chunk in studs
		local studMacroAreaX = math.floor(((key - 1) / vars.MACROAREAS_PER_CHUNKSIDE)) * vars.worldMacroareaSize
		local studMacroAreaZ = ((key - 1) % vars.MACROAREAS_PER_CHUNKSIDE) * vars.worldMacroareaSize

		-- position of the center relative to the macro area in studs
		local studCenterX = sample.Center.x * CELL_SIZE
		local studCenterZ = sample.Center.z * CELL_SIZE

		--[[ 
		    sum it all up and get the world position of the top left of the 
			square containing all the cells in the resource's radius
		]]--
	
		local studRadius = sample.Resource.CellRadius * CELL_SIZE

		local ResourceSquareTopLeft: Vector3 = Vector3.new(
			WorldChunkTlCorner.x + studMacroAreaX + (studCenterX - studRadius),
			0,
			WorldChunkTlCorner.z + studMacroAreaZ + (studCenterZ - studRadius)
		)

		local region = Region3.new(
			Vector3.new(ResourceSquareTopLeft.X, 0, ResourceSquareTopLeft.Z),
			Vector3.new(ResourceSquareTopLeft.X + sample.Resource.CellRadius * 2, heightStuds, ResourceSquareTopLeft.Z + sample.Resource.CellRadius * 2)
		)

		if processed >= batchSize then task.wait(); processed = 0
		else processed += 1 end

		task.synchronize()
		--[[
			Just for testing we use replace material which is going to make a square sized resource,
			this might be changed to make some more natural patches or circles
		]]--
		for _, material in vars.materialTable do

			if material ~= nil or material ~= sample.Resource.TerrainMaterial then
				EngineTerrain:ReplaceMaterial(region:ExpandToGrid(resolution), resolution, material, sample.Resource.TerrainMaterial or material)			
			end

		end

		task.desynchronize()
	end
end

function Voxel.UnloadChunk(ChunkPos: types.Position2D)
    local region = Region3.new(
        Vector3.new(ChunkPos.x * vars.worldChunkSize, 0, ChunkPos.z * vars.worldChunkSize),
        Vector3.new((ChunkPos.x + 1) * vars.worldChunkSize, vars.studChunkHeight, (ChunkPos.z + 1) * vars.worldChunkSize)
    )
	workspace.Terrain:FillRegion(region:ExpandToGrid(4), 4, Enum.Material.Air)
end



return Voxel
