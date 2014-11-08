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
	for (var/obj/screen/ability/ninja/AB in abilities)
		AB.maintain()
	if(!charge_process())
		n_gloves.draintarget = null
//		affecting << "<span class='notice'>Charging complete.</span>"
	if(!cell.use(s_cost))
		suit_power_failure()

//=======//Power Management//======//

/obj/item/clothing/suit/space/space_ninja/proc/charge_process()
//	world << "charge process runs"
	if(!(n_gloves && n_gloves.draintarget && n_gloves.candrain))
//		world << "can't drain or no target"
		return 0
	spark_system.start()
	var/chargeamt = s_cost*200
	if(do_after(affecting,5,1))
		world << "doafter"
		if(istype(n_gloves.draintarget,/obj/structure/grille))
			var/obj/structure/grille/B = n_gloves.draintarget
			var/obj/structure/cable/C = locate() in B.loc
			n_gloves.draintarget = C
		if(istype(n_gloves.draintarget,/obj/structure/cable))
			var/obj/structure/cable/A = n_gloves.draintarget
			var/datum/powernet/PN = A.get_powernet()
			if(!PN)
				affecting << "<span class='alert'>No powernet detected.</span>"
				return 0
			chargeamt = min(chargeamt,PN.avail)
			if(!chargeamt)
				for(var/obj/machinery/power/terminal/T in PN.nodes)
					if(istype(T.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/AP = T.master
						if(AP.operating && AP.cell)
							if(AP.cell.use(s_cost*10))
								chargeamt += s_cost*10
			PN.load += chargeamt
		else if(istype(n_gloves.draintarget,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = n_gloves.draintarget
			if(!A.cell || !A.cell.charge || !A.cell.use(chargeamt))
				chargeamt = A.cell.charge
				A.cell.use(chargeamt)
				affecting << "<span class='alert'>Target is discharged.</span>"
				return 0
			if(!A.emagged)
				flick("apc-spark", src)
				A.emagged = 1
				A.locked = 0
				A.update_icon()
		else if(istype(n_gloves.draintarget,/obj/machinery/power/smes))
			var/obj/machinery/power/smes/A = n_gloves.draintarget
			if(A.charge > (chargeamt))
				A.charge -= (chargeamt)
			else
				chargeamt = A.charge
				A.charge = 0
				affecting << "<span class='alert'>Target is discharged.</span>"
				return 0
		else if(istype(n_gloves.draintarget,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/A = n_gloves.draintarget
			if(!(A.cell && A.cell.use(chargeamt)))
				chargeamt = A.cell.charge
				A.cell.use(chargeamt)
				affecting << "<span class='alert'>Target is discharged.</span>"
				return 0
		else if(istype(n_gloves.draintarget,/obj/mecha))
			var/obj/mecha/A = n_gloves.draintarget
			if(!(A.get_charge() && (A.cell.use(chargeamt))))
				chargeamt = A.cell.charge
				A.cell.use(chargeamt)
				affecting << "<span class='alert'>Target is discharged.</span>"
				return 0
		else if(istype(n_gloves.draintarget,/obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/A = n_gloves.draintarget
			if (A.maxcharge > cell.maxcharge)
				affecting << "<span class='notice'>Higher cell capacity detected. Upgrade underway.</span>"
				if(do_after(affecting,s_delay))
					cell.maxcharge = A.maxcharge
					cell.give(A.charge)
					A.charge = 0
					A.corrupt()
					A.update_icon()
					affecting << "<span class='notice'>Upgrade complete.</span>"
					return 1
			if(!A.use(chargeamt))
				chargeamt = A.charge
				A.use(chargeamt)
				affecting << "<span class='alert'>Target is discharged</span>"
				return 0
		if(cell.give(chargeamt) < chargeamt)
			affecting << "<span class='notice'>Charging complete.</span>"
			return 0
		else
			return 1
	else
		affecting << "<span class='alert'>OPFAIL: Charging interrupted.</span>"
	return 0

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
//						unlock_suit()
						break
					U << "<span class='notice'>Linking neural-net interface...\nPattern </span>\green <B>GREEN</B><span class='notice'>, continuing operation.</span>"
				if(4)
					U << "<span class='notice'>VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>.</span>"
				if(5)
					U << "<span class='notice'>Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy: <B>[cell.charge]</B>.</span>"
					s_initialized = 1
					processing_objects.Add(src)
					spark_system.start()
					update_icon()
					U.regenerate_icons()
				if(6)
					U << "<span class='notice'>All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name].</span>"
					grant_ninja_buttons()
					grant_equip_verbs()
					s_busy = 0
			sleep(delay)
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
					remove_ninja_buttons()
				if(2)
					U << "<span class='notice'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>.</span>"
					s_initialized = 0
					update_icon()
					U.regenerate_icons()
					remove_ninja_buttons()
					cancel_stealth()//Shutdowns stealth.
					processing_objects.Remove(src)
				if(3)
					U << "<span class='notice'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>"
				if(4)
					U << "<span class='notice'>Disconnecting neural-net interface... <B>Success</B>.</span>"
				if(5)
					U << "<span class='notice'>Disengaging neural-net interface... <B>Success</B>.</span>"
				if(6)
					U << "<span class='notice'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>"
					remove_equip_verbs()
//					unlock_suit()
					s_busy = 0
			sleep(delay)
	return

//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/U = loc)
	set name = "Lock Suit"
	set desc = "Manually lock the ninja suit in place to allow operation."
	set category = "Ninja Equip"

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
		U << "<span class='alert'><B>ALERT:</B> [failed] error\s. Aborting...</span>"
		return 0


	if((flags & NODROP) && (newhood.flags & NODROP) && (newfeet.flags & NODROP) && (newgloves.flags & NODROP))
		U << "<span class='notice'>Suit is already locked.</span>"
		return 1
	affecting = U
	slowdown = 0
	flags |= NODROP
	n_hood = newhood
	n_hood.flags |= NODROP
	n_shoes = newfeet
	n_shoes.flags |= NODROP
	n_gloves = newgloves
	n_gloves.flags |= NODROP
	n_gloves.parent = src
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/lock_suit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/unlock_suit

	return 1

//This proc allows the suit to be taken off.
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	set name = "Unlock Suit"
	set desc = "Manually unlock the ninja suit."
	set category = "Ninja Equip"

	if(s_initialized)
		affecting << "<span class=alert>OPFAIL: Suit is still powered on. Cannot unlock at this time.</span>"
	affecting = null
	flags &= ~NODROP
	slowdown = 1
	if(n_hood)//Should be attached, might not be attached.
		n_hood.flags &= ~NODROP
	if(n_shoes)
		n_shoes.flags &= ~NODROP
	if(n_gloves)
		n_gloves.flags &= ~NODROP
		n_gloves.candrain = 0
		n_gloves.draintarget = null
		n_gloves.parent = null
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/lock_suit
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/unlock_suit

/obj/item/clothing/suit/space/space_ninja/proc/suit_power_failure()
	if(affecting)
		affecting << "<span class='alert'><B>ALERT:</B> Power levels critical. Entering hibernation mode.</span>"
	deinitialize()