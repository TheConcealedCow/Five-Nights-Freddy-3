local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local chic = game .. 'ToyChica/';
local BOX = 'gameAssets/Cutscenes/block';

local sv = 'FNAF3';

local fromExtra = false;
local k2 = false;
local cake = false;

local gameStopped = false;
local won = false;
local finBB = false;

local curCups = 0;

local wonTime = 0;
local kids = 4;

local gameScroll = {0, 0};

local cupCol = {};
for i = 1, 4 do cupCol[i] = true; end

local kidGot = {};
for i = 1, 4 do kidGot[i] = false; end

local c = {
	pos = {309, 589},
	
	rightTime = 0,
	leftTime = 0,
	
	fall1 = 0,
	fall2 = 0,
	
	dir = 'right',
	
	grounded = false,
	canJump = true,
	landSnd = false,
	jumpNum = 0,
	jumpTime = 0
};

local cryMove = {
	lTime = 0,
	rTime = 0,
};
function create()
	luaDebugMode = true;
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	fromExtra = getDataFromSave(sv, 'fromExtra', false);
	finBB = getDataFromSave(sv, 'bb', false);
	k2 = getDataFromSave(sv, 'k2', false);
	cake = getDataFromSave(sv, 'cake', false);
	
	setDataFromSave(sv, 'fromExtra', false);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb8', 1, 'bgMus', true);
	
	cacheSounds();
end

function makeGame()
	makeRoom();
	makeEdges();
	makeBalloons();
	makeGoal();
	makeChar();
	
	makeHud();
	makeTop();
end

function makeTop()
	makeAnimatedLuaSprite('blip', 'gameAssets/title/blip');
	addAnimationByPrefix('blip', 'blip', 'Blip', 45, false);
	hideOnFin('blip');
	addLuaSprite('blip');
	
	
	makeLuaSprite('lines', main .. 'hud/lines');
	setScrollFactor('lines');
	addLuaSprite('lines');
	
	makeLuaSprite('bug', main .. 'hud/bug');
	setScrollFactor('bug');
	addLuaSprite('bug');
	setAlpha('bug', 0.00001);
end

function makeHud()
	makeLuaSprite('title', chic .. 'title', 36, 24);
	setScrollFactor('title');
	addLuaSprite('title');
	
	makeLuaSprite('scoreIcon', chic .. 'icon', 874 - 30, 61 - 28);
	setScrollFactor('scoreIcon');
	addLuaSprite('scoreIcon');
	
	makeCounterSpr('scoreCount', 999, 103, curCups, main .. 'hud/nums/score/num');
	setScrollFactor('scoreCount');
	addLuaSprite('scoreCount');
end

function makeChar()
	makeLuaSprite('charBox', BOX);
	scaleObject('charBox', 46, 46);
	
	makeLuaSprite('leftBox', BOX);
	scaleObject('leftBox', 28, 54);
	
	makeLuaSprite('rightBox', BOX);
	scaleObject('rightBox', 28, 54);
	
	makeLuaSprite('topBox', BOX);
	scaleObject('topBox', 40, 22);
	
	
	makeLuaSprite('bottomBox1', BOX);
	scaleObject('bottomBox1', 50, 22);
	
	makeLuaSprite('bottomBox2', BOX);
	scaleObject('bottomBox2', 50, 22);
	
	makeLuaSprite('bottomBox3', BOX);
	scaleObject('bottomBox3', 52, 22);
	
	makeLuaSprite('chica', chic .. 'chica');
	addLuaSprite('chica');
	
	makeLuaSprite('holdCup', chic .. 'cupSmall');
	addToOffsets('holdCup', 18, 16);
	addLuaSprite('holdCup');
	setAlpha('holdCup', 0.00001);
	
	updateCharPos();
end

local gotGoal = false;
function updateCharPos()
	local p = c.pos;
	local r = c.dir == 'right';
	
	while p[1] > gameScroll[1] + 1024 do
		gameScroll[1] = gameScroll[1] + 1024;
		setScroll(nil, gameScroll[1], gameScroll[2]);
	end
	
	while p[1] < gameScroll[1] do
		gameScroll[1] = gameScroll[1] - 1024;
		setScroll(nil, gameScroll[1], gameScroll[2]);
	end
	
	while p[2] > gameScroll[2] + 768 do
		gameScroll[2] = gameScroll[2] + 768;
		setScroll(nil, gameScroll[1], gameScroll[2]);
		
		if p[2] > 1536 then
			activeExit();
		end
	end
	
	while p[2] < gameScroll[2] do
		gameScroll[2] = gameScroll[2] - 768;
		setScroll(nil, gameScroll[1], gameScroll[2]);
	end
	
	setPos('charBox', p[1] - 23, p[2] - 23);
	setPos('leftBox', (p[1] - 33) - 14, (p[2] - 3) - 27);
	setPos('rightBox', (p[1] + 39) - 14, (p[2] - 3) - 27);
	setPos('topBox', (p[1] + 5) - 20, (p[2] - 31) - 11);
	
	setPos('bottomBox1', (p[1] + 3) - 25, (p[2] + 41) - 11);
	setPos('bottomBox2', (p[1] + 3) - 25, (p[2] + 60) - 11);
	setPos('bottomBox3', (p[1] + 3) - 26, (p[2] + 30) - 11);
	
	setPos('chica', p[1] - (r and 56 or 55), (p[2] - 20) - 73);
	
	checkHitGoal();
	
	if curCups > 0 then
		setPos('holdCup', p[1] - (r and -34 or 34), p[2] - 55);
	end
	
	if canExit then for i = 1, 2 do
		if objectsOverlap('charBox', 'exit' .. i) and pixPerfOverlap('charBox', 'exit' .. i) then
			gotGoal = true;
			
			killSounds();
			gameStopped = true;
			won = true;
			setAlpha('bug', 1);
		end
	end end
	
	if cake and objectsOverlap('charBox', 'cake') and pixPerfOverlap('charBox', 'cake') then
		cake = false;
		gameStopped = true;
		killSounds();
		setVis('cake', true);
		
		setDataFromSave(sv, 'k2', true);
		
		runTimer('childLook', pl(100 / 60));
		runTimer('endScene', pl(200 / 60));
	end
end

function activeExit()
	if not canExit then
		canExit = true;
		setAlpha('exit1', 1);
		setAlpha('exit2', 1);
	end
end

function checkHitGoal()
	for i = 1, 4 do
		if cupCol[i] then
			local t = 'colCup' .. i;
			if objectsOverlap('chica', t) and pixPerfOverlap('chica', t) then
				cupCol[i] = false;
				curCups = curCups + 1;
				updateCounterSpr('scoreCount', curCups);
				
				setAlpha('holdCup', 1);
				doSound('get2', 1, 'chicSnd');
				
				setAlpha(t, 0);
			end
		end
		
		local a = 'childGoal' .. i;
		if curCups > 0 and not kidGot[i] and
			objectsOverlap('chica', a) and pixPerfOverlap('chica', a) then
			kidGot[i] = true;
			curCups = curCups - 1;
			kids = kids - 1;
			playAnim(a, 'cheer');
			
			doSound('feed', 1, 'chicSnd');
			
			updateCounterSpr('scoreCount', curCups);
			
			if curCups == 0 then
				setAlpha('holdCup', a);
			end
			
			if kids == 0 then
				activeExit();
			end
		end
	end
end

function makeRoom()
	LOST();
	
	makeGlass();
	
	makeLuaSprite('left1', BOX, 107, 132);
	scaleObject('left1', 32, 562);
	setColor('left1', 0x000f8b0b);
	addLuaSprite('left1');
	
	makeLuaSprite('down1', BOX, 106, 670);
	scaleObject('down1', 1322, 30);
	setColor('down1', 0x000f8b0b);
	addLuaSprite('down1');
	
	makeLuaSprite('down2', BOX, 1660, 670);
	scaleObject('down2', 1276, 30);
	setColor('down2', 0x000f8b0b);
	addLuaSprite('down2');
	
	makeLuaSprite('right1', BOX, 2905, 132);
	scaleObject('right1', 32, 562);
	setColor('right1', 0x000f8b0b);
	addLuaSprite('right1');
	
	makeLuaSprite('up1', BOX, 106, 132);
	scaleObject('up1', 2830, 30);
	setColor('up1', 0x000f8b0b);
	addLuaSprite('up1');
	
	
	
	makeLuaSprite('left2', BOX, 174, 768);
	scaleObject('left2', 32, 328);
	setColor('left2', 0x000f8b0b);
	addLuaSprite('left2');
	
	makeLuaSprite('left3', BOX, 332, 1066);
	scaleObject('left3', 32, 322);
	setColor('left3', 0x000f8b0b);
	addLuaSprite('left3');
	
	makeLuaSprite('left4', BOX, 1070, 792);
	scaleObject('left4', 32, 322);
	setColor('left4', 0x000f8b0b);
	addLuaSprite('left4');
	
	makeLuaSprite('left5', BOX, 1070, 1063);
	scaleObject('left5', 32, 322);
	setColor('left5', 0x000f8b0b);
	addLuaSprite('left5');
	
	makeLuaSprite('down3', BOX, 346, 1358);
	scaleObject('down3', 562, 30);
	setColor('down3', 0x000f8b0b);
	addLuaSprite('down3');
	
	makeLuaSprite('down4', BOX, 904, 1358);
	scaleObject('down4', 1276, 30);
	setColor('down4', 0x000f8b0b);
	addLuaSprite('down4');
	
	makeLuaSprite('down5', BOX, 1669, 1357);
	scaleObject('down5', 1276, 30);
	setColor('down5', 0x000f8b0b);
	addLuaSprite('down5');
	
	makeLuaSprite('right2', BOX, 2913, 824);
	scaleObject('right2', 32, 562);
	setColor('right2', 0x000f8b0b);
	addLuaSprite('right2');
	
	makeLuaSprite('up2', BOX, 1685, 818);
	scaleObject('up2', 1260, 30);
	setColor('up2', 0x000f8b0b);
	addLuaSprite('up2');
	
	
	makeLuaSprite('plat1', BOX, 176, 1066);
	scaleObject('plat1', 164, 30);
	setColor('plat1', 0x000f8b0b);
	addLuaSprite('plat1');
	
	makeLuaSprite('plat2', BOX, 330, 1066);
	scaleObject('plat2', 164, 30);
	setColor('plat2', 0x000f8b0b);
	addLuaSprite('plat2');
	
	makeLuaSprite('plat3', BOX, 1206, 560);
	scaleObject('plat3', 164, 30);
	setColor('plat3', 0x000f8b0b);
	addLuaSprite('plat3');
	
	makeLuaSprite('plat4', BOX, 1476, 412);
	scaleObject('plat4', 164, 30);
	setColor('plat4', 0x000f8b0b);
	addLuaSprite('plat4');
	
	makeLuaSprite('plat5', BOX, 1632, 412);
	scaleObject('plat5', 164, 30);
	setColor('plat5', 0x000f8b0b);
	addLuaSprite('plat5');
	
	makeLuaSprite('plat6', BOX, 1882, 280);
	scaleObject('plat6', 164, 30);
	setColor('plat6', 0x000f8b0b);
	addLuaSprite('plat6');
	
	makeLuaSprite('plat7', BOX, 1522, 752);
	scaleObject('plat7', 164, 30);
	setColor('plat7', 0x000f8b0b);
	addLuaSprite('plat7');
	
	makeLuaSprite('plat8', BOX, 1328, 852);
	scaleObject('plat8', 164, 30);
	setColor('plat8', 0x000f8b0b);
	addLuaSprite('plat8');
	
	makeLuaSprite('plat9', BOX, 1074, 948);
	scaleObject('plat9', 164, 30);
	setColor('plat9', 0x000f8b0b);
	addLuaSprite('plat9');
	
	makeLuaSprite('plat10', BOX, 1300, 1062);
	scaleObject('plat10', 164, 30);
	setColor('plat10', 0x000f8b0b);
	addLuaSprite('plat10');
	
	makeLuaSprite('plat11', BOX, 1598, 1156);
	scaleObject('plat11', 164, 30);
	setColor('plat11', 0x000f8b0b);
	addLuaSprite('plat11');
	
	makeLuaSprite('plat12', BOX, 1334, 1256);
	scaleObject('plat12', 164, 30);
	setColor('plat12', 0x000f8b0b);
	addLuaSprite('plat12');
	
	makeLuaSprite('plat13', BOX, 2250, 1278);
	scaleObject('plat13', 164, 30);
	setColor('plat13', 0x000f8b0b);
	addLuaSprite('plat13');
	
	makeLuaSprite('plat14', BOX, 2580, 1278);
	scaleObject('plat14', 164, 30);
	setColor('plat14', 0x000f8b0b);
	addLuaSprite('plat14');
end

function makeGlass()
	makeLuaSprite('window1', chic .. 'window', 216, 250);
	addLuaSprite('window1');
	
	makeLuaSprite('window2', chic .. 'window', 408, 252);
	addLuaSprite('window2');
	
	makeLuaSprite('window3', chic .. 'window', 690, 866);
	addLuaSprite('window3');
	
	makeLuaSprite('window4', chic .. 'window', 1386, 934);
	addLuaSprite('window4');
	
	makeLuaSprite('window5', chic .. 'window', 1746, 930);
	addLuaSprite('window5');
	
	makeLuaSprite('window6', chic .. 'window', 2260, 927);
	addLuaSprite('window6');
	
	makeLuaSprite('window7', chic .. 'window', 2604, 932);
	addLuaSprite('window7');
	
	makeLuaSprite('window8', chic .. 'window', 2132, 276);
	addLuaSprite('window8');
	
	makeLuaSprite('window9', chic .. 'window', 2444, 276);
	addLuaSprite('window9');
end

local crying = {
	{1140, 2134},
	{1300, 2132},
	{1538, 2134},
	{1826, 2132}
};
function LOST()
	makeLuaSprite('blue1', chic .. 'blue', -2, 1538);
	addLuaSprite('blue1');
	
	makeLuaSprite('blue2', chic .. 'blue', 1020, 1538);
	addLuaSprite('blue2');
	
	for i = 1, 4 do
		local t = 'crying' .. i;
		local p = crying[i];
		makeLuaSprite(t, chic .. 'lost', p[1], p[2]);
		addLuaSprite(t);
	end
	
	
	makeLuaSprite('follow', chic .. 'lost', 1716, 2279);
	addToOffsets('follow', 70, 141);
	addLuaSprite('follow');
end

local balloonPos = {
	{612, 1184},
	{785, 1260}
};
function makeBalloons()
	if not finBB then return; end
	
	for i, p in pairs(balloonPos) do
		local t = 'balloon' .. i;
		makeLuaSprite(t, main .. 'secret/platform', p[1] - 65, p[2] - 57);
		addLuaSprite(t);
	end
end

function makeEdges()
	makeLuaSprite('leftEdge', BOX, 0, -6);
	scaleObject('leftEdge', 32, 2316);
	setColor('leftEdge', 0x00000008);
	addLuaSprite('leftEdge');
	
	makeLuaSprite('downEdge', BOX, 0, 2274);
	scaleObject('downEdge', 3054, 30);
	setColor('downEdge', 0x00000008);
	addLuaSprite('downEdge');
	
	makeLuaSprite('upEdge', BOX, -2, -10);
	scaleObject('upEdge', 3054, 30);
	setColor('upEdge', 0x00000008);
	addLuaSprite('upEdge');
	
	makeLuaSprite('rightEdge', BOX, 3044, -2);
	scaleObject('rightEdge', 32, 2316);
	setColor('rightEdge', 0x00000008);
	addLuaSprite('rightEdge');

	
	makeLuaSprite('rightEdge2', BOX, 2014, 1534);
	scaleObject('rightEdge2', 32, 772);
	setColor('rightEdge2', 0x00000008);
	addLuaSprite('rightEdge2');
end

local collect = {
	{1283, 513},
	{1972, 240},
	{2334, 1240},
	{2659, 1238}
};
local children = {
	{2375, 668},
	{2679, 668},
	{1678, 1154},
	{1224, 1356}
};
local canExit = false;
function makeGoal()
	if not k2 then
		makeAnimatedLuaSprite('kid', main .. 'secret/win/child', 271 - 44, 1014 - 45);
		addAnimationByPrefix('kid', 'idle', 'Child', 0);
		addAnimationByPrefix('kid', 'look', 'Look', 0);
		playAnim('kid', 'idle', true);
		addLuaSprite('kid');
		
		if cake then
			makeLuaSprite('cake', main .. 'secret/win/cake', 402 - 79, 984 - 84);
			addLuaSprite('cake');
			setVis('cake', false);
		end
	end
	
	makeLuaSprite('exit1', main .. 'exit', 1874 - 47, 1289 - 57);
	addLuaSprite('exit1');
	setAlpha('exit1', 0.00001);
	
	makeLuaSprite('exit2', main .. 'exit', 128 - 47, 2206 - 57);
	addLuaSprite('exit2');
	setAlpha('exit2', 0.00001);
	
	for i = 1, 4 do
		local p = collect[i];
		local t = 'colCup' .. i;
		makeLuaSprite(t, chic .. 'cup', p[1] - 41, p[2] - 38);
		addLuaSprite(t);
		
		local a = children[i];
		local b = 'childGoal' .. i;
		makeAnimatedLuaSprite(b, chic .. 'kid', a[1] - 46, a[2] - 91);
		addAnimationByPrefix(b, 'idle', 'Cry', 0);
		addAnimationByPrefix(b, 'cheer', 'Cheer', 0);
		playAnim(b, 'idle');
		addLuaSprite(b);
	end
end

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateMove(e, ti);
		updateLost(e, ti);
		
		local ticks = 0;
		tickRate = tickRate + e;
		while (tickRate >= frameSec) do
			tickRate = tickRate - frameSec;
			ticks = ticks + 1;
			
			onTick();
		end
		
		callOnLuas('updateFunc', {e, ti, ticks});
	end
	
	if won then
		wonTime = wonTime + ti;
		if wonTime >= 200 then
			won = false;
			toFrame();
		end
	end
	
	return Function_StopLua;
end

function onTick()
	if onAnything('bottomBox3') then
		c.pos[2] = c.pos[2] - 5;
		updateCharPos();
	end
end

function updateLost(e)
	if c.pos[1] > getX('follow') then
		cryMove.rTime = cryMove.rTime + e;
		while cryMove.rTime >= 0.1 do
			cryMove.rTime = cryMove.rTime - 0.1;
			
			addX('follow', 10);
			setFlipX('follow', true);
			scaleObject('follow', 1, 1);
			addToOffsets('follow', 70, 141);
		end
	end
	if c.pos[1] < getX('follow') then
		cryMove.lTime = cryMove.lTime + e;
		while cryMove.lTime >= 0.1 do
			cryMove.lTime = cryMove.lTime - 0.1;
			
			addX('follow', -10);
			setFlipX('follow', false);
			scaleObject('follow', 1, 1);
			addToOffsets('follow', 71, 141);
		end
	end
end

function updateMove(e, t)
	checkMoveChar('A', 'left', e, function()
		c.pos[1] = c.pos[1] - 15;
		setDir('left');
		updateCharPos();
	end);
	
	checkMoveChar('D', 'right', e, function()
		c.pos[1] = c.pos[1] + 15;
		setDir('right');
		updateCharPos();
	end);
	
	checkFallChar(e);
	
	if keyboardPressed('W') then
		if c.canJump and c.grounded and c.jumpNum == 0 then
			c.canJump = false;
			c.jumpNum = 9;
			
			doSound('jump3', 1, 'chicSnd');
		end
	else
		c.canJump = true;
	end
	
	if c.jumpNum > 0 then
		c.jumpTime = c.jumpTime + e;
		while c.jumpTime >= 0.06 do
			c.jumpTime = c.jumpTime - 0.06;
			c.jumpNum = c.jumpNum - 1;
			
			c.pos[2] = c.pos[2] - 20;
			updateCharPos();
		end
		
		if onBackdrop('topBox') then
			c.jumpNum = 0;
		end
	end
end

function checkFallChar(e)
	if c.jumpNum > 0 then return; end
	
	for i = 1, 2 do
		local o = 'bottomBox' .. i;
		if not onAnything(o) then
			local n = 'fall' .. i;
			c[n] = c[n] + e;
			while c[n] >= 0.1 do
				c[n] = c[n] - 0.1;
				c.pos[2] = c.pos[2] + 10;
				updateCharPos();
			end
			
			if i == 1 then c.landSnd = false; end
			if i == 2 then c.grounded = false; end
		elseif i == 1 then
			if not c.landSnd then
				doSound('land', 1, 'chicSnd');
				c.landSnd = true;
			end
		elseif i == 2 then
			c.grounded = true;
		end
	end
end

function checkMoveChar(d, b, e, f)
	local t = b .. 'Time';
	if keyboardPressed(d) and not onBackdrop(b .. 'Box') then
		c[t] = c[t] + e;
		while c[t] >= 0.1 do
			c[t] = c[t] - 0.1;
			f();
		end
	end
end

function setDir(d)
	if c.dir == d then return; end
	c.dir = d;
	setFlipX('chica', d == 'left');
end

function onAnything(o)
	return onBackdrop(o) or onBalloon(o);
end

local canOverlap = {
	'left1', 'left2', 'left3', 'left4', 'left5', 'down1', 'down2', 'down4', 'down5', 'right1', 'right2', 'up1', 'up2',
	'plat1', 'plat2', 'plat3', 'plat4', 'plat5', 'plat6', 'plat7',
	'plat8', 'plat9', 'plat10', 'plat11', 'plat12', 'plat13', 'plat14',
	'leftEdge', 'downEdge', 'upEdge', 'rightEdge', 'rightEdge2'
};
function onBackdrop(o)
	for _, l in pairs(canOverlap) do
		if objectsOverlap(o, l) then return true; end
	end
	
	return false;
end

function onBalloon(o)
	if not finBB then return false; end
	
	for i = 1, 8 do
		local t = 'balloon' .. i;
		if objectsOverlap(o, t) and pixPerfOverlap(o, t) then return true; end
	end
	
	return false;
end

local timers = {
	['childLook'] = function()
		playAnim('kid', 'look');
	end,
	['endScene'] = function()
		setAlpha('bug', 1);
		won = true; 
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

function toFrame()
	if fromExtra then
		switchState('Extra');
	else
		switchState('WhatDay');
	end
end

function cacheSounds()
	precacheSound('feed');
	precacheSound('jump3');
	precacheSound('get2');
	precacheSound('land');
end
