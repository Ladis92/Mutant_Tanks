// Super Tanks++: Drop Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Drop Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define MELEE_AXE_V "models/weapons/melee/v_fireaxe.mdl"
#define MELEE_AXE_W "models/weapons/melee/w_fireaxe.mdl"
#define MELEE_BAT_V "models/weapons/melee/v_bat.mdl"
#define MELEE_BAT_W "models/weapons/melee/w_bat.mdl"
#define MELEE_CHAINSAW_V "models/weapons/melee/v_chainsaw.mdl"
#define MELEE_CHAINSAW_W "models/weapons/melee/w_chainsaw.mdl"
#define MELEE_CRICKET_V "models/weapons/melee/v_cricket_bat.mdl"
#define MELEE_CRICKET_W "models/weapons/melee/w_cricket_bat.mdl"
#define MELEE_CROWBAR_V "models/weapons/melee/v_crowbar.mdl"
#define MELEE_CROWBAR_W "models/weapons/melee/w_crowbar.mdl"
#define MELEE_GOLFCLUB_V "models/weapons/melee/v_golfclub.mdl"
#define MELEE_GOLFCLUB_W "models/weapons/melee/w_golfclub.mdl"
#define MELEE_GUITAR_V "models/weapons/melee/v_electric_guitar.mdl"
#define MELEE_GUITAR_W "models/weapons/melee/w_electric_guitar.mdl"
#define MELEE_KATANA_V "models/weapons/melee/v_katana.mdl"
#define MELEE_KATANA_W "models/weapons/melee/w_katana.mdl"
#define MELEE_KNIFE_V "models/v_models/v_knife_t.mdl"
#define MELEE_KNIFE_W "models/w_models/weapons/w_knife_t.mdl"
#define MELEE_MACHETE_V "models/weapons/melee/v_machete.mdl"
#define MELEE_MACHETE_W "models/weapons/melee/w_machete.mdl"
#define MELEE_PAN_V "models/weapons/melee/v_frying_pan.mdl"
#define MELEE_PAN_W "models/weapons/melee/w_frying_pan.mdl"
#define MELEE_TONFA_V "models/weapons/melee/v_tonfa.mdl"
#define MELEE_TONFA_W "models/weapons/melee/w_tonfa.mdl"
#define SCRIPT_AXE "scripts/melee/fireaxe.txt"
#define SCRIPT_BAT "scripts/melee/baseball_bat.txt"
#define SCRIPT_CRICKET "scripts/melee/cricket_bat.txt"
#define SCRIPT_CROWBAR "scripts/melee/crowbar.txt"
#define SCRIPT_GOLFCLUB "scripts/melee/golfclub.txt"
#define SCRIPT_GUITAR "scripts/melee/electric_guitar.txt"
#define SCRIPT_KATANA "scripts/melee/katana.txt"
#define SCRIPT_KNIFE "scripts/melee/knife.txt"
#define SCRIPT_MACHETE "scripts/melee/machete.txt"
#define SCRIPT_PAN "scripts/melee/frying_pan.txt"
#define SCRIPT_TONFA "scripts/melee/tonfa.txt"
#define WEAPON_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON_PISTOL_V "models/v_models/weapons/v_pistol_1911.mdl"
#define WEAPON_PISTOL_W "models/w_models/weapons/w_pistol_1911.mdl"
#define WEAPON_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"
#define WEAPON2_AK47_V "models/v_models/weapons/v_rifle_ak47.mdl"
#define WEAPON2_AK47_W "models/w_models/weapons/w_rifle_ak47.mdl"
#define WEAPON2_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON2_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON2_AWP_V "models/v_models/weapons/v_sniper_awp.mdl"
#define WEAPON2_AWP_W "models/w_models/weapons/w_sniper_awp.mdl"
#define WEAPON2_CHROME_V "models/v_models/weapons/v_shotgun.mdl"
#define WEAPON2_CHROME_W "models/w_models/weapons/w_shotgun.mdl"
#define WEAPON2_DESERT_V "models/v_models/weapons/v_desert_rifle.mdl"
#define WEAPON2_DESERT_W "models/w_models/weapons/w_desert_rifle.mdl"
#define WEAPON2_GRENADE_V "models/v_models/weapons/v_grenade_launcher.mdl"
#define WEAPON2_GRENADE_W "models/w_models/weapons/w_grenade_launcher.mdl"
#define WEAPON2_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON2_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON2_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON2_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON2_M60_V "models/v_models/weapons/v_m60.mdl"
#define WEAPON2_M60_W "models/w_models/weapons/w_m60.mdl"
#define WEAPON2_MAGNUM_V "models/v_models/weapons/v_desert_eagle.mdl"
#define WEAPON2_MAGNUM_W "models/w_models/weapons/w_desert_eagle.mdl"
#define WEAPON2_MILITARY_V "models/v_models/weapons/v_sniper_military.mdl"
#define WEAPON2_MILITARY_W "models/w_models/weapons/w_sniper_military.mdl"
#define WEAPON2_MP5_V "models/v_models/weapons/v_smg_mp5.mdl"
#define WEAPON2_MP5_W "models/w_models/weapons/w_smg_mp5.mdl"
#define WEAPON2_PISTOL_V "models/v_models/weapons/v_pistol_a.mdl"
#define WEAPON2_PISTOL_W "models/w_models/weapons/w_pistol_a.mdl"
#define WEAPON2_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON2_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON2_SCOUT_V "models/v_models/weapons/v_sniper_scout.mdl"
#define WEAPON2_SCOUT_W "models/w_models/weapons/w_sniper_scout.mdl"
#define WEAPON2_SG552_V "models/v_models/weapons/v_rifle_sg552.mdl"
#define WEAPON2_SG552_W "models/w_models/weapons/w_rifle_sg552.mdl"
#define WEAPON2_SILENCED_V "models/v_models/weapons/v_smg_a.mdl"
#define WEAPON2_SILENCED_W "models/w_models/weapons/w_smg_a.mdl"
#define WEAPON2_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON2_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"
#define WEAPON2_SPAS_V "models/v_models/weapons/v_shotgun_spas.mdl"
#define WEAPON2_SPAS_W "models/w_models/weapons/w_shotgun_spas.mdl"

bool g_bDrop[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sWeaponClass[32][128];
char g_sWeaponModel[32][128];
ConVar g_cvSTFindConVar[7];
float g_flDropWeaponScale[ST_MAXTYPES + 1];
float g_flDropWeaponScale2[ST_MAXTYPES + 1];
int g_iDrop[MAXPLAYERS + 1];
int g_iDropAbility[ST_MAXTYPES + 1];
int g_iDropAbility2[ST_MAXTYPES + 1];
int g_iDropChance[ST_MAXTYPES + 1];
int g_iDropChance2[ST_MAXTYPES + 1];
int g_iDropClipChance[ST_MAXTYPES + 1];
int g_iDropClipChance2[ST_MAXTYPES + 1];
int g_iDropWeapon[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Drop Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
	g_cvSTFindConVar[0] = bIsL4D2Game() ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTFindConVar[1] = bIsL4D2Game() ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTFindConVar[2] = FindConVar("ammo_huntingrifle_max");
	g_cvSTFindConVar[3] = FindConVar("ammo_assaultrifle_max");
	g_cvSTFindConVar[4] = FindConVar("ammo_grenadelauncher_max");
	g_cvSTFindConVar[5] = FindConVar("ammo_smg_max");
	g_cvSTFindConVar[6] = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vReset(iPlayer);
		}
	}
	PrecacheModel(MELEE_AXE_V, true);
	PrecacheModel(MELEE_AXE_W, true);
	PrecacheModel(MELEE_CHAINSAW_V, true);
	PrecacheModel(MELEE_CHAINSAW_W, true);
	PrecacheModel(MELEE_CRICKET_V, true);
	PrecacheModel(MELEE_CRICKET_W, true);
	PrecacheModel(MELEE_CROWBAR_V, true);
	PrecacheModel(MELEE_CROWBAR_W, true);
	PrecacheModel(MELEE_GOLFCLUB_V, true);
	PrecacheModel(MELEE_GOLFCLUB_W, true);
	PrecacheModel(MELEE_GUITAR_V, true);
	PrecacheModel(MELEE_GUITAR_W, true);
	PrecacheModel(MELEE_KATANA_V, true);
	PrecacheModel(MELEE_KATANA_W, true);
	PrecacheModel(MELEE_KNIFE_V, true);
	PrecacheModel(MELEE_KNIFE_W, true);
	PrecacheModel(MELEE_MACHETE_V, true);
	PrecacheModel(MELEE_MACHETE_W, true);
	PrecacheModel(MELEE_PAN_V, true);
	PrecacheModel(MELEE_PAN_W, true);
	PrecacheModel(MELEE_TONFA_V, true);
	PrecacheModel(MELEE_TONFA_W, true);
	PrecacheGeneric(SCRIPT_AXE, true);
	PrecacheGeneric(SCRIPT_BAT, true);
	PrecacheGeneric(SCRIPT_CRICKET, true);
	PrecacheGeneric(SCRIPT_CROWBAR, true);
	PrecacheGeneric(SCRIPT_GOLFCLUB, true);
	PrecacheGeneric(SCRIPT_GUITAR, true);
	PrecacheGeneric(SCRIPT_KATANA, true);
	PrecacheGeneric(SCRIPT_KNIFE, true);
	PrecacheGeneric(SCRIPT_MACHETE, true);
	PrecacheGeneric(SCRIPT_PAN, true);
	PrecacheGeneric(SCRIPT_TONFA, true);
	PrecacheModel(WEAPON2_AWP_V, true);
	PrecacheModel(WEAPON2_AWP_W, true);
	PrecacheModel(WEAPON2_GRENADE_V, true);
	PrecacheModel(WEAPON2_GRENADE_W, true);
	PrecacheModel(WEAPON2_M60_V, true);
	PrecacheModel(WEAPON2_M60_W, true);
	PrecacheModel(WEAPON2_MP5_V, true);
	PrecacheModel(WEAPON2_MP5_W, true);
	PrecacheModel(WEAPON2_SCOUT_V, true);
	PrecacheModel(WEAPON2_SCOUT_W, true);
	PrecacheModel(WEAPON2_SG552_V, true);
	PrecacheModel(WEAPON2_SG552_W, true);
	if (bIsL4D2Game())
	{
		g_sWeaponModel[1] = WEAPON2_AK47_W;
		g_sWeaponModel[2] = WEAPON2_AUTO_W;
		g_sWeaponModel[3] = WEAPON2_AWP_W;
		g_sWeaponModel[4] = WEAPON2_CHROME_W;
		g_sWeaponModel[5] = WEAPON2_DESERT_W;
		g_sWeaponModel[6] = WEAPON2_GRENADE_W;
		g_sWeaponModel[7] = WEAPON2_HUNT_W;
		g_sWeaponModel[8] = WEAPON2_M16_W;
		g_sWeaponModel[9] = WEAPON2_M60_W;
		g_sWeaponModel[10] = WEAPON2_MAGNUM_W;
		g_sWeaponModel[11] = WEAPON2_MILITARY_W;
		g_sWeaponModel[12] = WEAPON2_MP5_W;
		g_sWeaponModel[13] = WEAPON2_PUMP_W;
		g_sWeaponModel[14] = WEAPON2_PUMP_W;
		g_sWeaponModel[15] = WEAPON2_SCOUT_W;
		g_sWeaponModel[16] = WEAPON2_SG552_W;
		g_sWeaponModel[17] = WEAPON2_SILENCED_W;
		g_sWeaponModel[18] = WEAPON2_SMG_W;
		g_sWeaponModel[19] = WEAPON2_SPAS_W;
		g_sWeaponModel[20] = MELEE_AXE_W;
		g_sWeaponModel[21] = MELEE_BAT_W;
		g_sWeaponModel[22] = MELEE_CHAINSAW_W;
		g_sWeaponModel[23] = MELEE_CRICKET_W;
		g_sWeaponModel[24] = MELEE_CROWBAR_W;
		g_sWeaponModel[25] = MELEE_GOLFCLUB_W;
		g_sWeaponModel[26] = MELEE_GUITAR_W;
		g_sWeaponModel[27] = MELEE_KATANA_W;
		g_sWeaponModel[28] = MELEE_KNIFE_W;
		g_sWeaponModel[29] = MELEE_MACHETE_W;
		g_sWeaponModel[30] = MELEE_PAN_W;
		g_sWeaponModel[31] = MELEE_TONFA_W;
		g_sWeaponClass[1] = "weapon_rifle_ak47";
		g_sWeaponClass[2] = "weapon_autoshotgun";
		g_sWeaponClass[3] = "weapon_sniper_awp";
		g_sWeaponClass[4] = "weapon_shotgun_chrome";
		g_sWeaponClass[5] = "weapon_rifle_desert";
		g_sWeaponClass[6] = "weapon_grenade_launcher";
		g_sWeaponClass[7] = "weapon_hunting_rifle";
		g_sWeaponClass[8] = "weapon_rifle";
		g_sWeaponClass[9] = "weapon_rifle_m60";
		g_sWeaponClass[10] = "weapon_pistol_magnum";
		g_sWeaponClass[11] = "weapon_sniper_military";
		g_sWeaponClass[12] = "weapon_smg_mp5";
		g_sWeaponClass[13] = "weapon_pistol";
		g_sWeaponClass[14] = "weapon_pumpshotgun";
		g_sWeaponClass[15] = "weapon_sniper_scout";
		g_sWeaponClass[16] = "weapon_rifle_sg552";
		g_sWeaponClass[17] = "weapon_smg_silenced";
		g_sWeaponClass[18] = "weapon_smg";
		g_sWeaponClass[19] = "weapon_shotgun_spas";
		g_sWeaponClass[20] = "fireaxe";
		g_sWeaponClass[21] = "baseball_bat";
		g_sWeaponClass[22] = "weapon_chainsaw";
		g_sWeaponClass[23] = "cricket_bat";
		g_sWeaponClass[24] = "crowbar";
		g_sWeaponClass[25] = "golfclub";
		g_sWeaponClass[26] = "electric_guitar";
		g_sWeaponClass[27] = "katana";
		g_sWeaponClass[28] = "knife";
		g_sWeaponClass[29] = "machete";
		g_sWeaponClass[30] = "frying_pan";
		g_sWeaponClass[31] = "tonfa";
	}
	else
	{
		g_sWeaponModel[1] = WEAPON_AUTO_W;
		g_sWeaponModel[2] = WEAPON_HUNT_W;
		g_sWeaponModel[3] = WEAPON_M16_W;
		g_sWeaponModel[4] = WEAPON_PISTOL_W;
		g_sWeaponModel[5] = WEAPON_PUMP_W;
		g_sWeaponModel[6] = WEAPON_SMG_W;
		g_sWeaponClass[1] = "weapon_autoshotgun";
		g_sWeaponClass[2] = "weapon_hunting_rifle";
		g_sWeaponClass[3] = "weapon_rifle";
		g_sWeaponClass[4] = "weapon_pistol";
		g_sWeaponClass[5] = "weapon_pumpshotgun";
		g_sWeaponClass[6] = "weapon_smg";
	}
}

public void OnClientPostAdminCheck(int client)
{
	vReset(client);
}

public void OnClientDisconnect(int client)
{
	vReset(client);
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vReset(iPlayer);
		}
	}
}

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (iOwner == client)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void ST_Configs(char[] savepath, int limit, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = 1; iIndex <= limit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iDropAbility[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", 0)) : (g_iDropAbility2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", g_iDropAbility[iIndex]));
			main ? (g_iDropAbility[iIndex] = iSetCellLimit(g_iDropAbility[iIndex], 0, 1)) : (g_iDropAbility2[iIndex] = iSetCellLimit(g_iDropAbility2[iIndex], 0, 1));
			main ? (g_iDropChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", 4)) : (g_iDropChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", g_iDropChance[iIndex]));
			main ? (g_iDropChance[iIndex] = iSetCellLimit(g_iDropChance[iIndex], 1, 9999999999)) : (g_iDropChance2[iIndex] = iSetCellLimit(g_iDropChance2[iIndex], 1, 9999999999));
			main ? (g_iDropClipChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", 4)) : (g_iDropClipChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", g_iDropClipChance[iIndex]));
			main ? (g_iDropClipChance[iIndex] = iSetCellLimit(g_iDropClipChance[iIndex], 1, 9999999999)) : (g_iDropClipChance2[iIndex] = iSetCellLimit(g_iDropClipChance2[iIndex], 1, 9999999999));
			main ? (g_flDropWeaponScale[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", 1.0)) : (g_flDropWeaponScale2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", g_flDropWeaponScale[iIndex]));
			main ? (g_flDropWeaponScale[iIndex] = flSetFloatLimit(g_flDropWeaponScale[iIndex], 1.0, 2.0)) : (g_flDropWeaponScale2[iIndex] = flSetFloatLimit(g_flDropWeaponScale2[iIndex], 1.0, 2.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	int iDropChance = !g_bTankConfig[ST_TankType(client)] ? g_iDropChance[ST_TankType(client)] : g_iDropChance2[ST_TankType(client)];
	if (bIsTank(client) && bIsValidEntity(g_iDrop[client]) && GetRandomInt(1, iDropChance) == 1)
	{
		float flDropWeaponScale = !g_bTankConfig[ST_TankType(client)] ? g_flDropWeaponScale[ST_TankType(client)] : g_flDropWeaponScale[ST_TankType(client)];
		float flPos[3];
		float flAngle[3];
		GetClientEyePosition(client, flPos);
		GetClientAbsAngles(client, flAngle);
		if (StrContains(g_sWeaponClass[g_iDropWeapon[client]], "weapon") != -1)
		{
			int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[client]]);
			if (bIsValidEntity(iDrop))
			{
				TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
				DispatchSpawn(iDrop);
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flDropWeaponScale);
				}
			}
			int iAmmo;
			int iClip;
			if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_autoshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_shotgun_spas") == 0)
			{
				iAmmo = g_cvSTFindConVar[0].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_pumpshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_shotgun_chrome") == 0)
			{
				iAmmo = g_cvSTFindConVar[1].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_hunting_rifle") == 0)
			{
				iAmmo = g_cvSTFindConVar[2].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_ak47") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_desert") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_sg552") == 0)
			{
				iAmmo = g_cvSTFindConVar[3].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_grenade_launcher") == 0)
			{
				iAmmo = g_cvSTFindConVar[4].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg_silenced") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg_mp5") == 0)
			{
				iAmmo = g_cvSTFindConVar[5].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_scout") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_military") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_awp") == 0)
			{
				iAmmo = g_cvSTFindConVar[6].IntValue;
			}
			int iDropClipChance = !g_bTankConfig[ST_TankType(client)] ? g_iDropClipChance[ST_TankType(client)] : g_iDropClipChance2[ST_TankType(client)];
			if (GetRandomInt(1, iDropClipChance) == 1)
			{
				iClip = iAmmo; 
			}
			if (iClip > 0)
			{
				SetEntProp(iDrop, Prop_Send, "m_iClip1", iClip);
			}
			if (iAmmo > 0)
			{
				SetEntProp(iDrop, Prop_Send, "m_iExtraPrimaryAmmo", iAmmo);
			}
		}
		else
		{
			int iDrop = CreateEntityByName("weapon_melee");
			if (bIsValidEntity(iDrop))
			{
				DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[client]]);
				TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
				DispatchSpawn(iDrop);
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iDrop, Prop_Send,"m_flModelScale", flDropWeaponScale);
				}
			}
		}
	}
	vDeleteDrop(client);
}

public void ST_Spawn(int client)
{
	int iDropAbility = !g_bTankConfig[ST_TankType(client)] ? g_iDropAbility[ST_TankType(client)] : g_iDropAbility2[ST_TankType(client)];
	if (iDropAbility == 1 && bIsTank(client) && !g_bDrop[client])
	{
		g_bDrop[client] = true;
		CreateTimer(1.0, tTimerDrop, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vDeleteDrop(int client)
{
	if (bIsValidEntity(g_iDrop[client]))
	{
		vDeleteEntity(g_iDrop[client]);
		SDKUnhook(g_iDrop[client], SDKHook_SetTransmit, SetTransmit);
	}
	g_iDrop[client] = 0;
}

void vGetPosAng(float pos[3], float angle[3], int position, float &scale)
{
	switch (position)
	{
		case 1:
		{
			vSetVector(pos, 1.0, -5.0, 3.0);
			vSetVector(angle, 0.0, -90.0, 90.0);
		}
		case 2:
		{
			vSetVector(pos, 4.0, -5.0, -3.0);
			vSetVector(angle, 0.0, -90.0, 90.0);
		}
	}
}

void vGetPosAng2(int client, int weapon, float pos[3], float angle[3], int position, float &scale)
{
	if (weapon == 22)
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, -23.0, -30.0, -5.0);
				vSetVector(angle, 0.0, 60.0, 180.0);
			}
			case 2:
			{
				vSetVector(pos, -9.0, -32.0, -1.0);
				vSetVector(angle, 0.0, 60.0, 180.0);
			}
		}
	}
	else if (weapon >= 1)
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, 1.0, -5.0, 3.0);
				vSetVector(angle, 0.0, -90.0, 90.0);
			}
			case 2:
			{
				vSetVector(pos, 4.0, -5.0, -3.0);
				vSetVector(angle, 0.0, -90.0, 90.0);
			}
		}
	}	
	else
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, -4.0, 0.0, 3.0);
				vSetVector(angle, 0.0, -11.0, 100.0);
			}
			case 2:
			{
				vSetVector(pos, 4.0, 0.0, -3.0);
				vSetVector(angle, 0.0, -11.0, 100.0);
			}
		}
	}
	scale = 2.5;
	switch (weapon)
	{
		case 22: scale = 2.0;
		case 23: scale = 1.7;
		case 26: scale = 2.3;
		case 27: scale = 3.0;
		case 29: scale = 4.0;
		case 30: scale = 3.5;
	}
	float flDropWeaponScale = !g_bTankConfig[ST_TankType(client)] ? g_flDropWeaponScale[ST_TankType(client)] : g_flDropWeaponScale2[ST_TankType(client)];
	scale = scale * flDropWeaponScale;
}

void vReset(int client)
{
	g_bDrop[client] = false;
	g_iDrop[client] = 0;
	g_iDropWeapon[client] = 0;
}

void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

public Action tTimerDrop(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		vDeleteDrop(iTank);
	 	int iWeapon = bIsL4D2Game() ? GetRandomInt(1, 31) : GetRandomInt(1, 6);
		int iPosition;
		switch (GetRandomInt(1, 2))
		{
			case 1: iPosition = 1;
			case 2: iPosition = 2;
		}
		float flScale;
		int iDrop = CreateEntityByName("prop_dynamic_override");
		if (bIsValidEntity(iDrop))
		{
			float flPos[3];
			float flAngle[3];
			char sPosition[32];
			SetEntityModel(iDrop, g_sWeaponModel[iWeapon]);
			TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
			DispatchSpawn(iDrop);
			SetVariantString("!activator");
			AcceptEntityInput(iDrop, "SetParent", iTank);
			switch (iPosition)
			{
				case 1: sPosition = "rhand";
				case 2: sPosition = "lhand";
			}
			SetVariantString(sPosition);
			AcceptEntityInput(iDrop, "SetParentAttachment");
			bIsL4D2Game() ? vGetPosAng2(iTank, iWeapon, flPos, flAngle, iPosition, flScale) : vGetPosAng(flPos, flAngle, iPosition, flScale);
			SetEntProp(iDrop, Prop_Send, "m_CollisionGroup", 2);
			if (bIsL4D2Game())
			{
				SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flScale);
			}
			g_iDrop[iTank] = iDrop;
			g_iDropWeapon[iTank] = iWeapon;
			SDKHook(g_iDrop[iTank], SDKHook_SetTransmit, SetTransmit);
		}
	}
	return Plugin_Continue;
}