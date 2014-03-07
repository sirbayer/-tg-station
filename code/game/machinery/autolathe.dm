//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/autolathe_recipes = list( \
		/* screwdriver removed*/ \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher(), \
		new /obj/item/device/multitool(), \
		new /obj/item/device/analyzer(), \
		new /obj/item/device/t_scanner(), \
		new /obj/item/weapon/weldingtool(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/airlock_electronics(), \
		new /obj/item/weapon/airalarm_electronics(), \
		new /obj/item/weapon/firealarm_electronics(), \
		new /obj/item/stack/sheet/metal(), \
		new /obj/item/stack/sheet/glass(), \
		new /obj/item/stack/sheet/rglass(), \
		new /obj/item/stack/rods(), \
		new /obj/item/weapon/rcd_ammo(), \
		new /obj/item/weapon/kitchenknife(), \
		new /obj/item/weapon/scalpel(), \
		new /obj/item/weapon/circular_saw(), \
		new /obj/item/weapon/surgicaldrill(),\
		new /obj/item/weapon/retractor(),\
		new /obj/item/weapon/cautery(),\
		new /obj/item/weapon/hemostat(),\
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_box/c38(), \
		new /obj/item/device/taperecorder/empty(), \
		new /obj/item/device/tape(), \
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio/off(), \
		new /obj/item/device/assembly/infra(), \
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/weapon/camera_assembly(), \
		new /obj/item/newscaster_frame(), \
		new /obj/item/weapon/reagent_containers/syringe(), \
	)

var/global/list/autolathe_recipes_hidden = list( \
		new /obj/item/weapon/flamethrower/full(), \
		new /obj/item/weapon/rcd(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/largetank(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_box/a357(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/buckshot(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		new /obj/item/ammo_casing/shotgun/incendiary(), \
		/* new /obj/item/weapon/shield/riot(), */ \
	)

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/m_amount = 0.0
	var/max_m_amount = 150000.0

	var/g_amount = 0.0
	var/max_g_amount = 75000.0

	var/operating = 0.0
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff
	var/datum/wires/autolathe/wires = null

/obj/machinery/autolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

	wires = new(src)
	src.L = autolathe_recipes
	src.LL = autolathe_recipes_hidden

/obj/machinery/autolathe/interact(mob/user)
	if(..())
		return
	if (src.shocked)
		src.shock(user,50)
	regular_win(user)
	return

/obj/machinery/autolathe/attackby(obj/item/O, mob/user)
	if (stat)
		return 1
	if (busy)
		user << "\red The autolathe is busy. Please wait for completion of previous operation."
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			if(m_amount >= 3750)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(m_amount / 3750)
			if(g_amount >= 3750)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / 3750)
			default_deconstruction_crowbar(O)
			return 1
		else
			attack_hand(user)
			return 1

	if (src.m_amount + O.m_amt > max_m_amount)
		user << "\red The autolathe is full. Please remove metal from the autolathe in order to insert more."
		return 1
	if (src.g_amount + O.g_amt > max_g_amount)
		user << "\red The autolathe is full. Please remove glass from the autolathe in order to insert more."
		return 1
	if (O.m_amt == 0 && O.g_amt == 0)
		user << "\red This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials."
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = O.m_amt
	var/g_amt = O.g_amt
	if (istype(O, /obj/item/stack))
		stack = O
		amount = stack.amount
		if (m_amt)
			amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
			flick("autolathe_o",src)//plays metal insertion animation
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
			flick("autolathe_r",src)//plays glass insertion animation
		stack.use(amount)
	else
		if(!user.unEquip(O))
			user << "<span class='notice'>/the [O] is stuck to your hand, you can't put it in \the [src]!</span>"
		O.loc = src
	icon_state = "autolathe"
	busy = 1
	use_power(max(1000, (m_amt+g_amt)*amount/10))
	src.m_amount += m_amt * amount
	src.g_amount += g_amt * amount
	user << "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe."
	if (O && O.loc == src)
		del(O)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/autolathe/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["make"])
			var/coeff = 2 ** prod_coeff
			var/turf/T = get_step(src.loc, get_dir(src,usr))
			var/obj/template = locate(href_list["make"])
			var/multiplier = text2num(href_list["multiplier"])
			if (!multiplier) multiplier = 1
			var/power = max(2000, (template.m_amt+template.g_amt)*multiplier/5)
			if(src.m_amount >= template.m_amt*multiplier/coeff && src.g_amount >= template.g_amt*multiplier/coeff)
				busy = 1
				use_power(power)
				icon_state = "autolathe"
				flick("autolathe_n",src)
				spawn(32/coeff)
					use_power(power)
					if(istype(template, /obj/item/stack))
						src.m_amount -= template.m_amt*multiplier
						src.g_amount -= template.g_amt*multiplier
						var/obj/new_item = new template.type(T)
						var/obj/item/stack/S = new_item
						S.amount = multiplier
					else
						src.m_amount -= template.m_amt/coeff
						src.g_amount -= template.g_amt/coeff
						var/obj/new_item = new template.type(T)
						new_item.m_amt /= coeff
						new_item.g_amt /= coeff
					if(src.m_amount < 0)
						src.m_amount = 0
					if(src.g_amount < 0)
						src.g_amount = 0
					busy = 0
	else
		usr << "\red The autolathe is busy. Please wait for completion of previous operation."
	src.updateUsrDialog()
	return

/obj/machinery/autolathe/RefreshParts()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	max_m_amount = tot_rating * 2
	max_g_amount = tot_rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/proc/regular_win(mob/user)
	var/dat
	if(!panel_open)
		var/coeff = 2 ** prod_coeff
		dat = "<div class='statusDisplay'><B>Metal Amount:</B> [src.m_amount] / [max_m_amount] cm<sup>3</sup><BR>"
		dat += "<B>Glass Amount:</B> [src.g_amount] / [max_g_amount] cm<sup>3</sup><HR>"
		var/list/objs = list()
		objs += src.L
		if(src.hacked)
			objs += src.LL
		for(var/obj/t in objs)
			if(disabled || m_amount<t.m_amt || g_amount<t.g_amt)
				dat += "<span class='linkOff'>[t.name]</span>"
			else
				dat += "<A href='?src=\ref[src];make=\ref[t]'>[t.name]</A>"

			if(istype(t, /obj/item/stack))
				var/obj/item/stack/S = t
				var/max_multiplier = min(S.max_amount, S.m_amt?round(m_amount/S.m_amt):INFINITY, S.g_amt?round(g_amount/S.g_amt):INFINITY)
				if (max_multiplier>10 && !disabled)
					dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[10]'>x[10]</A>"
				if (max_multiplier>25 && !disabled)
					dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[25]'>x[25]</A>"
				if (max_multiplier>1 && !disabled)
					dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
				dat += " [t.m_amt] m / [t.g_amt] g"
			else
				dat += " [t.m_amt/coeff] m / [t.g_amt/coeff] g"
			dat += "<br>"
		dat += "</span>"
	else
		dat = wires.GetInteractWindow()

	var/datum/browser/popup = new(user, "autolathe", name, 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0
