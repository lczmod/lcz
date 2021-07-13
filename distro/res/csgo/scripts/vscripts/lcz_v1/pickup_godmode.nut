/**
 * Godmode pickup library.
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

initialized <- false;

godmodeTrigger <-		null;
godmodeModel <-			null;
godmodeSpawnEffect <-	null;
godmodeSpawnSound <-	null;
godmodePickupSound <-	null;
godmodeDamageFilter <-	null;
godmodeFadeIn <-		null;
godmodeFadeOut <-		null;

godmodeRespawnTime <-	120;
godmodeDuration <-		10;

// Fade times for screenspace effect. Godmode itself is toggled instantaneously.
godmodeFadeInTime <-	0.5;
godmodeFadeOutTime <-	0.5;

/**
 * Activates godmode damage filter for player for certain duration.
 *
 * Damage filter allows only DROWN type of damage.
 * Damage filter & custom filter keyvalue are automatically reset to gamemode default after
 * pickup timeout, player respawn or upon cs_pre_restart event.
 */
function lczGodmodePickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczGodmodePickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczGodmodePickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczGodmodePickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	if(lcz.hasPlayerKV(plrId, "CustomDamageFilter"))
	{
		if(lcz.debug) printl("LCZ I: lczGodmodePickup(): Custom damage filter already active on player " + plrId + ", ignoring.");
		return;
	}
	
	if(lcz.hasPlayerKV(plrId, "CustomModel"))
	{
		if(lcz.debug) printl("LCZ I: lczGodmodePickup(): Custom model already active on player " + plrId + ", ignoring.");
		return;
	}
	
	local playerTeam = activator.GetTeam();
	if(playerTeam < 2 || playerTeam > 3)
	{
		if(lcz.debug) printl("LCZ I: lczGodmodePickup(): Player " + plrId + " has wrong team id (" + playerTeam + "), ignoring.");
		return;
	}
	
	lcz.setPlayerDamageFilter(plrId, godmodeDamageFilter);
	lcz.currentLifeDelayedCall
	(
		godmodeDuration,
		plrId,
		// Callback function
		function(playerId)
		{
			lcz.resetPlayerDamageFilter(playerId);
		},
		// Array of callback arguments
		// Must include 'this' as first argument
		[this, plrId]
	);
	
	local prevModel = activator.GetModelName();
	lcz.addPlayerKV(plrId, "CustomModel", prevModel);
	local currModel = "models/player/custom_player/lcz_v1/plr_godmode_t.mdl";
	if(playerTeam == 3)
		currModel = "models/player/custom_player/lcz_v1/plr_godmode_ct.mdl";
	activator.SetModel(currModel);
	
	EntFireByHandle(godmodeTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(godmodeModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(godmodeSpawnEffect, "Stop", "", 0, null, null);
	EntFireByHandle(godmodePickupSound, "PlaySound", "", 0, null, null);
	EntFireByHandle(godmodeFadeIn, "Fade", "", 0, activator, null);
	
	EntFireByHandle(godmodeTrigger, "Enable", "", godmodeRespawnTime, activator, null);
	EntFireByHandle(godmodeModel, "TurnOn", "", godmodeRespawnTime, activator, null);
	EntFireByHandle(godmodeSpawnEffect, "Start", "", godmodeRespawnTime, activator, null);
	EntFireByHandle(godmodeSpawnSound, "PlaySound", "", godmodeRespawnTime, activator, null);
	if(godmodeFadeInTime + godmodeFadeOutTime < godmodeDuration)
		lcz.currentLifeDelayedCall
		(
			godmodeDuration - godmodeFadeOutTime,
			plrId,
			// Callback function
			function(fadeOut, activator, prevModel)
			{
				// Activator will always be valid player; Checks are performed in delayed call finisher.
				local plrId = activator.entindex();
				if(lcz.hasPlayerKV(plrId, "CustomModel"))
					lcz.removePlayerKV(plrId, "CustomModel");
				activator.SetModel(prevModel);
				EntFireByHandle(fadeOut, "Fade", "", 0, activator, null);
			},
			// Array of callback arguments
			// Must include 'this' as first argument
			[this, godmodeFadeOut, activator, prevModel]
		);
}

function Precache()
{
	// This script is also used in point_template within godmode pickup instance
	if(self.GetClassname() == "point_template")
		return;
	
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_godmode Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 7; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_godmode Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	godmodeTrigger =		EntityGroup[0];
	godmodeModel =			EntityGroup[1];
	godmodeSpawnEffect =	EntityGroup[2];
	godmodeSpawnSound =		EntityGroup[3];
	godmodePickupSound =	EntityGroup[4];
	godmodeDamageFilter =	EntityGroup[5];
	godmodeFadeIn =			EntityGroup[6];
	godmodeFadeOut =		EntityGroup[7];
	
	if(godmodeFadeInTime + godmodeFadeOutTime >= godmodeDuration)
	{
		printl("LCZ W: Godmode duration (" + godmodeDuration + ") is less than fade in + fade out effect times (" + godmodeFadeInTime + ", " + godmodeFadeOutTime + ").");
		godmodeFadeIn.__KeyValueFromFloat("holdtime", godmodeDuration);
	}
	else
	{
		godmodeFadeIn.__KeyValueFromFloat("duration", godmodeFadeInTime);
		godmodeFadeIn.__KeyValueFromFloat("holdtime", godmodeDuration - godmodeFadeInTime - godmodeFadeOutTime);
		godmodeFadeOut.__KeyValueFromFloat("duration", godmodeFadeOutTime);
	}
	
	initialized = true;
}