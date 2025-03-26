local DefaultFlags = {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_LUA_SERVER};

CreateConVar ( 
    "toolgunbal_proj_force", 
    15, 
    DefaultFlags, 
    "Projectile's speed", 
    0, 1500 
); CreateConVar ( 
    "toolgunbal_proj_gravity", 
    60, 
    DefaultFlags, 
    "Projectile's gravity", 
    -1500, 5500 

); CreateConVar ( 
    "toolgunbal_proj_perplayer", 
    7, 
    DefaultFlags, 
    "How much projectiles you can have active per player", 
    0, 50 

); CreateConVar ( 
    "toolgunbal_enabled", 
    1, 
    DefaultFlags, 
    "Toggles the Health Ring System addon.",
    0,1
); CreateConVar ( 
    "toolgunbal_plycolor", 
    1, 
    DefaultFlags, 
    "Use player's weapon color for the effects.",
    0,1
);

concommand.Add( "toolgunbal_refresh", function( ply, cmd, args )
    if !ply:IsSuperAdmin() then return end;
    local Bitches = player.GetAll()
    for _,v in pairs(Bitches) do
        if not IsValid(v:GetWeapon("gmod_tool")) then continue end
        v:GetWeapon("gmod_tool"):Remove()
        timer.Simple(0.05, function()
            v:Give("gmod_tool")
        end)
    end
end)

// local LastThink = 0
hook.Add("Think", "tool_ballistics_physics", function()

    // local D = ents.FindByClass("gmod_tool_proj")
    // if D[1] then
    //     Entity(110):SetPos( D[1]:GetPos() + Vector(50,25,25) )
    // end

    // if LastThink+0.02 > CurTime() then return end

    // LastThink = CurTime()

    local Enabled = GetConVar("toolgunbal_enabled")
    local SPEEEEEED = GetConVar("toolgunbal_proj_force")  if SPEEEEEED then SPEEEEEED = SPEEEEEED:GetInt() else SPEEEEEED = 0 end;
    local Gravityy = GetConVar("toolgunbal_proj_gravity") if Gravityy  then Gravityy = Gravityy:GetInt()  else Gravityy = 0 end;

    if Enabled and !Enabled:GetBool() then return end;

    local PROJs = ents.FindByClass("gmod_tool_proj")

    for _,v in pairs(PROJs) do
        if not IsValid(v) then continue end
 
        local PROJ_SPEED, PROJ_GRAVITY = SPEEEEEED,Gravityy
        
        if not v.TGAcceleration then
            v.TGAcceleration = 0
        else
            v.TGAcceleration = v.TGAcceleration + PROJ_GRAVITY/500
        end

        local Acce = v.TGAcceleration
        local tr = {
            start = v:GetPos(),
            endpos = v:GetPos() + v:GetForward() * PROJ_SPEED - Vector(0,0,Acce), -- - self:GetAngles():Up() * PROJ_GRAVITY/45
            filter = {v,v:GetOwner()},
        }
        
        local trace = util.TraceLine( tr )
        if !trace then return end;

        v:SetPos(trace.HitPos)
        if SERVER then
            if not v.ToolgunOBJ then v:Remove() continue end
            if not IsValid(v.ToolgunOBJ.Weapon) then v:Remove() continue end
        end
        if trace.Hit and SERVER then 
            if v.ProjType == 1 then
                v.ToolgunOBJ:LeftClick( trace )
            elseif v.ProjType == 2 then
                v.ToolgunOBJ:RightClick( trace )
            elseif v.ProjType == 3 then
                v.ToolgunOBJ:Reload( trace )
            end
            local EPC = pcall(function()
                local NewEffect = EffectData()
                NewEffect:SetOrigin( v:GetPos() )
                NewEffect:SetAngles( v:GetAngles() )
                NewEffect:SetNormal( trace.HitNormal )
                NewEffect:SetStart(Vector( v:GetColor().r, v:GetColor().g, v:GetColor().b ))
                util.Effect("custom_toolgun_hit", NewEffect, true, nil)
            end)
            v:Remove()
        end

    end
end)