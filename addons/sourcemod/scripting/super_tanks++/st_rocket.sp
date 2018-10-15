// Super Tanks++: Rocket Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Rocket Ability",
	author = ST_AUTHOR,
	description = "The Super Tank sends survivors into space.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_FIRE "sprites/sprite_fire01.vmt"

#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_FIRE "weapons/rpg/rocketfire1.wav"
#define SOUND_LAUNCH "npc/env_headcrabcanister/launch.wav"

bool g_bCloneInstalled, g_bLateLoad, g_bRocket[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sRocketEffect[ST_MAXTYPES + 1][4], g_sRocketEffect2[ST_MAXTYPES + 1][4];

float g_flRocketChance[ST_MAXTYPES + 1], g_flRocketChance2[ST_MAXTYPES + 1], g_flRocketDelay[ST_MAXTYPES + 1], g_flRocketDelay2[ST_MAXTYPES + 1], g_flRocketRange[ST_MAXTYPES + 1], g_flRocketRange2[ST_MAXTYPES + 1], g_flRocketRangeChance[ST_MAXTYPES + 1], g_flRocketRangeChance2[ST_MAXTYPES + 1];

int g_iRocket[ST_MAXTYPES + 1], g_iRocketAbility[ST_MAXTYPES + 1], g_iRocketAbility2[ST_MAXTYPES + 1], g_iRocketHit[ST_MAXTYPES + 1], g_iRocketHit2[ST_MAXTYPES + 1], g_iRocketHitMode[ST_MAXTYPES + 1], g_iRocketHitMode2[ST_MAXTYPES + 1], g_iRocketMessage[ST_MAXTYPES + 1], g_iRocketMessage2[ST_MAXTYPES + 1], g_iRocketSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Rocket Ability only supports Left 4 Dead 1 & 2.");

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
	g_iRocketSprite = PrecacheModel(SPRITE_FIRE, true);

	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bRocket[client] = false;
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

		if ((iRocketHitMode(attacker) == 0 || iRocketHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRocketHit(victim, attacker, flRocketChance(attacker), iRocketHit(attacker), 1, "1");
			}
		}
		else if ((iRocketHitMode(victim) == 0 || iRocketHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRocketHit(attacker, victim, flRocketChance(victim), iRocketHit(victim), 1, "2");
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

				g_iRocketAbility[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Enabled", 0);
				g_iRocketAbility[iIndex] = iClamp(g_iRocketAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Rocket Ability/Ability Effect", g_sRocketEffect[iIndex], sizeof(g_sRocketEffect[]), "123");
				g_iRocketMessage[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Message", 0);
				g_iRocketMessage[iIndex] = iClamp(g_iRocketMessage[iIndex], 0, 3);
				g_flRocketChance[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Chance", 33.3);
				g_flRocketChance[iIndex] = flClamp(g_flRocketChance[iIndex], 0.1, 100.0);
				g_flRocketDelay[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Delay", 1.0);
				g_flRocketDelay[iIndex] = flClamp(g_flRocketDelay[iIndex], 0.1, 9999999999.0);
				g_iRocketHit[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit", 0);
				g_iRocketHit[iIndex] = iClamp(g_iRocketHit[iIndex], 0, 1);
				g_iRocketHitMode[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit Mode", 0);
				g_iRocketHitMode[iIndex] = iClamp(g_iRocketHitMode[iIndex], 0, 2);
				g_flRocketRange[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range", 150.0);
				g_flRocketRange[iIndex] = flClamp(g_flRocketRange[iIndex], 1.0, 9999999999.0);
				g_flRocketRangeChance[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range Chance", 15.0);
				g_flRocketRangeChance[iIndex] = flClamp(g_flRocketRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRocketAbility2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Enabled", g_iRocketAbility[iIndex]);
				g_iRocketAbility2[iIndex] = iClamp(g_iRocketAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Rocket Ability/Ability Effect", g_sRocketEffect2[iIndex], sizeof(g_sRocketEffect2[]), g_sRocketEffect[iIndex]);
				g_iRocketMessage2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Message", g_iRocketMessage[iIndex]);
				g_iRocketMessage2[iIndex] = iClamp(g_iRocketMessage2[iIndex], 0, 3);
				g_flRocketChance2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Chance", g_flRocketChance[iIndex]);
				g_flRocketChance2[iIndex] = flClamp(g_flRocketChance2[iIndex], 0.1, 100.0);
				g_flRocketDelay2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Delay", g_flRocketDelay[iIndex]);
				g_flRocketDelay2[iIndex] = flClamp(g_flRocketDelay2[iIndex], 0.1, 9999999999.0);
				g_iRocketHit2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit", g_iRocketHit[iIndex]);
				g_iRocketHit2[iIndex] = iClamp(g_iRocketHit2[iIndex], 0, 1);
				g_iRocketHitMode2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit Mode", g_iRocketHitMode[iIndex]);
				g_iRocketHitMode2[iIndex] = iClamp(g_iRocketHitMode2[iIndex], 0, 2);
				g_flRocketRange2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range", g_flRocketRange[iIndex]);
				g_flRocketRange2[iIndex] = flClamp(g_flRocketRange2[iIndex], 1.0, 9999999999.0);
				g_flRocketRangeChance2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range Chance", g_flRocketRangeChance[iIndex]);
				g_flRocketRangeChance2[iIndex] = flClamp(g_flRocketRangeChance2[iIndex], 0.1, 100.0);
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
		int iRocketAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iRocketAbility[ST_TankType(tank)] : g_iRocketAbility2[ST_TankType(tank)];

		float flRocketRange = !g_bTankConfig[ST_TankType(tank)] ? g_flRocketRange[ST_TankType(tank)] : g_flRocketRange2[ST_TankType(tank)],
			flRocketRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRocketRangeChance[ST_TankType(tank)] : g_flRocketRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRocketRange)
				{
					vRocketHit(iSurvivor, tank, flRocketRangeChance, iRocketAbility, 2, "3");
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
			g_bRocket[iPlayer] = false;
		}
	}
}

static void vRocketHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bRocket[survivor])
	{
		int iFlame = CreateEntityByName("env_steam");
		if (!bIsValidEntity(iFlame))
		{
			return;
		}

		g_bRocket[survivor] = true;

		float flRocketDelay = !g_bTankConfig[ST_TankType(tank)] ? g_flRocketDelay[ST_TankType(tank)] : g_flRocketDelay2[ST_TankType(tank)],
			flPosition[3], flAngles[3];
		GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flPosition);
		flPosition[2] += 30.0;
		flAngles[0] = 90.0;
		flAngles[1] = 0.0;
		flAngles[2] = 0.0;

		DispatchKeyValue(iFlame, "spawnflags", "1");
		DispatchKeyValue(iFlame, "Type", "0");
		DispatchKeyValue(iFlame, "InitialState", "1");
		DispatchKeyValue(iFlame, "Spreadspeed", "10");
		DispatchKeyValue(iFlame, "Speed", "800");
		DispatchKeyValue(iFlame, "Startsize", "10");
		DispatchKeyValue(iFlame, "EndSize", "250");
		DispatchKeyValue(iFlame, "Rate", "15");
		DispatchKeyValue(iFlame, "JetLength", "400");

		SetEntityRenderColor(iFlame, 180, 70, 10, 180);

		TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
		DispatchSpawn(iFlame);
		vSetEntityParent(iFlame, survivor);

		iFlame = EntIndexToEntRef(iFlame);
		vDeleteEntity(iFlame, 3.0);

		g_iRocket[survivor] = iFlame;
		EmitSoundToAll(SOUND_FIRE, survivor, _, _, _, 1.0);

		DataPack dpRocketLaunch;
		CreateDataTimer(flRocketDelay, tTimerRocketLaunch, dpRocketLaunch, TIMER_FLAG_NO_MAPCHANGE);
		dpRocketLaunch.WriteCell(GetClientUserId(survivor));
		dpRocketLaunch.WriteCell(GetClientUserId(tank));
		dpRocketLaunch.WriteCell(enabled);

		DataPack dpRocketDetonate;
		CreateDataTimer(flRocketDelay + 1.5, tTimerRocketDetonate, dpRocketDetonate, TIMER_FLAG_NO_MAPCHANGE);
		dpRocketDetonate.WriteCell(GetClientUserId(survivor));
		dpRocketDetonate.WriteCell(GetClientUserId(tank));
		dpRocketDetonate.WriteCell(message);
		dpRocketDetonate.WriteCell(enabled);

		char sRocketEffect[4];
		sRocketEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sRocketEffect[ST_TankType(tank)] : g_sRocketEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sRocketEffect, mode);
	}
}

static float flRocketChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRocketChance[ST_TankType(tank)] : g_flRocketChance2[ST_TankType(tank)];
}

static int iRocketHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRocketHit[ST_TankType(tank)] : g_iRocketHit2[ST_TankType(tank)];
}

static int iRocketHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRocketHitMode[ST_TankType(tank)] : g_iRocketHitMode2[ST_TankType(tank)];
}

public Action tTimerRocketLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bRocket[iSurvivor])
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iRocketAbility = pack.ReadCell();
	if (iRocketAbility == 0)
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	float flVelocity[3];
	flVelocity[0] = 0.0, flVelocity[1] = 0.0, flVelocity[2] = 800.0;

	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	return Plugin_Handled;
}

public Action tTimerRocketDetonate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bRocket[iSurvivor])
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iRocketChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iRocketAbility = pack.ReadCell();
	if (iRocketAbility == 0)
	{
		g_bRocket[iSurvivor] = false;

		return Plugin_Stop;
	}

	float flPosition[3];
	int iRocketMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iRocketMessage[ST_TankType(iTank)] : g_iRocketMessage2[ST_TankType(iTank)];

	GetClientAbsOrigin(iSurvivor, flPosition);

	TE_SetupExplosion(flPosition, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
	TE_SendToAll();

	g_iRocket[iSurvivor] = 0;

	ForcePlayerSuicide(iSurvivor);
	SetEntityGravity(iSurvivor, 1.0);

	if (iRocketMessage == iRocketChat || iRocketMessage == 3)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(iTank, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Rocket", sTankName, iSurvivor);
	}

	g_bRocket[iSurvivor] = false;

	return Plugin_Handled;
}