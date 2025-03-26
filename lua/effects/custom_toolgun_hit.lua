
function EFFECT:Init( data )

	local vOffset = data:GetOrigin()
	local vAngle = data:GetAngles()
	local vNormal = data:GetNormal()
	
	local function fc(Vec)
		return Vector(math.Clamp(Vec[1],0,255), math.Clamp(Vec[2],0,255), math.Clamp(Vec[3],0,255))
	end

	local Col = fc(data:GetStart())
	


	sound.Play( "SolidMetal.BulletImpact", vOffset, 90, 100 )
	sound.Play( "EpicMetal.ImpactHard", vOffset, 90, 100 )
	sound.Play( "Airboat.FireGunRevDown", vOffset, 90, 100 )

	local emitter = ParticleEmitter( vOffset, true )

	for i = 0, 15 do
		local Pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )
		local particle = emitter:Add( "particle/fire", vOffset - vAngle:Forward()*25 )
		if ( particle ) then
			
			local ANG = math.rad( (360) * i)/15
			local Axis1 = math.cos(ANG) * 1.2
			local Axis2 = math.sin(ANG) * 1.2
			
			local VelSpread = ( Vector(Axis1-Axis1*math.abs(vNormal[1]), Axis2-Axis2*math.abs(vNormal[2]), Axis2*-math.abs(vNormal[2])+(Axis1*-math.abs(vNormal[1]))) ) * 250 

			particle:SetVelocity( VelSpread )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.5 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			local Size = math.Rand( 1, 3 )
			particle:SetStartSize( 15 )
			particle:SetEndSize( 1 )

			particle:SetLighting( false )
			particle:SetAirResistance( 350 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			
			// particle:SetColor(150, 150, 255)
			local Col = fc(Col+Vector(0,50,0))
			particle:SetColor(Col[1],Col[2],Col[3])

			particle:SetCollide( true )

			particle:SetNextThink( CurTime() )
			particle:SetThinkFunction( function( pa )
				pa:SetAngles( ( LocalPlayer():GetShootPos() - pa:GetPos() ):Angle() )
				pa:SetNextThink( CurTime()+0.2 )
			end )

		end
	end

	for i = 0, 5 do
		local Pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )
		local particle = emitter:Add( "particle/fire", vOffset + Pos * 2 - vAngle:Forward()*25 )
		if ( particle ) then
			
			particle:SetVelocity( -vAngle:Forward()*150 + Pos*150 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 2 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )

			local Size = math.Rand( 1, 3 )
			particle:SetStartSize( 9 )
			particle:SetEndSize( 1 )

			// particle:SetRoll( EyeAngles() )
			// particle:SetRollDelta( math.Rand( -2, 2 ) )
			particle:SetLighting( false )
			// particle:SetAirResistance( 500 )
			particle:SetGravity( Vector( 0, 0, -400 * math.Rand(0.9,1.2) ) )
			particle:SetBounce( 0.2 )
			//particle:SetColor(150, 200, 255)
			particle:SetColor(Col[1],Col[2],Col[3])

			particle:SetCollide( true )

			// particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) )

			particle:SetNextThink( CurTime() )
			particle:SetThinkFunction( function( pa )
				pa:SetAngles( ( LocalPlayer():GetShootPos() - pa:GetPos() ):Angle() )
				pa:SetNextThink( CurTime()+0.2 )
			end )

		end
	end


	local particle = emitter:Add( "particle/fire", vOffset - vAngle:Forward()*15 )
	particle:SetLifeTime( 0 )
	particle:SetDieTime( 0.5 )

	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 0 )

	particle:SetStartSize( 75 )
	particle:SetEndSize( 0 )

	// particle:SetColor(75, 200, 255)
	Col = fc(Col*2)
	particle:SetColor(Col[1],Col[2],Col[3])


	particle:SetNextThink( CurTime() )
	particle:SetThinkFunction( function( pa )
		pa:SetAngles( ( LocalPlayer():GetShootPos() - pa:GetPos() ):Angle() )
		pa:SetNextThink( CurTime()+1 )
	end )

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
