manager = nil

function createHttRq( data_tbl,url )
	-- body
	if manager ~= nil then
		return manager:createHttRq(data_tbl,url)
	end
end