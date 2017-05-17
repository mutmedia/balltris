local Load = {}

function Load.luafiles(...)
  local ok, chunk, result
  for _, path in pairs({...}) do
    Load.luafile(path)
  end
end

function Load.luafile(path)
  ok, chunk = pcall(love.filesystem.load, path)
  if not ok then
    print('LOAD ERROR: An error happened while loading '..path..' :'..tostring(chunk))
  elseif not chunk then
    print('LOAD ERROR: File '..path..' could not be loaded')
  else
    -- will let chunk errors pass through
    return chunk()
  end
end

return Load
