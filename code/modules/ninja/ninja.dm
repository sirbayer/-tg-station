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