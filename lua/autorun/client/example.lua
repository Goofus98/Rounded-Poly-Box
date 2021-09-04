local bar_mat = Material("gauge_stroke")
local bar_mat_w, bar_mat_h = bar_mat:Width() * 2, bar_mat:Height()

local texture = GetRenderTarget( "HUD_Gauges", bar_mat_w, bar_mat_h, false )
local mat = CreateMaterial( "HUD_Gauges","UnlitGeneric",{
  ["$basetexture"] = texture,
  ["$ignorez"] = 1,
  ["$vertexcolor"] = 1,
  ["$vertexalpha"] = 1
});
local lerp_hp, lerp_mp = bar_mat_h, bar_mat_h
--not letting the texture clamp to edges to avoid grainy looking hud
local offset = 2
hook.Add("HUDPaint", "PolyHUD_RT", function()
  if IsValid(LocalPlayer():GetActiveWeapon()) then
    local ammo = LocalPlayer():GetActiveWeapon():Clip1()
    local max_ammo = LocalPlayer():GetActiveWeapon():GetMaxClip1()
    if max_ammo == 0 then max_ammo,ammo = -1, -1 end --for stuff like gravgun
    lerp_mp = Lerp(10 * FrameTime(), lerp_mp, bar_mat_h / 2 - ((bar_mat_h / 2) * 1 / ( max_ammo / (max_ammo - ammo))))
  end
  lerp_hp = Lerp(4 * FrameTime(), lerp_hp, bar_mat_h - (bar_mat_h * 1 / ( 100 / (100 - LocalPlayer():Health()))))
  render.PushRenderTarget(texture)
  cam.Start2D()
  render.OverrideAlphaWriteEnable(true, true)
    render.ClearDepth()
    render.Clear( 0, 0, 0, 0 )

    --draw black BG
    surface.SetDrawColor(color_black)
    surface.DrawRect(offset, 0, bar_mat_w / 2 - offset, bar_mat_h)
    if LocalPlayer():Health() < 25 and LocalPlayer():Alive() then
      surface.SetDrawColor(128, 0, 32, math.sin( CurTime() * 20 ) * 10 + 50)
      surface.DrawRect(offset, 0, bar_mat_w / 2 - offset, bar_mat_h)
    end
    surface.SetDrawColor(color_black)
    surface.DrawRect(bar_mat_w / 2, 0, bar_mat_w / 2 - offset, bar_mat_h / 2  )
    surface.SetDrawColor(255, 0, 0, 75)
    surface.DrawRect(offset, 1, bar_mat_w / 2 - offset,  math.Clamp(math.ceil(lerp_hp) - .2, 0, bar_mat_h - .2 ) - 1)
    --add a little indent
    render.SetScissorRect( offset, 1, bar_mat_w / 2, bar_mat_h - (bar_mat_h * 1 / ( 100 / (100 - LocalPlayer():Health()))), true )
      surface.SetDrawColor(25, 230, 45)
      surface.SetMaterial(bar_mat)
      surface.DrawTexturedRect(offset, 0, bar_mat_w / 2 - offset, bar_mat_h)
    render.SetScissorRect( 0, 0, 0, 0, false )

    render.SetScissorRect( bar_mat_w / 2, 0, bar_mat_w, math.Clamp(math.ceil(lerp_mp) - .2, 0, bar_mat_h / 2 - .2 ) , true )
      surface.SetDrawColor(25, 130, 245)
      surface.SetMaterial(bar_mat)
      surface.DrawTexturedRect(bar_mat_w / 2, 1, bar_mat_w / 2 - offset, bar_mat_h )
    render.SetScissorRect( 0, 0, 0, 0, false )
  cam.End2D()
  render.PopRenderTarget()

  mat:SetTexture("$basetexture", texture)
  --display our Mat for example
  surface.SetDrawColor(255,255,255)
  surface.SetMaterial(mat)
  surface.DrawTexturedRect(0, 0, 32 , 256)
end)

local prec = 12
--top left, top right, bottom left, bottom right, cache
local rounded = {true, true, true, true, true}
local h = ( ScrH() + ( ScrW() - ScrH() ) ) * 0.055
local w =  ScrW() * 0.055
local extrude = (w + h) / 4.5

--make it circular
local radius = w + h

local x = ( w + (ScrW() * .1) + math.abs(extrude) ) * .5
local y = (h + (ScrH() * .45 ) + math.abs(extrude) ) * .5
--better to lower the prec for avatar box
local box = draw.RoundedPolyBoxEX( radius, x, y, w + offset + extrude / 8, h + offset + extrude / 8, math.max(prec - 6, 4), 1, 1, unpack(rounded) )
--only need rounded border for dual gauges
local outline = draw.RoundedPolyBorderEX( radius, extrude, x, y, w , h, prec, 1, 1, 0, 0, unpack(rounded) )
local avatar = vgui.Create( "AvatarImage" )
avatar:SetPos( x - (w + offset + extrude / 8) / 2, y - (h + offset + extrude / 8) / 2 )
avatar:SetSize( w + offset + extrude / 8, h + offset + extrude / 8 )
avatar:SetPaintedManually(true)
--for low hp alarm eff
local target = w + h + extrude + 10
local ring = Material("effects/select_ring")
local anim = 0
local rate = 5.5

hook.Add( "InitPostEntity", "HUDBindAvatar", function()
  if !IsValid(LocalPlayer()) then return end
  avatar:SetPlayer(LocalPlayer(), 84)
end )

hook.Add( "OnScreenSizeChanged", "HUDScaleTest", function()
  h = ( ScrH() + ( ScrW() - ScrH() ) ) * 0.055
  w =  ScrW() * 0.055
  extrude = (w + h) / 4.5
  radius = w + h
  x = ( w + (ScrW() * .1) + math.abs(extrude) ) * .5
  y = (h + (ScrH() * .45 ) + math.abs(extrude) ) * .5
  target = w + h + extrude + 10
  --need to reconstruct
  outline = draw.RoundedPolyBorderEX( radius, extrude, x, y, w , h, prec, 1, 1, 0, 0, unpack(rounded) )
  box = draw.RoundedPolyBoxEX( radius, x, y, w + offset + extrude / 8, h + offset + extrude / 8, math.max(prec - 6, 4), 1, 1, unpack(rounded) )
  avatar:SetPos( x - (w + offset + extrude / 8) / 2, y - (h + offset + extrude / 8) / 2    )
  avatar:SetSize( w + offset + extrude / 8, h + offset + extrude / 8 )
end )

hook.Add("HUDPaint", "PolyHUDTest", function()
  if !IsValid(LocalPlayer()) then return end

  surface.SetDrawColor( color_white )
  --avatar image stencil
  render.ClearStencil()
  render.SetStencilEnable(true)

  render.SetStencilWriteMask(1)
  render.SetStencilTestMask(1)

  render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
  render.SetStencilPassOperation(STENCILOPERATION_ZERO)
  render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
  render.SetStencilReferenceValue(1)
  draw.NoTexture()
  for i = 1, #box do
    surface.DrawPoly( box[i] )
  end
  render.SetStencilFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
  render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
  render.SetStencilReferenceValue(1)

  avatar:SetPaintedManually(false)
  avatar:PaintManual()
  avatar:SetPaintedManually(true)

  if LocalPlayer():Health() < 25 and LocalPlayer():Alive() then
    surface.SetDrawColor(228, 0, 32, math.sin( CurTime() * 10 ) * 10 + 40)
    surface.DrawRect(x - (w + offset + extrude / 8) / 2, y - (h + offset + extrude / 8) / 2, w + offset + extrude / 8, h + offset + extrude / 8)
  end

  render.SetStencilEnable(false)
  render.ClearStencil()
  --hp and ammo bar
  surface.SetDrawColor(color_white)
  surface.SetMaterial(mat)
  for i = 1, #outline do
    surface.DrawPoly( outline[i] )
  end
  --alarm ring
  if LocalPlayer():Health() < 25 and LocalPlayer():Alive() then
    if math.floor(anim) >= math.floor(target) - 5 then
      anim = 0
    else
      anim = Lerp(FrameTime() * rate, anim, target)
    end
    surface.SetDrawColor(Color(255, 0, 0, 105 ))
    surface.SetMaterial(ring)
    surface.DrawTexturedRect(x - anim / 2, y - anim / 2, anim, anim)
  end
end )
