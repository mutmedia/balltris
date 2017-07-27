local Checksum = require 'checksum'
local Serialize = require 'lib/serialize'

local LOCAL_GAMES_PATH = 'local_games_v'..VERSION..'.lua'
local localGames = nil

local LocalGames = {}

local error = function(str)
  print('LOCAL FILES ERROR: '..(str or ''))
end

local function LazyLoad()
  if localGames then return end
  local ok 
  ok, localGames = Checksum.LoadWith(LOCAL_GAMES_PATH)
  if not ok then
    error('could not load local files')
  end
end

local function SaveAll()
  Checksum.SaveWith(
    LOCAL_GAMES_PATH, 
    string.format('return %s', Serialize(localGames))
    )
end

function LocalGames.AddNew(stats, gamenumber, use)
  LazyLoad()
  local data = {
    username=Game.usernameText,
    game=gamenumber,
    stats=stats,
    version=VERSION,
    synced=false,
    --over=isOver or false,
  }
  localGames = localGames or {}
  table.insert(localGames, data)
  SaveAll()
end

return LocalGames
