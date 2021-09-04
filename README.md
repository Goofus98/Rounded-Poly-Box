# Rounded Poly Box/Border
This addon allows you to create rounded boxes and borders using surface.drawpoly.

# Rounded Poly Box: 
This works just like the gmod's draw.roundedboxEX except the pivot point is located at the center of the shape.

Prec defines the number of slices you want for a rounded corner.
u & v are for uv tiling & cache makes the function return a table of the calculated shape
(use whenever you can for better performance).
```Lua
--[[Prec defines the number of slices you want for a rounded corner.
u & v are for uv tiling & cache makes the function return a table
of the calculated shape (use whenever you can for better performance).]]--

draw.RoundedPolyBoxEX( radius, x, y, w, h, prec, u=1, v=1, tl=true, tr=true, bl=true, br=true, cache=false )
```
Cache usage:
```Lua
local box = draw.RoundedPolyBoxEX( 124, 0, 0, 256, 256, 5, 1, 1, true, true, true, true, true )

--in drawing hook:
for i = 1, #box do
  surface.DrawPoly( box[i] )
end
```

# Rounded Poly Border:
This compliments Poly Box by creating an outline around it, but you can use it for other purposes too.

```Lua
--[[Prec defines the number of slices you want for a rounded corner.
Extrude defines the outline width. u & v are for uv tiling, u_offset &
v_offset take a value from -1 to 1.]]--

draw.RoundedPolyBorderEX( radius, extrude, x, y, w, h, prec, u=1, v=1, u_offset=0, v_offset=0, tl=true, tr=true, bl=true, br=true, cache=false )
```
Cache usage:

```Lua
local outline = draw.RoundedPolyBorderEX( 124, 24, 0, 0, 256 , 256, 10, 1, 1, 0, 0,  true, true, true, true, true )

--in drawing hook
for i = 1, #outline do
  surface.DrawPoly( outline[i] )
end
```

# NOTE
Really use the cache for something like this since drawing this is way more expensive. Watch out for too narrow bends this can lead to uv anomalies. Seams are going to exist of course though I only noticed them when I applied a scrolling texture and tanked my fps to 35.

I like to use this for making rounded or circular gauges/progress bars using RT textures.

# Showcase:
![alt text](https://i.imgur.com/mi0wzJH.gif)
![alt text](https://i.imgur.com/etKutro.jpg)
![alt text](https://i.imgur.com/mXxjUDm.jpg)
![alt text](https://i.imgur.com/zqRZNb8.jpg)


