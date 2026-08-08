local FOODS, MAX_FOOD = {
	[2328] = {80, "Gulp."},  [2362] = {48, "Yum."}, [2666] = {175, "Munch."}, [2667] = {145, "Munch."},
	[2668] = {120, "Mmmm."}, [2669] = {200, "Munch."}, [2670] = {48, "Gulp."}, [2671] = {350, "Chomp."},
	[2672] = {700, "Chomp."}, [2673] = {64, "Yum."}, [2674] = {72, "Yum."}, [2675] = {150, "Yum."},
	[2676] = {96, "Yum."}, [2677] = {13, "Yum."}, [2678] = {210, "Slurp."}, [2679] = {13, "Yum."},
	[2680] = {24, "Yum."}, [2681] = {105, "Yum."}, [2682] = {230, "Yum."}, [2683] = {200, "Munch."},
	[2684] = {64, "Crunch."}, [2685] = {72, "Munch."}, [2686] = {105, "Crunch."}, [2687] = {24, "Crunch."},
	[2688] = {24, "Mmmm."}, [2689] = {120, "Crunch."}, [2690] = {72, "Crunch."}, [2691] = {96, "Crunch."},
	[2695] = {72, "Gulp."}, [2696] = {105, "Smack."}, [8112] = {105, "Urgh."}, [2769] = {64, "Crunch."}, [2787] = {105, "Crunch."},
	[2788] = {48, "Munch."}, [2789] = {255, "Munch."}, [2790] = {350, "Crunch."}, [2791] = {105, "Crunch."},
	[2792] = {72, "Crunch."}, [2793] = {145, "Crunch."}, [2794] = {35, "Crunch."}, [2795] = {420, "Crunch."},
	[2796] = {290, "Crunch."}, [5097] = {48, "Yum."}, [5678] = {96, "Gulp."}, [6125] = {96, "Mmmm."},
	[6278] = {120, "Mmmm."}, [6279] = {175, "Mmmm."}, [6393] = {145, "Mmmm."}, [6394] = {175, "Mmmm."},
	[6501] = {230, "Mmmm."}, [6541] = {72, "Gulp."}, [6542] = {72, "Gulp."}, [6543] = {72, "Gulp."},
	[6544] = {72, "Gulp."}, [6545] = {72, "Gulp."}, [6569] = {13, "Mmmm."}, [6574] = {64, "Mmmm."},
	[7158] = {290, "Munch."}, [7159] = {175, "Munch."}, [7372] = {0, "Yummy."}, [7373] = {0, "Yummy."},
	[7374] = {0, "Yummy."},  [7375] = {0, "Yummy."}, [7376] = {0, "Yummy."}, [7377] = {0, "Yummy."},
	[7963] = {700, "Munch."},  [8838] = {120, "Gulp."}, [8839] = {64, "Yum."}, [8840] = {13, "Yum."},
	[8841] = {13, "Urgh."}, [8842] = {80, "Munch."}, [8843] = {64, "Crunch."}, [8844] = {13, "Gulp."},
	[8845] = {64, "Munch."}, [8847] = {128, "Yum."}, [9114] = {64, "Crunch."}, [12378] = {96, "Crunch."}, 
	[12377] = {120, "Munch."}, [9005] = {88, "Slurp."}, [12598] = {640, "Gulp."}, [12599] = {210, "Yum."}, [6574] = {64, "Mmmm."},
	[7245] = {80, "Munch."}, [9996] = {0, "Slurp."}, [12379] = {105, "Crunch."}, [12600] = {24, "Munch."}, [12376] = {230, "Yum."},
	[10454] = {0, "Your head begins to feel better."}
}, 1200

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(item.itemid == 6280) then
		if(fromPosition.x == CONTAINER_POSITION) then
			fromPosition = getThingPosition(cid)
		end

		doCreatureSay(cid, getPlayerName(cid) .. " blew out the candle.", TALKTYPE_MONSTER)
		doTransformItem(item.uid, item.itemid - 1)

		doSendMagicEffect(fromPosition, CONST_ME_POFF)
		return true
	end

	local food = FOODS[item.itemid]
	if(food == nil) then
		return false
	end

	local size = food[1]
	if(getPlayerFood(cid) + size > MAX_FOOD) then
		doPlayerSendCancel(cid, "You are full.")
		return true
	end

	doPlayerFeed(cid, size)
	doRemoveItem(item.uid, 1)

	doCreatureSay(cid, food[2], TALKTYPE_MONSTER)
	return true
end
