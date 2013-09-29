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
LIGHTING3 = 0x12
LIGHTING4 = 0x13
LIGHTING5 = 0x14
LIGHTING6 = 0x15
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

LIGHTING1 = { ["ID"] = 0x10,
              ["SUBTYPES"] = { [0x00] = 'X10 lighting', 'ARC',
                               'ELRO AB400D (Flamingo)', 'Waveman',
                               'Chacon EMW200', 'IMPULS', 'RisingSun',
                               'Philips SBC' },
              ["COMMANDS"] = { [0x00] = 'Off', 'On', 'Dim', 'Bright',
                                        'All/group off', 'All/group on',
                                        'Chime', [0xFF]='Illigal command' },
             }

LIGHTING2 = { ["ID"] = 0x11,
              ["SUBTYPES"] = { [0] = 'AC', 'HomeEasy EU', 'ANSLUT' },
              ["COMMANDS"] = { [0] = 'Off', 'On', 'Set level', 
                                     'Group off', 'Group on','Set group level' }
        }

TEMP = { ["ID"] = 0x50,
         ["SUBTYPES"] = { "THR128/138, THC138", 
                          "THC238/268, THN132, THWR288, THRN122, THN122, AW129/131",
                          "THWR800", "RTHN318", "La Crosse TX3, TX4, TX17",
                          "TS15C", "Viking 02811", "La Crosse WS2300", 
              "RUBiCSON", "TFA 30.3133" }
          }

TEMPHUM = { ["ID"] = 0x51,
            ["SUBTYPES"] ={ [0x01] = "THGN122/123, THGN132, THGR122/228/238/268",
                            "THGR810, THGN800", "RTGR328", "THGR328", "WTGR800",
                            "THGR918, THGRN228, THGN500", "TFA TS34C, Cresta", 
                            "WT260,WT260H,WT440H,WT450,WT450H",
                            "Viking 02035,02038" },
        ["HUMSTATUS"] = { [0x00] = "Dry", "Comfort", "Normal", "Wet" }
          }






-- INTERFACE CONTROLL types
-- msg3
msg3 = {
  ["UNDECODED"] = 0x80, ["RFU6"] = 0x40, ["RFU5"] = 0x20,
  ["RSL"] = 0x10, ["Lighting4"] = 0x08, ["Viking"] = 0x04,
  ["Rubicson"] = 0x02, ["AEBlyss"] = 0x01,
}

msg4 = {
  ["BlindsT1234"] = 0x80, ["BlindsT0"] = 0x40, ["Proguard"] = 0x20,
  ["FS20"] = 0x10, ["LaCrosse"] = 0x08, ["Hideki"] = 0x04,
  ["ADLightwaveRF"] = 0x02, ["Mertik"] = 0x01,
}

msg5 = {
  ["Visonic"] = 0x80, ["ATI"] = 0x40, ["OregonScientific"] = 0x20,
  ["Meiantech"] = 0x10, ["HomeEasyEU"] = 0x08, ["AC"] = 0x04,
  ["ARC"] = 0x02, ["X10"] = 0x01,
}
