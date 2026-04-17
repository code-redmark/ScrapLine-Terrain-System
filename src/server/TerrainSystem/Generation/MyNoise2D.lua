local Noise2D = {}

function Noise2D.Fractal(octaves: number, x, z, persistence: number, lacunarity: number, scale: number)
	-- The sum of our octaves
	local value = 0 
	local totalAmplitude = 0
	local noise = math.noise
	local clamp = math.clamp

	-- These coordinates will be scaled the lacunarity
	local x1 = x 
	local z1 = z

	-- Determines the effect of each octave on the previous sum
	local amplitude = 1
	local inverseScale = 1 / scale

	for i = 1, octaves, 1 do
		-- Multiply the noise output by the amplitude and add it to our sum
		value += noise(x1 * inverseScale, z1 * inverseScale) * amplitude
		totalAmplitude += amplitude

		-- Scale up our perlin noise by multiplying the coordinates by lacunarity
		z1 *= lacunarity
		x1 *= lacunarity

		-- Reduce our amplitude by multiplying it by persistence
		amplitude *= persistence
	end

	if totalAmplitude > 0 then
		value /= totalAmplitude
	end

	return clamp(value, -1, 1)
end

-- Perlin-like Noise
function Noise2D.Perlin(x: number, z: number)	
	
	local topLeft, topRight, bottomLeft, bottomRight = Corners(x, z)
	local dotCorners: GradientDTContainer = dCorners(topLeft, topRight, bottomLeft, bottomRight, x,z) -- Dot product of gradient vectors with positions distance vector

	-- interpolation
	local FlatX = x - math.floor(x)
	local FlatZ = z - math.floor(z)	
	
	-- lerp 
	local bottom = math.lerp(dotCorners.BottomLeft, dotCorners.BottomRight, PerlinFade(FlatX))
	local top = math.lerp(dotCorners.TopLeft, dotCorners.TopRight, PerlinFade(FlatX))
	local final = math.lerp(bottom, top, PerlinFade(FlatZ))
	
	return math.clamp(final, -1, 1)
end

type GradientDTContainer = { -- Containing all dot products of corner
	TopLeft: number,
	TopRight: number,
	BottomLeft: number,
	BottomRight: number
}

type GridPosition = {
	gx: number,
	gz: number
}

-- TODO: Grid Definition
local GradientSet = { -- Set of all possible gradient vectors, every value represents a differently orientated vector
	{1, 1},  -- Top Right
	{-1, 1}, -- Top Left
	{1, -1}, -- Bottom Right
	{-1, -1}, -- Bottom Left
	{1, 0}, -- Right
	{-1, 0}, -- Left
	{0, 1}, -- Up
	{0, -1}, -- Down
}

function dCorners(tl: GridPosition, tr: GridPosition, bl: GridPosition, br: GridPosition, x: number, z: number): GradientDTContainer
	-- Get corner-position displacement, Hash the corner's vector and do the dot product
	
	local TLOrientation = GradientOrientation(tl)
	local TROrientation = GradientOrientation(tr)
	local BLOrientation = GradientOrientation(bl)
	local BROrientation = GradientOrientation(br)
	
	local TopLeftDT = (x - tl.gx) * TLOrientation[1] + (z - tl.gz) * TLOrientation[2]
	local TopRightDT = (x - tr.gx) * TROrientation[1] + (z - tr.gz) * TROrientation[2]
	local BottomLeftDT = (x - bl.gx) * BLOrientation[1] + (z - bl.gz) * BLOrientation[2]
	local BottomRightDT = (x - br.gx) * BROrientation[1] + (z - br.gz) * BROrientation[2]
	
	local Container: GradientDTContainer = {
		TopLeft = TopLeftDT,
		TopRight = TopRightDT,
		BottomLeft = BottomLeftDT,
		BottomRight = BottomRightDT
	}
	return Container
end

function Corners(x: number, z: number): {GridPosition}
	-- Get the 4 corners of the position's square
	local topLeft: GridPosition = {
		gx = math.floor(x),
		gz = math.floor(z) + 1
	}
	
	local topRight: GridPosition = {
		gx = math.floor(x) + 1,
		gz = math.floor(z) + 1
	}
	
	local bottomLeft: GridPosition = {
		gx = math.floor(x),
		gz = math.floor(z)
	}
	
	local bottomRight: GridPosition = {
		gx = math.floor(x) + 1,
		gz = math.floor(z)
	}

	return topLeft, topRight, bottomLeft, bottomRight
end

function PerlinFade(n: number)
	local t = n - math.floor(n)
	return 6 * t^5 - 15 * t^4 + 10 * t^3
end

function GradientOrientation(corner: GridPosition)
	return GradientSet[PositionHash(corner.gx, corner.gz) % #GradientSet + 1]
end

function PositionHash(x, z)
	local n = bit32.bxor(x * 374761393, z * 668265263)
	n = bit32.bxor(n, bit32.rshift(n, 13))
	n = n * 1274126177
	n = bit32.bxor(n, bit32.rshift(n, 16))
	return bit32.band(n, 0x7fffffff)
end

return Noise2D
