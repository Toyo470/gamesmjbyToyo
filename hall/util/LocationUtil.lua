

local LocationUtil = class("LocationUtil")

function LocationUtil:getDistance(lat1,lng1,lat2,lng2)

	local radLat1 = self:rad(lat1)
	local radLat2 = self:rad(lat2)

	local a = radLat1 - radLat2
	local b = self:rad(lng1) - self:rad(lng2)

	local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2) , 2) + math.cos(radLat1) * math.cos(radLat2) * math.pow(math.sin(b / 2), 2)))
	s = s * 6378137   -- 米
	-- s = math.round(s * 10000) / 1000

	s = math.floor(s)

	-- s = s / 10

	return s
	
end

function LocationUtil:rad(d)

	return d * math.pi / 180.0;
	
end

return LocationUtil