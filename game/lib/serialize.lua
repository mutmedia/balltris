function serialize (o)
  local str = {}
  if type(o) == 'number' then
    table.insert(str, o)
  elseif type(o) == 'string' then
    table.insert(str, string.format('%q', o))
  elseif type(o) == 'table' then
    table.insert(str, '{\n')
    for k,v in pairs(o) do
      table.insert(str, '\t['..serialize(k)..'] = ')
      table.insert(str, serialize(v))
      table.insert(str, ',\n')
    end
    table.insert(str, '}\n')
  elseif type(o) == 'boolean' then
    table.insert(str, string.format('%s', o and 'true' or 'false'))
  else
    error('cannot serialize a ' .. type(o))
  end
  return table.concat(str)
end

return serialize

