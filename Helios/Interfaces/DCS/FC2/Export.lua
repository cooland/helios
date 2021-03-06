﻿os.setlocale("ISO-8559-1", "numeric")

-- Simulation id
gSimID = string.format("%08x*",os.time())

-- State data for export
gPacketSize = 0
gSendStrings = {}
gLastData = {}

-- Frame counter for non important data
gTickCount = 0

-- DCS Export Functions
function LuaExportStart()
-- Works once just before mission start.
    -- 2) Setup udp sockets to talk to helios
    package.path  = package.path..";.\\LuaSocket\\?.lua"
    package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
   
    socket = require("socket")
    
    c = socket.udp()
	c:setsockname("*", 0)
    c:setpeername(gHost, gPort)
    c:settimeout(.001) -- set the timeout for reading the socket 
end

function LuaExportBeforeNextFrame()
end

function LuaExportAfterNextFrame()	
end

function LuaExportStop()
-- Works once just after mission stop.
    c:close()
end

function LuaExportActivityNextEvent(t)
	local tNext = t + gExportInterval	

	local altBar = LoGetAltitudeAboveSeaLevel()
	local altRad = LoGetAltitudeAboveGroundLevel()
	local pitch, bank, yaw = LoGetADIPitchBankYaw()
	local engine = LoGetEngineInfo()
	local hsi    = LoGetControlPanel_HSI()
	local vvi = LoGetVerticalVelocity()
	local ias = LoGetIndicatedAirSpeed()
	local route = LoGetRoute()
	local myData = LoGetSelfData()
	local aoa = LoGetAngleOfAttack()
	local distanceToWay = 999
	
	local glide = LoGetGlideDeviation()
	local side = LoGetSideDeviation()
	
	if (myData ~= nil) then
		local myLoc = LoGeoCoordinatesToLoCoordinates(myData.LatLongAlt.Long, myData.LatLongAlt.Lat)
		distanceToWay = math.sqrt((myLoc.x - route.goto_point.world_point.x)^2 + (myLoc.y -  route.goto_point.world_point.y)^2)
	end

	if (pitch ~= nill) then
		SendData("1", pitch * 57.3, "%.2f")
		SendData("2", bank * 57.3, "%.2f")
		SendData("3", yaw * 57.3, "%.2f")
		SendData("4", altBar, "%.2f")
		SendData("5", altRad, "%.2f")
		SendData("6", 360 - (hsi.ADF * 57.3), "%.2f")
		SendData("7", 360 - (hsi.RMI * 57.3), "%.2f")
		SendData("8", 360 - (hsi.Compass * 57.3), "%.2f")
		SendData("9", engine.RPM.left, "%.2f")
		SendData("10", engine.RPM.right, "%.2f")
		SendData("11", engine.Temperature.left, "%.2f")
		SendData("12", engine.Temperature.right, "%.2f")
		SendData("13", vvi, "%.2f")
		SendData("14", ias, "%.2f")
		SendData("15", distanceToWay, "%.2f")
		SendData("16", 12 + (aoa * 57.3), "%.2f")
		SendData("17", glide, "%.2f")
		SendData("18", side, "%.2f")

		FlushData()
	end

	return tNext
end

-- Helper Functions
function StrSplit(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Status Gathering Functions
function ProcessArguments(device, arguments)
	local lArgument , lFormat , lArgumentValue
		
	for lArgument, lFormat in pairs(arguments) do 
		lArgumentValue = string.format(lFormat,device:get_argument_value(lArgument))
		SendData(lArgument, lArgumentValue)
	end
end

-- Network Functions
function SendData(id, value)	
	if string.len(value) > 3 and value == string.sub("-0.00000000",1, string.len(value)) then
		value = value:sub(2)
	end
	
	if gLastData[id] ~= value then
		local data =  id .. "=" .. value
		local dataLen = string.len(data)

		if dataLen + gPacketSize > 576 then
			FlushData()
		end

		table.insert(gSendStrings, data)
		gLastData[id] = value	
		gPacketSize = gPacketSize + dataLen + 1
	end	
end

function FlushData()
	if #gSendStrin                                                                                                                                                                                               