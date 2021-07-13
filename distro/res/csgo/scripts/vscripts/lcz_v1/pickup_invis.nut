/**
 * Invis pickup library.
 *
 * Changelog:
 * - Version 1.0
 *   Initial release
 * 
 * This file is part of LCZ Mod.
 * 
 * LCZ Mod is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * LCZ Mod is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with LCZ Mod.  If not, see <http://www.gnu.org/licenses/>.
 */

initialized <-	false;

invisTrigger <-		null;
invisModel <-		null;
invisSpawnEffect <-	null;
invisSpawnSound <-	null;
invisPickupSound <-	null;
invisFadeIn <-		null;
invisFadeOut <-		null;

// Fade times for screenspace effect. Invisibility of player model itself is toggled instantaneously.
invisFadeInTime <-	0.5;
invisFadeOutTime <-	0.5;

invisDuration <-	10;
invisRespawnTime <-	60;

/**
 * Activates invisibility (special invis playermodel) for activator player for certain duration.
 *
 * Model is reset to ones used before activation upon pickup timeout, player respawn or round restart.
 */
function lczInvisPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczInvisPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczInvisPickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczInvisPickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	if(lcz.hasPlayerKV(plrId, "CustomModel"))
	{
		if(lcz.debug) printl("LCZ I: lczInvisPickup(): Custom model already active on player " + plrId + ", ignoring.");
		return;
	}
	
	local prevModel = activator.GetModelName();
	lcz.addPlayerKV(plrId, "CustomModel", prevModel);
	activator.SetModel("models/player/custom_player/lcz_v1/plr_invis.mdl");
	
	EntFireByHandle(invisTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(invisModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(invisSpawnEffect, "Stop", "", 0, null, null);
	EntFireByHandle(invisPickupSound, "PlaySound", "", 0, null, null);
	EntFireByHandle(invisFadeIn, "Fade", "", 0, activator, null);
	
	EntFireByHandle(invisTrigger, "Enable", "", invisRespawnTime, null, null);
	EntFireByHandle(invisModel, "TurnOn", "", invisRespawnTime, null, null);
	EntFireByHandle(invisSpawnEffect, "Start", "", invisRespawnTime, null, null);
	EntFireByHandle(invisSpawnSound, "PlaySound", "", invisRespawnTime, null, null);
	if(invisFadeInTime + invisFadeOutTime < invisDuration)
		lcz.currentLifeDelayedCall
		(
			invisDuration - invisFadeOutTime,
			plrId,
			function(targetEnt, activator, prevModel)
			{
				// Activator will always be valid player; Checks are performed in delayed call finisher.
				local plrId = activator.entindex();
				if(lcz.hasPlayerKV(plrId, "CustomModel"))
					lcz.removePlayerKV(plrId, "CustomModel");
				activator.SetModel(prevModel);
				EntFireByHandle(targetEnt, "Fade", "", 0, activator, null);
			},
			[this, invisFadeOut, activator, prevModel]
		);
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_invis Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 6; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_invis Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	invisTrigger =		EntityGroup[0];
	invisModel =		EntityGroup[1];
	invisSpawnEffect =	EntityGroup[2];
	invisSpawnSound =	EntityGroup[3];
	invisPickupSound =	EntityGroup[4];
	invisFadeIn =		EntityGroup[5];
	invisFadeOut =		EntityGroup[6];
	
	if(invisFadeInTime + invisFadeOutTime >= invisDuration)
	{
		printl("LCZ W: Invis duration (" + invisDuration + ") is less than fade in + fade out effect times (" + invisFadeInTime + ", " + invisFadeOutTime + ").");
		invisFadeIn.__KeyValueFromFloat("holdtime", invisDuration);
	}
	else
	{
		invisFadeIn.__KeyValueFromFloat("duration", invisFadeInTime);
		invisFadeIn.__KeyValueFromFloat("holdtime", invisDuration - invisFadeInTime - invisFadeOutTime);
		invisFadeOut.__KeyValueFromFloat("duration", invisFadeOutTime);
	}
	
	initialized = true;
}