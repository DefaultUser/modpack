//FEATURE: Teammate collisions (if supported), pass through teammates instead of bumping into them!

#ifdef GAMEQC
REGISTER_MUTATOR(team_collisions, true);
#endif
#ifdef SVQC
AUTOCVAR(g_team_collisions, bool, false, "Enable to allow passing through teammates, requires the clipgroup engine extension");
#endif

REGISTER_STAT(TEAM_COLLISIONS, bool, autocvar_g_team_collisions)

#ifdef SVQC
.int clipgroup;

MUTATOR_HOOKFUNCTION(team_collisions, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	if(teamplay && autocvar_g_team_collisions && Team_IsValidTeam(player.team)) // allow toggling mid match
		player.clipgroup = player.team;
}

#elif defined(CSQC)
.int clipgroup;

// unfortunately, we need to be a bit sneaky about getting the clip group on the client
MUTATOR_HOOKFUNCTION(team_collisions, ForcePlayermodels_Skip)
{
	entity player = M_ARGV(0, entity);
	if(!STAT(TEAM_COLLISIONS) || !teamplay)
		return;

	int theteam = entcs_GetTeam(player.entnum - 1);
	if(!Team_IsValidTeam(theteam))
		return;

	player.clipgroup = theteam;
}

#endif
