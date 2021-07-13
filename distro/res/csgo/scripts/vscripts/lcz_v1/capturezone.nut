/**
 * Capture zone library.
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

captureSound <-	null;

/**
 * Called by capture zone trigger.
 *
 * @param	czTeam	Team that touched capture zone belongs to, 2 = T, 3 = CT.
 */
function lczCZTouch(czTeam)
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!lcz.gamemode || lcz.gamemode.name != "ctf")
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): Expected ctf gamemode, current gamemode is \"" +
			lcz.gamemode ? lcz.gamemode.name : "null" + "\", exiting.");
		return;
	}
	
	if(czTeam < 2 || czTeam > 3)
	{
		 if(lcz.debug) printl("LCZ E: lczCZTouch(): Flag must belong to T or CT, got team number " + czTeam + ", exiting.");
		 return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local playerTeam = activator.GetTeam();
	if(playerTeam != czTeam || playerTeam < 2 || playerTeam > 3)
	{
		if(lcz.debug) printl("LCZ I: lczCZTouch(): Player " + plrId + " has wrong team id (" + playerTeam + ") to capture the flag, ignoring.");
		return;
	}
	
	if
	(
		!lcz.gamemode.scope.canCapWithoutOwnFlag &&
		lcz.hasPlayerKV(plrId, "CTFFlagCarried") &&
		(
			czTeam == 2 && lcz.gamemode.scope.missingFlagsT > 0 ||
			czTeam == 3 && lcz.gamemode.scope.missingFlagsCT > 0
		)
	)
	{
		lcz.teamAlertMessage("Return your flag to capture enemy flag!", czTeam);
		return;
	}
	
	if(!lcz.hasPlayerKV(plrId, "CTFFlagCarried"))
	{
		if(lcz.debug) printl("LCZ I: lczCZTouch(): Player " + plrId + " is not carrying a flag, ignoring.");
		return;
	}
	
	local flagScope = lcz.getPlayerKV(plrId, "CTFFlagCarried");
	if(!flagScope)
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): No flag script scope for flag on carrier with id " + plrId + ", exiting.");
		return;
	}
	
	// dropFlag will also call returnFlagToSpawn, which will reduce lcz.gamemode.scope.missingFlagT/CT by 1
	flagScope.dropFlag(flagScope.flagStartPos);
	lcz.addScore(plrId, lcz.gamemode.scope.playerCapReward);
	
	if
	(
		czTeam == 2 &&
		++lcz.gamemode.scope.cappedFlagsT == lcz.gamemode.scope.flagCapLimitT
	)
		lcz.roundEndTWin(lcz.gamemode.scope.postWinTime);
	else if
	(
		czTeam == 3 &&
		++lcz.gamemode.scope.cappedFlagsCT == lcz.gamemode.scope.flagCapLimitCT
	)
		lcz.roundEndCTWin(lcz.gamemode.scope.postWinTime);
	else
		// When team wins a round, it gets a point automatically.
		// So keep adding team points only when below flag cap limit.
		lcz.addTeamScore(czTeam, lcz.gamemode.scope.teamCapReward);
	
	EntFireByHandle(captureSound, "PlaySound", "", 0, null, null);
	
	lcz.alertMessage((czTeam == 2 ? "Counter-Terrorist" : "Terrorist") + " flag captured!");
	
	lcz.removePlayerKV(plrId, "CTFFlagCarried");
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: capturezone Precache(): EntityGroup == null");
		return;
	}
	
	if(!EntityGroup[0])
	{
		printl("LCZ E: capturezone Precache(): EntityGroup[0] == null");
		return;
	}
	
	captureSound = EntityGroup[0];
	
	initialized = true;
}