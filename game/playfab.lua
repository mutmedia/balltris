local socket = require 'socket'


local PlayFabSettings = {
  TitleId = '1BA2'
}


local PlayFab = {}

function PlayFab.connect()
  local systemOS= love.system.getOS()
  if systemOS == 'Android' then
    
  else 
    PlayFab.sessionTicket = PlayFab.LoginWithCustomID('8fa79815413d472d')
  end
end
