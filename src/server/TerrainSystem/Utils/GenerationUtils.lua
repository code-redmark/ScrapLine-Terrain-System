local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local genUtils = {}

genUtils.eps = 1e-9

function genUtils.AliasResourcePrecompute(list: {[number] : {Resource: types.EnvironmentResource, Weight: number}})
	
	local totalWeight = 0
	for i, v in ipairs(list) do
		totalWeight += v.Weight
	end
	
	local prob: {number} = {}
	local full: {} = {}
	local small: {number} = {}
	local large: {number} = {}
	
	-- Get each Resource's probability
	for i, v in ipairs(list) do
		local ResourceProb = (v.Weight/totalWeight) * #list
		
		prob[i] = ResourceProb
		
		if ResourceProb > 1 + genUtils.eps then
			table.insert(large, i)
		elseif ResourceProb < 1 - genUtils.eps then
			table.insert(small, i)
		else
			full[i] = {prob = 1, aliasIndex = nil, value = v.Resource}
		end
		
	end
	
	-- Fill all the small buckets
	while #small > 0 and #large > 0 do
		local sBucket = table.remove(small)
		local lBucket = table.remove(large)
		
		full[sBucket] = {
			prob = prob[sBucket],
			aliasIndex = lBucket,
			value = list[sBucket].Resource
		}
		
		prob[lBucket] -= (1 - prob[sBucket])
		
		if math.abs(prob[lBucket] - 1) < genUtils.eps then
			prob[lBucket] = 1
		elseif math.abs(prob[lBucket]) < genUtils.eps then
			prob[lBucket] = 0
		end
		
		if prob[lBucket] > 1 + genUtils.eps then
			table.insert(large, lBucket)
		elseif prob[lBucket] < 1 - genUtils.eps then
			table.insert(small, lBucket)
		else
			--[[
				Do nothing, values equal to one or 
				large buckets that dont become small
				after filling
				dont need any processing
			]]--
		end
	end
	
	-- The rest of the buckets is full
	for i = 1, #list do
		if not full[i] then
			full[i] = {
				prob = 1,
				aliasIndex = nil,
				value = list[i].Resource
			}
		end
	end
	
	return full
end

return genUtils
