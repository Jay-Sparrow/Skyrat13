/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_BLOOD
	color = BLOOD_COLOR_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/bloodmeme = ""
	var/data = ""

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if(!data)
		C.data = add_blood_DNA(return_blood_DNA())
	if (bloodiness)
		if (C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	if(!bloodmeme)
		C.bloodmeme = add_blood_DNA(return_blood_DNA())
	update_icon()
	return ..()

//obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_dna)
//	return TRUE

/obj/effect/decal/cleanable/blood/transfer_mob_blood_dna()
	. = ..()
	update_icon()

/obj/effect/decal/cleanable/blood/update_icon()
	for(var/datum/reagent/R in reagents.reagent_list)
		// Get blood data from the blood reagent.
		if(istype(R, /datum/reagent/blood))
			if(R.data["blood_type"])
				bloodmeme = R.data["blood_type"]
				color = bloodtype_to_color(R.data["blood_type"])
		else if(istype(R, /datum/reagent/liquidgibs))
			if(R.data["blood_type"])
				bloodmeme = R.data["blood_type"]
				color = bloodtype_to_color(R.data["blood_type"])
		else
			color = blood_DNA_to_color()

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while. Eew."
	bloodiness = 0
	color = "#3a0505"

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state += "-old" //This IS necessary because the parent /blood type uses icon randomization.
	add_blood_DNA(list("blood_type"= "A+"))

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose so that it shows up even on regular splatters
	name = "blood"
	icon_state = "ltrails_1"
	desc = "Your instincts say you shouldn't be following these."
	random_icon_states = null
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/update_icon()
	for(var/datum/reagent/R in reagents.reagent_list)
		// Get blood data from the blood reagent.
		if(istype(R, /datum/reagent/blood))
			if(R.data["blood_type"])
				color = bloodtype_to_color(R.data["blood_type"]) //Color the blood with our dna stuff

/obj/effect/cleanable/trail_holder/Initialize()
	. = ..()
	AddComponent(/datum/component/forensics)
	update_icon()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/trail_holder/transfer_mob_blood_dna()
	. = ..()
	update_icon()

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "tracks"
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "nothingwhatsoever"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	random_icon_states = null
	var/entered_dirs = 0
	var/exited_dirs = 0
	var/print_state = FOOTPRINT_SHOE //the icon state to load images from
	var/list/shoe_types = list()

/obj/effect/decal/cleanable/blood/footprints/tracks/Crossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S)
			if(S.last_bloodtype)
				color = bloodtype_to_color(S.last_bloodtype)
			else
				color = bloodtype_to_color(bloodmeme)
		else
			if(H.last_bloodtype)
				color = bloodtype_to_color(H.last_bloodtype)
			else
				color = bloodtype_to_color(bloodmeme)


		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types |= S.type
			if (!(entered_dirs & H.dir))
				entered_dirs |= H.dir
				update_icon()
		else
			H.blood_smear[blood_state] = max(H.blood_smear[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			if (!(entered_dirs & H.dir))
				entered_dirs |= H.dir
				update_icon()

/obj/effect/decal/cleanable/blood/footprints/tracks/Uncrossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S)
			if(S.last_bloodtype)
				color = bloodtype_to_color(S.last_bloodtype)
			else
				color = bloodtype_to_color(bloodmeme)
		else
			if(H.last_bloodtype)
				color = bloodtype_to_color(H.last_bloodtype)
			else
				color = bloodtype_to_color(bloodmeme)

		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types  |= S.type
			if (!(exited_dirs & H.dir))
				exited_dirs |= H.dir
				update_icon()
		else
			H.blood_smear[blood_state] = max(H.blood_smear[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			if (!(exited_dirs & H.dir))
				exited_dirs |= H.dir
				update_icon()


/obj/effect/decal/cleanable/blood/footprints/tracks/update_icon()
	cut_overlays()

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[print_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[print_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[print_state]1", dir = Ddir)
			bloodstep_overlay.color = bloodtype_to_color(bloodmeme)
			add_overlay(bloodstep_overlay)
		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[print_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[print_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[print_state]2", dir = Ddir)
			bloodstep_overlay.color = bloodtype_to_color(bloodmeme)
			add_overlay(bloodstep_overlay)

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA+bloodiness

/obj/effect/decal/cleanable/blood/footprints/tracks/examine(mob/user)
	. = ..()
	if(shoe_types.len)
		. += "You recognise the footprints as belonging to:\n"
		for(var/shoe in shoe_types)
			var/obj/item/clothing/shoes/S = shoe
			. += "some <B>[initial(S.name)]</B> [icon2html(initial(S.icon), user)]\n"

	to_chat(user, .)

/obj/effect/decal/cleanable/blood/footprints/tracks/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	if(color != C.color)
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/tracks/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE

/obj/effect/decal/cleanable/blood/footprints/tracks/footprints
	name = "footprints"
	desc = "They look like tracks left by footwear."
	icon_state = FOOTPRINT_SHOE
	print_state = FOOTPRINT_SHOE

/obj/effect/decal/cleanable/blood/footprints/tracks/snake
	name = "tracks"
	desc = "They look like tracks left by a giant snake."
	icon_state = FOOTPRINT_SNAKE
	print_state = FOOTPRINT_SNAKE

/obj/effect/decal/cleanable/blood/footprints/tracks/paw
	name = "tracks"
	desc = "They look like tracks left by mammalian paws."
	icon_state = FOOTPRINT_PAW
	print_state = FOOTPRINT_PAW

/obj/effect/decal/cleanable/blood/footprints/tracks/claw
	name = "tracks"
	desc = "They look like tracks left by reptilian claws."
	icon_state = FOOTPRINT_CLAW
	print_state = FOOTPRINT_CLAW

/obj/effect/decal/cleanable/blood/footprints/tracks/wheels
	name = "tracks"
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	icon_state = FOOTPRINT_WHEEL
	print_state = FOOTPRINT_WHEEL

/obj/effect/decal/cleanable/blood/footprints/tracks/body
	name = "trails"
	desc = "A trail left by something being dragged."
	icon_state = FOOTPRINT_DRAG
	print_state = FOOTPRINT_DRAG
