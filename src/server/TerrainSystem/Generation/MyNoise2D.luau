local Noise2D = {}

function Noise2D.Fractal(octaves: number, x, z, persistence: number, lacunarity: number, scale: number)
	-- The sum of our octaves
	local value = 0 
	local totalAmplitude = 0

	-- These coordinates will be scaled the lacunarity
	local x1 = x 
	local z1 = z

	-- Determines the effect of each octave on the previous sum
	local amplitude = 1
	local inverseScale = 1 / scale

	for i = 1, octaves, 1 do
		-- Multiply the noise output by the amplitude and add it to our sum
		value += math.noise(x1 * inverseScale, z1 * inverseScale) * amplitude
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

	return math.clamp(value, -1, 1)
end


return Noise2D
