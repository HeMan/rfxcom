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
require "common"

local M = {}
local parsers = {}

--- Function to convert indata from binary "string" to table of values
-- First byte is datatype
-- Rest of bytes is binary data from the RFXcom USB tranciever
-- @param indata the binary "string" from RFXcom
-- @return pair of data consisting of datatype and table with data

function tableconvert(indata)
	local datatype = string.byte(indata:sub(1, 1))
	local t = { indata:byte(2, #indata) }

	return datatype, t
end

--- Function to reduce boilerplate code
-- Returns the subtype and id from indata
-- @param indata is the unparsed data
-- @param subtypes is an array of subtypes
-- @return returns table with subtype, subname, seqnr and id

function parsesome(indata, subtypes, idbytes)
	local t = {}
	local bytes = 0
	local id = 0

	t['subtype'] = indata[1]
	t['subname'] = subtypes[indata[1]]
	t['seqnr'] = indata[2]

	while (bytes < idbytes) do
		id = bit.lshift(id, 8) + indata[3 + bytes]
		bytes = bytes + 1
	end

	t['id'] = id

	return t
end

--- Parse interface info
-- Parses the interfce info and return info about the RFXcom
-- @param indata is "raw" data in a table
-- @return table with info about the RFXcom

parsers[INTERFACE] = function(indata)
	local t = {}

	local rectrans = { [0x50] = "310MHz", "315MHz", 
			"433.92MHz receiver only", "433.92MHz transceiver",
			"868.00MHz", "868.00MHz FSK", "868.30MHz", 
			"868.30MHz FSK", "868.35MHz", "868.35MHz FSK",
			"868.95MHz" }

	t['type'] = rectrans[indata[4]]
	t['typeraw'] = indata[4]
	t['fw version'] = indata[5]

	return t
end

--- Parses status message from receiver
parsers[RECEIVERTRANSMITTER] = function(indata)
	local t = {}

	local response = { [0x00] = 'ACK, transmit OK',
			'ACK, but transmit started after 3 seconds delay anyway with RF receive data',
			'NAK, transmitter did not lock on the requested transmit frequency',
			'NAK, AC address zero in id1-id4 not allowed' }

	t['subtype'] = indata[1]
	t['seq'] = indata[2]
	t['message'] = response[indata[3]]
	t['msgraw'] = indata[3]

	return t
end

--- Parses data from remote
-- Parses data from remote of type 0x11
-- @param indata is "raw" data in a table
-- @return table with remote command

parsers[LIGHTNING2] = function(indata)
	local t = {}

	local subtypes = { [0] = 'AC', 'HomeEasy EU', 'ANSLUT' }
	local commands = { [0] = 'Off', 'On', 'Set leve', 'Group off', 'Group on','Set group level' }

	t = parsesome(indata, subtypes, 4)

	t['unitcode'] = indata[7]
	t['cmnd'] = indata[8]
	t['command'] = commands[indata[8]]
	t['level'] = indata[9]
	t['rssi'] = bit.band(indata[10], 0x0F)

	return t
end

--- Parses data from temp sensors
-- Parses the data from temp sensors (type 0x50)
-- @param indata is "raw" data in a table
-- @return table with temp, battery status and radio level

parsers[TEMP] = function(indata)
	local t = {}
	local subtypes = { "THR128/138, THC138", 
	"THC238/268, THN132, THWR288, THRN122, THN122, AW129/131",
	"THWR800","RTHN318","La Crosse TX3, TX4, TX17",
	"TS15C", "Viking 02811", "La Crosse WS2300", "RUBiCSON",
	"TFA 30.3133" }

	t = parsesome(indata, subtypes, 2)

	t['tempraw'] = indata[5]*256 + indata[6]
	t['temp'] = ((bit.band(indata[5], 0x7F))*256 + indata[6])/10

	if (bit.band(indata[5], 0x80) == 0x80) then
		t['temp'] = -t['temp']
	end

	t['battery'] = bit.rshift(indata[7], 4)
	t['rssi'] = bit.band(indata[7], 15)

	return t
end

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
	end
end

return M
