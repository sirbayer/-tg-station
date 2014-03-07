/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++//                    //++++++++++++++++++++++++++++++++++
==================================SPACE NINJA ABILITIES====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//basic definitions below

/obj/screen/ability/ninja
	var/obj/item/clothing/suit/space/space_ninja/parent = null //the ninja suit this comes from
	var/acost = 0 //ability cost
	var/cd = 0 //current cooldown
	var/ncd = 0 //cooldown
	var/aname = "Generic Ninja Ability"
	var/adesc = "A generic spess ninja ability. You shouldn't be seeing this."

/obj/screen/ability/ninja/activate(var/checkstat = 1)
	if (!parent || !parent.affecting)
		return 0
	if (parent.s_busy)
		parent.affecting << "<span class='alert'>Suit is already busy, please wait.</span>"
		return 0
	if (cd)
		parent.affecting << "<span class='alert'>ALERT: [src.aname] is not ready for use.</span>"
		return 0
	var/thecheck = special_check()
	if (thecheck)
		parent.affecting << thecheck
		return 0
	if (!parent.cell.use(acost))
		parent.affecting << "<span class='alert'><B>ALERT:</B> Insufficient energy for operation.</span>"
		return 0
	if (checkstat && (parent.affecting.stat || parent.affecting.incorporeal_move))
		parent.affecting << "<span class='alert'>You must be solid and conscious to do this.</span>"
		return 0
	cd = ncd
	return 1

/obj/screen/ability/ninja/proc/special_check()
	return

/obj/screen/ability/ninja/proc/maintain()
	if (cd)
		cd--

//=======//SMOKE//=======//
/*Summons smoke in radius of user.
Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.*/
/obj/screen/ability/ninja/ninjasmoke
	aname = "Smoke Bomb"
	adesc = "Generate a cloud of smoke from emitters in your suit to blind and choke pursuers."
	acost = 50
	ncd = 5
	icon_state = "smoke"

/obj/screen/ability/ninja/ninjasmoke/activate()
	if (..())
		var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
		smoke.set_up(10, 0, parent.affecting.loc)
		smoke.start()
		playsound(parent.affecting.loc, 'sound/effects/bamf.ogg', 50, 2)

//=======//TELEPORT GRAB CHECK//=======//
/obj/screen/ability/ninja/proc/handle_teleport_grab(turf/T)
	if(istype(parent.affecting.get_active_hand(),/obj/item/weapon/grab))//Handles grabbed persons.
		var/obj/item/weapon/grab/G = parent.affecting.get_active_hand()
		G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
	if(istype(parent.affecting.get_inactive_hand(),/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = parent.affecting.get_inactive_hand()
		G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
	return

//=======//9-8 TILE TELEPORT//=======//
//Click to to teleport 9-10 tiles in direction facing.
/obj/screen/ability/ninja/ninjajaunt
	aname = "Phase Jaunt"
	adesc = "Utilize VOID-shift tech to teleport imprecisely to a location you're facing."
	acost = 1000
	ncd = 1
	var/turf/dest
	var/turf/mobloc
	icon_state = "jaunt"

/obj/screen/ability/ninja/ninjajaunt/special_check()
	dest = get_teleport_loc(parent.affecting.loc,parent.affecting,9,1,3,1,0,1)
	mobloc = get_turf(parent.affecting.loc)
	if(!(dest&&istype(mobloc, /turf)))
		return "<span class='alert'>ALERT: Unacceptable starting location. Cannot jaunt or shift from this terrain.</span>"

/obj/screen/ability/ninja/ninjajaunt/activate()
	if(..())
		spawn(0)
			playsound(mobloc, "sparks", 50, 1)
			anim(mobloc,src,'icons/mob/mob.dmi',,"phaseout",,parent.affecting.dir)

		handle_teleport_grab(dest)
		parent.affecting.loc = dest

		spawn(0)
			parent.spark_system.start()
			playsound(dest, 'sound/effects/phasein.ogg', 25, 1)
			playsound(dest, "sparks", 50, 1)
			anim(dest.loc,parent.affecting,'icons/mob/mob.dmi',,"phasein",,parent.affecting.dir)

		spawn(0)
			dest.kill_creatures(parent.affecting)//Any living mobs in teleport area are gibbed. Check turf procs for how it does it.
		return

//=======//RIGHT CLICK TELEPORT//=======//
//Right click to teleport somewhere, almost exactly like admin jump to turf.
/obj/screen/ability/ninja/ninjajaunt/ninjashift
	aname = "Phase Shift"
	adesc = "Utilize VOID-shift tech to teleport to a targeted location in view."
	//set src = usr.contents//Fixes verbs not attaching properly for objects. Praise the DM reference guide! (???)
	acost = 2000
	icon_state = "shift"

/obj/screen/ability/ninja/ninjajaunt/ninjashift/special_check()
	..()
	//dest = ?????? WE NEED TO TARGET HERE
	if(dest.density)
		return "<span class='alert'>ALERT: Unacceptable end location. Cannot shift into solid objects.</span>"

//=======//EM PULSE//=======//
//Disables nearby tech equipment.
/obj/screen/ability/ninja/ninjapulse
	aname = "EM Burst"
	adesc = "Force extra charge through the suit's circuits, causing an electro-magnetic pulse."
	acost = 2500
	ncd = 10
	icon_state = "emp"

/obj/screen/ability/ninja/ninjapulse/activate()
	if(..())
		playsound(parent.affecting.loc, 'sound/effects/EMPulse.ogg', 60, 2)
		empulse(parent.affecting, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.

//=======//ENERGY BLADE//=======//
//Summons a blade of energy in active hand.
/obj/screen/ability/ninja/ninjablade
	aname = "Energy Blade"
	adesc = "Create a focused beam of energy in your active hand. Requires power to maintain."
	acost = 50
	icon_state = "blade"

/obj/screen/ability/ninja/ninjablade/special_check()
	if(blade_check())
		return "<span class='alert'>ALERT: Energy blade is already active.</span>"
	if(parent.affecting.get_active_hand())
		return "<span class='alert'>ALERT: Hand is already occupied.</span>"

/obj/screen/ability/ninja/ninjablade/activate()
	if(..())
		var/obj/item/weapon/melee/energy/blade/W = new()
		parent.spark_system.start()
		playsound(parent.affecting.loc, "sparks", 50, 1)
		parent.affecting.put_in_hands(W)

/obj/screen/ability/ninja/ninjablade/maintain()
	if (!parent || !parent.cell)
		del(src) //ha ha desperate measures
	if(!parent.cell.use(acost))
		blade_kill()
		parent.cell.charge = 0
		return

/obj/screen/ability/ninja/ninjablade/proc/blade_check()
	if(istype(parent.affecting.get_active_hand(), /obj/item/weapon/melee/energy/blade) || istype(parent.affecting.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
		return 1
	return 0

/obj/screen/ability/ninja/ninjablade/proc/blade_kill()
	if(istype(parent.affecting.get_active_hand(), /obj/item/weapon/melee/energy/blade))
		parent.affecting.drop_item()
	if(istype(parent.affecting.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
		parent.affecting.swap_hand()
		parent.affecting.drop_item()

//=======//NINJA STARS//=======//
/*Shoots ninja stars at random people.
This could be a lot better but I'm too tired atm.*/
/obj/screen/ability/ninja/ninjastar
	aname = "Energy Star"
	adesc = "Throw an energy star at a random living target."
	acost = 500
	ncd = 1
	var/targets[] = list()//So yo can shoot while yo throw dawg
	icon_state = "star"

/obj/screen/ability/ninja/ninjastar/special_check()
	targets = list()
	for(var/mob/living/M in oview(parent.affecting.loc))
		if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
		targets.Add(M)
	if(!targets.len)
		return "<span class='alert'>ALERT: No targets detected.</span>"

/obj/screen/ability/ninja/ninjastar/activate()
	if (..())
		var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.
		var/turf/curloc = parent.affecting.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return
		var/obj/item/projectile/energy/dart/A = new /obj/item/projectile/energy/dart(parent.affecting.loc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		A.process()

//=======//ADRENALINE BOOST//=======//
/*Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
Movement impairing would indicate drugs and the like.*/
/obj/screen/ability/ninja/ninjaboost
	aname = "Adrenaline Boost"
	adesc = "Overcharge the suit's assist servos and inject adrenaline to counteract incapacitation."
	acost = 1000
	ncd = 3
	icon_state = "boost"

/obj/screen/ability/ninja/ninjaboost/activate()
	if(..(0))//Have to make sure stat is not counted for this ability.
		parent.affecting.SetParalysis(0)
		parent.affecting.SetStunned(0)
		parent.affecting.SetWeakened(0)
		parent.affecting.stat = 0//At least now you should be able to teleport away or shoot ninja stars.
		spawn(30)//Slight delay so the enemy does not immedietly know the ability was used. Due to lag, this often came before waking up.
			parent.affecting.say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))