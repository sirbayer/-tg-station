//=======//CURRENT PLAYER VERB//=======//

/client/proc/cmd_admin_ninjafy(var/mob/living/carbon/human/H in player_list)
	set category = null
	set name = "Make Space Ninja"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!istype(H))
		return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	log_admin("[key_name(src)] turned [H.key] into a Space Ninja.")
	H.mind = create_ninja_mind(H.key)
	H.mind_initialize()
	H.equip_space_ninja(1)

//=======//CURRENT GHOST VERB//=======//

/client/proc/send_space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	set popup_menu = 0

	if(!holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/mission = copytext(sanitize(input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", null) as text|null),1,MAX_MESSAGE_LEN)

	var/client/C = input("Pick character to spawn as the Space Ninja", "Key", "") as null|anything in clients
	if(!C)
		return

	var/datum/round_event/ninja/E = new /datum/round_event/ninja()
	E.key=C.key
	E.mission=mission

	message_admins("\blue [key_name_admin(key)] has spawned [key_name_admin(C.key)] as a Space Ninja.")
	log_admin("[key] used Spawn Space Ninja.")

	return

//=======//NINJA CREATION PROCS//=======//

proc/create_ninja_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = "MODE"
	Mind.special_role = "Space Ninja"
	ticker.mode.traitors |= Mind			//Adds them to current traitor list. Which is really the extra antagonist list.
	return Mind

/proc/create_space_ninja(spawn_loc)
	var/mob/living/carbon/human/new_ninja = new(spawn_loc)
	if(prob(50)) new_ninja.gender = "female"
	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	A.copy_to(new_ninja)
	ready_dna(new_ninja)
	new_ninja.equip_space_ninja()
	return new_ninja

/mob/living/carbon/human/proc/equip_space_ninja(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		del(w_uniform)
		del(wear_suit)
		del(wear_mask)
		del(head)
		del(shoes)
		del(gloves)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	equip_to_slot_or_del(R, slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	var/obj/item/clothing/suit/space/space_ninja/newsuit = new /obj/item/clothing/suit/space/space_ninja(src)
	equip_to_slot_or_del(newsuit, slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_belt)
	equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/jetpack/carbondioxide(src), slot_back)

	newsuit.ninitialize()
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(src)
	E.imp_in = src
	E.implanted = 1
	return 1

//=======//HELPER PROCS//=======//

//Randomizes suit parameters.
/*
/obj/item/clothing/suit/space/space_ninja/proc/randomize_param()
	s_cost = rand(1,20)
	s_acost = rand(20,100)
	k_cost = rand(100,500)
	k_damage = rand(1,20)
	s_delay = rand(10,100) //fuk u ninja code
	s_bombs = rand(5,20)
	a_boost = rand(1,7)*/



//=======//KAMIKAZE VERBS//=======//
/*
/obj/item/clothing/suit/space/space_ninja/proc/grant_kamikaze(mob/living/carbon/U)
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth

	kamikaze = 1

	icon_state = U.gender==FEMALE ? "s-ninjakf" : "s-ninjak"
	if(n_gloves)
		n_gloves.icon_state = "s-ninjak"
		n_gloves.item_state = "s-ninjak"
		n_gloves.candrain = 0
		n_gloves.draining = 0
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

	cancel_stealth()

	U << browse(null, "window=spideros")
	U << "\red Do or Die, <b>LET'S ROCK!!</b>"

/obj/item/clothing/suit/space/space_ninja/proc/remove_kamikaze(mob/living/carbon/U)
	if(kamikaze)
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

		verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
		if(n_gloves)
			n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

		U.incorporeal_move = 0
		kamikaze = 0
		k_unlock = 0
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
*/ //Kamikaze never worked in the first place. Get out.

//=======//AI VERBS//=======//

