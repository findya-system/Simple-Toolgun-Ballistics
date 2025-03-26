AddCSLuaFile( )

ENT.Type = "anim"
ENT.PrintName = "gmod_tool proj"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Category = "Ring health system"
ENT.Spawnable = false
// ENT.AdminOnly = true
ENT.Model = "models/hunter/misc/sphere025x025.mdl"

function ENT:Initialize()
    self:SetModel( self.Model )
	self:SetMoveType( MOVETYPE_VPHYSICS )

    if CLIENT then return end;
    local TrailColor = Color(25*(self.ProjType*2),150,255,150)

    
    local PlyCol = GetConVar("toolgunbal_plycolor")

    if PlyCol and PlyCol:GetBool() then
        local Cmp = self:GetOwner():GetWeaponColor()
        local TypE = self.ProjType*50
        TrailColor = Color(Cmp[1]*255 + TypE, Cmp[2]*255 + TypE, Cmp[3]*255 + TypE)
    end
   
    self:SetColor(TrailColor)

    util.SpriteTrail( 
        self, 
        0, 
        TrailColor, 
        true, 
        5, 
        0, 
        0.5, 
        255, 
        "effects/beam_generic01"
    );
end

function ENT:Draw()
    // self:DrawModel()
end