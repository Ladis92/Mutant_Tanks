// Super Tanks++: Smash Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flSmashRange[ST_MAXTYPES + 1], g_flSmashRange2[ST_MAXTYPES + 1];
int g_iSmashAbility[ST_MAXTYPES + 1], g_iSmashAbility2[ST_MAXTYPES + 1], g_iSmashChance[ST_MAXTYPES + 1], g_iSmashChance2[ST_MAXTYPES + 1], g_iSmashHit[ST_MAXTYPES + 1], g_iSmashHit2[ST_MAXTYPES + 1], g_iSmashRangeChance[ST_MAXTYPES + 1], g_iSmashRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Smash Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_BLOOD);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iSmashChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmashChance[ST_TankType(attacker)] : g_iSmashChance2[ST_TankType(attacker)],
					iSmashHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmashHit[ST_TankType(attacker)] : g_iSmashHit2[ST_TankType(attacker)];
				vSmashHit(victim, iSmashChance, iSmashHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0)) : (g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]));
			main ? (g_iSmashAbility[iIndex] = iSetCellLimit(g_iSmashAbility[iIndex], 0, 1)) : (g_iSmashAbility2[iIndex] = iSetCellLimit(g_iSmashAbility2[iIndex], 0, 1));
			main ? (g_iSmashChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", 4)) : (g_iSmashChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", g_iSmashChance[iIndex]));
			main ? (g_iSmashChance[iIndex] = iSetCellLimit(g_iSmashChance[iIndex], 1, 9999999999)) : (g_iSmashChance2[iIndex] = iSetCellLimit(g_iSmashChance2[iIndex], 1, 9999999999));
			main ? (g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0)) : (g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]));
			main ? (g_iSmashHit[iIndex] = iSetCellLimit(g_iSmashHit[iIndex], 0, 1)) : (g_iSmashHit2[iIndex] = iSetCellLimit(g_iSmashHit2[iIndex], 0, 1));
			main ? (g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0)) : (g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]));
			main ? (g_flSmashRange[iIndex] = flSetFloatLimit(g_flSmashRange[iIndex], 1.0, 9999999999.0)) : (g_flSmashRange2[iIndex] = flSetFloatLimit(g_flSmashRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iSmashRangeChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", 16)) : (g_iSmashRangeChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", g_iSmashRangeChance[iIndex]));
			main ? (g_iSmashRangeChance[iIndex] = iSetCellLimit(g_iSmashRangeChance[iIndex], 1, 9999999999)) : (g_iSmashRangeChance2[iIndex] = iSetCellLimit(g_iSmashRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId),
			iSmashAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSmashAbility[ST_TankType(iTank)] : g_iSmashAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iSmashAbility == 1 && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					AcceptEntityInput(iCorpse, "Kill");
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iSmashAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSmashAbility[ST_TankType(client)] : g_iSmashAbility2[ST_TankType(client)],
			iSmashRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iSmashChance[ST_TankType(client)] : g_iSmashChance2[ST_TankType(client)];
		float flSmashRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmashRange[ST_TankType(client)] : g_flSmashRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmashRange)
				{
					vSmashHit(iSurvivor, iSmashRangeChance, iSmashAbility);
				}
			}
		}
	}
}

void vSmashHit(int client, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		EmitSoundToAll(SOUND_SMASH, client);
		vAttachParticle(client, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(client);
	}
}