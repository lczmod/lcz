/**
 * Jumppads library, version 3.
 * 
 * Changelog:
 * - Version 1.0
 *   ar_lc_apote, initial.
 * - Version 2.0
 *   ar_lc_het, fixed addheight compensation when end Z + addheight < start Z.
 * - Version 3.0
 *   Integrated with LCZ Mod v1, rewritten, added more comments.
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

addheightMin <- 100;

/**
 * Converts inches to meters
 *
 * @param	i	inches
 *
 * @return	meters
 */
function itm(i)
{
	return i * 0.0254;
}

/**
 * Converts meters to inches
 *
 * @param	m	meters
 *
 * @return	inches
 */
function mti(m)
{
	return m * 39.37007874;
}

/**
 * Pushes activator player to coordinates of self (the entity that script scope belongs to).
 *
 * This script file should be added to entity scripts of jumppad target entity (NOT the trigger).
 * This function should then be called in target entity script scope via RunScriptCode input.
 * Activator must be present (it will be if you make a call upon player activating the trigger).
 *
 * Certain setups can result in velocities above 4096 u/s on Z axis, if sv_maxvelocity allows it.
 * These velocities appear to work fine, but Source console outputs error messages about clamping
 * m_flFallVelocity value in DataTable. This might affect other mods.
 *
 * @param	addheight	Trajectory apex will be this many units above end position.
 *						Can be used to change curvature of flight path.
 *						If necessary, addheight will be adjusted to be at least @link addheightMin @endlink
 *						units above either start or end position, whichever is heigher.
 */
function pushPlayerToSelf(addheight)
{
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: pushPlayerToSelf(): activator is missing, exiting.");
		return;
	}
	
	if(activator.GetClassname() != "player")
	{
		if(lcz.debug) printl("LCZ E: pushPlayerToSelf(): activator is not of player class, exiting.");
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczGodmodePickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local startPos =	activator.GetOrigin();
	local endPos =		self.GetOrigin();
	// Base in-game gravitational acceleration, in meters/seconds^2
	local baseGravAcc =	itm(lcz.gravity);
	
	// Player's own gravity is not being modified currently during their lifetime.
	/*if(lcz.hasPlayerKV(plrId, "CustomSpeedMod"))
	{
		local playerSpeedMod = lcz.getPlayerKV(plrId, "CustomSpeedMod");
		if(playerSpeedMod)
			// Player gravity mod is set to 1 / (speed mod)
			baseGravAcc /= playerSpeedMod;
	}
	else*/
	baseGravAcc /= lcz.baseSpeedMul;
	
	// Vector representing horizontal distance between start & end positions
	local horVec = Vector(endPos.x, endPos.y) - Vector(startPos.x, startPos.y);
	local horLen = itm(horVec.Length());
	
	// Maximum & minimum of the trajectory
	local topZ = lcz.max(startPos.z, endPos.z);
	local botZ = lcz.min(startPos.z, endPos.z);
	// Check if addheight + end position Z is too low for nice curve and compensate if needed
	local intendedAbsAddheight = endPos.z + addheight;
	local minAllowedAbsAddheight = topZ + addheightMin;
	if(intendedAbsAddheight < minAllowedAbsAddheight)
		addheight = topZ - botZ + addheightMin;
	
	// Vertical heights of flight curve pre- and post-apex
	local vertPathPreApex =		itm(endPos.z + addheight - startPos.z);
	local vertPathPostApex =	itm(addheight);
	
	// Times required to reach apex & end position
	local vertTimePreApex =		sqrt(2 * vertPathPreApex / baseGravAcc);
	local vertTimePostApex =	sqrt(2 * vertPathPostApex / baseGravAcc);
	
	// Vertical velocity at the apex must be zero
	// We can calculate the instantaneous speed of a stationary object falling from the pre-apex height
	// and apply same upwards velocity to player at the start position
	local vertVelocity =	mti(baseGravAcc * vertTimePreApex);
	// Horizontal velocity throughout the flight should be a constant
	// unless player starts air strafing
	// Thus, absolute starting velocity is simply (path length / time)
	local horVelocity =		mti(horLen / (vertTimePreApex + vertTimePostApex));
	
	// Angle between horizontal jump direction vector and positive X axis
	local horAngle = atan2(horVec.y, horVec.x);
	
	// Starting X & Y velocities are derived from absolute horizontal velocity
	local finalVelocity = Vector
	(
		// Factor for X velocity is cosine of angle between horizontal jump direction and positive X axis
		// This will result in factor of 1 for 0 degrees, 0.866 for 30 degrees, -0.5 for 120, etc.
		horVelocity * cos(horAngle),
		// Factor for Y velocity is sine of the same angle
		// 0 at 0 degrees, 0.5 at 30, 0.866 at 120, etc.
		horVelocity * sin(horAngle),
		// Starting vertical velocity is already calculated
		vertVelocity
	);
	
	activator.SetVelocity(finalVelocity);
	activator.EmitSound("Bullets.DefaultNearmiss");
}