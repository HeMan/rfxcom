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

function M.reset()
	return string.char(0,0,0,0,0,0,0,0,0,0,0,0,0)
end  ----------  end of function reset  ----------


function M.get_status()
	return string.char(0,0,1,2,0,0,0,0,0,0,0,0,0)
end  ----------  end of function get_status  ----------

encoders[LIGHTNING2] = function(subtype, id, unitcode, command)
	return string.char(LIGHTNING2, subtype, 0)..splitid(id, 4)..string.char(unitcode, command, 0, 0)
end

function M.encode(package)
	return string.char(string.len(package))..package
end  ----------  end of function M.encode  ----------

M.encoders = encoders
return M

