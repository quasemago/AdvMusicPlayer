/******************************************************************/
/*                                                                */
/*                     Advanced Music Player                      */
/*                                                                */
/*                                                                */
/*  File:          command.sp                                     */
/*  Description:   An advanced music player.                      */
/*                                                                */
/*                                                                */
/*  Copyright (C) 2020  Kyle                                      */
/*  2020/07/27 04:52:19                                           */
/*                                                                */
/*  This code is licensed under the GPLv3 License.                */
/*                                                                */
/******************************************************************/



void Command_CreateCommand()
{
    // console command
    RegConsoleCmd("sm_music",        Command_Music);
    RegConsoleCmd("sm_dj",           Command_Music);
    RegConsoleCmd("sm_media",        Command_Music);

    // admin command
    RegAdminCmd("sm_adminmusicstop", Command_AdminStop, ADMFLAG_BAN);
    RegAdminCmd("sm_musicban",       Command_MusicBan,  ADMFLAG_BAN);
}

public Action Command_Music(int client, int args)
{
    // ignore console
    if (!IsValidClient(client))
        return Plugin_Handled;

#if defined DEBUG
    UTIL_DebugLog("Command_Music -> %N", client);
#endif

    // display main menu to client
    DisplayMainMenu(client);

    return Plugin_Handled;
}

public Action Command_AdminStop(int client, int args)
{

#if defined DEBUG
    UTIL_DebugLog("Command_Music -> %N", client);
#endif

    // notify sound end
    Player_Reset();
    ChatAll("%t", "admin force stop");

    return Plugin_Handled;
}

public Action Command_MusicBan(int client, int args)
{
    // args: sm_musicban <client SteamId|UserId>
    if (args < 1)
        return Plugin_Handled;

    char buffer[16];
    GetCmdArg(1, buffer, 16);
    int target = FindTarget(client, buffer, true);

    // valid target?
    if (!IsValidClient(target))
        return Plugin_Handled;

    // processing ban
    g_bBanned[target] = !g_bBanned[target];
    Cookie_SetValue(target, Opts_Banned, g_bBanned[target]);
    ChatAll("%t", "music ban chat", target, g_bBanned[target] ? "BAN" : "UNBAN");
    
#if defined DEBUG
    UTIL_DebugLog("Command_MusicBan -> \"%L\" %s \"%N\"", client, g_bBanned[target] ? "BAN" : "UNBAN", target);
#endif

    return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    // ignore console and not handing client
    if (!client || !g_bHandle[client])
        return Plugin_Continue;

    g_bHandle[client] = false;

    Chat(client, "%T", "searching", client, g_EngineName[g_kEngine[client]], client);

    char url[256];
    g_Cvars.apiurl.GetString(url, 256);
    Format(url, 256, "%s/?action=search&engine=%s&limit=%d&song=%s", url, g_EngineName[g_kEngine[client]], g_Cvars.limits.IntValue, sArgs);
    //i dont want to urlencode. xD
    ReplaceString(url, 256, " ", "+", false);

#if defined DEBUG
    UTIL_DebugLog("OnClientSayCommand -> %N -> %s -> %s", client, sArgs, url);
#endif

    char path[128];
    BuildPath(Path_SM, path, 128, "data/music/search_%d.kv", GetClientUserId(client));

    Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
    SteamWorks_SetHTTPRequestContextValue(hRequest, GetClientUserId(client));
    SteamWorks_SetHTTPRequestNetworkActivityTimeout(hRequest, 30);
    SteamWorks_SetHTTPCallbacks(hRequest, API_SearchMusic_SteamWorks);
    SteamWorks_SendHTTPRequest(hRequest);

    g_bLocked[client] = true;

    return Plugin_Stop;
}