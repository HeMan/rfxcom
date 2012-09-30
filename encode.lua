--
--------------------------------------------------------------------------------
--         FILE:  encode.lua
--        USAGE:  ./encode.lua 
--  DESCRIPTION:  Encoding library for rfxcom
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:   (), <>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-09-25 20:06:35 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--
local bit = require "bit"

require "common"

local M = {}

local encoders = {}

function splitid(id, idbytes)
	local bytes = 0
	local idstring = ''
	while bytes < idbytes do
		print(id)
		idstring = string.char(bit.band(id, 0xFF))..idstring
		id = bit.rshift(id, 8)
		bytes = bytes + 1
	end
	return idstring
end

function addlen(data)
	return string.char(string.len(data))..data
end

function M.reset()
	return addlen(string.char(0,0,0,0,0,0,0,0,0,0,0,0,0))
end  ----------  end of function reset  ----------

function M.get_status()
	return addlen(string.char(0,0,1,2,0,0,0,0,0,0,0,0,0))
end  ----------  end of function get_status  ----------

encoders[LIGHTNING1] = function(subtype, housecode, unitcode, command)
	return addlen(string.char(LIGHTNING1, subtype, 0)..housecode..string.char(unitcode, command, 0))
end

encoders[LIGHTNING2] = function(subtype, id, unitcode, command, level)
	return addlen(string.char(LIGHTNING2, subtype, 0)..splitid(id, 4)..string.char(unitcode, command, level, 0))
end

M.encoders = encoders
return M

