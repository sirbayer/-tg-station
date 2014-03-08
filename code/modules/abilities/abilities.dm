//Ability button framework. Buttons, when clicked, call their activation code.

/obj/screen/ability
	icon = 'icons/obj/abilities.dmi'

/obj/screen/ability/Click() //The default response upon a button being clicked is to call the activate() proc.
	activate()

/obj/screen/ability/proc/activate() //Fill in with your own behavior.
	return

/mob/living
	var/list/abilities = list() //Allows ability aggregation for handling.

///datum/hud
//	var/list/ability_list = list() //Because HUD != mob, we have to keep two separate lists. It's this or trawl through the entire client.screen to find out what needs to go when we update.

/mob/living/proc/update_abilities() //All abilities have to be aggregated into the mob's abilities. Once that's done, this proc handles all that remains.
	if(!hud_used || !client)
		return
	for (var/obj/screen/ability/A in client.screen)
		A.screen_loc = null
		client.screen -= A
	for (var/i = 1, i <= abilities.len, i++)
		var/obj/screen/ability/A = abilities[i]
		var/screenrow = (abilities.len-i)%7 //modulo because we're going to stack these seven wide
		var/screencolumn = round((i-1)/7)+1 //abusing the fact that 'round' translates to 'floor' in byondspeak
		A.screen_loc = "EAST[screenrow ? "-[screenrow]" : ""]:[-6-(2*screenrow)], NORTH[screencolumn ? "-[screencolumn]" : ""]:[26-(2*screencolumn)]"
		client.screen |= A

/mob/living/proc/add_abilities(var/list/A)
	if (!A)
		return
	abilities += A
	update_abilities()

/mob/living/proc/remove_abilities(var/list/A)
	if (!A)
		return
	abilities -= A
	update_abilities()