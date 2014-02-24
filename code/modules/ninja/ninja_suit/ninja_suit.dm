/*
===================================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<SPACE NINJA SUIT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
===================================================================================
*/



/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/cell)
	slowdown = 0
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

		//Important parts of the suit.
	var/mob/living/carbon/affecting = null//The wearer.
	var/obj/item/weapon/cell/cell//Starts out with a high-capacity cell using New().
	var/datum/effect/effect/system/spark_spread/spark_system//To create sparks.
	var/stored_research[]//For stealing station research.
	var/obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_lock = 0
	var/const/s_cost = 5.0//Base energy cost each ntick.
	var/const/s_delay = 50.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
	var/list/abilities

		//Support function variables.
	var/spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
	var/s_active = 0//Stealth off.
	var/s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.

		//Onboard AI related variables.
	var/mob/living/silicon/ai/AI//If there is an AI inside the suit.
	var/obj/item/device/paicard/pai//A slot for a pAI device
	var/obj/effect/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
	var/flush = 0//If an AI purge is in progress.
	var/s_control = 1//If user in control of the suit.


//=======//NEW AND DEL//=======//

/obj/item/clothing/suit/space/space_ninja/New()
	..()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_instruction//for AIs
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo
	//verbs += /obj/item/clothing/suit/space/space_ninja/proc/display_verb_procs//DEBUG. Doesn't work.
	spark_system = new()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	stored_research = new()//Stolen research initialize.
	cell = new/obj/item/weapon/cell/high//The suit should *always* have a battery because so many things rely on it.
	cell.charge = 9000//Starting charge should not be higher than maximum charge. It leads to problems with recharging.

/obj/item/clothing/suit/space/space_ninja/Del()
	if(affecting)//To make sure the window is closed.
		affecting << browse(null, "window=hack spideros")
	if(AI)//If there are AIs present when the ninja kicks the bucket.
		killai()
	if(hologram)//If there is a hologram
		del(hologram.i_attached)//Delete it and the attached image.
		del(hologram)
	..()
	return

//Allows the mob to grab a stealth icon.
/mob/proc/NinjaStealthActive(atom/A)//A is the atom which we are using as the overlay.
	invisibility = INVISIBILITY_LEVEL_TWO//Set ninja invis to 2.
	var/icon/opacity_icon = new(A.icon, A.icon_state)
	var/icon/alpha_mask = getIconMask(src)
	var/icon/alpha_mask_2 = new('icons/effects/effects.dmi', "at_shield1")
	alpha_mask.AddAlphaMask(alpha_mask_2)
	opacity_icon.AddAlphaMask(alpha_mask)
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x -= 1
			if(2)
				I.pixel_x += 1
			if(3)
				I.pixel_y -= 1
			if(4)
				I.pixel_y += 1

		overlays += I//And finally add the overlay.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)

//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)
	playsound(loc, 'sound/effects/stealthoff.ogg', 75, 1)



//Simply deletes all the attachments and self, killing all related procs.
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	del(n_hood)
	del(n_gloves)
	del(n_shoes)
	processing_objects.Remove(src)
	del(src)



//=======//GENERAL SUIT PROCS//=======//

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U)
	if(U==affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		if(istype(I, /obj/item/device/aicard))//If it's an AI card.
			var/obj/item/device/aicard/newcard = I
			if(s_control)
				newcard.transfer_ai("NINJASUIT","AICARD",src,U)
			else
				U << "<span class='alert'><b>ALERT:</b> Remote access channel disabled.</span>"
			return//Return individually so that ..() can run properly at the end of the proc.
		else if(istype(I, /obj/item/device/paicard) && !pai)//If it's a pai card.
			affecting.drop_item()
			I.loc = src
			pai = I
			U << "<span class='notice'>You slot \the [I] into \the [src].</span>"
			updateUsrDialog()
			return
		else if(istype(I, /obj/item/weapon/cell))
			if(I:maxcharge>cell.maxcharge&&n_gloves&&n_gloves.candrain)
				affecting << "<span class='notice'>Higher maximum capacity detected.\nUpgrading...</span>"
				if (n_gloves&&n_gloves.candrain&&do_after(U,s_delay))
					U.drop_item()
					I.loc = src
					I:charge = min(I:charge+cell.charge, I:maxcharge)
					var/obj/item/weapon/cell/old_cell = cell
					old_cell.charge = 0
					U.put_in_hands(old_cell)
					old_cell.add_fingerprint(U)
					old_cell.corrupt()
					old_cell.updateicon()
					cell = I
					U << "<span class='notice'>Upgrade complete. Maximum capacity: <b>[cell.maxcharge]</b></span>"
				else
					U << "<span class='alert'><B>ALERT:</B> Procedure interrupted. Protocol terminated.</span>"
			return
		else if(istype(I, /obj/item/weapon/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
			var/obj/item/weapon/disk/tech_disk/TD = I
			if(TD.stored)//If it has something on it.
				U << "Research information detected, processing..."
				if(do_after(U,s_delay))
					for(var/datum/tech/current_data in stored_research)
						if(current_data.id==TD.stored.id)
							if(current_data.level<TD.stored.level)
								current_data.level=TD.stored.level
							break
					TD.stored = null
					U << "<span class='notice'>Data analyzed and updated. Disk erased.</span>"
				else
					U << "<span class='alert'><b>ERROR:</b> Procedure interrupted. Process terminated.</span>"
			else
				I.loc = src
				t_disk = I
				U << "<span class='notice'>You slot \the [I] into \the [src].</span>"
			return
	..()

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	if(s_active)
		cancel_stealth()
	else
		activate_stealth()
	return

/obj/item/clothing/suit/space/space_ninja/proc/activate_stealth()
	var/mob/living/carbon/human/U = affecting
	spawn(0)
		anim(U.loc,U,'icons/mob/mob.dmi',,"cloak",,U.dir)
	s_active = 1
	U.update_icons()	//update their icons
	U.visible_message("[U] vanishes into thin air!","<span class='notice'>CLOAK-tech is now active; you are invisible to normal detection.</span>")

/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		spawn(0)
			anim(U.loc,U,'icons/mob/mob.dmi',,"uncloak",,U.dir)
		s_active = 0
		U.update_icons()	//update their icons
		U.visible_message("[U] appears from thin air!","<span class='danger'>CLOAK-tech is now inactive; you are visible to normal detection.</span>")
		return 1
	return 0

/obj/item/clothing/suit/space/space_ninja/update_icon()
	..()
	var/G = 0
	if (affecting)
		if (affecting.gender == FEMALE)
			G = 1
	icon_state = "s-ninja[s_initialized ? "n[G ? "f" : ""]" : ""]"
	item_state = "s-ninja[s_initialized ? "n[G ? "f" : ""]" : ""]"
	if (n_gloves)
		n_gloves.update_icon(s_initialized)

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(s_initialized)
		var/mob/living/carbon/human/U = affecting
		if(s_control)
			U << "All systems operational. Current energy: <B>[cell.charge]/[cell.maxcharge]</B>."
		else
			U <<  "�rr�R �a��a�� No-�-� f��N� 3RR�r"