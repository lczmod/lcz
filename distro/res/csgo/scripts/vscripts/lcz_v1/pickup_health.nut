/**
 * Health pickup library.
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

healthModel <-			null;
healthTrigger <-		null;
healthSpawnSound <-		null;
healthPickupSound <-	null;
healthGlow <-			null;

healthSmallRespawnTime <-		10;
healthSmallRestoreAmount <-		10;
healthSmallRestoreCap <-		100;
healthMediumRespawnTime <-		30;
healthMediumRestoreAmount <-	50;
healthMediumRestoreCap <-		150;
healthBigRespawnTime <-			60;
healthBigRestoreAmount <-		200;
healthBigRestoreCap <-			200;

/**
 * Attempts to heal activator player for certain amount with certain health cap, as set in gamemode rules.
 */
function lczHealthSmallPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczHealthSmallPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczHealthSmallPickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczHealthSmallPickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local currHealth = activator.GetHealth();
	if(currHealth < 1 || currHealth >= healthSmallRestoreCap)
	{
		if(lcz.debug) printl("LCZ I: lczHealthSmallPickup(): Nothing to heal, ignoring.");
		return;
	}
	
	currHealth += healthSmallRestoreAmount;
	if(currHealth > healthSmallRestoreCap)
		currHealth = healthSmallRestoreCap;
	activator.SetHealth(currHealth);
	
	EntFireByHandle(healthGlow, "HideSprite", "", 0, null, null);
	EntFireByHandle(healthModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(healthTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(healthPickupSound, "PlaySound", "", 0, null, null);
	
	EntFireByHandle(healthTrigger, "Enable", "", healthSmallRespawnTime, null, null);
	EntFireByHandle(healthModel, "TurnOn", "", healthSmallRespawnTime, null, null);
	EntFireByHandle(healthGlow, "ShowSprite", "", healthSmallRespawnTime, null, null);
	EntFireByHandle(healthSpawnSound, "PlaySound", "", healthSmallRespawnTime, null, null);
}

/**
 * Attempts to heal activator player for certain amount with certain health cap, as set in gamemode rules.
 */
function lczHealthMediumPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczHealthMediumPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczHealthMediumPickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczHealthMediumPickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local currHealth = activator.GetHealth();
	if(currHealth < 1 || currHealth >= healthMediumRestoreCap)
	{
		if(lcz.debug) printl("LCZ I: lczHealthMediumPickup(): Nothing to heal, ignoring.");
		return;
	}
	
	currHealth += healthMediumRestoreAmount;
	if(currHealth > healthMediumRestoreCap)
		currHealth = healthMediumRestoreCap;
	activator.SetHealth(currHealth);
	
	EntFireByHandle(healthGlow, "HideSprite", "", 0, null, null);
	EntFireByHandle(healthModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(healthTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(healthPickupSound, "PlaySound", "", 0, null, null);
	
	EntFireByHandle(healthTrigger, "Enable", "", healthMediumRespawnTime, null, null);
	EntFireByHandle(healthModel, "TurnOn", "", healthMediumRespawnTime, null, null);
	EntFireByHandle(healthGlow, "ShowSprite", "", healthMediumRespawnTime, null, null);
	EntFireByHandle(healthSpawnSound, "PlaySound", "", healthMediumRespawnTime, null, null);
}

/**
 * Attempts to heal activator player for certain amount with certain health cap, as set in gamemode rules.
 */
function lczHealthBigPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczHealthBigPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczHealthBigPickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczHealthBigPickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local currHealth = activator.GetHealth();
	if(currHealth < 1 || currHealth >= healthBigRestoreCap)
	{
		if(lcz.debug) printl("LCZ I: lczHealthBigPickup(): Nothing to heal, ignoring.");
		return;
	}
	
	currHealth += healthBigRestoreAmount;
	if(currHealth > healthBigRestoreCap)
		currHealth = healthBigRestoreCap;
	activator.SetHealth(currHealth);
	
	EntFireByHandle(healthGlow, "HideSprite", "", 0, null, null);
	EntFireByHandle(healthModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(healthTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(healthPickupSound, "PlaySound", "", 0, null, null);
	
	EntFireByHandle(healthTrigger, "Enable", "", healthBigRespawnTime, null, null);
	EntFireByHandle(healthModel, "TurnOn", "", healthBigRespawnTime, null, null);
	EntFireByHandle(healthGlow, "ShowSprite", "", healthBigRespawnTime, null, null);
	EntFireByHandle(healthSpawnSound, "PlaySound", "", healthBigRespawnTime, null, null);
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_health Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 4; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_health Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	healthModel =		EntityGroup[0];
	healthTrigger =		EntityGroup[1];
	healthSpawnSound =	EntityGroup[2];
	healthPickupSound =	EntityGroup[3];
	healthGlow =		EntityGroup[4];
	
	EntFireByHandle(healthGlow, "SetParent", healthModel.GetName(), 0, null, null);
	EntFireByHandle(healthGlow, "SetParentAttachment", "root", 0.01, null, null);
	
	initialized = true;
}