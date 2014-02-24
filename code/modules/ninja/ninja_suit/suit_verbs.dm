//=======//SUIT VERBS//=======//
//Verbs link to procs because verb-like procs have a bug which prevents their use if the arguments are not readily referenced.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Ninja Equip"

	ninitialize()
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
			return
		deinitialize()
	else
		affecting << "<span class='alert'>ALERT: Suit failed to shut down.</span> Ensure all processes have finished and try again."
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		display_spideros()
	else
		affecting << "<span class='alert'>ALERT: SpiderOS is not responding.</span>"
	return

/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	set name = "Toggle Stealth"
	set desc = "Utilize the internal CLOAK-tech device to activate or deactivate stealth-camo."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		toggle_stealth()
	else
		affecting << "<span class='alert'>ALERT: CLOAK-tech is not responding.</span>"
	return

/*
/obj/item/clothing/suit/space/space_ninja/proc/grant_equip_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
	n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled

/obj/item/clothing/suit/space/space_ninja/proc/remove_equip_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth
	if(n_gloves)
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

/obj/item/clothing/suit/space/space_ninja/proc/grant_ninja_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet


/obj/item/clothing/suit/space/space_ninja/proc/remove_ninja_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet
*/

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_busy = 0
	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_control = 1