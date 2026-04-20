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
    the chunk active
]]--
function state.getChunk(x, z)
    return state.ActiveChunks[chunkKey(x, z)]
end 

function state.addPlrActiveChunk(x, z, playerName)
    local chunkKey = chunkKey(x, z)
    if state.ActiveChunks[chunkKey] then
        state.ActiveChunks[chunkKey][playerName] = true
    else
        state.ActiveChunks[chunkKey] = {[playerName] = true}
    end
end

function state.removePlrFromChunk(x, z, playerName)
    state.ActiveChunks[chunkKey(x, z)][playerName] = nil
end

function state.isChunkActive(x, z)
    return state.ActiveChunks[chunkKey(x, z)]
end

state.ActiveChunks = {}
state.LatestRequests = {}



return state