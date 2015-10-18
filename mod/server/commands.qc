STATIC_INIT(mod_cmds)
{
	localcmd("\nalias ircmsg \"sv_cmd ircmsg ${* ?}\"\n");
	localcmd("\nalias _ircmessage \"ircmsg ${* ?}\"\n");

	localcmd("\nalias chlevel \"sv_cmd chlevel ${* ?}\"\n");

	localcmd("\nalias stufftoall \"sv_cmd stufftoall ${* ?}\"\n");

	localcmd("\nalias dumpmodcvars \"sv_cmd dumpmodcvars ${* ?}\"\n");
}

void IRCSay(string msgstr)
{
	if(msgstr == "")
		return;

	msgstr = strcat("\{1}", strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint

	entity head;
	FOR_EACH_CLIENTSLOT(head)
	{
		if(!intermission_running)
		if((autocvar_g_chat_nospectators == 1) || (autocvar_g_chat_nospectators == 2 && !(warmup_stage || gameover)))
		if(IS_PLAYER(head))
			continue;
		if(IS_REAL_CLIENT(head))
			sprint(head, msgstr);
	}
}

float mod_cvar_file;
void RegisterModCvars_Set(string name, string def, string desc, bool archive, string file)
{
	if(substring(file, 0, 10) != "../../mod/")
		return;

	// NOTE: the file must be opened beforehand, or this will implode!
    string thecvar = sprintf("\n%s %s \"%s\" \"%s\"", (archive ? "seta" : "set"), name, def, desc);
    fputs(mod_cvar_file, thecvar);
}

MUTATOR_HOOKFUNCTION(mutator_mod, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	if(cmd_name == "chlevel")
	{
		string m = MapInfo_FixName(argv(1));
		localcmd(strcat("\nchangelevel ", m, "\n"));
		LOG_INFO("Switching to ", m, "\n");
		return true;
	}

	if(cmd_name == "ircmsg")
	{
		IRCSay(substring(cmd_string, strlen(argv(0))+1, strlen(cmd_string)));
		return true;
	}

#ifdef STUFFTO_ENABLED
	if(cmd_name == "stufftoall")
	{
		entity head;
		FOR_EACH_REALCLIENT(head)
		{
			bool accepted = VerifyClientEntity(head, true, false);
			if(accepted > 0)
			{
				stuffcmd(head, strcat("\n", argv(1), "\n"));
				LOG_INFO(strcat("Command: \"", argv(1), "\" sent to ", GetCallerName(head), ".\n"));
				continue;
			}
			else
			{
				LOG_INFO("stuffto failed on ", GetCallerName(head), ".\n");
				continue;
			}
		}
		return true;
	}
#endif

	if(cmd_name == "dumpmodcvars")
	{
		mod_cvar_file = fopen("mod_cvars.cfg", FILE_WRITE);
		if(mod_cvar_file >= 0)
		{
			fputs(mod_cvar_file, "// DO NOT MODIFY THIS FILE!!");
			fputs(mod_cvar_file, "\n// Put your changes in server.cfg, this file is automatically generated!");
			fputs(mod_cvar_file, "\n\n\n// Mod Cvars:\n");
			RegisterCvars(RegisterModCvars_Set);
			fputs(mod_cvar_file, "\n");
			LOG_INFO("Dumping mod cvars... File located in ^2data/data/mod_cvars.cfg^7.\n");
			fclose(mod_cvar_file);
		}
		else
			LOG_INFO("^1Error: ^7Could not open file 'mod_cvars.cfg'!\n");
			
		return true;
	}

	return false;
}