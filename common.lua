--
--------------------------------------------------------------------------------
--         FILE:  common.lua
--        USAGE:  ./common.lua 
--  DESCRIPTION:  Common definitions for both encode and decode
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:   (), <>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-09-29 10:00:24 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

INTERFACE = 0x01
RECEIVERTRANSMITTER = 0x02
UNDECODEDRF = 0x03
LIGHTNING1 = 0x10
LIGHTNING2 = 0x11
LIGHTNING3 = 0x12
LIGHTNING4 = 0x13
LIGHTNING5 = 0x14
LIGHTNING6 = 0x15
CURTAIN1 = 0x18
BLINDS1 = 0x19
SECURITY1 = 0x20
CAMERA1 = 0x28
REMOTE = 0x30
THERMOSTAT1 = 0x40
THERMOSTAT2 = 0x41
THERMOSTAT3 = 0x42
TEMP = 0x50
HUMIDITY = 0x51
TEMPHUM = 0x52
BAROMETRIC = 0x53
TEMPHUMBAR = 0x54
RAIN = 0x55
WIND = 0x56
UV = 0x57
DATETIME = 0x58
CURRENT = 0x59
ENERGY = 0x5A
GAS = 0x5B
WATER = 0x5C
WEIGHT = 0x5D
RFXSENSOR = 0x70
RFXMETER = 0x71
FS20 = 0x72

-- LIGHTNING1 subtypes
X10LIGHTNING = 0x00
ARC = 0x01
ELROAB400D = 0x02
WAVEMAN = 0x03
CHACONEMW200 = 0x04
IMPULS = 0x05
RISINGSIN = 0x06
PHILIPSSBC = 0x07

-- LIGHTNING2 subtypes
AC = 0x00
HOMEEASYEU = 0x01
ANSLUT = 0x02
