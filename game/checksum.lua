require 'data_constants'
local Load = require 'lib/load'
local Serialize = require 'lib/serialize'
local SecretHash = require 'password' or function() return 'no hash' end

local CHECKSUMS_PATH = 'checksums_v'..VERSION..'.lua'

local checksums = nil

local error = function(str)
  print('CHECKSUM ERROR: '..(str or ''))
end

local function LazyLoad()
  if checksums then return end
  local ok
  ok, checksums = Load.luafile(CHECKSUMS_PATH)
  if not ok then
    error('Could not find checksum file')
  end
  checksums = checksums or {}
end

local function SaveChecksums()
  local checksumString = string.format('return %s', serialize(checksums))
  local file, errorstr = love.filesystem.newFile(CHECKSUMS_PATH, 'w') 
  if errorstr then 
    error(errorstr)
    return 
  end

  local s, err = file:write(checksumString)
  if err then
    error(err)
  end
end

local function AddChecksum(key, value)
  LazyLoad()
  checksums[key] = SecretHash(value)
  SaveChecksums()
end

local function DoChecksum(key, value)
  LazyLoad()
  if not checksums[key] then return false end
  return checksums[key] == SecretHash(value)
end

function SaveWithChecksum(path, data)
  local file, errorstr = love.filesystem.newFile(path, 'w') 
  if errorstr then 
    error(errorstr)
    return 
  end

  local s, err = file:write(data)
  if err then
    error(err)
  end
  AddChecksum(path, data)
end

function LoadWithChecksum(path)
  local data = love.filesystem.read(path)
  if not data then return false, nil end
  if DoChecksum(path, data) then
    return Load.luafile(path)
  end
  return false, nil 
end

return {
  SaveWith = SaveWithChecksum,
  LoadWith = LoadWithChecksum
}




