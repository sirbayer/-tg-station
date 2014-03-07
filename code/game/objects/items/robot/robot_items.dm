//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

	attack(mob/M as mob, mob/living/silicon/robot/user as mob)

		user.cell.charge -= 30

		M.Weaken(5)
		if (M.stuttering < 5)
			M.stuttering = 5
		M.Stun(5)

		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message("\red <B>[user] has prodded [M] with an electrically-charged arm!</B>", 1, "\red You hear someone fall", 2)
		add_logs(user, M, "stunned", object="[src.name]", addition="(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "\proper x-ray Vision"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "thermal"


/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "meson"


/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "healthhud"


	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health(src)
		return


/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "securityhud"

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/security(src)
		return