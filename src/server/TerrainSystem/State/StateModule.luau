local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local state = {} :: {
    
    --[[
        ActiveChunks represents the chunks currently containing
        atleast ONE player, all the 8 chunks adjacent to this
        are loaded in full detail
    ]]--
    ActiveChunks: {types.Position2D},

    --[[
        LatestRequest contains each player's latest
        request's ChunkPosition, this is saved so that
        if new requests come from the same chunk they are ignored
    ]]--
    LatestRequests: {[string] : types.Position2D}
}

state.ActiveChunks = {}
state.LatestRequests = {}



return state