
local function ToolgunAct(Key,Gtool) // Basically this is just a ripped code from the gmod_tool, but i've got more control.
    local owner = Gtool:GetOwner()

    local LArray = {}

    if owner.ProjectilesTGOBJ then
        LArray = owner.ProjectilesTGOBJ
    else
        local TAB = {}
        owner.ProjectilesTGOBJ = TAB
        LArray = TAB
    end

    for I,v in pairs(LArray) do
        if not IsValid(v) then
            table.remove(LArray, I)
        end
    end

    local Limit = GetConVar("toolgunbal_proj_perplayer") if Limit then Limit = Limit:GetInt() else Limit = 4 end
    
    if LArray and #LArray > Limit then return end

    local TDE = owner // Entity(101)
    local tr = {
        start = TDE:GetShootPos(),
        endpos = TDE:GetShootPos() + TDE:GetForward()*255555*255*255,
        filter = TDE,
    }
    tr.mask = toolmask
    tr.mins = vector_origin
    tr.maxs = tr.mins
    local trace = util.TraceLine( tr )
    if ( !trace.Hit ) then trace = util.TraceHull( tr ) end;
    if ( !trace.Hit ) then return end;
    local tool = Gtool:GetToolObject()
    if ( !tool ) then return end;
    tool:CheckObjects()
    if ( !tool:Allowed() ) then return end;
    local mode = Gtool:GetMode()
    if ( !gamemode.Call( "CanTool", owner, trace, mode, tool, 1 ) ) then return end;
    
    Gtool:EmitSound( Gtool.ShootSound )
    Gtool:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    owner:SetAnimation( PLAYER_ATTACK1 )

    if CLIENT then return end;

    local ENT_PROJ = ents.Create( "gmod_tool_proj" )
    // owner.ProjLimit = owner.ProjLimit + 1
    ENT_PROJ:SetPos( trace.StartPos )
    ENT_PROJ:SetAngles( ( trace.HitPos - trace.StartPos ):Angle() )
    ENT_PROJ:SetOwner( owner )
    ENT_PROJ.ToolgunOBJ = tool
    ENT_PROJ.ProjType = Key
    
    table.insert(LArray, #LArray, ENT_PROJ)

    ENT_PROJ:Spawn()

    SafeRemoveEntityDelayed(ENT_PROJ, 10)
end



hook.Add("PlayerSwitchWeapon", "ballin_stics_toolgun_yueeeeee", function(PLY, _, ASS)
    local Enabled = GetConVar("toolgunbal_enabled")
    if Enabled and !Enabled:GetBool() then return end;
    if ASS:GetClass() ~= "gmod_tool" then return end;
    
    function ASS:PrimaryAttack() 
        if Enabled and !Enabled:GetBool() then return end;
        self:SetNextPrimaryFire(CurTime()+0.1)
        ToolgunAct(1,self)
    end
    
    function ASS:SecondaryAttack() 
        if Enabled and !Enabled:GetBool() then return end;
        self:SetNextSecondaryFire(CurTime()+0.1)
        ToolgunAct(2,self)
    end

    function ASS:Reload() 
        if Enabled and !Enabled:GetBool() then return end;
        if ( !self:GetOwner():KeyPressed( IN_RELOAD ) ) then return end;
        ToolgunAct(3,self)
    end
end)


if CLIENT then

    CreateClientConVar(
        "toolgunbal_debug_enable", 
        0, 
        true, 
        false, 
        "Toggles trajectory prediction, and other debug things", 
        0, 1
    ); CreateClientConVar(
        "toolgunbal_debug_segments", 
        100, 
        true, 
        false, 
        "How much segments in trajectory prediction (WARNING! It can impact your game performance)", 
        0, 2000
    );
end


local color_red = Color(255, 0, 0)
local C


local function GetBitches()
    
    local CollectedInfo = {}

    for _,v in pairs( ents.FindByClass("gmod_tool_proj") ) do
        local Col = v:GetColor()
        local Pos = v:GetPos()
        table.insert(CollectedInfo, 1, {Col,Pos})
    end
    return CollectedInfo
end
    

hook.Add( "PostDrawTranslucentRenderables", "MySuper3DRenderingHook_TGDEBUGGGGGGGGGGG_AAAAA", function()
    
    

    local Enabled = GetConVar("toolgunbal_debug_enable")
    local Segments = GetConVar("toolgunbal_debug_segments") if Segments then Segments = Segments:GetInt() else Segments = 25 end

    if Enabled and !Enabled:GetBool() then return end
    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" then return end;
    if !LocalPlayer():IsAdmin() then return end;

    local SPEEEEEED = GetConVar("toolgunbal_proj_force")  if SPEEEEEED then SPEEEEEED = SPEEEEEED:GetInt() else SPEEEEEED = 0 end;
    local Gravityy = GetConVar("toolgunbal_proj_gravity") if Gravityy  then Gravityy = Gravityy:GetInt()  else Gravityy = 0 end;

    local Predict = LocalPlayer()
    local PROJ_SPEED, PROJ_GRAVITY = SPEEEEEED,Gravityy
    local Length = 1

    PROJ_SPEED = PROJ_SPEED*Length
    PROJ_GRAVITY = PROJ_GRAVITY*Length

    local LastPredict = Predict:GetShootPos()
    local LastAng = 0

    for _,v in pairs(GetBitches()) do
        render.DrawSphere(v[2], 2, 10, 10, v[1])
    end

    for I = 1,Segments do
        local tr = {
            start = LastPredict,
            endpos = LastPredict + Predict:GetForward() * PROJ_SPEED - Vector(0,0,LastAng), -- - self:GetAngles():Up() * PROJ_GRAVITY/45
            filter = {Predict},
        }

        local trace = util.TraceLine( tr )

        if !trace then continue end
        
        if !LastPredict then 
            LastPredict = trace.StartPos
        end

        C = Color(100-I,255-I*3,100+I*3,200-math.sin(CurTime()*3)*100)
        // Right, all the way to the right offset so that people would see this thing properly  
        local VisOffset = ( Predict:GetAngles():Right()*1.5 )
        if trace.Hit then 
            C = Color(255,75,75,255) 
            render.DrawSphere(trace.StartPos+VisOffset, -2, 15, 15, Color(255,150,75))

            render.DrawLine( LastPredict+VisOffset, trace.HitPos+VisOffset, C )
            render.DrawSphere(trace.HitPos+VisOffset, 2, 15, 15, C)
            return
        end
        render.DrawLine( LastPredict+VisOffset, trace.HitPos+VisOffset, C ) 

        

        LastPredict = trace.HitPos
        LastAng = LastAng + PROJ_GRAVITY/500
    end
end )






hook.Add( "AddToolMenuCategories", "RingSys_category_TG", function()
    spawnmenu.AddToolCategory("Utilities", "findyastuff", "Findya's Stuff")
end)



hook.Add( "PopulateToolMenu", "RingSys_settings_TG", function()
    spawnmenu.AddToolMenuOption("Utilities", "findyastuff", "tg_xxhhs", "Toolgun ballistics settings", "", "", function(panel)
        panel:SetName( "Toolgun ballistics settings" )

        if not LocalPlayer():IsSuperAdmin() then

            panel:Help("YOU HAVE NO PERMISSION TO VIEW THIS MENU!") 
            
            panel:Help(" ") 
            panel:Help(" ") 

            panel:Button( "Refresh spawnmenu", "spawnmenu_reload")
            panel:ControlHelp("Use this button in case you have right permission to view this menu (SuperAdmin)") 
            return;
        end

        panel:CheckBox( "Enabled", "toolgunbal_enabled")

        panel:NumSlider( "Projectile force", "toolgunbal_proj_force", 0, 999, 0)
        panel:NumSlider( "Projectile gravity", "toolgunbal_proj_gravity", -750, 750, 0) 
        panel:NumSlider( "Max projectiles at once", "toolgunbal_proj_perplayer", 0, 50, 0) 
        panel:CheckBox( "Use weapon color", "toolgunbal_plycolor")

        panel:Button( "Refresh", "toolgunbal_refresh")

        panel:Help(" ") 
        panel:Help("Debug") 
        panel:CheckBox( "Enabled", "toolgunbal_debug_enable")
        panel:NumSlider( "Segments in trajectory prediction", "toolgunbal_debug_segments", 0, 2000, 0) 
    end)

end)