/**
 * This script can be injected into player's scope to establish link
 * between killer and victim. It's a bit inconvenient, however,
 * since this input gets invoked way after other player death / kill events -
 * and sometimes even after player spawn event if death was
 * due to team change and instant respawn is enabled.
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

function InputKilledNPC()
{
	printl("Killer id: " + self.entindex());
	printl("Killer name: [" + self.GetName() + "]");
	if(activator && activator.IsValid())
	{
		printl("Activator id: " + activator.entindex());
		printl("Activator name: [" + activator.GetName() + "]");
	}
	if(caller && caller.IsValid())
	{
		printl("Caller id: " + caller.entindex());
		printl("Caller name: [" + caller.GetName() + "]");
	}
	
	return true;
}