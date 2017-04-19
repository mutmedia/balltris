--local DEBUGGER_MODE = true
local MAX_LINES = 10

DEBUGGER = {
  text = '',
}

function DEBUGGER.draw()
  if DEBUGGER_MODE then
    love.graphics.setColor({255, 0, 255, 255})
    love.graphics.print('DEBUGGER:\n'..DEBUGGER.text, 10, 150)
  end
end

function DEBUGGER.line(text)
  DEBUGGER.text = DEBUGGER.text..text..'\n'
  local i = 0
  local newSplit = {}
  local _, count = DEBUGGER.text:gsub('\n', '\n')
  if count > MAX_LINES then
    local line1 = string.find(DEBUGGER.text, '\n')
    DEBUGGER.text = string.sub(DEBUGGER.text, line1 + 1)
  end
end

function DEBUGGER.clear()
  DEBUGGER.text = ''
end
