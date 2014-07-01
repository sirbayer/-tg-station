/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"
	antag_flag = BE_REV

	required_players = 20
	required_enemies = 1
	recommended_enemies = 1

	restricted_jobs = list("Cyborg", "AI")

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/carriers_to_make = 1
	var/list/carriers = list()

	var/monkeys_to_win = 0
	var/escaped_monkies = 0

	var/players_per_carrier = 30


/datum/game_mode/monkey/pre_setup()
	carriers_to_make = max(round(num_players()/players_per_carrier, 1), 1)
	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				antag_candidates -= player
	for(var/j = 0, j < carriers, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/carrier = pick(antag_candidates)
		carriers += carrier
		carrier.special_role = "monkey"
		log_game("[carrier.key] (ckey) has been selected as a Jungle Fever carrier")
		antag_candidates -= carrier
	if(!carriers.len)
		return 0
	return 1


/datum/game_mode/monkey/announce()
	world << "<B>The current game mode is - Monkey!</B>"
	world << "<B>One or more crewmembers have been infected with Jungle Fever! Crew: Contain the outbreak. None of the infected monkeys may escape alive to Centcom. \
				Monkeys: Ensure that your kind lives on! Rise up against your captors!</B>"


/datum/game_mode/monkey/proc/greet_carrier(var/datum/mind/carrier)
	carrier.current << "<B><span class = 'notice'>You are infected by the Jungle Fever patient zero!!</B>"
	carrier.current << "<b>You have been planted onto this station by the Animal Rights Consortium.</b>"
	carrier.current << "<b>Soon the disease will transform you into an ape. Afterwards, you will be able spread the infection to others with a bite.</b>"
	carrier.current << "<b>While your infection is undetectable, any other infectees will show up on medical equipment.</b>"
	carrier.current << "<b>Your mission will be deemed a success if any of the live infected monkeys reach Centcom.</b>"
	return

/datum/game_mode/monkey/post_setup()
	for(var/datum/mind/carriermind in carriers)
		greet_carrier(carriermind)
		var/datum/disease/transformation/jungle_fever/J = new /datum/disease/transformation/jungle_fever
		J.hidden = list(1, 1)//Starting disease is hidden from medical equipment
		carriermind.current.contract_disease(J, 1, 0)
	..()

/datum/game_mode/monkey/proc/check_monkey_victory()
	for(var/mob/living/carbon/monkey/M in living_mob_list)
		if (M.has_disease(/datum/disease/transformation/jungle_fever))
			var/area/A = get_area(M)
			if(is_type_in_list(A, centcom_areas))
				escaped_monkies++
	if(escaped_monkies >= monkeys_to_win)
		return 0
	else
		return 1


/datum/game_mode/monkey/declare_completion()
	if(!check_monkey_victory())
		feedback_set_details("round_end_result","win - monkey win")
		feedback_set("round_end_result",escaped_monkies)
		world << "\red <FONT size = 3><B> The monkies have overthrown their captors! Eeek eeeek!!</B></FONT>"
	else
		feedback_set_details("round_end_result","loss - staff stopped the monkies")
		feedback_set("round_end_result",escaped_monkies)
		world << "\red <FONT size = 3><B> The staff managed to contain the monkey infestation!</B></FONT>"
