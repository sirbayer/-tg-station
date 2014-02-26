//=======//PROCESS PROCS//=======//

/obj/item/clothing/suit/space/space_ninja/process()
	//Let's check for some safeties.
	if(s_initialized&&!affecting)	terminate()//Kills the suit and attached objects.
	if(!s_initialized)	return//When turned off the proc stops.
	if(AI&&AI.stat==2)//If there is an AI and it's ded. Shouldn't happen without purging, could happen.
		if(!s_control)
			ai_return_control()//Return control to ninja if the AI was previously in control.
		killai()//Delete AI.
	//Now let's do the normal processing.
	for (var/datum/sn_ability/AB in abilities)
		AB.maintain()
	if(!cell.use(s_cost))
		suit_power_failure()

//=======//INITIALIZE//=======//

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(U.mind && !s_initialized && !s_busy)//Shouldn't be busy... but anything is possible I guess.
		s_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					U << "<span class='notice'>Now initializing...</span>"
				if(1)
					if(!lock_suit(U))//To lock the suit onto wearer.
						break
					U << "<span class='notice'>Securing external locking mechanism...\nNeural-net established.</span>"
				if(2)
					U << "<span class='notice'>Extending neural-net interface...\nNow monitoring brain wave pattern...</span>"
				if(3)
					if(U.stat==2||U.health<=0)
						U << "<span class='notice'>Linking neural-net interface...</span>\n<span class='alert'>ALERT: Pattern <b>RED</b>. Link cannot complete. Aborting...</span>"
						unlock_suit()
						break
					lock_suit(U)
					U << "<span class='notice'>Linking neural-net interface...\nPattern </span>\green <B>GREEN</B><span class='notice'>, continuing operation.</span>"
				if(4)
					U << "<span class='notice'>VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>.</span>"
				if(5)
					U << "<span class='notice'>Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy: <B>[cell.charge]</B>.</span>"
					s_initialized = 1
					update_icon()
					U.regenerate_icons()
				if(6)
					U << "<span class='notice'>All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name].</span>"
					grant_ninja_buttons()
					processing_objects.Add(src)
			sleep(delay)
		s_busy = 0
	else
		U << "<span class='alert'><B>ALERT:</B> Initialization failed. Check suit for power or ongoing initialization.</span>"
	return

//=======//DEINITIALIZE//=======//

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc&&!s_busy)
		var/mob/living/carbon/human/U = affecting
		if(!s_initialized)
			U << "<span class='alert'><B>ALERT:</B> Deinitialization failed. Suit is not initialized.</span>"
			return
		s_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					U << "<span class='notice'>Now de-initializing...</span>"
					spideros = 0//Spideros resets.
				if(1)
					U << "<span class='notice'>Logging off, [U.real_name]. Shutting down SpiderOS.</span>"
//					remove_ninja_verbs()
				if(2)
					U << "<span class='notice'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>.</span>"
					s_initialized = 0
					update_icon()
					U.regenerate_icons()
					remove_ninja_buttons()
					cancel_stealth()//Shutdowns stealth.
				if(3)
					U << "<span class='notice'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>"
				if(4)
					U << "<span class='notice'>Disconnecting neural-net interface... <B>Success</B>.</span>"
				if(5)
					U << "<span class='notice'>Disengaging neural-net interface... <B>Success</B>.</span>"
				if(6)
					U << "<span class='notice'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>"
//					remove_equip_verbs()
					unlock_suit()
			sleep(delay)
		s_busy = 0
	return

//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/U)
	if(!U.mind)
		return 0
	if(U.mind.special_role!="Space Ninja")
		U << "<span class='userdanger'>ALERT: Unauthorized use detected. Terminating user. Goodbye.</span>"
		U.gib()
		return 0
	var/obj/item/clothing/head/helmet/space/space_ninja/newhood = U:head
	var/obj/item/clothing/shoes/space_ninja/newfeet = U:shoes
	var/obj/item/clothing/gloves/space_ninja/newgloves = U:gloves
	var/failed = 0
	if(!newhood)
		U << "<span class='alert'><B>ALERT:</B> Unable to locate head gear.</span>"
		failed++
	if(!newfeet)
		U << "<span class='alert'><B>ALERT:</B> Unable to locate foot gear.</span>"
		failed++
	if(!newgloves)
		U << "<span class='alert'><B>ALERT:</B> Unable to locate hand gear</span>"
		failed++
	if(failed)
		U << "<span class='alert'><B>ALERT:</B> [failed] error\s detected. Aborting...</span>"
		return 0

	affecting = U
	canremove = 0
	slowdown = 0
	n_hood = newhood
	n_hood.canremove = 0
	n_shoes = newfeet
	n_shoes.canremove = 0
	n_shoes.slowdown = -1
	n_gloves = newgloves
	n_gloves.canremove = 0

	return 1

//This proc allows the suit to be taken off.
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	affecting = null
	canremove = 1
	slowdown = 1
	if(n_hood)//Should be attached, might not be attached.
		n_hood.canremove = 1
	if(n_shoes)
		n_shoes.canremove = 1
		n_shoes.slowdown = 0
	if(n_gloves)
		n_gloves.canremove = 1
		n_gloves.candrain = 0
		n_gloves.draining = 0

/obj/item/clothing/suit/space/space_ninja/proc/suit_power_failure()
	deinitialize()