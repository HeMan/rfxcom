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

local M = {}

local encoders = {}

function M.reset()
	return string.char(0,0,0,0,0,0,0,0,0,0,0,0,0)
end  ----------  end of function reset  ----------


function M.get_status()
	return string.char(0,0,1,2,0,0,0,0,0,0,0,0,0)
end  ----------  end of function get_status  ----------


function M.encode(package)
	return string.char(string.len(package))..package
end  ----------  end of function M.encode  ----------
return M

