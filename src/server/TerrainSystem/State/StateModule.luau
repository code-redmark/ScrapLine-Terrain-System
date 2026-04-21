--local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local state = {} -- :: {
    
--     -- --[[
--     --     ActiveChunks represents the chunks currently containing
--     --     atleast ONE player, all the 8 chunks adjacent to this
--     --     are loaded in full detail
--     -- ]]--
--     -- ActiveChunks: [string] : {string},

--     -- --[[
--     --     LatestRequest contains each player's latest
--     --     request's chunk position stored in a 2D array, this is saved so that
--     --     if new requests come from the same chunk they are ignored
--     -- ]]--
--     -- LatestRequests: {[number]: types.Position2D }
-- }

local function chunkKey(x, z)
    return x..', '..z
end

--[[
    Returns the list of players currently keeping
    the chunk active (or nil if none)
]]--
function state.getChunk(x, z)
    return state.ActiveChunks[chunkKey(x, z)]
end 

-- Add a player to the chunk's active set. `playerId` should be a number (UserId).
function state.addPlrActiveChunk(x, z, playerId)
    local k = chunkKey(x, z)
    local chunk = state.ActiveChunks[k]
    if chunk then
        chunk[playerId] = true
    else
        state.ActiveChunks[k] = {[playerId] = true}
    end
end

-- Remove a player from a chunk. If the chunk has no players afterwards, remove its entry.
function state.removePlrFromChunk(x, z, playerId)
    local k = chunkKey(x, z)
    local chunk = state.ActiveChunks[k]
    if not chunk then return end
    chunk[playerId] = nil
    if next(chunk) == nil then
        state.ActiveChunks[k] = nil
    end
end

-- True if at least one player currently keeps the chunk active.
function state.isChunkActive(x, z)
    return state.ActiveChunks[chunkKey(x, z)] ~= nil
end

-- --- Loaded / sampling tracking ---
state.LoadedChunks = {}
state.SamplingChunks = {}

function state.markChunkLoaded(x, z)
    state.LoadedChunks[chunkKey(x, z)] = true
end

function state.unmarkChunkLoaded(x, z)
    state.LoadedChunks[chunkKey(x, z)] = nil
end

function state.isChunkLoaded(x, z)
    return state.LoadedChunks[chunkKey(x, z)] == true
end

function state.markChunkSampling(x, z)
    state.SamplingChunks[chunkKey(x, z)] = true
end

function state.unmarkChunkSampling(x, z)
    state.SamplingChunks[chunkKey(x, z)] = nil
end

function state.isChunkSampling(x, z)
    return state.SamplingChunks[chunkKey(x, z)] == true
end

state.ActiveChunks = {}
state.LatestRequests = {}



return state