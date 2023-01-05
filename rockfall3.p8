pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--rockfall 3
--mr awesome

cartdata("mrawesome_rockfall_3")

grav = 0.05
screen = 0
isyellow = false

function cprint(text, x, y, c1, c2)
	for x1 = -1, 1 do
		for y1 = -1, 1 do
			print(text, x1+x, y1+y, c2)
		end
	end
	print(text, x, y, c1)
end


-- into one thing b/c
-- i don't like all the
-- extra global vars
-- anyway.
menudata = {
	-- index = screen + 1
	-- so screen 0
	-- uses menuitem[1]
	{
		-- main menu
		onitem = 0,
	},

	{
		-- nothing, because
		-- it's for the playing
		-- screen
	},

	{
		-- options menu
		onitem = 0
	},
	
	{
		-- customize menu
		onitem = 0
	},
	
	{
		-- graphics menu
		onitem = 0
	},
	
	{
		-- diffiulty menu
		onitem = 0
	}
}

-- if not played (dget returns 0 if not defined) then we set all the defaults
if dget(7) == 0 then
	dset(0,0)
	dset(1,-1)
	dset(2,3)
	dset(3,11)
	dset(4,1)
	dset(5,1)
	dset(6,1)
	dset(7,1)
end

isc = dget(3)
hlc = dget(2)
emc = dget(4)
hat = dget(1)

graphics = dget(5)
difficulty = dget(6)

shaking4 = 0

anim3y = (graphics >= 1 and -40 or 30)
anim3yv = 2

hiscore = dget(0)
score = 0
tss = 0 -- ticks since start (for scorekeeping)

-- menuitem(1, "clear data", function() dset(7,0) hiscore = 0 end)

function rndcamshake()
	camera(rnd(2)-1,rnd(2)-1)
end

parts = {}
function addpart(x,y,xv,yv,col,ttd)
	add(parts,{
		x=x, -- x pos
		y=y, -- y pos
		xv=xv, -- x velocity
		yv=yv, -- y velocity
		col=col, -- colour
		ttd=0, --time till destroy
		tttd=ttd --total time till destroy
	})
end

function movepart(part)
	part.x += part.xv
	part.xv /= 1.5
	part.y += part.yv
	part.yv += grav
	
	if(part.ttd >= part.tttd) then del(parts,part) end
	
	part.ttd += 1
end

function collide(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 <= x2+w2 and x1+w1 >= x2 and y1 <= y2+h2 and y1+h1 >= y2
end

p={
	x=55,
	y=93,
	yv=0
}

function p:move()
	if btn(⬅️) and not btn(➡️) then
		p.x -= 1
		if p.y == 93 and graphics >= 1 then
			addpart(p.x + 16 + (rnd(10)-5),
										 p.y + 16,
										 rnd(2),
										 -rnd(1),
										 rnd({3,11,-5,-13}),
										 rnd(15)
										)
		end
	elseif btn(➡️) and not btn(⬅️) then
		p.x += 1
		if p.y == 93 and graphics >= 1 then
			addpart(p.x + (rnd(10)-5),
										 p.y + 16,
										 -rnd(2),
										 -rnd(1),
										 rnd({3,11,-5,-13}),
										 rnd(15)
										)
		end
	end
	
	p.yv += grav
	p.y += p.yv
	
	if p.y > 93 then
		p.y = 93
		p.yv = 0
	end
	
	if btn(🅾️) and p.y == 93 then
		p.yv = -1.4
		sfx(3,1)
	end
	
	p.x = mid(0,p.x,112)
end

rocks = {}
function newrock()
	add(rocks,{
		y=-16,
		x=rnd(112),
		yv=rnd(2)
	})
end

function moverock(r)
	r.yv += grav
	r.y += r.yv
	
	if collide(p.x,p.y,15,15,r.x+3,r.y+3,12,12) then
		p.x=55
		p.y=93
		p.yv=0
		screen = 0
		rocks = {}
		newrock()
		
		if score > hiscore then
			dset(0, score)
			hiscore = score
		end
		
		if graphics >= 1 then
			shaking4 = 30
		end
		
		sfx(4,2)
	end
	
	if r.y > 128 then
		r.y = -16
		r.x = rnd(112)
		r.yv = rnd(2)
	end

end
newrock()
ticks = 0

function _init()
	music(0,0)
end

function _update60()	
	if ticks%30==0 then
		isyellow = not isyellow
	end
	
	if screen == 0 then
	
		if graphics >= 1 then
			if anim3y < 30 then
				anim3yv += grav
				anim3y += anim3yv
			elseif anim3y > 30 then
				anim3y = 30
				for i=0, 200 do
					addpart(
						51 + rnd(24),
						66 + rnd(10)-5,
						rnd(4)-2,
						0,
						rnd({5,5,5,6}),
						rnd(7)
					)
				end
			end
		end
		
		if btnp(❎) then
			if menudata[1].onitem == 0 then
				screen = 1
				anim3yv = 2
				anim3y = (graphics >= 1 and -40 or 30)
				tss = ticks
			end
			
			if menudata[1].onitem == 1 then
				screen = 2
			end
		end		
		
		if btn(⬆️) then
			menudata[1].onitem = mid(0,menudata[1].onitem - 1, 1)
		end
		
		if btn(⬇️) then
			menudata[1].onitem = mid(0,menudata[1].onitem + 1, 1)
		end
	elseif screen == 1 then
		p:move()
		for k,v in pairs(rocks) do
			moverock(v)
		end
		
		if rnd(480/(difficulty/10)) < 1 then
			newrock()
		end
		
		score = flr((ticks-tss)/60)
	elseif screen == 2 then
		
		if btnp(⬆️) then
			menudata[3].onitem = mid(0, menudata[3].onitem - 1, 3)
		end
		
		if btnp(⬇️) then
			menudata[3].onitem = mid(0, menudata[3].onitem + 1, 3)
		end
		
		if btnp(❎) then
			local on = menudata[3].onitem
			
			if on == 0 then
				screen = 3
			elseif on == 1 then
				screen = 4
			elseif on == 2 then
				screen = 5
			elseif on == 3 then
				screen = 0
			end
			
			menudata[3].onitem = 0
		end

	elseif screen == 3 then
		
		if btnp(⬆️) then
			menudata[4].onitem = mid(0, menudata[4].onitem - 1, 4)
		end

		if btnp(⬇️) then
			menudata[4].onitem = mid(0, menudata[4].onitem + 1, 4)
		end
		
		if btnp(⬅️) then
			local on = menudata[4].onitem
			
			if on == 0 then
				hat = mid(-1, hat - 1, 8)
			elseif on == 1 then
				hlc = mid(0, hlc - 1, 15)
			elseif on == 2 then
				emc = mid(0, emc - 1, 15)
			elseif on == 3 then
				isc = mid(0, isc - 1, 15)
			end
		end
		
		if btnp(➡️) then
			local on = menudata[4].onitem
			
			if on == 0 then
				hat = mid(-1, hat + 1, 7)
			elseif on == 1 then
				hlc = mid(0, hlc + 1, 15)
			elseif on == 2 then
				emc = mid(0, emc + 1, 15)
			elseif on == 3 then
				isc = mid(0, isc + 1, 15)
			end
		end
		
		if btnp(❎) and menudata[4].onitem == 4 then
			dset(1,hat)
			dset(2,hlc)
			dset(3,isc)
			dset(4,emc)
			screen = 2
		end
		
		
	elseif screen == 4 then 
		
		local on = menudata[5].onitem
		if btnp(⬆️) then
			menudata[5].onitem = mid(0, on - 1, 1)
		elseif btnp(⬇️) then
			menudata[5].onitem = mid(0, on + 1, 1)
		end
		
		if on == 0 then
			
			if btnp(⬅️) then
				graphics = mid(0, graphics - 1, 2)
			elseif btnp(➡️) then
				graphics = mid(0, graphics + 1, 2)
			end
		else
			if btnp(❎) then
				if graphics ~= 2 then
					screen = 2
					menudata[5].onitem = 0
					dset(5,graphics)
				else
					shaking4 = 30
				end
			end
		end
	elseif screen == 5 then
		local on = menudata[6].onitem
		if on == 0 then
			
			if btnp(⬅️) then
				difficulty = mid(5, difficulty - 1, 20)
			elseif btnp(➡️) then
				difficulty = mid(5, difficulty + 1, 20)
			end
		else
			if btnp(❎) then
				screen = 0
				menudata[6].onitem = 0
				dset(6,difficulty)
			end
		end
		
		if btnp(⬇️) then
			menudata[6].onitem = mid(0, on + 1, 1)
		elseif btnp(⬆️) then
			menudata[6].onitem = mid(0, on - 1, 1)
		end
	end
	
	for k,v in pairs(parts) do
		movepart(v)
	end
	
	ticks += 1
end

function _draw()
	camera(0,0)
	cls(12)
	
	if shaking4 > 0 then 
		rndcamshake()
		shaking4 -= 1
	end

	for k,v in pairs(parts) do
		pset(v.x,v.y,v.col)
	end
	
	map(0,0,-8,5,128,128)
	
	cprint("sCORE: "..score,1,114,7, 1)
	cprint("hI: "..(score < hiscore and hiscore or score),1,122,7, 1)

	if(hat != -1)spr(64+(2*hat),p.x,p.y-16,2,2)
	pal(5,emc,0)
	pal(7,isc,0)
	pal(6,hlc,0)
	spr(1,p.x,p.y,2,2)
	pal()

	if screen == 0 then
		cprint("\^w\^trockfall",36,15,7,1)
		sspr(72,0,16,24,51,anim3y,24,36)

		if menudata[1].onitem == 0 then
			if isyellow then
				cprint("➡️ play",44,70,10,1)
			else
				cprint("➡️ play",44,70,9,1,1)
			end
			cprint("options",50,80,7,1)
		else

			if isyellow then
					cprint("➡️ options",38,80,10,1)
				else
					cprint("➡️ options",38,80,9,1)
				end
				cprint("play",56,70,7,1)
			end
		else
		for k,v in pairs(rocks) do
			spr(3,v.x,v.y,2,2)
		end
	end
	
	if screen == 2 then
		rect(18,18,109,109,6)
		rectfill(19,19,108,108,7)
		
		local on = menudata[3].onitem
		
		cprint("oPTIONS", 50, 20, 7, 1)
		
		cprint((on == 0 and "\^i" or "").."cUSTOMIZE", 46, 35, 7, 1)
		cprint((on == 1 and "\^i" or "").."gRAPHICS", 48, 50, 7, 1)
		cprint((on == 2 and "\^i" or "").."dIFFICULTY", 43, 65, 7, 1)
		cprint((on == 3 and "\^i" or "").."cLOSE", 54, 80, 7, 1)
		
		cprint("🅾️⬆️⬇️ TO CHOOSE", 21, 102, 7, 1)
	end
	
	if screen == 3 then
		rect(18,18,109,109,6)
		rectfill(19,19,108,108,12)
		
		pal(5,emc,0)
		pal(7,isc,0)
		pal(6,hlc,0)
		sspr(8,0,16,16,40,60,48,48)
		pal()
		sspr(0+(hat*16),32,16,16,40,12,48,48)

	
		for i=0, 3 do
			spr(12 - (menudata[4].onitem == i and 1 or 0), 20, i*20+30)
			spr(12 - (menudata[4].onitem == i and 1 or 0), 100, i*20+30, 1, 1, true, false)
		end
	
		cprint((menudata[4].onitem == 4 and "\^i" or "").."sAVE", 54, 113, 7, 1)
	
	end
	
	if screen == 4 then
		rect(18,18,109,109,6)
		rectfill(19,19,108,108,7)
		cprint("gRAPHICS", 47, 20, 7, 1)
		local on = menudata[5].onitem
		col = (on == 0 and 9 or 1)
		cprint("gRAPHICS lEVEL: ", 31, 53, 7, 1)
		if graphics == 0 then
			cprint("⬅️ fAST ➡️", 43, 62, 7, col)
			cprint("nO PARTICLES.\nrUNS QUICKLY.", 40, 70, 7, 1)
		elseif graphics == 1 then
			cprint("⬅️ fANCY ➡️", 41, 62, 7, col)
			cprint("  pARTICLES.\nhARDER TO RUN,\n bUT STILL ok.", 35, 70, 7, 1)
		elseif graphics == 2 then
			cprint("⬅️ oVERKILL ➡️", 35, 62, 7, col)
			cprint("  fOR PREMIUM USERS.\n wAY MORE PARTICLES.", 23, 70, 7, 1)
		end
		
		cprint((on == 1 and "\^i" or "").."sAVE", 55, 98, 7, 1)
		cprint("⬅️➡️⬆️⬇️❎ tO sELECT", 25, 30, 7, 1)
	end
	
	if screen == 5 then
		rect(16,16,111,111,6)
		rectfill(17,17,110,110,7)
		local on = menudata[6].onitem
		
		cprint("dIFFICULTY", 43, 20, 7, 1)
		cprint("⬅️➡️⬆️⬇️❎ tO sELECT", 25, 30, 7, 1)
		
		for i = 5, 20 do
			if i == 5 or i == 10 or i == 15 or i == 20 then
				line(i*5+1, 59, i*5+1, 66, (i == difficulty and 8 or 1))
			else
				line(i*5+1, 60, i*5+1, 65, (i == difficulty and 8 or 1))
			end
		end
		
		cprint("eASY", 18, 70, 7, 1)
		cprint("mED", 46, 70, 7, 1)
		cprint("hARD", 68, 70, 7, 1)
		cprint("xHRD", 93, 70, 7, 1)
		
		if on == 0 then
			cprint("\^i⬅️ dIFFICULTY: "..tostr(difficulty/10).." ➡️", 63-(36 + #tostr(difficulty/10)*2), 45, 7, 1)
		else
			cprint("dIFFICULTY: "..tostr(difficulty/10), 63-(24 + #tostr(difficulty/10)*2), 45, 7, 1)
		end
		cprint((on == 0 and "" or "\^i").."sAVE", 55, 90, 7, 1)
	end
end
__gfx__
00000000666666666666666600005555555500000000aaaaaaaa0000333333334444444400000000000000000000000000000000000000000000000000000000
000000006677777777777766005556666665550000aaaaaaaaaaaa00232233234444444405555555555555000000999000005550000000000000000000000000
00700700677777777777777605566666666665500aaaaaaaaaaaaa90424423424444444405666666666665500099aa9000556650000000000000000000000000
00077000675777777777757605666556666666500aaaaaaaaaaaaa904444424444444444055666666666665009aaaa9005666650000000000000000000000000
0007700067577777777775765566656666666655aaaaaaaaaaaaaaa94444444444444444005555555555665009aaaa9005666650000000000000000000000000
0070070067777777777777765666666666666665aaaaaaaaaaaaaaa9444444444444444400000000000566500099aa9000556650000000000000000000000000
0000000067777777777777765666666666666665aaaaaaaaaaaaaaa9444444444444444400000000000566500000999000005550000000000000000000000000
0000000067777777777777765656666666666665aaaaaaaaaaaaaaa9444444444444444400000000000566500000000000000000000000000000000000000000
0000000067777777777777765666666666666565aaaaaaaaaaaaaaa9000000000000000000000000000566500000000000000000000000000000000000000000
0000000067577777777775765666665666666565aaaaaaaaaaaaaaa9000000000000000000000000000566500000000000000000000000000000000000000000
0000000067557777777755765666666666665565aaaaaaaaaaaaaaa9000000000000000000555555555566500000000000000000000000000000000000000000
0000000067755777777557765566666666666655aaaaaaaaaaaaaaa9000000000000000000566666666666500000000000000000000000000000000000000000
00000000677755555555777605666666666666500aaaaaaaaaaaaa90000000000000000000566666666666500000000000000000000000000000000000000000
00000000677777777777777605566665566665500aaaaaaaaaaaaa90000000000000000000555555555666500000000000000000000000000000000000000000
00000000667777777777776600555666666555000099aaaaaaaa9900000000000000000000000000005666500000000000000000000000000000000000000000
00000000666666666666666600005555555500000000999999990000000000000000000000000000005666500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005666500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005666500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000555000555666500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000566555666666500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000566666666665500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000556666666550000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000055555555500000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000057000000000000000000000000000000000000000000000000000000000
00011111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00015555555510000000000000000000000000000000000000000000000000000000000000007500000000000000000000000000000000000000000770000000
00015555555510000000000000000000000000000000000000000000000000000075000004000000000000000000000000000000000000000000000770000000
00015555555510000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000880000000
00015555555510000000000080000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000008888000000
00015555555510000000000890000000000000000000000000000000000000000000000004400000000000000000000000000000000000000000008888000000
00015555555510000000000980000000000033333333000000000555555000000000000444400000000000000000000000000000000000000000088888800000
0001555555551000000000988000000000003b1bb1b3000000005566665500000000004444440000000000000000000000000000000000000000088888800000
0001555555551000000000889800000000003bbbbbb3000000005665666500000000004444440000000000000000000000000000000000000000888888880000
0001555555551000000000898800000000003bbbbbb3000000005666656500000000444444440000000000666660000000099999999990000000888888880000
1111888888881111000008988900000000003bbbbbb3000000005656666500000000444444440000000066060606600000900000000009000008888888888000
155188888888155100000988988000000000311bb113000000005666566500000004444444444000000060606060600000900000000009000008888888888000
1155555555555511000098898890000000003b1111b3000000005566665500000044444444444400000066060606600000099999999990000077777777777700
01111111111111100000889889880000000033333333000000000555555000000044444444444400666666666666600000000000000000000077777777777700
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccaaaaaaaacccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccaaaaaaaaaaaaccccc11111111cc111111cc1111111111111111111111111111111111cccc1111ccccccccccccccccccccccccccccccccc
cccccccccccccccccaaaaaaaaaaaaa9cccc17777771cc177771cc1777711771177117777771177777711771cccc1771ccccccccccccccccccccccccccccccccc
cccccccccccccccccaaaaaaaaaaaaa9cccc1777777111177771111777711771177117777771177777711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc1771177117711771177111111771177117711111177117711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc17711771177117711771cccc17711771177111cc177117711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc17777111177117711771cccc17777111177771cc177777711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc17777111177117711771cccc17777111177771cc177777711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc17711771177117711771cccc17711771177111cc177117711771cccc1771ccccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc177117711771177117711111177117711771cccc177117711771111117711111ccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc177117711777711111177771177117711771cccc177117711777777117777771ccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaa9ccc17711771177771cccc177771177117711771cccc177117711777777117777771ccccccccccccccccccccccccccccc
cccccccccccccccccaaaaaaaaaaaaa9cccc11111111111111cccc111111111111111111cccc111111111111111111111111ccccccccccccccccccccccccccccc
cccccccccccccccccaaaaaaaaaaaaa9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc99aaaaaaaa99cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc5555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc566666666666666666555cccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc566666666666666666555cccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc555666666666666666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555555555566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555555555566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555555555566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555555555566655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666666666666666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666666666666666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666666666666666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555555555666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555cccc55555666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55555cccc55555666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666555566666666655cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666666666666666555cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55666666666666666555cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc55566666666666555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc5555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc5555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc1111111cccc1111111c111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc11aaaaa11ccc1aaa1a1c1aaa1a1a1cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc1aa11aaa1ccc1a1a1a1c1a1a1a1a1cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc1aa111aa1ccc1aaa1a1c1aaa1aaa1cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc1aa11aaa1ccc1a111a111a1a111a1cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc11aaaaa11ccc1a1c1aaa1a1a1aaa1cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc1111111cccc111c1111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111c1111cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc11771777177717771177177111771cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc17171717117111711717171717111cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc17171777117151711717171717771cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc17171711117111711717171711171cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc1771171cc17117771771171717711cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc1111111cc1111111111111111111ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1555555551cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1555555551cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1555555551cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111888888881111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1551888888881551ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1155555555555511ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333333333333ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc33bbbbbbbbbbbb33ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b1bbbbbbbbbb1b3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b1bbbbbbbbbb1b3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b1bbbbbbbbbb1b3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b11bbbbbbbb11b3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb11bbbbbb11bb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbb11111111bbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbbbbbbbb3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc33bbbbbbbbbbbb33ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333333333333ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
23223323232233232322332323223323232233232322332323223323232233232322332323223323232233232322332323223323232233232322332323223323
42442342424423424244234242442342424423424244234242442342424423424244234242442342424423424244234242442342424423424244234242442342
44444244444442444444424444444244444442444444424444444244444442444444424444444244444442444444424444444244444442444444424444444244
41111444444444444444444444441111144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11771111111111111111111144441777144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17111177117717711777117144441717144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17771711171717171771111144441717144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11171711171717711711117144441717144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17711177177117171177111144441777144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11114111111111111111144444441111144444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11111444444444441111111114444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17171111111144441717171714444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17171777117144441717171714444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17771171111144441777177714444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17171171117144441117111714444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
17171777111144444417141714444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
11111111144444444411141114444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000506000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001516000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a00001a4401a44006640066401a440125401a4401a4401a4401a4401a440194401944018440184401744017440165401a54016440164401954016540154401254014440144401254014440145401444014440
000a000013440134400c6400c640134401344013440134401344013440134401344014440164401844006640066401a4401744017440184401944018440156401244008640104400864015440144401444015440
000a000014440144401344011440104400c6401144011440134401444016440174400a64015440144401344011440114400f44009640096400964010440114401244013440134401644017440076400764007640
0002000009750047500375002750027500375006750087500f75018750277502c7500070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200001065012650176501a650126500e6500e6500f650106501265012650106500e6500c6500d6500e6500f6500f6500f65010650106500000000000000000000000000000000000000000000000000000000
__music__
01 00414244
00 01424344
02 02424344
00 43424344

