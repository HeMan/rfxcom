---
--------------------------------------------------------------------------------
--         FILE:  parse.lua
--        USAGE:  require "parse"
--  DESCRIPTION:  Read data from rfxcom
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:   (), <>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-05-22 21:58:56 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

local bit = require "bit"
local M = {}
local parsers = {}

--- Function to convert indata from binary "string" to table of values
-- First byte is datatype
-- Rest of bytes is binary data from the RFXcom USB tranciever
-- @param indata the binary "string" from RFXcom
-- @return pair of data consisting of datatype and table with data

function tableconvert(indata)
	local datatype = string.byte(indata:sub(1,1))
	local t = { indata:byte(2, #indata) }
	return datatype,t
end

function parsesome(indata, subtypes, idbytes)
	local t = {}
	local bytes = 0
	local id = 0
	t['subtype']=indata[1]
	t['subname']=subtypes[indata[1]]
	t['seqnr']=indata[2]
	while (bytes < idbytes) do
		print(id, bytes)
		id=bit.lshift(id,8)+indata[3+bytes]
		bytes=bytes+1
	end
	t['id']=id
	return t
end

parsers[0x11]=function(indata)
	local t = {}
	local subtypes = { [0]='AC', 'HomeEasy EU', 'ANSLUT' }
	local commands = { [0]='Off', 'On', 'Set leve', 'Group off', 'Group on','Set group level' }
	t=parsesome(indata, subtypes, 4)

	t['unitcode']=indata[7]
	t['cmnd']=indata[8]
	t['command']=commands[indata[8]]
	t['level']=indata[9]
	t['rssi']=bit.band(indata[10],0x0F)
	return t
end

parsers[0x50]=function(indata)
	local t = {}
	local subtypes = {"THR128/138, THC138", 
	"THC238/268,THN132,THWR288,THRN122,THN122,AW129/131",
	"THWR800","RTHN318","La Crosse TX3, TX4, TX17",
	"TS15C","Viking 02811","La Crosse WS2300","RUBiCSON",
	"TFA 30.3133"}
	t=parsesome(indata,subtypes,2)

	t['temp']=((bit.band(indata[5],0x7F))*256+indata[6])/10
	if (bit.band(indata[5],0x80)==0x80) then
		t['temp']=-t['temp']
	end
	t['tempraw']=indata[5]*256+indata[6]
	t['battery']=bit.rshift(indata[7],4)
	t['rssi']=bit.band(indata[7],15)

	return t
end

function M.parse(data)
	datatype, mytable = tableconvert(data)
	if parsers[datatype] then
		realdata = parsers[datatype](mytable)
		return(realdata)
	else
		return(nil)
	end
end

return M
