
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/user)
	return
/atom/movable/attackby(obj/item/W, mob/user)
	if(W && !(W.flags&NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user)
	I.attack(src, user)

/mob/living/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	apply_damage(I.force, I.damtype)
	if(I.damtype == "brute")
		if(prob(33) && I.force)
			var/turf/location = src.loc
			if(istype(location, /turf/simulated))
				location.add_blood_floor(src)

	var/showname = "."
	if(user)
		showname = " by [user]!"
	if(!(user in viewers(I, null)))
		showname = "."

	if(I.attack_verb && I.attack_verb.len)
		src.visible_message("<span class='danger'>[src] has been [pick(I.attack_verb)] with [I][showname]</span>",
		"<span class='userdanger'>[src] has been [pick(I.attack_verb)] with [I][showname]</span>")
	else if(I.force)
		src.visible_message("<span class='danger'>[src] has been attacked with [I][showname]</span>",
		"<span class='userdanger'>[src] has been attacked with [I][showname]</span>")
	if(!showname && user)
		if(user.client)
			user << "\red <B>You attack [src] with [I]. </B>"

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

// Overrides the weapon attack so it can attack any atoms like when we want to have an effect on an object independent of attackby
// It is a powerfull proc but it should be used wisely, if there is other alternatives instead use those
// If it returns 1 it exits click code. Always . = 1 at start of the function if you delete src.
/obj/item/proc/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

obj/item/proc/get_clamped_volume()
	if(src.force && src.w_class)
		return Clamp((src.force + src.w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
	else if(!src.force && src.w_class)
		return Clamp(src.w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	if (!istype(M)) // not sure if this is the right thing...
		return

	if (hitsound && force > 0) //If an item's hitsound is defined and the item's force is greater than zero...
		playsound(loc, hitsound, get_clamped_volume(), 1, -1) //...play the item's hitsound at get_clamped_volume() with varying frequency and -1 extra range.
	else if (force == 0)//Otherwise, if the item's force is zero...
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)//...play tap.ogg at get_clamped_volume()
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	add_logs(user, M, "attacked", object=src.name, addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////
	M.attacked_by(src, user, def_zone)
	add_fingerprint(user)
	return 1