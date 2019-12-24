function GetColorFromHSV(h, s, v, a)
  local a = a or 1

  local c = v * s
  local x = c * (1-math.abs((h/60)%2 -1))
  local m = v - c
  local hdiv = math.floor(h/60)

  local HSVtoRGBt = {
    {c, x, 0},
    {x, c, 0},
    {0, c, x},
    {0, x, c},
    {x, 0, c},
    {c, 0, x}
  }

  local rr, gg, bb = unpack(HSVtoRGBt[hdiv + 1])

  local r = (rr + m) * 1
  local g = (gg + m) * 1
  local b = (bb + m) * 1

  return {r, g, b, a}
end

