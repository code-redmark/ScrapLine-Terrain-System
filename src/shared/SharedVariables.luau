local vars = {}

--[[
    Setting this to true will make the server preload the entire world
    on startup with a radius set in server variables
]]--
vars.PRELOADED = true

--[[
    Toggles chunk loading on request

    If set to false vars.PRELOADED **MUST** be set to true, otherwise the world is going to be empty
]]--
vars.INFINITE_WORLD = false


--[[
    in chunks, this is the radius of the world, in ScrapLine
    this represent the entire level's (level intended as roblox place) radius,
    after which there will be some sort of portal to the next level
]]-- 
vars.PRELOAD_RADIUS = 25  

--[[
    We want bigger chunks when preloading to speed up the total time.
    for infinite, partially preloaded worlds (PRELOADED = true and INFINITE_WORLD = true)
    the grids must be the same size
]]--
vars.PRELOAD_CELLS_PER_CHUNKSIDE = 32


--[[
    Smaller cells = smaller times to load cells that need to be instantly loaded
]]--
vars.CELLS_PER_CHUNKSIDE = 32
vars.CELL_SIZE = 4

if (vars.PRELOADED and vars.INFINITE_WORLD) and (vars.PRELOAD_CELLS_PER_CHUNKSIDE ~= vars.CELLS_PER_CHUNKSIDE) then
    error('Preloaded infinite worlds must have the same CELL_SIZE')
end

return vars