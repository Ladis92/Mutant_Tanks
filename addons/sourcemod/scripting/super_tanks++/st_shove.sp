// Super Tanks++: Shove Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = "The Super Tank shoves survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShove[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sShoveEffect[ST_MAXTYPES + 1][4], g_sShoveEffect2[ST_MAXTYPES + 1][4];

float g_flShoveChance[ST_MAXTYPES + 1], g_flShoveChance2[ST_MAXTYPES + 1], g_flShoveDuration[ST_MAXTYPES + 1], g_flShoveDuration2[ST_MAXTYPES + 1], g_flShoveInterval[ST_MAXTYPES + 1], g_flShoveInterval2[ST_MAXTYPES + 1], g_flShoveRange[ST_MAXTYPES + 1], g_flShoveRange2[ST_MAXTYPES + 1], g_flShoveRangeChance[ST_MAXTYPES + 1], g_flShoveRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKShovePlayer;

int g_iShoveAbility[ST_MAXTYPES + 1], g_iShoveAbility2[ST_MAXTYPES + 1], g_iShoveHit[ST_MAXTYPES + 1], g_iShoveHit2[ST_MAXTYPES + 1], g_iShoveHitMode[ST_MAXTYPES + 1], g_iShoveHitMode2[ST_MAXTYPES + 1], g_iShoveMessage[ST_MAXTYPES + 1], g_iShoveMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Shove Ability only supports Left 4 Dead 1 & 2.");

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

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();

	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_PREFIX);
	}

	delete gdSuperTanks;

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

	g_bShove[client] = false;
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

		if ((iShoveHitMode(attacker) == 0 || iShoveHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShoveHit(victim, attacker, flShoveChance(attacker), iShoveHit(attacker), 1, "1");
			}
		}
		else if ((iShoveHitMode(victim) == 0 || iShoveHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShoveHit(attacker, victim, flShoveChance(victim), iShoveHit(victim), 1, "2");
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

				g_iShoveAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", 0);
				g_iShoveAbility[iIndex] = iClamp(g_iShoveAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect[iIndex], sizeof(g_sShoveEffect[]), "123");
				g_iShoveMessage[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Message", 0);
				g_iShoveMessage[iIndex] = iClamp(g_iShoveMessage[iIndex], 0, 3);
				g_flShoveChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", 33.3);
				g_flShoveChance[iIndex] = flClamp(g_flShoveChance[iIndex], 0.1, 100.0);
				g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", 5.0);
				g_flShoveDuration[iIndex] = flClamp(g_flShoveDuration[iIndex], 0.1, 9999999999.0);
				g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", 0);
				g_iShoveHit[iIndex] = iClamp(g_iShoveHit[iIndex], 0, 1);
				g_iShoveHitMode[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", 0);
				g_iShoveHitMode[iIndex] = iClamp(g_iShoveHitMode[iIndex], 0, 2);
				g_flShoveInterval[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", 1.0);
				g_flShoveInterval[iIndex] = flClamp(g_flShoveInterval[iIndex], 0.1, 9999999999.0);
				g_flShoveRange[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", 150.0);
				g_flShoveRange[iIndex] = flClamp(g_flShoveRange[iIndex], 1.0, 9999999999.0);
				g_flShoveRangeChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", 15.0);
				g_flShoveRangeChance[iIndex] = flClamp(g_flShoveRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iShoveAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[iIndex]);
				g_iShoveAbility2[iIndex] = iClamp(g_iShoveAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect2[iIndex], sizeof(g_sShoveEffect2[]), g_sShoveEffect[iIndex]);
				g_iShoveMessage2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Message", g_iShoveMessage[iIndex]);
				g_iShoveMessage2[iIndex] = iClamp(g_iShoveMessage2[iIndex], 0, 3);
				g_flShoveChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", g_flShoveChance[iIndex]);
				g_flShoveChance2[iIndex] = flClamp(g_flShoveChance2[iIndex], 0.1, 100.0);
				g_flShoveDuration2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[iIndex]);
				g_flShoveDuration2[iIndex] = flClamp(g_flShoveDuration2[iIndex], 0.1, 9999999999.0);
				g_iShoveHit2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", g_iShoveHit[iIndex]);
				g_iShoveHit2[iIndex] = iClamp(g_iShoveHit2[iIndex], 0, 1);
				g_iShoveHitMode2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", g_iShoveHitMode[iIndex]);
				g_iShoveHitMode2[iIndex] = iClamp(g_iShoveHitMode2[iIndex], 0, 2);
				g_flShoveInterval2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", g_flShoveInterval[iIndex]);
				g_flShoveInterval2[iIndex] = flClamp(g_flShoveInterval2[iIndex], 0.1, 9999999999.0);
				g_flShoveRange2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", g_flShoveRange[iIndex]);
				g_flShoveRange2[iIndex] = flClamp(g_flShoveRange2[iIndex], 1.0, 9999999999.0);
				g_flShoveRangeChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", g_flShoveRangeChance[iIndex]);
				g_flShoveRangeChance2[iIndex] = flClamp(g_flShoveRangeChance2[iIndex], 0.1, 100.0);
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
		int iShoveAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iShoveAbility[ST_TankType(tank)] : g_iShoveAbility2[ST_TankType(tank)];

		float flShoveRange = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveRange[ST_TankType(tank)] : g_flShoveRange2[ST_TankType(tank)],
			flShoveRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveRangeChance[ST_TankType(tank)] : g_flShoveRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShoveRange)
				{
					vShoveHit(iSurvivor, tank, flShoveRangeChance, iShoveAbility, 2, "3");
				}
			}
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShove[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int message)
{
	g_bShove[survivor] = false;

	if (iShoveMessage(tank) == message || iShoveMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Shove2", survivor);
	}
}

static void vShoveHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bShove[survivor])
	{
		g_bShove[survivor] = true;

		float flShoveInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveInterval[ST_TankType(tank)] : g_flShoveInterval2[ST_TankType(tank)];
		DataPack dpShove;
		CreateDataTimer(flShoveInterval, tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShove.WriteCell(GetClientUserId(survivor));
		dpShove.WriteCell(GetClientUserId(tank));
		dpShove.WriteCell(message);
		dpShove.WriteCell(enabled);
		dpShove.WriteFloat(GetEngineTime());

		char sShoveEffect[4];
		sShoveEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sShoveEffect[ST_TankType(tank)] : g_sShoveEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sShoveEffect, mode);

		if (iShoveMessage(tank) == message || iShoveMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Shove", sTankName, survivor);
		}
	}
}

static float flShoveChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flShoveChance[ST_TankType(tank)] : g_flShoveChance2[ST_TankType(tank)];
}

static int iShoveHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShoveHit[ST_TankType(tank)] : g_iShoveHit2[ST_TankType(tank)];
}

static int iShoveHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShoveHitMode[ST_TankType(tank)] : g_iShoveHitMode2[ST_TankType(tank)];
}

static int iShoveMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShoveMessage[ST_TankType(tank)] : g_iShoveMessage2[ST_TankType(tank)];
}

public Action tTimerShove(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bShove[iSurvivor])
	{
		g_bShove[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iShoveChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iShoveChat);

		return Plugin_Stop;
	}

	int iShoveAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flShoveDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShoveDuration[ST_TankType(iTank)] : g_flShoveDuration2[ST_TankType(iTank)];

	if (iShoveAbility == 0 || (flTime + flShoveDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iShoveChat);

		return Plugin_Stop;
	}

	float flOrigin[3];
	GetClientAbsOrigin(iSurvivor, flOrigin);

	SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);

	return Plugin_Continue;
}