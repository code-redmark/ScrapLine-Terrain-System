local request = game.ReplicatedStorage.Events.RequestChunk :: RemoteEvent

local stress = {}


--[[
	Loads all the chunk in specified radius
]]--
function stress.StressTest(radius: number)
	for x = -radius, radius do
		for z = -radius, radius do
			request:FireServer({x = x, z = z})
		end
	end
end

return stress