------------------------------------------------------------------------------
-- Broker_ProfessionsMenu                                                   --
-- Author: Yargoro@Arathor-EU												--
-- Former Author: Sanori/Pathur                                             --
------------------------------------------------------------------------------
local ADDON = select(2,...)				--Includes all functions and variables
local MODNAME = "Broker_ProfessionsMenu"
local _

ADDON.name = MODNAME 
ADDON.debug = string.find(GetAddOnMetadata(MODNAME,"X-Debug"),"true") and true or false
ADDON.version = "|cFF33FF99Version:"..GetAddOnMetadata(MODNAME, "Version").."|r"..(ADDON.debug and " (Debug)" or "")

--addon specific function

local C =   --common
{
    tableCopy = function(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in pairs(orig) do
                copy[orig_key] = orig_value
            end
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end,

    tableClone = function(org)
        return {table.unpack(org)}
    end,

    tableMerge = function(t1, t2)
        for k,v in pairs(t2) do
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    tableMerge(t1[k] or {}, t2[k] or {})
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
        return t1
    end,
}

local D =   --debug
{
    Debug = function(self,msg,...)
        if ADDON.debug and DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage(ADDON.name .. " (dbg): " .. string.format(msg,...), 1.0, 0.37, 0.37)
        end
    end, 
    
    --Table helper functions 
    
    -- Print contents of `tbl`, with indentation. indent` sets the initial level of indentation.
    tprint = function(self,tbl, indent)
        if not indent then indent = 0 end
        for k, v in pairs(tbl) do
            local formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                self:Debug(formatting)
                self:tprint(v, indent+1)
            elseif type(v) == 'boolean' then
                self:Debug(formatting .. tostring(v))      
            else
            self:Debug(formatting .. v)
            end
        end
    end,
}

local OR  = 1
local XOR = 3
local AND = 4

local BitEnum = 
{
    VALUE = 0,

    bitoper = function(a, b, oper)
        local r, m, s = 0, 2^52
        repeat
            s,a,b = a+b+m, a%m, b%m
            r,m = r + m*oper%(s-a-b), m/2
        until m < 1
        return r
    end,

    add = function(...)
        local self = select(1,...)
        local arg ={...}
        for i = 2, #arg do
            self.VALUE = self.bitoper(self.VALUE,arg[i],OR)
        end        
    end,

    set = function(self,bit)
        self.VALUE = bit
    end,

    clr = function(self,bit)
        self.VALUE = self.bitoper(self.VALUE,bit,XOR)
    end,

    is = function(self,bit)
        return self.bitoper(self.VALUE,bit,AND) == bit 
    end,
}

ADDON.C = C
ADDON.D = D

ADDON.ProfSortOptions = 
{
    Alphabetical                = 1,
    PrimarySecondary            = 2,
    Unsorted                    = 4,

    IncludeCharacterSpecific    = 8,
    IncludeExpansionRanks       = 16,
    IncludeSpells               = 32,
    IncludeExpansionName        = 64,
    
    new = function(...)
        local arg ={...}
        local o = C.tableMerge(C.tableCopy(arg[1]),BitEnum)   -- create object if user does not provide one
        table.remove(arg,1)
        o:add(unpack(arg))
        return o
    end,
}
