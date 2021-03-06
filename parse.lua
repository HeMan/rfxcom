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

local bit = require "nixio".bit

local rfxcompath = (...):match("(.-)[^%.]+$") 

require(rfxcompath .. "common")

local M = {}
local parsers = {}

--- Function to convert indata from binary "string" to table of values
-- First byte is datatype
-- Rest of bytes is binary data from the RFXcom USB tranciever
-- @param indata the binary "string" from RFXcom
-- @return pair of data consisting of datatype and table with data

local function tableconvert(indata)
  local datatype = string.byte(indata:sub(1, 1))
  local t = { indata:byte(2, #indata) }

  return datatype, t
end  ----------  end of function tableconvert  ----------


--- Function to reduce boilerplate code
-- Returns the subtype and id from indata
-- @param indata is the unparsed data
-- @param subtypes is an array of subtypes
-- @return returns table with subtype, subname, seqnr and id

local function parsesome(indata, subtypes, idbytes)
  local t = indata
  local bytes = 0
  local id = 0

  t.subtype = indata[1]
  t.subname = subtypes[indata[1]]
  t.seqnr = indata[2]
  if (idbytes > 0) then
    while (bytes < idbytes) do
      id = bit.lshift(id, 8) + indata[3 + bytes]
      bytes = bytes + 1
    end -- while

    t.id = id
  end -- if idbytes

  return t
end ----------  end of function parsesome ----------


--- Parse interface info
-- Parses the interfce info and return info about the RFXcom
-- @param indata is "raw" data in a table
-- @return table with info about the RFXcom

parsers[INTERFACE] = function(indata)
  local t = indata
  local enabled = {}
  local disabled = {}

  local rectrans = { [0x50] = "310MHz", "315MHz",
      "433.92MHz receiver only", "433.92MHz transceiver",
      "868.00MHz", "868.00MHz FSK", "868.30MHz", 
      "868.30MHz FSK", "868.35MHz", "868.35MHz FSK",
      "868.95MHz" }

  local function bitmap(val, map, enabled, disabled)
    local revmap={}
    for k,v in pairs(map) do
      revmap[v]=k
    end

    if (type(val) == "number") then
      for s,c in pairs(revmap) do
        if bit.check(val, s) then
          table.insert(enabled, c)
        else
          table.insert(disabled, c)
        end -- if bit set
      end -- for
    end
    return enabled, disabled
  end ----------  end of function bitmap  ----------


  t.type = rectrans[indata[4]]
  t.typeraw = indata[4]
  t.fwversion = indata[5]
  enabled, disabled = bitmap(indata[6], msg3, enabled, disabled)
  enabled, disabled = bitmap(indata[7], msg4, enabled, disabled)
  enabled, disabled = bitmap(indata[8], msg5, enabled, disabled)
  t.enabled = table.concat(enabled,', ')
  t.disabled = table.concat(disabled,', ')

  return t
end ----------  end of function parsers[INTERFACE]  ----------


--- Parses status message from receiver
-- Parses the status message from receiver/transmitter
-- @param indata is "raw" data in a table
-- @return table with status of lates operation

parsers[RECEIVERTRANSMITTER] = function(indata)
  local t = indata

  local response = { [0x00] = 'ACK, transmit OK',
      'ACK, but transmit started after 3 seconds delay anyway with RF receive data',
      'NAK, transmitter did not lock on the requested transmit frequency',
      'NAK, AC address zero in id1-id4 not allowed' }

  t.subtype = indata[1]
  t.seq = indata[2]
  t.message = response[indata[3]]
  t.msgraw = indata[3]

  return t
end ----------  end of function parsers[RECEIVERTRANSMITTER]  ----------


--- "Parse" unknown data
-- Parse the unknown data message (0x03).
-- @param indata "raw" data in table
-- @return table with the parsable info, rest is raw

parsers[UNDECODEDRF] = function(indata)
  local t = {}

  local subtypes = { [0x00] = 'ac', 'arc', 'ati', 'hideki/upm',
      'lacrosse/viking', 'ad', 'mertik', 'oregon1', 'oregon2',
      'oregon3', 'proguard', 'visonic', 'nec', 'fs20',
      'reserved', 'blinds', 'rubicson',  'ae', 'fineoffset'}

  t = parsesome(indata, subtypes, 0)
  return t
end ----------  end of function parsers[UNDECODEDRF]  ----------


--- Parses data from remote
-- Parses data from remote of type 0x10
-- @param indata is "raw" data in a table
-- @return table with remote command

parsers[LIGHTING1.ID] = function(indata)
  local t = {}
  t = parsesome(indata, LIGHTING1.SUBTYPES, 2)

  t.housecode = string.char(indata[3])
  t.unitcode = indata[4]
  t.command = LIGHTING1.COMMANDS[indata[5]]
  t.rssi = bit.band(indata[6], 0x0F)

  return t

end ----------  end of function parsers[LIGHTING1]  ----------


--- Parses data from remote
-- Parses data from remote of type 0x11
-- @param indata is "raw" data in a table
-- @return table with remote command

parsers[LIGHTING2.ID] = function(indata)
  local t = {}

  t = parsesome(indata, LIGHTING2.SUBTYPES, 4)

  t.unitcode = indata[7]
  t.cmnd = indata[8]
  t.command = LIGHTING2.COMMANDS[indata[8]]
  t.level = indata[9]
  t.rssi = bit.band(indata[10], 0x0F)

  return t
end ----------  end of function parsers[LIGHTING2]  ----------


--- Parses data from temp sensors
-- Parses the data from temp sensors (type 0x50)
-- @param indata is "raw" data in a table
-- @return table with temp, battery status and radio level

parsers[TEMP.ID] = function(indata)
  local t = {}
  t = parsesome(indata, TEMP.SUBTYPES, 2)

  t.tempraw = indata[5]*256 + indata[6]
  t.temp = ((bit.band(indata[5], 0x7F))*256 + indata[6])/10

  if (bit.band(indata[5], 0x80) == 0x80) then
    t.temp = -t.temp
  end -- if negative

  t.battery = bit.rshift(indata[7], 4)
  t.rssi = bit.band(indata[7], 0x0F)

  return t
end ----------  end of function parsers[TEMP]  ----------

--- Parses data from temp and humidity sensors
-- Parses the data from temp sensors (type 0x52)
-- @param indata is "raw" data in a table
-- @return table with temp, humidity, battery status and radio level

parsers[TEMPHUM.ID] = function(indata)
  local t = {}

  t = parsesome(indata, TEMPHUM.SUBTYPES, 2)

  t.tempraw = indata[5]*256 + indata[6]
  t.temp = ((bit.band(indata[5], 0x7F))*256 + indata[6])/10

  if (bit.band(indata[5], 0x80) == 0x80) then
    t.temp = -t.temp
  end -- if negative

  t.humidity = indata[7]
  t.humstatus = TEMPHUM.HUMSTATUS[indata[8]]

  t.battery = bit.rshift(indata[9], 4)
  t.rssi = bit.band(indata[9], 0x0F)

  return t
end  ----------  end of function parsers[TEMPHUM]  ----------

--- Parses the raw data
-- Takes the raw data and converts it in to a table
-- If the datatype represents an type that is implemented
-- it calls the parsing function for that
-- @param data is raw data from the RFXcom
-- @return a table of parsed data and nil if datatype is not implemented

function M.parse(data)
  local datatype, mytable = tableconvert(data)
  if parsers[datatype] then
    realdata = parsers[datatype](mytable)
    return(realdata)
  else
    return(nil)
  end -- if exists
end ----------  end of function m.parse  ----------


return M
