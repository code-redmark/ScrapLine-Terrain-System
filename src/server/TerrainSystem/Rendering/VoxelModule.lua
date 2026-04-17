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
	local heightStuds = 64 * CELLSize

	local region = Region3.new(
		Vector3.new(baseX, 0, baseZ),
		Vector3.new(baseX + sizeStuds, heightStuds, baseZ + sizeStuds)
	)

	local materials, occupancy = EngineTerrain:ReadVoxels(region, resolution)

	local sizeX = materials.Size.X
	local sizeY = materials.Size.Y
	local sizeZ = materials.Size.Z
	local air = Enum.Material.Air

	-- fill
	for x = 1, sizeX do
		local materialColumn = materials[x]
		local occupancyColumn = occupancy[x]
		for z = 1, sizeZ do

			local index = (x - 1) * sizeZ + z
			local sample = TerrainMap[index]

			if sample then

				local mat = sample.biome.SurfacePart.Material
				local h = math.floor(sample.height / resolution)

				if h < 1 then h = 1 end
				if h > sizeY then h = sizeY end

				for y = 1, h do
					materialColumn[y][z] = mat
					occupancyColumn[y][z] = 1
				end

				for y = h + 1, sizeY do
					materialColumn[y][z] = air
					occupancyColumn[y][z] = 0
				end
			else
				-- important: clear column to avoid holes
				for y = 1, sizeY do
					materialColumn[y][z] = air
					occupancyColumn[y][z] = 0
				end
			end

			if processed >= batchSize then
				task.wait()
				processed = 0
				continue
			else
				processed += 1
			end

		end
	end
	
	task.synchronize()

	EngineTerrain:WriteVoxels(region, resolution, materials, occupancy)

	task.desynchronize()
end

function Voxel.RenderChunkEnvironment(ChunkPosition: types.Position2D, EnvironmentMap: {types.EnvironmentSample})

	-- local batchSize = variables.E_RENDER_BATCH_SIZE
	-- local processed = 0
	
	-- Render resources and such
	
end

return Voxel
