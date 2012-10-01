---
--------------------------------------------------------------------------------
--         FILE:  encode.lua
--        USAGE:  require "encode"
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

local E = {}

--- Splits number to bytes
-- Internal function to split a large number to bytes
-- @param id the number to be splitted
-- @param idbytes the number of bytes it represents
-- @return a binary "string" of the id, size idbytes

local function splitid(id, idbytes)
  local bytes = 0
  local idstring = ''
  while bytes < idbytes do
    print(id)
    idstring = string.char(bit.band(id, 0xFF))..idstring
    id = bit.rshift(id, 8)
    bytes = bytes + 1
  end -- while more bytes
  return idstring
end ----------  end of function splitid  ----------


--- builds binary blob
-- Internal function to take integers, strings and tables and serialize them
-- to a binary "string" and add length as first character
-- @param arg an table that could contain integers, strings or tables
-- @return a binary "string" with first charcter representing lenght

local function build ( arg )
  local blob = ''
  local function untable ( arg )
    local str = ''
    for _, val in pairs(arg) do
      print(type(val))
      if type(val) == "table" then
        str = str..untable(val)
      elseif type(val) == "string" then
        str = str..val
      else
        str = str..string.char(val)
      end -- if type
    end -- end loop
    return str
  end  ----------  end of function untable  ----------
  blob = untable(arg)
  return string.char(string.len(blob))..blob
end  ----------  end of function build  ----------

--- Creates reset message
-- This creates a reset message for the RFXcom
-- @return a binary "string"

function M.reset()
  return build{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end  ----------  end of function M.reset  ----------

--- Creates get status message
-- This creates a message that asks for the RFXcom status
-- @return a binary "string"

function M.get_status()
  return build{0, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end  ----------  end of function M.get_status  ----------

--- Creates enable all message
-- This creates a messa ge that ask the RFXcom to turn on all it's
-- known protocols.
-- @return a binary "string"

function M.enable_all ()
  return build{0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end  ----------  end of function M.enable_all  ----------

--- Creates enable undecoded message
-- The RFXcom could read some protocolls that it hasn't got a decoder for.
-- This is by default turned off, but this message turns it on.
-- @return a binary "string"

function M.enable_undecoded ()
  return build{0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end  ----------  end of function M.enable_undecoded  ----------

--- Creates message for LIGHTNING1 (0x10) protocol
-- Encodes a message to control LIGHTNING1 devices
-- @param subtype the type of the device
-- @param housecode the group selector on the device group
-- @param unitcode the device selector on the device
-- @param command the command to send
-- @return a binary "string"

E[LIGHTNING1] = function(subtype, housecode, unitcode, command)
  return buid{LIGHTNING1, subtype, 0, housecode, unitcode, command, 0}
end ----------  end of function E[LIGHTNING1]  ----------

--- Creates message for LIGHTNING2 (0x11) protocol
-- Encodes a message to control LIGHTNING2 devices
-- @param subtype the type of the device
-- @param id the group selector for the device group
-- @param unitcode the the device selector for the device
-- @param command the command to send
-- @param level the level to fade to
-- @return a binary "string"

E[LIGHTNING2] = function(subtype, id, unitcode, command, level)
  return build{LIGHTNING2, subtype, 0,splitid(id, 4),unitcode, command, level, 0}
end ----------  end of function E[LIGHTNING2]  ----------

M.encode = E
return M

