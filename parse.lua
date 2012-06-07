--
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

local M = {}
local parsers = {}
function tableconvert(indata)
	local datatype = string.byte(indata:sub(1,1))
	local t = { indata:byte(2, #indata) }
	return datatype,t
end

parsers[17]=function(indata)
	local t = {}
	local subtypes = { [0]='AC', 'HomeEasy EU', 'ANSLUT' }
	local commands = { [0]='Off', 'On', 'Set leve', 'Group off', 'Group on','Set group level' }
	t['subtype']=indata[1]
	t['subname']=subtypes[indata[1]]
	t['seqnr']=indata[2]
	t['id']=indata[3]*16777216+indata[4]*65535+indata[5]*256+indata[6]
	t['unitcode']=indata[7]
	t['cmnd']=indata[9]
	t['command']=commands[indata[8]]
	t['level']=indata[9]
	t['rssi']=indata[10]
	return t
end

parsers[80]=function(indata)
	local t = {}
	local subtypes = {"THR128/138, THC138", 
	"THC238/268,THN132,THWR288,THRN122,THN122,AW129/131",
	"THWR800","RTHN318","La Crosse TX3, TX4, TX17",
	"TS15C","Viking 02811"}
	t['subtype']=indata[1]
	t['subname']=subtypes[indata[1]]
	t['seqnr']=indata[2]
	t['id']=indata[3]*256+indata[4]
	t['temp']=((indata[5])*256+indata[6])/10
	t['tempraw']=indata[5]*256+indata[6]
	t['battery']=(indata[7])/16
	t['rssi']=indata[7]

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
