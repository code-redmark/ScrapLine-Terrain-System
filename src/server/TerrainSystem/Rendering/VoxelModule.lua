local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local EngineTerrain = game.Workspace:FindFirstChildOfClass('Terrain')

local Voxel = {}

--[[
	Loads the chunk's terrain following a TerrainMap's
	biome and height specified per voxel
]]--
function Voxel.RenderChunkTerrain(ChunkPosition: types.Position2D, TerrainMap: {types.TerrainSample})

	local batchSize = variables.T_RENDER_BATCH_SIZE
	local processed = 0
	
	local resolution = 4
	local CELLSize = variables.CELL_SIZE

	local size = variables.CELLS_PER_CHUNKSIDE
	local sizeStuds = size * CELLSize

	local baseX = ChunkPosition.x * sizeStuds
	local baseZ = ChunkPosition.z * sizeStuds

	-- IMPORTANT: Y size must be consistent with terrain limits
	local heightStuds = variables.HM_AMPLITUDE * 3 + 1

	local region = Region3.new(
		Vector3.new(baseX, 0, baseZ),
		Vector3.new(baseX + sizeStuds, heightStuds, baseZ + sizeStuds)
	)

	local materials = {}
	local occupancy = {}

	local sizeX = math.ceil(region.Size.X / resolution)
	local sizeY = math.ceil(region.Size.Y / resolution)
	local sizeZ = math.ceil(region.Size.Z / resolution)

	
	for x = 1, sizeX do
		materials[x] = {}
		occupancy[x] = {}
		local materialColumn = materials[x]
		local occupancyColumn = occupancy[x] 

		for z = 1, sizeZ do
			
			local sampleIndex = sizeZ * (x - 1) + z
			local sample = TerrainMap[sampleIndex]

				if sample then

					local mat = sample.biome.SurfacePart.Material
					local h = math.floor(sample.height / resolution)

					if h < 1 then h = 1 end

					if h > sizeY then print('hit height limit'); h = sizeY end

					for SolidY = 1, h do
						materialColumn[SolidY] = materialColumn[SolidY] or {}
						occupancyColumn[SolidY] = occupancyColumn[SolidY] or {}
						materialColumn[SolidY][z] = mat
						occupancyColumn[SolidY][z] = 1
					end

					for EmptyY = h + 1, sizeY do
						materialColumn[EmptyY] = materialColumn[EmptyY] or {}
						occupancyColumn[EmptyY] = occupancyColumn[EmptyY] or {}
						materialColumn[EmptyY][z] = Enum.Material.Air
						occupancyColumn[EmptyY][z] = 0
					end
				else
					-- important: clear column to avoid holes
					for ClearY = 1, sizeY do
						materialColumn[ClearY][z] = Enum.Material.Air
						occupancyColumn[ClearY][z] = 0
					end
			end

			if processed >= batchSize then task.wait(); processed = 0
			else processed += 1 end

		end

		

	end

	task.synchronize()

	print(#materials[1])
	EngineTerrain:WriteVoxels(region:ExpandToGrid(resolution), resolution, materials, occupancy)

	task.desynchronize()
end

function Voxel.RenderChunkEnvironment(ChunkPosition: types.Position2D, EnvironmentMap: {types.EnvironmentSample})

	-- local batchSize = variables.E_RENDER_BATCH_SIZE
	-- local processed = 0
	
	-- Render resources and such
	
end

return Voxel
