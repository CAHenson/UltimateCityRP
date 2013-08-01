/*================ March 14th UPDATES: ====================

	* Added 3 new commands: /Mute, /Unmute, /Muted ( Shows list of muted players )
	* Players cannot talk while they are muted!! :p
	* Added admin chat, type: !Message
	* Fixed the "Weird" spawn bug. Also added ALL skins to chose.
	* Made a quick RequestClass spot
	* Added random messages
	* Random spawns if its the firs time on the server! ( Should also fix a bug )
	* Added: UsePlayerPedAnims(); for the CJ running style.
	* Chat bubble appears ontop of your head when you talk ( type a message )
	* Fixed the half way connection problem

==========================================================*/
#include <a_samp>
#include <djson>
#include <CMD>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 			20 // Remember to change.

#define COLOR_GREEN 			0x008000FF
#define COLOR_LIGHTBLUE 		0xADD8E6FF
#define COLOR_RED 				0xFF0000FF
#define COLOR_LIGHTGREEN 		0x90EE90FF
#define COLOR_GREY 				0x808080FF

#define CYELLOW "{9DBD1E}"
#define CORANGE "{E68C0E}"
#define CBLUE   "{39AACC}"
#define CDGREEN "{6FA828}"
#define CWHITE  "{FFFFFF}"
#define CRED    "{FF0000}"
#define COBJS1	"{D0A5D1}"
#define COBJS2  "{8FC95F}"
#define CSALMON "{FA8072}"

new ForRndColorLabel[] =
{
	COLOR_GREEN,
	COLOR_LIGHTBLUE,
	COLOR_RED,
	COLOR_LIGHTGREEN
};

#define ICON_FILE_NAME 			"DMapIcons.txt"
#define VEHICLE_FILE_NAME 		"DVehicles.txt"
#define PICKUP_FILE_NAME 		"DPickups.txt"
#define LABEL_FILE_NAME 		"DLabels.txt"

#define PFiles 					"PFiles/%s.json"

#define LOGIN 					0
#define REGISTER 				1
#define STATS 					2
#define DIALOG_MUTED_INFO       3

enum _PINFO
{
	pKills,
	pDeaths,
	pLevel,
	Float:pLastX,
	Float:pLastY,
	Float:pLastZ,
	pMuted,
	pMutedReason
}
new PVar[MAX_PLAYERS][_PINFO];
new Msg[128];

main() { }

new
	Float:RandSpawns[][3] = {
	{2261.9048, 2035.9547, 10.8203},
	{2262.0986, 2398.6572, 10.8203},
	{2244.2566, 2523.7280, 10.8203},
	{2335.3228, 2786.4478, 10.8203},
	{2150.0186, 2734.2297, 11.1763},
	{2158.0811, 2797.5488, 10.8203},
	{1969.8301, 2722.8564, 10.8203},
	{1652.0555, 2709.4072, 10.8265},
	{1564.0052, 2756.9463, 10.8203},
	{1271.5452, 2554.0227, 10.8203},
	{1441.5894, 2567.9099, 10.8203}
};
//==============================================================================
// ON GAMEMODE INIT
//==============================================================================
public OnGameModeInit()
{
	for(new i = 0; i < 299; ++i)
	{
	    if(IsValidSkin(i)) AddPlayerClass(i, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	}
	
	SetTimer("RandMessages", 60 * 1000 * 5, true);

	UsePlayerPedAnims();
	djson_GameModeInit();
	
	print("=====================================================================");
	new Line[60], Veh, Pickup, Labels;
	Pickup = AddPickupFromFile(PICKUP_FILE_NAME);
	format(Line, sizeof(Line),"** %i\t<->\tPickups Loaded From\t<->\tDPickups.txt **", Pickup);
	printf(Line);

	Veh = AddVehiclesFromFile(VEHICLE_FILE_NAME);
	format(Line, sizeof(Line), "** %i\t<->\tVehicles Loaded From\t<->\tDVehicles.txt **", Veh);
	printf(Line);

	Labels = AddLabelsFromFile(LABEL_FILE_NAME);
	format(Line, sizeof(Line), "** %i\t<->\tLabels Loaded From\t<->\tDLabels.txt **",Labels);
	printf(Line);
	print("=====================================================================\n");
	print("Ultimate City RP!");
	return 1;
}
//==============================================================================
// ON GAMEMODE EXIT
//==============================================================================
public OnGameModeExit()
{
	djson_GameModeExit();
	DestroyAllDynamicMapIcons();
	DestroyAllDynamicPickups();
	DestroyAllDynamic3DTextLabels();
	return 1;
}
//==============================================================================
// ON PLAYER REQUEST CLASS
//==============================================================================
public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, -2661.3604, 1932.9404, 225.7578);
	SetPlayerFacingAngle(playerid, 213.0498);

	SetPlayerCameraPos(playerid, -2659.3604, 1906.9404, 226.7578);
	SetPlayerCameraLookAt(playerid, -2661.3604, 1932.9404, 225.7578);
	return 1;
}
//=============================================================================
// ON PLAYER CONNECT
//==============================================================================
public OnPlayerConnect(playerid)
{
    AddMapIconFromFile(ICON_FILE_NAME);
    
    new CString[50];
    format(CString, sizeof(CString), "Player: %s(%d) has joined ultimate city!", pName(playerid), playerid);
    SendClientMessageToAll(COLOR_GREY, CString);
    
	new File[50];
	format(File, sizeof(File), PFiles, pName(playerid));

	if(fexist(File))
	{
		new
			iStr[128];

		format(iStr, sizeof(iStr), ""#CBLUE"Welcome back: "#CDGREEN"%s(%d)\n"#CBLUE"Enter your password to login:", pName(playerid), playerid);
		ShowPlayerDialog(playerid, LOGIN, DIALOG_STYLE_INPUT, ""#CBLUE"Login", iStr, "Login", "Leave");
	}
	else
	{
		new
		    iStr[128];

		format(iStr, sizeof(iStr), ""#CBLUE"Welcome: "#CDGREEN"%s(%d)\n"#CBLUE"This account has not been registered! Please enter a password:", pName(playerid), playerid);
		ShowPlayerDialog(playerid, REGISTER, DIALOG_STYLE_INPUT, ""#CDGREEN"Register", iStr, "Register", "Leave");
	}
	return 1;
}
//==============================================================================
// ON PLAYER DISCONNECT
//==============================================================================
public OnPlayerDisconnect(playerid, reason)
{
    new
		CString[50];
    format(CString, sizeof(CString), "Player: %s(%d) has left ultimate city!", pName(playerid), playerid);
    SendClientMessageToAll(COLOR_GREY, CString);

	new File[50]; format(File, sizeof(File), PFiles, pName(playerid));

	GetPlayerPos(playerid, PVar[playerid][pLastX], PVar[playerid][pLastY], PVar[playerid][pLastZ]);
	
	djSetInt		(File, "Kills", 	PVar[playerid][pKills]);
	djSetInt		(File, "Deaths", 	PVar[playerid][pDeaths]);
	djSetInt		(File, "Level", 	PVar[playerid][pLevel]);
	djSetInt        (File, "Muted",     PVar[playerid][pMuted]);
	djSet           (File, "MutedReason", PVar[playerid][pMutedReason]);

	djSetFloat		(File, "LastX", 	PVar[playerid][pLastX]);
	djSetFloat		(File, "LastY", 	PVar[playerid][pLastY]);
	djSetFloat		(File, "LastZ", 	PVar[playerid][pLastZ]);
	return 1;
}
//==============================================================================
// ON PLAYERSPAWN
//==============================================================================
public OnPlayerSpawn(playerid)
{
	if(PVar[playerid][pLastX] == 0.0 && PVar[playerid][pLastY] == 0.0)
	{
		new
		    RPos = random(sizeof(RandSpawns));

		SetPlayerPos(playerid, RandSpawns[RPos][0], RandSpawns[RPos][1], RandSpawns[RPos][2]);
	}
	else SetPlayerPos(playerid, PVar[playerid][pLastX], PVar[playerid][pLastY], PVar[playerid][pLastZ]);
	return 1;
}
//==============================================================================
// ON PLAYER DEATH
//==============================================================================
public OnPlayerDeath(playerid, killerid, reason)
{
	PVar[killerid][pKills] += 1;
	PVar[playerid][pDeaths] += 1;
	return 1;
}
//==============================================================================
// ON PLAYER TEXT
//==============================================================================
public OnPlayerText(playerid, text[])
{
	if(PVar[playerid][pMuted] == 1)
	{
	    SendClientMessage(playerid, COLOR_RED, "You are muted. You cannot talk. Try PMing an admin!");
		return 0;
	}

	if(text[0] == '!' && PVar[playerid][pLevel] >= 1)
	{
	    for(new i = 0; i < MAX_PLAYERS; ++i)
	    {
	        if(IsPlayerConnected(i) && !IsPlayerNPC(i) && PVar[i][pLevel] >= 1)
	        {
	            new
	                iMsg[150];

				format(iMsg, sizeof(iMsg), ""#CDGREEN"Admin: "#CORANGE"%s(%d) - "#CYELLOW"%s", pName(playerid), playerid, text[1]);
				SendClientMessage(i, -1, iMsg);
				return 0;
			}
		}
	}
	
	SetPlayerChatBubble(playerid, text, COLOR_LIGHTBLUE, 100.0, 10000);
	return 1;
}
/*::::::::::::::::::::::::: REGULAR PLAYER COMMANDS ::::::::::::::::::::::::::*/
CMD:addicon(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 5)
	{
		new MType, Float:MX, Float:MY, Float:MZ, MColor;
		if(unformat(params, "ih", MType, MColor)) return SendClientMessage(playerid, COLOR_RED,"[USAGE] /AddIcon < Icon ID > < Icon Color >");
		GetPlayerPos(playerid, MX, MY, MZ);

		AddMapIconToFile(ICON_FILE_NAME, MX, MY, MZ, MType, MColor);

		for(new PID; PID < MAX_PLAYERS; PID++) if(IsPlayerConnected(PID))
		{
			CreateDynamicMapIcon(MX, MY, MZ, MType, MColor, -1, -1, -1, 100.0);
		}
		format(Msg,sizeof(Msg),"A new map icon has beed dynamically added. Model: (%d) Color: (%d).",MType, MColor);
		return SendClientMessage(playerid, COLOR_GREEN, Msg);
	}
	else return AdminCMD(playerid, 5);
}

CMD:addvehicle(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 5)
	{
		new vModel, Float:VX, Float:VY, Float:VZ, Float:VA;
		if(IsPlayerInAnyVehicle(playerid))
		{
			GetPlayerPos(playerid, VX, VY, VZ);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), VA);
			vModel = GetVehicleModel(GetPlayerVehicleID(playerid));

			AddVehicleToFile(VEHICLE_FILE_NAME, VX, VY, VZ, VA, vModel);
			format(Msg,sizeof(Msg),"A new vehicle has been dynamically added. Model: (%d).",vModel);
			return SendClientMessage(playerid, COLOR_GREEN, Msg);
		}
		else return SendClientMessage(playerid, COLOR_RED, "You must be in a vehicle to use this command!");
	}
	else return AdminCMD(playerid, 5);
}

CMD:addpickup(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 5)
	{
		new PModel, PType, Float:PX, Float:PY, Float:PZ;
		if(unformat(params, "ih", PModel, PType)) return SendClientMessage(playerid, COLOR_RED,"[USAGE] /AddPickup < Pickup ID > < Spawn Type >");
		GetPlayerPos(playerid, PX, PY, PZ);

		AddPickupToFile(PICKUP_FILE_NAME, PX, PY, PZ, PModel, PType);
		CreateDynamicPickup(PModel, PType, PX, PY, PZ, -1, -1, -1, 100.0);
		format(Msg,sizeof(Msg),"A New Pickup Has Been Added. Model: \"%d\" - Spawn Type: \"%d\"",PModel, PType);
		return SendClientMessage(playerid, COLOR_GREEN, Msg);
	}
	else return AdminCMD(playerid, 5);
}

CMD:add3dlabel(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 5)
	{
		new Float:X, Float:Y, Float:Z;
		if(unformat(params, "s[128]",params)) return SendClientMessage(playerid, COLOR_RED, "[USAGE] /Add3DLabel < Description >");
		GetPlayerPos(playerid, X, Y, Z);

		AddLabelToFile(LABEL_FILE_NAME, params, X, Y, Z);
		CreateDynamic3DTextLabel(params, ForRndColorLabel[random(sizeof(ForRndColorLabel))], X, Y, Z, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
		format(Msg, sizeof(Msg), "A new 3D Text Label has been dynamically added. Description: \"%s\".",params);
		return SendClientMessage(playerid, COLOR_GREEN, Msg);
	}
	else return AdminCMD(playerid, 5);
}
/*::::::::::::::::::::::::: REGULAR PLAYER COMMANDS ::::::::::::::::::::::::::*/
CMD:stats(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /Stats < Player ID >");
	
	new pID = strval(params);
	
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

	return PStats(playerid, pID);
}
/*::::::::::::::::::::::::: LEVEL 4 ADMIN COMMANDS :::::::::::::::::::::::::::*/
CMD:setlevel(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 4 || IsPlayerAdmin(playerid))
	{
		new pID, Level;
		if(sscanf(params, "ui", pID, Level)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /SetLevel < Player ID > < Level >");

		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		format(Msg, sizeof(Msg), "Admin: %s(%d) has given you admin level: %d", pName(playerid), playerid, Level);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, Msg);

		format(Msg, sizeof(Msg), "You have been given admin level: %d to: %s(%d)", Level, pName(pID), pID);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, Msg);
		
		return PVar[pID][pLevel] = Level;
	}
	else return AdminCMD(playerid, 3);
}
/*::::::::::::::::::::::::: LEVEL 3 ADMIN COMMANDS :::::::::::::::::::::::::::*/
CMD:kick(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 3)
	{
		new pID;
		if(sscanf(params, "us[60]", pID, params)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /Kick < Player ID > < Reason >");

		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		format(Msg, sizeof(Msg), "Admin: %s(%d) has kicked: %s(%d) for: %s", pName(playerid), playerid, pName(pID), pID, params);
		SendClientMessageToAll(COLOR_GREY, Msg);

		return Kick(pID);
	}
	else return AdminCMD(playerid, 3);
}

CMD:ban(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 3)
	{
		new pID;
		if(sscanf(params, "us[60]", pID, params)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /Ban < Player ID > < Reason >");

		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		format(Msg, sizeof(Msg), "Admin: %s(%d) has banned: %s(%d) for: %s", pName(playerid), playerid, pName(pID), pID, params);
		SendClientMessageToAll(COLOR_GREY, Msg);

		return BanEx(pID, "Admin Ban!");
	}
	else return AdminCMD(playerid, 3);
}
/*::::::::::::::::::::::::: LEVEL 2 ADMIN COMMANDS :::::::::::::::::::::::::::*/
CMD:slap(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /Slap < Player ID >");

		new pID = strval(params);
		
		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		new Float:PPos[3];
		GetPlayerPos(pID, PPos[0], PPos[1], PPos[2]);

		format(Msg, sizeof(Msg), "Admin: %s(%d) has slapped: %s(%d)!!", pName(playerid), playerid, pName(pID), pID);
		SendClientMessageToAll(COLOR_GREY, Msg);
		
		return SetPlayerPos(pID, PPos[0], PPos[1], PPos[2] + 10);
	}
	else return AdminCMD(playerid, 2);
}

CMD:explode(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /Explode < Player ID >");
		
		new pID = strval(params);
		
		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

        new Float:PPos[3];
		GetPlayerPos(pID, PPos[0], PPos[1], PPos[2]);
		
		format(Msg, sizeof(Msg), "Admin: %s(%d) has exploded: %s(%d)!!", pName(playerid), playerid, pName(pID), pID);
		SendClientMessageToAll(COLOR_GREY, Msg);
		
		return CreateExplosion(PPos[0], PPos[1], PPos[2], 2, 5);
	}
	else return AdminCMD(playerid, 2);
}

CMD:setskin(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
		new pID, SkinID;
		if(sscanf(params, "ui", pID, SkinID)) return SendClientMessage(playerid, COLOR_RED, "* Usage: /SetSkin < Player ID > < Skin ID >");

		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		format(Msg, sizeof(Msg), "Admin: %s(%d) has set your skin id to: %d", pName(playerid), playerid);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, Msg);

		format(Msg, sizeof(Msg), "You have set: %s(%d)'s skin id to: %d", pName(pID), pID, SkinID);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, Msg);

		return SetPlayerSkin(pID, SkinID);
	}
	else return AdminCMD(playerid, 2);
}

CMD:mute(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
	    new
	        pID,
			iStr[160];

		if(sscanf(params, "us[50]", pID, params)) return SendClientMessage(playerid, -1, ""#CRED"Usage: "#CORANGE"/Mute < Player ID > < Reason >");
		if(strlen(params) < 5 || strlen(params) > 50) return SendClientMessage(playerid, COLOR_RED, "Please enter a reason between '5' and '50' characters!");
		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		PVar[pID][pMuted] = 1;
		format(PVar[pID][pMutedReason], 52, "%s", params);

		format(iStr, sizeof(iStr), ""#CBLUE"Admin: "#CDGREEN"%s(%d) "#CBLUE"has muted: "#CDGREEN"%s(%d). "#CBLUE"Reason: "#CRED"%s", pName(playerid), playerid, pName(pID), pID, params);
		SendClientMessageToAll(-1, iStr);
		return 1;
	}
	else return AdminCMD(playerid, 2);
}

CMD:unmute(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
	    new
	        pID = strval(params),
	        iStr[150];

		if(isnull(params)) return SendClientMessage(playerid, -1, ""#CRED"Usage: "#CORANGE"/Unmute < Player ID >");
		if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_RED, "That user is not connected!");

		PVar[pID][pMuted] = 0;
		format(PVar[pID][pMutedReason], 50, "Not Muted!");

		format(iStr, sizeof(iStr), ""#CBLUE"Admin: "#CDGREEN"%s(%d) "#CBLUE"has unmuted: "#CDGREEN"%s(%d).", pName(playerid), playerid, pName(pID), pID);
		SendClientMessageToAll(-1, iStr);
		return 1;
	}
	else return AdminCMD(playerid, 2);
}

CMD:muted(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 2)
	{
		new
		    iQuery[256];

		format(iQuery, sizeof(iQuery), ""#CBLUE"Player:\t\t\t"#CRED"Reason:\n");

		for(new i = 0; i < MAX_PLAYERS; ++i)
		{
		    if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		    {
		    	if(PVar[i][pMuted] == 1)
		    	{
		        	format(iQuery, sizeof(iQuery), "%s"#CBLUE"%s(%d)\t\t"#CRED"%s\n", iQuery, pName(i), i, PVar[i][pMutedReason]);
				}
			}
		}
		return ShowPlayerDialog(playerid, DIALOG_MUTED_INFO, DIALOG_STYLE_MSGBOX, ""#CBLUE"=Famous= "#CRED"Muted Players", iQuery, "OK", "");
	}
	else return AdminCMD(playerid, 2);
}
/*::::::::::::::::::::::::: LEVEL 1 ADMIN COMMANDS :::::::::::::::::::::::::::*/
CMD:jetpack(playerid, params[])
{
	if(PVar[playerid][pLevel] >= 1)
	{
		return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	}
	else return AdminCMD(playerid, 1);
}
//==============================================================================
// ON DIALOG RESPONSE
//==============================================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new File[50];
	format(File, sizeof(File), PFiles, pName(playerid));
	switch(dialogid)
	{
		case LOGIN:
		{
		    if(response)
		    {
		        if(strlen(inputtext) == 0)
		        {
					new
						iStr[128];

					format(iStr, sizeof(iStr), ""#CBLUE"Welcome back: "#CDGREEN"%s(%d)\n"#CBLUE"Enter your password to login:", pName(playerid), playerid);
					return ShowPlayerDialog(playerid, LOGIN, DIALOG_STYLE_INPUT, ""#CBLUE"Login", iStr, "Login", "Leave");
				}
    			if(strcmp(inputtext, dj(File, "Password", 40), true) == 0)
		    	{
		        	SendClientMessage(playerid, COLOR_LIGHTGREEN, "You are now logged in!");
		        
					PVar[playerid][pKills] 		= djInt		(File, "Kills");
					PVar[playerid][pDeaths] 	= djInt		(File, "Deaths");
					PVar[playerid][pLevel] 		= djInt		(File, "Level");
					PVar[playerid][pMuted]      = djInt     (File, "Muted");
					format(PVar[playerid][pMutedReason], 52, "%s", dj(File, "MutedReason"));
					
					PVar[playerid][pLastX]      = djFloat	(File, "LastX");
					PVar[playerid][pLastY]      = djFloat	(File, "LastY");
					PVar[playerid][pLastZ]      = djFloat	(File, "LastZ");
				}
				else
				{
					new
						iStr[128];

					format(iStr, sizeof(iStr), ""#CBLUE"Welcome back: "#CDGREEN"%s(%d)\n"#CBLUE"Enter your password to login:", pName(playerid), playerid);
					return ShowPlayerDialog(playerid, LOGIN, DIALOG_STYLE_INPUT, ""#CBLUE"Login", iStr, "Login", "Leave");
				}
			}
			else Kick(playerid);
		}
		case REGISTER:
		{
		    if(response)
		    {
		        if(strlen(inputtext) == 0)
		        {
					new
					    iStr[128];

					format(iStr, sizeof(iStr), ""#CBLUE"Welcome: "#CDGREEN"%s(%d)\n"#CBLUE"This account has not been registered! Please enter a password:", pName(playerid), playerid);
					return ShowPlayerDialog(playerid, REGISTER, DIALOG_STYLE_INPUT, ""#CDGREEN"Register", iStr, "Register", "Leave");
				}
				djCreateFile(File);
				
				djSet			(File, "Password", 	inputtext);
				djSetInt		(File, "Kills", 	0);
				djSetInt		(File, "Deaths", 	0);
				djSetInt		(File, "Level", 	0);
				djSetInt        (File, "Muted",     0);
				djSet           (File, "MutedReason", "Not Muted!");
				
				djSetFloat		(File, "LastX", 	0.0);
				djSetFloat		(File, "LastY", 	0.0);
				djSetFloat		(File, "LastZ", 	0.0);
			
				djCommit(File);
			
		    	SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have been registered and logged in!");
			}
			else Kick(playerid);
		}
	}
	return 1;
}
//==============================================================================
// CUSTOM STOCKS
//==============================================================================
stock AdminCMD(iPlayer, iLevel)
{
	new
		Str[50];
	format(Str, sizeof(Str), "** Only admin level: %d + Can use that command!", iLevel);
	return SendClientMessage(iPlayer, COLOR_RED, Str);
}

stock PStats(iPlayer, iTarget)
{
	new Str[128];
	format(Str, sizeof(Str), "Player Name: %s\t\tID: %d\n\n** Kills: %d\n\n** Deaths: %d\n\n** Admin Level: %d",
	pName(iTarget),
	iTarget,
	PVar[iTarget][pKills],
	PVar[iTarget][pDeaths],
	PVar[iTarget][pLevel]);

	return ShowPlayerDialog(iPlayer, STATS, DIALOG_STYLE_MSGBOX, "PLAYER STATISTICS", Str, "OK", "CLOSE");
}

//==============================================================================
// Dynamic Map Icons
//==============================================================================
stock AddMapIconFromFile(DFileName[])
{
	if(!fexist(DFileName)) return 0;

	new File:MapFile, MType, Float:MX, Float:MY, Float:MZ, MColor, Line[128];

	MapFile = fopen(DFileName, io_read);
	while(fread(MapFile, Line))
	{
	    if(Line[0] == '/' || isnull(Line)) continue;
	    unformat(Line, "fffii", MX, MY, MZ, MType, MColor);
	    CreateDynamicMapIcon(MX, MY, MZ, MType, MColor, -1, -1, -1, 100.0);
	}
	fclose(MapFile);
	return 1;
}

stock AddMapIconToFile(DFileName[], Float:MX, Float:MY, Float:MZ, MType, MColor)
{
	new File:MapFile, Line[128];

	format(Line, sizeof(Line), "%f %f %f %i %i\r\n", MX, MY, MZ, MType, MColor);
	MapFile = fopen(DFileName, io_append);
	fwrite(MapFile, Line);
	fclose(MapFile);
	return 1;
}
//==============================================================================
// Dynamic Vehicles
//==============================================================================
stock AddVehiclesFromFile(DFileName[])
{
	if(!fexist(DFileName)) return 0;

	new File:VehicleFile, vModel, Float:VX, Float:VY, Float:VZ, Float:VA, vTotal, Line[128];

	VehicleFile = fopen(DFileName, io_read);
	while(fread(VehicleFile, Line))
	{
	    if(Line[0] == '/' || isnull(Line)) continue;
	    unformat(Line, "ffffi", VX, VY, VZ, VA, vModel);
	    AddStaticVehicleEx(vModel, VX, VY, VZ, VA, -1, -1, (30*60));
	    vTotal++;
	}
	fclose(VehicleFile);
	return vTotal;
}

stock AddVehicleToFile(DFileName[], Float:VX, Float:VY, Float:VZ, Float:VA, vModel)
{
	new File:VehicleFile, Line[128];

	format(Line, sizeof(Line), "%f %f %f %f %i\r\n", VX, VY, VZ, VA, vModel);
	VehicleFile = fopen(DFileName, io_append);
	fwrite(VehicleFile, Line);
	fclose(VehicleFile);
	return 1;
}
//==============================================================================
// Dynamic Pickups
//==============================================================================
stock AddPickupFromFile(DFileName[])
{
	if(!fexist(DFileName)) return 0;

	new File:PickupFile, PType, PModel, Float:PX, Float:PY, Float:PZ, pTotal, Line[128];

	PickupFile = fopen(DFileName, io_read);
	while(fread(PickupFile, Line))
	{
	    if(Line[0] == '/' || isnull(Line)) continue;
	    unformat(Line, "fffii", PX, PY, PZ, PModel, PType);
	    CreateDynamicPickup(PModel, PType, PX, PY, PZ, -1, -1, -1, 100.0);
	    pTotal++;
	}
	fclose(PickupFile);
	return pTotal;
}

stock AddPickupToFile(DFileName[], Float:PX, Float:PY, Float:PZ, PModel, PType)
{
	new File:PickupFile, Line[128];

	format(Line, sizeof(Line), "%f %f %f %i %i\r\n", PX, PY, PZ, PModel, PType);
	PickupFile = fopen(DFileName, io_append);
	fwrite(PickupFile, Line);
	fclose(PickupFile);
	return 1;
}
//==============================================================================
// Dynamic 3D TextLabels
//==============================================================================
stock AddLabelsFromFile(LFileName[])
{
	if(!fexist(LFileName)) return 0;

	new File:LFile, Line[128], LabelInfo[128], Float:LX, Float:LY, Float:LZ, lTotal = 0;

	LFile = fopen(LFileName, io_read);
	while(fread(LFile, Line))
	{
	    if(Line[0] == '/' || isnull(Line)) continue;
	    unformat(Line, "p<,>s[128]fff", LabelInfo,LX,LY,LZ);
        CreateDynamic3DTextLabel(LabelInfo, ForRndColorLabel[random(sizeof(ForRndColorLabel))], LX, LY, LZ, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
		lTotal++;
	}
	fclose(LFile);
	return lTotal;
}

stock AddLabelToFile(LFileName[], LabelInfo[], Float:LX, Float:LY, Float:LZ)
{
	new File:LFile, Line[128];

	format(Line, sizeof(Line), "%s,%.2f,%.2f,%.2f\r\n",LabelInfo, LX, LY, LZ);
	LFile = fopen(LFileName, io_append);
	fwrite(LFile, Line);
	fclose(LFile);
	return 1;
}
//==============================================================================
// RANDOM MESSAGES
//==============================================================================
forward RandMessages();
public RandMessages()
{
	new
	    iMessages[][] = {
		{"You can check your stats using: /Stats"},
		{"Remember to register at our forums at: www.website.com"} // Remember if you add more msgs, add a coma, DO NOT PUT A COMMA ON THE LAST MSG
	};

	new
	    rMessages = random(sizeof(iMessages));

	SendClientMessageToAll(ForRndColorLabel[random(sizeof(ForRndColorLabel))], iMessages[rMessages]);
	return 1;
}
//==============================================================================
// OTHER STOCKS
//==============================================================================
stock pName(playerid)
{
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, sizeof(Name));
	return Name;
}

stock IsValidSkin(SkinID)
{
	if(0 < SkinID < 300)
	{
		switch(SkinID)
		{
		    case 3..6, 8, 42, 65, 74, 86, 119, 149, 208, 273, 289: return 0;
		}
		return 1;
	}
	return 0;
}
