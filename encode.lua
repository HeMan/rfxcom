---
--------------------------------------------------------------------------------
--         FILE:  encode.lua
--        USAGE:  require "encode"
--  DESCRIPTION:  Encoding library for rfxcom
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Jimmy Hedman (), <jimmy.hedman@gmail.com>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-09-25 20:06:35 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--
local bit = require "nixio".bit

require "common"

local M = {}

local E = {}

-----------------------------------------------
-- Base class for sending commands with rfxcom
-- @class table
-- @name Protocol

Protocol = {}

function Protocol:new()
  o = {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end  -----------  end of function Protocol:new  ----------

-------------------------
-- Uses tty to send data
-- @parm data to send
-- @return number of bytes sent
-- @see Protocol
function Protocol:send(data)
-- :TODO:2012-11-30 18:15:07::  Don't use global tty
  return tty:write(data)
end  ----------  end of function Protocol:send  ----------

-----------------------------------------------------------------------------
-- Internal function to take integers, strings and tables and serialize them
-- to a binary "string" and add length as first character
-- @param arg an table that could contain integers, strings or tables
-- @return a binary "string" with first charcter representing lenght
-- @see Protocol

function Protocol:build ( arg )
  local blob = ''
  local function untable ( arg )
    local str = ''
    for _, val in pairs(arg) do
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

------------------------------------------------------
-- Internal function to split a large number to bytes
-- @param id the number to be splitted
-- @param idbytes the number of bytes it represents
-- @return a binary "string" of the id, size idbytes
-- @see Protocol

function Protocol:splitid(id, idbytes)
  local bytes = 0
  local idstring = ''
  while bytes < idbytes do
    idstring = string.char(bit.band(id, 0xFF))..idstring
    id = bit.rshift(id, 8)
    bytes = bytes + 1
  end -- while more bytes
  return idstring
end ----------  end of function splitid  ----------

--- Creates reset message
-- This creates a reset message for the RFXcom
-- @return a binary "string"

function Protocol:reset()
  return self:send(self:build{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
end  ----------  end of function M.reset  ----------

--- Creates get status message
-- This creates a message that asks for the RFXcom status
-- @return a binary "string"

function Protocol:get_status()
  return self:send(self:build{0, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0})
end  ----------  end of function M.get_status  ----------

--- Creates enable all message
-- This creates a messa ge that ask the RFXcom to turn on all it's
-- known protocols.
-- @return a binary "string"

function Protocol:enable_all ()
  return self:send(self:build{0, 0, 0, 3, 0x53, 0, 0x07, 0xBF, 0xFF, 0, 0, 0, 0})
end  ----------  end of function M.enable_all  ----------

--- Creates enable undecoded message
-- The RFXcom could read some protocolls that it hasn't got a decoder for.
-- This is by default turned off, but this message turns it on.
-- @return a binary "string"

function Protocol:enable_undecoded ()
  return self:send(self:build{0, 0, 0, 3, 0x53, 0, 0x87, 0xBF, 0xFF, 0, 0, 0, 0})
end  ----------  end of function M.enable_undecoded  ----------


-------------------------------------------------------------------
-- The baseclass for all lighting protocolls. It has four standard 
-- methods (off, on, groupon and groupoff).
-- Constructor takes command values when default don't work
-- @class table
-- @name Lighting
-- @see Protocol

Lighting = Protocol:new()

function Lighting:new(commands, id)
	o = {}
	setmetatable(o, self)
	self.__index = self
	self.commands = {}
	self.commands.on = commands.on or 1
	self.commands.off = commands.off or 0
	self.commands.groupon = commands.groupon or 6
	self.commands.groupoff = commands.groupoff or 5
	if id then
		self.id = id
	end
	return o
end  ----------  end of function Lighting:new  ----------

--------------------------------------------
-- Abstract function for regular operations
-- @parm id is a table with id of the receiver
-- @parm command on/off/groupon/groupoff for the receiver
-- @see Lighting

function Lighting:base(command, id)
	assert(false,"Not implemented")
end  ----------  end of function Lighting:base  ----------

--------------------------------
-- Turn on light, base function
-- @parm id is a table with id of the receiver
-- @see Lighting
function Lighting:on(id)
	self:send(self:base(id or self.id, self.commands.on))
end  ----------  end of function Lighting:base  ----------


---------------------------------
-- Turn off light, base function
-- @parm id is a table with id of the receiver
-- @see Lighting
function Lighting:off(id)
	self:send(self:base(id or self.id, self.commands.off))
end  ----------  end of function Lighting:base  ----------


--------------------------------------
-- Turn on light group, base function
-- @parm id is a table with id of the receiver
-- @see Lighting
function Lighting:groupon(id)
	self:send(self:base(id or self.id, self.commands.groupon))
end  ----------  end of function Lighting:base  ----------


---------------------------------------
-- Turn off light group, base function
-- @parm id is a table with id of the receiver
-- @see Lighting
function Lighting:groupoff(id)
	self:send(self:base(id or self.id, self.commands.groupoff))
end  ----------  end of function Lighting:base  ----------

--------------------------------------
-- Implements the LIGHTING1 protocoll
-- @class table
-- @name Lighting1
-- @see Lighting

Lighting1 = Lighting:new({})

-------------------------------------------
-- Override abstract function with code for LIGHTING1 protocol
-- @parm id is a table with id of the receiver
-- @parm command is what command to perform
-- @return blob to send
function Lighting1:base(command, id)
	if self.id then
		id = self.id
	end
	return self:build{LIGHTING1, id.subtype, 0, id.housecode, id.unitcode, command}
end  ----------  end of function Lighting:base  ----------

--------------------------------------
-- Implements the LIGHTING2 protocoll
-- @class table
-- @name Lighting2

Lighting2 = Lighting:new({groupoff=3, groupon=4})

-------------------------------------------
-- Override abstract function with code for LIGHTING2 protocol
-- @parm id is a table with id of the receiver
-- @parm command is what command to perform
-- @return blob to send
-- @see Lighting2
function Lighting2:base(command, id)
	if self.id then
		id = self.id
	end
	return self:build{LIGHTING2, id.subtype, 0, splitid(id.id, 4), id.unitcode, command, 2}
-- :BUG:2012-12-25 22:32:54::  Should it really be "2" as last argument
end  ----------  end of function Lighting:base  ----------

----------------------------------------------------------
-- LIGHTING2 has two extra functions compare to LIGHTING1
-- setlevel is one of them
-- @parm id is a table with id of receiver
-- @see Lighting2
function Lighting2:setlevel(level, id)
	self:send(self:build{LIGHTING2, id.subtype, 0, splitid(id.id, 4), id.unitcode, 2, level})
end  ----------  end of function Lighting:base  ----------


----------------------------------------------------------
-- LIGHTING2 has two extra functions compare to LIGHTING1
-- setgrouplevel is one of them
-- @parm id is a table with id of receiver
-- @see Lighting2
function Lighting2:setgrouplevel(level, id)
	if self.id then
		id = self.id
	end
	self:send(self:build{LIGHTING2, id.subtype, 0, splitid(id.id, 4), id.unitcode, 5, level})
end  ----------  end of function Lighting:base  ----------

M.Protocol = Protocol
M.Lighting = Lighting
M.Lighting1 = Lighting1
M.Lighting2 = Lighting2

return M

