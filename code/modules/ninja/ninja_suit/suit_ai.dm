//=======//SPECIAL AI FUNCTIONS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo(var/turf/T in oview(3,affecting))//To have an internal AI display a hologram to the AI and ninja only.
	set name = "Display Hologram"
	set desc = "Channel a holographic image directly to the user's field of vision. Others will not see it."
	set category = null
	set src = usr.loc

	if(s_initialized&&affecting&&affecting.client&&istype(affecting.loc, /turf))//If the host exists and they are playing, and their location is a turf.
		if(!hologram)//If there is not already a hologram.
			hologram = new(T)//Spawn a blank effect at the location.
			hologram.invisibility = 101//So that it doesn't show up, ever. This also means one could attach a number of images to a single obj and display them differently to differnet people.
			hologram.anchored = 1//So it cannot be dragged by space wind and the like.
			hologram.dir = get_dir(T,affecting.loc)
			var/image/I = image(AI.holo_icon,hologram)//Attach an image to object.
			hologram.i_attached = I//To attach the image in order to later reference.
			AI << I
			affecting << I
			affecting << "<span class='notice'>An image flicks to life nearby. It appears visible to you only.</span>"

			verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear

			ai_holo_process()//Move to initialize
		else
			AI << "<span class='alert'>ERROR: </span>Image feed in progress."
	else
		AI << "<span class='alert'>ERROR: </span>Unable to project image."
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_process()
	set background = BACKGROUND_ENABLED

	spawn while(hologram&&s_initialized&&AI)//Suit on and there is an AI present.
		if(!s_initialized||get_dist(affecting,hologram.loc)>3)//Once suit is de-initialized or hologram reaches out of bounds.
			del(hologram.i_attached)
			del(hologram)

			verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
			return
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/ai_instruction()//Let's the AI know what they can do.
	set name = "Instructions"
	set desc = "Displays a list of helpful information."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear()
	set name = "Clear Hologram"
	set desc = "Stops projecting the current holographic image."
	set category = "AI Ninja Equip"
	set src = usr.loc

	del(hologram.i_attached)
	del(hologram)

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja()
	set name = "Hack SpiderOS"
	set desc = "Hack directly into the Black Widow(tm) neuro-interface."
	set category = "AI Ninja Equip"
	set src = usr.loc

	display_spideros()
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_return_control()
	set name = "Relinquish Control"
	set desc = "Return control to the user."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << browse(null, "window=spideros")//Close window
	AI << "You have seized your hacking attempt. [affecting.real_name] has regained control."
	affecting << "<b>UPDATE</b>: [AI.real_name] has ceased hacking attempt. All systems clear."

	remove_AI_verbs()
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_locked()
	if (affecting)
		affecting << "<span class='alert'><B>ALERT:</B> Remote access channel disabled.</span>"

/obj/item/clothing/suit/space/space_ninja/proc/killai(mob/living/silicon/ai/A = AI)
	if(A.client)
		A << "<span class='userdanger'>Self-erase protocol dete--</span> *bzzzzz*"
		A << browse(null, "window=hack spideros")
	AI = null
	A.death(1)//Kill, deleting mob.
	del(A)
	return