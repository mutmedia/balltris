local Load = {}

function Load.luafiles(...)
  local ok, chunk, result
  for _, path in pairs({...}) do
    ok, chunk = pcall(love.filesystem.load, path)
    if not ok then
      print('ERROR: An error happened while loading '..path..' :'..tostring(chunk))
    elseif not chunk then
      print('ERROR: File '..path..' could not be loaded')
    else
      chunk()
      if not ok then
        print('ERROR: An error happened while executing '..path..' :'..tostring(result))
      end
    end
  end
end

return Load
