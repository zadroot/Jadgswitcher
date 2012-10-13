/**
* team switcher for jagd by Root
*
* Description:
*   Plugin switch teams at round start on dod_jagd (for balanced gameplay). Plugin switching teams in the same way as done on gravelpit in TF2
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

#pragma semicolon 1 // Force strict semicolon mode.

// ====[ INCLUDES ]====================================================
#include <sourcemod>
//#include <sdktools>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_NAME			"Jagd balancer"
#define PLUGIN_AUTHOR		"Root"
#define PLUGIN_VERSION		"1.0"
#define PLUGIN_CONTACT		"http://steamcommunity.com/id/zadroot/"
#define SPEC				1
#define ALLIES				2
#define AXIS				3

// ====[ VARIABLES ]===================================================
new Handle:g_BonusRoundValue = INVALID_HANDLE;

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
	name			= PLUGIN_NAME,
	author			= PLUGIN_AUTHOR,
	description		= "Swap teams at round start on jagd",
	version			= PLUGIN_VERSION,
	url				= PLUGIN_CONTACT
};

/* OnPluginStart()
 *
 * When the plugin starts up.
 * --------------------------------------------------------------------- */
public OnPluginStart()
{
	// Create convars
	CreateConVar("jagdswitcher_version", PLUGIN_VERSION, "Plugin version", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED);

	// Check value for dod_bonusroundtime cvar then create timer with same value
	g_BonusRoundValue = FindConVar("dod_bonusroundtime");

	// Hook events
	HookEvent("dod_round_win", Event_round_end);
}

/* Event_round_starts()
 *
 * Called when a round starts.
 * --------------------------------------------------------------------- */
public Event_round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Check if current map is jagd
	decl String:curmap[64];
	GetCurrentMap(curmap, sizeof(curmap));
	if (StrEqual(curmap, "dod_jagd") || StrEqual(curmap, "dod_strand"))
	{
		// Yep, its jagd. Let's call switch event when round starts and event when player changes team
		HookEvent("player_team", Event_changeteam, EventHookMode_Pre);
		new Float:time = float(GetConVarInt(g_BonusRoundValue));
		CreateTimer(time, StartSwitch);
	}
}

/* Event_changeteam()
 *
 * Called when a player changes team.
 * --------------------------------------------------------------------- */
public Action:Event_changeteam(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Lets hide message '*Player joined Wermacht/U.S'
	if (!dontBroadcast && !GetEventBool(event, "silent"))
	{
		SetEventBroadcast(event, true);
	}
	return Plugin_Continue;
}

/* StartSwitch()
 *
 * Switch a teams on a delay.
 * --------------------------------------------------------------------- */
public Action:StartSwitch(Handle:timer)
{
	SwitchTeams();
}

/* GetOtherTeam()
 *
 * Check current player's team and switch to other.
 * --------------------------------------------------------------------- */
public Action:SwitchTeams()
{
	// Switch function written by <eVa>Dog
	for (new client = 1; client <= MaxClients; client++)
	{
		// Checking clients
		if (IsClientInGame(client) && (GetClientTeam(client) == ALLIES)) // is player on US?
		{
			// Yep, get the other team
			ChangeClientTeam(client, SPEC);
			ChangeClientTeam(client, AXIS);
			ShowVGUIPanel(client, "class_ger", INVALID_HANDLE, false);
		}
		else if (IsClientInGame(client) && (GetClientTeam(client) == AXIS)) // Nope, he is GER
		{
			// You probably want ask - why players moving to spectators? Its needed for switching teams without deaths (old DoD:S bug: you dont die when you joined spectators)
			ChangeClientTeam(client, SPEC);
			ChangeClientTeam(client, ALLIES);
			ShowVGUIPanel(client, "class_us", INVALID_HANDLE, false);
		}
	}
	UnhookEvent("player_team", Event_changeteam, EventHookMode_Pre);
	return Plugin_Handled;
}