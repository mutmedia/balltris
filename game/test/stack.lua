local Stack = require 'lib/stack'
local test = Stack.New()

local print = function(str)
  print('STACK TEST: '..(str or ''))
end

print('Pushing 10')
test:push(10)
print('Stack top = '..test:peek())

print('Adding 1 to 9')
for i=1,9 do
  test:push(i)
end

print('Stack top = '..test:peek())
print('Stack top = '..test:peek())

local t = test:pop()
while t do
  print('Popping '..t)
  t = test:pop()
end
print('stack empty')

print('peeking at empty stack: '..(test:peek() == nil and 'nil' or 'error'))

