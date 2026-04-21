
local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)

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
	local CELLSize = variables.CELL_SIZE

	local size = variables.CELLS_PER_CHUNKSIDE
	local sizeStuds = size * CELLSize

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
				mat = sample.biome.SurfacePart.Material
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

	-- local batchSize = variables.E_RENDER_BATCH_SIZE
	-- local processed = 0
	
	-- Render resources and such
	
end

function Voxel.RenderChunkArea(ChunkPosition: types.Position2D, areaIndex: number)

end

function Voxel.UnloadChunk(ChunkPos: types.Position2D)

    local region = Region3.new(
        Vector3.new(ChunkPos.x * variables.CELL_SIZE  * variables.CELLS_PER_CHUNKSIDE, 0, ChunkPos.z * variables.CELL_SIZE  * variables.CELLS_PER_CHUNKSIDE),
        Vector3.new((ChunkPos.x + 1) * variables.CELL_SIZE  * variables.CELLS_PER_CHUNKSIDE, variables.ChunkHeight, (ChunkPos.z + 1) * variables.CELL_SIZE  * variables.CELLS_PER_CHUNKSIDE)
    )
	workspace.Terrain:FillRegion(region:ExpandToGrid(4), 4, Enum.Material.Air)
end

return Voxel
