// Super Tanks++: Lag Ability
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Lag Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors lag.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLag[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sLagEffect[ST_MAXTYPES + 1][4], g_sLagEffect2[ST_MAXTYPES + 1][4];

float g_flLagChance[ST_MAXTYPES + 1], g_flLagChance2[ST_MAXTYPES + 1], g_flLagDuration[ST_MAXTYPES + 1], g_flLagDuration2[ST_MAXTYPES + 1], g_flLagPosition[MAXPLAYERS + 1][4], g_flLagRange[ST_MAXTYPES + 1], g_flLagRange2[ST_MAXTYPES + 1], g_flLagRangeChance[ST_MAXTYPES + 1], g_flLagRangeChance2[ST_MAXTYPES + 1];

int g_iLagAbility[ST_MAXTYPES + 1], g_iLagAbility2[ST_MAXTYPES + 1], g_iLagHit[ST_MAXTYPES + 1], g_iLagHit2[ST_MAXTYPES + 1], g_iLagHitMode[ST_MAXTYPES + 1], g_iLagHitMode2[ST_MAXTYPES + 1], g_iLagMessage[ST_MAXTYPES + 1], g_iLagMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Lag Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bLag[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iLagHitMode(attacker) == 0 || iLagHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLagHit(victim, attacker, flLagChance(attacker), iLagHit(attacker), 1, "1");
			}
		}
		else if ((iLagHitMode(victim) == 0 || iLagHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLagHit(attacker, victim, flLagChance(victim), iLagHit(victim), 1, "2");
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iLagAbility[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Enabled", 0);
				g_iLagAbility[iIndex] = iClamp(g_iLagAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Lag Ability/Ability Effect", g_sLagEffect[iIndex], sizeof(g_sLagEffect[]), "123");
				g_iLagMessage[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Message", 0);
				g_iLagMessage[iIndex] = iClamp(g_iLagMessage[iIndex], 0, 3);
				g_flLagChance[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Chance", 33.3);
				g_flLagChance[iIndex] = flClamp(g_flLagChance[iIndex], 0.1, 100.0);
				g_flLagDuration[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Duration", 5.0);
				g_flLagDuration[iIndex] = flClamp(g_flLagDuration[iIndex], 0.1, 9999999999.0);
				g_iLagHit[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit", 0);
				g_iLagHit[iIndex] = iClamp(g_iLagHit[iIndex], 0, 1);
				g_iLagHitMode[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit Mode", 0);
				g_iLagHitMode[iIndex] = iClamp(g_iLagHitMode[iIndex], 0, 2);
				g_flLagRange[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range", 150.0);
				g_flLagRange[iIndex] = flClamp(g_flLagRange[iIndex], 1.0, 9999999999.0);
				g_flLagRangeChance[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range Chance", 15.0);
				g_flLagRangeChance[iIndex] = flClamp(g_flLagRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iLagAbility2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Enabled", g_iLagAbility[iIndex]);
				g_iLagAbility2[iIndex] = iClamp(g_iLagAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Lag Ability/Ability Effect", g_sLagEffect2[iIndex], sizeof(g_sLagEffect2[]), g_sLagEffect[iIndex]);
				g_iLagMessage2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Message", g_iLagMessage[iIndex]);
				g_iLagMessage2[iIndex] = iClamp(g_iLagMessage2[iIndex], 0, 3);
				g_flLagChance2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Chance", g_flLagChance[iIndex]);
				g_flLagChance2[iIndex] = flClamp(g_flLagChance2[iIndex], 0.1, 100.0);
				g_flLagDuration2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Duration", g_flLagDuration[iIndex]);
				g_flLagDuration2[iIndex] = flClamp(g_flLagDuration2[iIndex], 0.1, 9999999999.0);
				g_iLagHit2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit", g_iLagHit[iIndex]);
				g_iLagHit2[iIndex] = iClamp(g_iLagHit2[iIndex], 0, 1);
				g_iLagHitMode2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit Mode", g_iLagHitMode[iIndex]);
				g_iLagHitMode2[iIndex] = iClamp(g_iLagHitMode2[iIndex], 0, 2);
				g_flLagRange2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range", g_flLagRange[iIndex]);
				g_flLagRange2[iIndex] = flClamp(g_flLagRange2[iIndex], 1.0, 9999999999.0);
				g_flLagRangeChance2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range Chance", g_flLagRangeChance[iIndex]);
				g_flLagRangeChance2[iIndex] = flClamp(g_flLagRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flLagRange = !g_bTankConfig[ST_TankType(tank)] ? g_flLagRange[ST_TankType(tank)] : g_flLagRange2[ST_TankType(tank)],
			flLagRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flLagRangeChance[ST_TankType(tank)] : g_flLagRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flLagRange)
				{
					vLagHit(iSurvivor, tank, flLagRangeChance, iLagAbility(tank), 2, "3");
				}
			}
		}
	}
}

static void vLagHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bLag[survivor])
	{
		g_bLag[survivor] = true;

		float flPos[3];
		GetClientAbsOrigin(survivor, flPos);
		g_flLagPosition[survivor][1] = flPos[0];
		g_flLagPosition[survivor][2] = flPos[1];
		g_flLagPosition[survivor][3] = flPos[2];

		DataPack dpLagTeleport;
		CreateDataTimer(1.0, tTimerLagTeleport, dpLagTeleport, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpLagTeleport.WriteCell(GetClientUserId(survivor));
		dpLagTeleport.WriteCell(GetClientUserId(tank));
		dpLagTeleport.WriteCell(message);
		dpLagTeleport.WriteCell(enabled);
		dpLagTeleport.WriteFloat(GetEngineTime());

		DataPack dpLagPosition;
		CreateDataTimer(0.5, tTimerLagPosition, dpLagPosition, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpLagPosition.WriteCell(GetClientUserId(survivor));
		dpLagPosition.WriteCell(GetClientUserId(tank));
		dpLagPosition.WriteCell(enabled);
		dpLagPosition.WriteFloat(GetEngineTime());

		char sLagEffect[4];
		sLagEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sLagEffect[ST_TankType(tank)] : g_sLagEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sLagEffect, mode);

		if (iLagMessage(tank) == message || iLagMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Lag", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bLag[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int message)
{
	g_bLag[survivor] = false;

	if (iLagMessage(tank) == message || iLagMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Lag2", survivor);
	}
}

static float flLagChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flLagChance[ST_TankType(tank)] : g_flLagChance2[ST_TankType(tank)];
}

static float flLagDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flLagDuration[ST_TankType(tank)] : g_flLagDuration2[ST_TankType(tank)];
}

static int iLagAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLagAbility[ST_TankType(tank)] : g_iLagAbility2[ST_TankType(tank)];
}

static int iLagHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLagHit[ST_TankType(tank)] : g_iLagHit2[ST_TankType(tank)];
}

static int iLagHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLagHitMode[ST_TankType(tank)] : g_iLagHitMode2[ST_TankType(tank)];
}

static int iLagMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLagMessage[ST_TankType(tank)] : g_iLagMessage2[ST_TankType(tank)];
}

public Action tTimerLagTeleport(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bLag[iSurvivor])
	{
		g_bLag[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iLagChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iLagChat);

		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();

	if (iLagEnabled == 0 || (flTime + flLagDuration(iTank) < GetEngineTime()))
	{
		vReset2(iSurvivor, iTank, iLagChat);

		return Plugin_Stop;
	}

	float flPos[3];
	flPos[0] = g_flLagPosition[iSurvivor][1];
	flPos[1] = g_flLagPosition[iSurvivor][2];
	flPos[2] = g_flLagPosition[iSurvivor][3];
	TeleportEntity(iSurvivor, flPos, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Continue;
}

public Action tTimerLagPosition(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bLag[iSurvivor])
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();

	if (iLagEnabled == 0 || (flTime + flLagDuration(iTank) < GetEngineTime()))
	{
		return Plugin_Stop;
	}

	float flPos[3];
	GetClientAbsOrigin(iSurvivor, flPos);
	g_flLagPosition[iSurvivor][1] = flPos[0];
	g_flLagPosition[iSurvivor][2] = flPos[1];
	g_flLagPosition[iSurvivor][3] = flPos[2];

	return Plugin_Continue;
}