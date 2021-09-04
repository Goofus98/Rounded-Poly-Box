local math, surface = math, surface
local cos, sin, min, floor, round, clamp, pi = math.cos, math.sin, math.min, math.floor, math.Round, math.Clamp, math.pi
local drawpoly = surface.DrawPoly
local pi_2, threePi_2 = pi / 2, 3 * pi / 2

function draw.RoundedPolyBoxEX( radius, x, y, w, h, prec, u, v, tl, tr, bl, br, cache )
	if ( prec <= 0 or radius <= 0 or w <= 0 or h <= 0 ) then if !cache then return end return {} end
	local width = w * .5
	local height = h * .5
	radius = min( round( radius ), floor( width ), floor( height ) )
	u, v = u or 1, v or 1
	tl, tr, bl, br = (tl != false), (tr != false), (bl != false), (br != false)
	--Flat UVs
	local part_w = w / radius
	local part_h = h / radius
	local u1 = u / part_w
	local u2 = u1 + ( (w - radius * 2) / w ) * u
	local v1 = v / part_h
	local v2 = v1 + ( ( h - radius * 2 ) / h ) * v

	--Points of rotation
	local p1_x = x - width + radius
	local p1_y = y - height + radius
	local p2_x = x + width - radius
	local p2_y = y + height - radius

	local center = {{ x = p1_x, y = p1_y, u = u1 , v = v1 },
	{ x = p2_x , y = p1_y, u = u2, v = v1 },
	{ x = p2_x, y = p2_y, u = u2, v = v2 },
	{ x = p1_x, y = p2_y, u = u1, v = v2 }}

	--Bridges
	local bl_corner = {{ x = p1_x, y = p2_y, u = u1, v = v2 },
	{ x = p2_x, y = p2_y , u = u2, v = v2 },
	{ x = p2_x, y = y + height , u = u2, v = v },
	{ x = p1_x, y = y + height , u = u1, v = v }}

	local tl_corner = {{ x = p1_x , y = p1_y, u = u1, v = v1 },
	{ x = p1_x, y = p2_y , u = u1, v = v2 },
	{ x = p1_x - radius , y = p2_y , u = 0, v = v2 },
	{ x = p1_x - radius , y = p1_y, u = 0, v = v1 } }

	if (!bl) then
		tl_corner[2].y, tl_corner[3].y = tl_corner[2].y + radius, tl_corner[3].y + radius
		tl_corner[2].v, tl_corner[3].v = v, v
	end
	if (!tl) then
		tl_corner[1].y, tl_corner[4].y = tl_corner[1].y - radius, tl_corner[4].y - radius
		tl_corner[1].v, tl_corner[4].v = 0, 0
	end

	local tr_corner = {{ x = p2_x, y = p1_y, u = u2, v = v1 },
	{ x = p1_x, y = p1_y, u = u1, v = v1 } ,
	{ x = p1_x , y = p1_y - radius, u = u1, v = 0 },
	{ x = p2_x , y = p1_y - radius, u = u2, v = 0 }}

	local br_corner = {{ x = p2_x, y = p2_y, u = u2, v = v2 },
	{ x = p2_x, y = p1_y, u = u2, v = v1 },
	{ x = x + width, y = p1_y, u = u, v = v1  },
	{ x = p2_x + radius , y = p2_y  , u = u, v = v2 }}
	if (!br) then
		br_corner[1].y, br_corner[4].y  = br_corner[1].y + radius, br_corner[4].y + radius
		br_corner[1].v, br_corner[4].v  = v, v
	end
	if (!tr) then
		br_corner[2].y, br_corner[3].y  = br_corner[2].y - radius, br_corner[3].y - radius
		br_corner[2].v, br_corner[3].v  = 0, 0
	end
	--Insert rounded corners
	for i = 0, prec do
		local a = ( i / prec ) * -pi_2
		if (bl) then
			bl_corner[#bl_corner + 1] = { x = p1_x + sin( a ) * radius, y = p2_y + cos( a ) * radius, u = (sin( a ) * u) / part_w + u1, v = (cos( a ) * v) / part_h + v2}
		end
		if (tl) then
			tl_corner[#tl_corner + 1] = { x = p1_x + sin( a - pi_2 ) * radius, y = p1_y + cos( a - pi_2 ) * radius, u = (sin( a - pi_2 ) * u) / part_w + u1, v = (cos( a - pi_2 ) * v) / part_h + v1 }
		end
		if (tr) then
			tr_corner[#tr_corner + 1] = { x = p2_x + sin( a - pi ) * radius, y = p1_y + cos( a - pi ) * radius, u = (sin( a - pi ) * u) / part_w + u2, v = (cos( a - pi ) * v) / part_h + v1 }
		end
		if (br) then
			br_corner[#br_corner + 1] = { x = p2_x + sin( a - threePi_2 ) * radius, y = p2_y + cos( a - threePi_2 ) * radius, u = (sin( a - threePi_2 ) * u) / part_w + u2, v = (cos( a - threePi_2 ) * v) / part_h + v2 }
		end
	end

	if !cache then
		drawpoly(center) drawpoly( bl_corner ) drawpoly( tl_corner ) drawpoly( tr_corner ) drawpoly( br_corner )
	else
		return { center, bl_corner, tl_corner, tr_corner, br_corner }
	end
end

function draw.RoundedPolyBorderEX( radius, extrude, x, y, w, h, prec, u, v, u_offset, v_offset, tl, tr, bl, br, cache )
	if ( extrude == 0 or prec <= 0 or radius <= 0 or w <= 0 or h <= 0 ) then if !cache then return end return {} end
	local width = w * .5
	local height = h * .5
	radius = min( round( radius ), floor( width ), floor( height ) )
	u_offset = clamp(u_offset or 0, -1, 1)
	v_offset = clamp(v_offset or 0, -1, 1)
	u, v = u or 1, v or 1
	tl, tr, bl, br = (tl != false), (tr != false), (bl != false), (br != false)
	local corners = {tr, br, bl, tl}
	--Number of corners that are rounded
	local rounded_corners = (tl and 1 or 0) + (tr and 1 or 0) + (bl and 1 or 0) + (br and 1 or 0)
	--Points of rotation
	local p1_x = x - width + radius
	local p1_y = y - height + radius
	local p2_x = x + width - radius
	local p2_y = y + height - radius

	local data
	if cache then data = {} end
	--points on the bridges that are affected by rounded corners
	local x1_1, x1_2, y3_1, y3_2, x5_1, x5_2, y7_1, y7_2 =
				p1_x, p2_x, p1_y, p2_y, p2_x, p1_x, p2_y, p1_y
	if !tr then
		x1_2 = x + width + extrude
		y3_1 = y - height - extrude
	end
	if !bl then
		x5_2 = x - width - extrude
		y7_1 = y + height + extrude
	end
	if !tl then
		x1_1 = x - width - extrude
		y7_2 = y - height - extrude
	end
	if !br then
		y3_2 = y + height + extrude
		x5_1 = x + width, x + width + extrude
	end
	--Initialize verts for the shape.
	local inner, outer = {}, {}
	--For V wrapping
	local t_length, r_length, b_length, l_length = x1_2 - x1_1, y3_2 - y3_1, x5_1 - x5_2, y7_1 - y7_2
	local total_length = t_length + r_length + b_length + l_length
	local corner_v
	--Only include cross section lengths when needed
	if rounded_corners > 0 then
		total_length = total_length + (( pi_2 * radius + extrude ) * rounded_corners)
		corner_v = ( ( pi_2 * radius + extrude ) / total_length) / prec
	end

	total_length = 1 / total_length --Inverse
	local v_info = { t_length * total_length, r_length * total_length, b_length * total_length, l_length * total_length }
	local real_estate = v_offset - (t_length * total_length) * .5 --V tracker

	--Build path clockwise
	for case = 1, 4 do
		if corners[case] then -- making a rounded corner
			local rot, p_x, p_y
			if case == 1 then rot = pi  p_x, p_y = p2_x, p1_y
			elseif case == 2 then rot = threePi_2 p_x, p_y = p2_x, p2_y
			elseif case == 3 then rot = 0 p_x, p_y = p1_x, p2_y
			elseif case == 4 then rot = pi_2  p_x, p_y = p1_x, p1_y end

			for j = 0, prec do
				if j == 0 then v_seg = v_info[case] else v_seg = corner_v end
				local a = ( j / prec ) * -pi_2

				inner[#inner + 1] = { x = p_x + sin( a - rot ) * radius, y = p_y + cos( a - rot ) * radius,
					u = u_offset, v = v_seg * v + real_estate }
				outer[#outer + 1] = { x = inner[#inner].x + (sin( a - rot ) * extrude), y = inner[#inner].y + (cos( a - rot ) * extrude ),
					u = u + u_offset, v = v_seg * v + real_estate }

				real_estate = v_seg * v + real_estate -- increment
				if j != 0 or case != 1 then
					local quad
					if extrude > 0 then
						quad = { inner[#inner], inner[#inner - 1], outer[#outer - 1], outer[#outer] }
					else
						quad = { outer[#outer], outer[#outer - 1], inner[#inner - 1], inner[#inner] }
					end
					if !cache then drawpoly( quad ) else data[#data + 1] = quad end
				end
			end
		else
			--not a rounded corner
			v_seg = v_info[case]
			if case == 1 then
				inner[#inner + 1] = { x = x + width, y = y - height }
				outer[#outer + 1] = { x = x + width + extrude, y = y - height - extrude }
			elseif case == 2 then
				inner[#inner + 1] = { x = x + width, y = y + height }
				outer[#outer + 1] = { x = x + width + extrude, y = y + height + extrude }
			elseif case == 3 then
				inner[#inner + 1] = { x = x - width, y = y + height }
				outer[#outer + 1] = { x = x - width - extrude, y = y + height + extrude }
			elseif case == 4 then
				inner[#inner + 1] = { x = x - width, y = y - height }
				outer[#outer + 1] = { x = x - width - extrude, y = y - height - extrude }
			end
			--Calc UVs
			inner[#inner].u, outer[#outer].u = u_offset, u + u_offset
			inner[#inner].v, outer[#outer].v = v_seg * v + real_estate, v_seg * v + real_estate
			real_estate = v_seg * v + real_estate

			if case != 1 then -- only drawpoly when we have 4 points
				local quad
				if extrude > 0 then
					quad = { inner[#inner], inner[#inner - 1], outer[#outer - 1], outer[#outer] }
				else
					quad = { outer[#outer], outer[#outer - 1], inner[#inner - 1], inner[#inner] }
				end
				if !cache then drawpoly( quad ) else data[#data + 1] = quad end
			end
		end
	end
	--Draw the top bridge to tie it up
	local in_begin, out_begin = {x = inner[1].x, y = inner[1].y, u = u_offset, v = v + inner[1].v },
	{x = outer[1].x, y = outer[1].y, u = u + u_offset, v = v + outer[1].v }

	local quad
	if extrude > 0 then
		quad = { in_begin, inner[#inner], outer[#outer], out_begin }
	else
		quad = { out_begin, outer[#outer], inner[#inner], in_begin }
	end

	if !cache then drawpoly( quad ) return else data[#data + 1] = quad return data end
end
