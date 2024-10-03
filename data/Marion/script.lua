local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local mar = game .. 'Marion/';
local BOX = 'gameAssets/Cutscenes/block';

local sv = 'FNAF3';

local k1 = false;
local k2 = false;
local k3 = false;
local k4 = false;
local goodEnd = false;
local hitGoal = false;
local cake = false;
local gameStopped = false;
local won = false;
local wonTime = 0;

local balloonFloat = false;

local gameScroll = {0, 0};

local kidMaskTime = 0;
local marMaskTime = 0;
local marMaskEl = 0;

local c = {
	pos = {309, 589},
	
	rightTime = 0,
	leftTime = 0,
	
	offX = 1,
	fall1 = 0,
	fall2 = 0,
	
	stopped = false,
	
	dir = 'right'
};

function create()
	luaDebugMode = true;
	
	k1 = getDataFromSave(sv, 'k1', false);
	k2 = getDataFromSave(sv, 'k2', false);
	k3 = getDataFromSave(sv, 'k3', false);
	k4 = getDataFromSave(sv, 'k4', false);
	cake = getDataFromSave(sv, 'cake', false); 
	
	goodEnd = (cake and k1 and k2 and k3 and k4);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb2', 1, 'bgMus', true);
end

function makeGame()
	makeRoom();
	makeGoal();
	makeChar();
	makeSeat();
	
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
	makeLuaSprite('title', mar .. 'title', 34, 18);
	addLuaSprite('title');
end

local seatPos = {
	{533, 587},
	{913, 590},
	{1150, 591},
	{1531, 590},
	{1665, 591}
};
function makeSeat()
	for i = 1, 5 do
		local t = 'seat' .. i;
		local p = seatPos[i];
		makeLuaSprite(t, mar .. 'children/' .. i, p[1] - 44, p[2] - 68);
		addLuaSprite(t);
	end
	
	if k1 then
		makeAnimatedLuaSprite('kid1', mar .. 'grey/children/1', 2151, 598);
		addAnimationByPrefix('kid1', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid1', 'rest', 'Rest', 0);
		addOffset('kid1', 'idle', 63, 58);
		addOffset('kid1', 'rest', 12, 54);
		playAnim('kid1', 'idle', true);
		addLuaSprite('kid1');
	end
	if k2 then
		makeAnimatedLuaSprite('kid2', mar .. 'grey/children/2', 2246, 598);
		addAnimationByPrefix('kid2', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid2', 'rest', 'Rest', 0);
		addOffset('kid2', 'idle', 63, 58);
		addOffset('kid2', 'rest', 8, 55);
		playAnim('kid2', 'idle', true);
		addLuaSprite('kid2');
	end
	if k3 then
		makeAnimatedLuaSprite('kid3', mar .. 'grey/children/3', 2352, 598);
		addAnimationByPrefix('kid3', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid3', 'rest', 'Rest', 0);
		addOffset('kid3', 'idle', 63, 58);
		addOffset('kid3', 'rest', 24, 53);
		playAnim('kid3', 'idle', true);
		addLuaSprite('kid3');
	end
	if k4 then
		makeAnimatedLuaSprite('kid4', mar .. 'grey/children/4', 2462, 598);
		addAnimationByPrefix('kid4', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid4', 'rest', 'Rest', 0);
		addOffset('kid4', 'idle', 63, 58);
		addOffset('kid4', 'rest', 18, 58);
		playAnim('kid4', 'idle', true);
		addLuaSprite('kid4');
	end
end

function makeChar()
	makeLuaSprite('charBox', BOX);
	scaleObject('charBox', 46, 46);
	
	makeLuaSprite('leftBox', BOX);
	scaleObject('leftBox', 28, 54);
	
	makeLuaSprite('rightBox', BOX);
	scaleObject('rightBox', 28, 54);
	
	
	makeLuaSprite('bottomBox1', BOX);
	scaleObject('bottomBox1', 50, 22);
	
	makeLuaSprite('bottomBox2', BOX);
	scaleObject('bottomBox2', 50, 22);
	
	makeAnimatedLuaSprite('marion', mar .. 'marion');
	addAnimationByPrefix('marion', 'idle', 'Idle', 0);
	addAnimationByPrefix('marion', 'rest', 'Rest', 0);
	playAnim('marion', 'idle', true);
	addLuaSprite('marion');
	
	updateCharPos();
end

function updateCharPos()
	local p = c.pos;
	
	while p[1] > gameScroll[1] + 1024 do
		gameScroll[1] = gameScroll[1] + 1024;
		setScroll(nil, gameScroll[1], gameScroll[2]);
	end
	
	while p[1] < gameScroll[1] do
		gameScroll[1] = gameScroll[1] - 1024;
		setScroll(nil, gameScroll[1], gameScroll[2]);
	end
	
	setPos('charBox', p[1] - 23, p[2] - 23);
	setPos('leftBox', (p[1] - 33) - 14, (p[2] - 3) - 27);
	setPos('rightBox', (p[1] + 39) - 14, (p[2] - 3) - 27);
	
	setPos('bottomBox1', (p[1] + 3) - 25, (p[2] + 41) - 11);
	setPos('bottomBox2', (p[1] + 3) - 25, (p[2] + 60) - 11);
	
	setPos('marion', p[1] - (55 + c.offX), (p[2] - 10) - 59);
	
	
	if objectsOverlap('marion', 'exit') and pixPerfOverlap('marion', 'exit') then
		killSounds();
		gameStopped = true;
		won = true;
		setAlpha('bug', 1);
	end
	
	if not hitGoal and goodEnd and objectsOverlap('charBox', 'goal') then
		hitGoal = true;
		c.stopped = true;
		
		runTimer('childLook', pl(100 / 60));
		runTimer('childMask', pl(200 / 60));
		runTimer('childRest', pl(300 / 60));
		runTimer('endScene', pl(1300 / 60));
		
		setVis('happiest', true);
	end
end

local balloonPos = {
	{226, 338},
	{312, 250},
	{444, 362},
	{822, 326},
	{974, 276},
	{1122, 302},
	{1250, 330},
	{1526, 262},
	{1638, 336},
	{1766, 296}
};
local tables = {
	{{598, 562}, {730, 476}},
	{{1215, 562}, {1337, 478}},
	{{1722, 561}, {1840, 478}}
};
function makeRoom()
	makeLuaSprite('left', BOX, 106, 132);
	scaleObject('left', 32, 538);
	setColor('left', 0x00a7a7a7);
	addLuaSprite('left');
	
	makeLuaSprite('down', BOX, 106, 668);
	scaleObject('down', 2846, 30);
	setColor('down', 0x00a7a7a7);
	addLuaSprite('down');
	
	makeLuaSprite('up', BOX, 106, 132);
	scaleObject('up', 2846, 30);
	setColor('up', 0x00a7a7a7);
	addLuaSprite('up');
	
	makeLuaSprite('right', BOX, 2921, 134);
	scaleObject('right', 32, 562);
	setColor('right', 0x00a7a7a7);
	addLuaSprite('right');
	
	for i = 1, 3 do
		local c = 'table' .. i;
		local p = tables[i];
		makeLuaSprite(c, mar .. 'table', p[1][1], p[1][2]);
		addLuaSprite(c);
		
		local m = 'cake' .. i;
		makeLuaSprite(m, main .. 'secret/win/cake', p[2][1] - 79, p[2][2] - 84);
		addLuaSprite(m);
	end
	
	for i = 1, 10 do
		local t = 'balloon' .. i;
		local p = balloonPos[i];
		makeLuaSprite(t, mar .. 'balloons/' .. getRandomInt(1, 5), p[1] - 34, p[2] - 57);
		addLuaSprite(t);
	end
end

local balFloatPos = {
	{2132, 324},
	{2212, 376},
	{2354, 288},
	{2436, 338},
	{2554, 296},
	{2820, 364}
};
function makeGoal()
	makeLuaSprite('exit', main .. 'exit', 198 - 47, 601 - 57);
	addLuaSprite('exit');
	
	makeLuaSprite('goal', BOX, 2559 - 30, 524 - 127);
	scaleObject('goal', 64, 272);
	addLuaSprite('goal');
	setVis('goal', false);
	
	makeLuaSprite('table', mar .. 'grey/left', 2554, 563);
	addLuaSprite('table');
	
	if goodEnd then
		makeLuaSprite('happiest', mar .. 'grey/happiest', 2686 - 77, 501 - 105);
		addLuaSprite('happiest');
		setVis('happiest', false);
		
		makeAnimatedLuaSprite('kid5', mar .. 'grey/children/grey', 2854, 616);
		addAnimationByPrefix('kid5', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid5', 'rest', 'Rest', 0);
		addOffset('kid5', 'idle', 58, 75);
		addOffset('kid5', 'rest', 46, 71);
		playAnim('kid5', 'idle', true);
		addLuaSprite('kid5');
		setVis('kid5', false);
	end
	
	makeAnimatedLuaSprite('kid', main .. 'secret/win/child', 2854 - 44, 616 - 45);
	addAnimationByPrefix('kid', 'idle', 'Child', 0);
	addAnimationByPrefix('kid', 'look', 'Look', 0);
	playAnim('kid', 'idle', true);
	addLuaSprite('kid');
	
	for i = 1, 6 do
		local t = 'float' .. i;
		local p = balFloatPos[i];
		makeLuaSprite(t, mar .. 'balloons/' .. getRandomInt(1, 5), p[1] - 34, p[2] - 57);
		addLuaSprite(t);
	end
end

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateMove(e);
		
		if marMaskTime > 0 then
			marMaskEl = marMaskEl + e;
			while marMaskEl >= 0.1 and marMaskTime > 0 do
				marMaskEl = marMaskEl - 0.1;
				marMaskTime = marMaskTime - 1;
				
				addY('marion', 1);
				if marMaskTime == 0 then balloonFloat = true; end
			end
		end
		
		tickRate = tickRate + e;
		while (tickRate >= frameSec) do
			tickRate = tickRate - frameSec;
			
			onTick();
		end
	end
	
	if won then
		wonTime = wonTime + ti;
		if wonTime >= 200 then
			won = false;
			switchState('WhatDay');
		end
	end
	
	return Function_StopLua;
end

function onTick()
	if kidMaskTime > 0 then
		kidMaskTime = kidMaskTime - 1;
		
		for i = 1, 5 do
			addY('kid' .. i, 1);
		end
	end
	
	if not balloonFloat then return; end
	
	if Random(5) == 1 then
		addY('float' .. getRandomInt(1, 6), -20);
	end
	
	for i = 1, 2 do
		if Random(10) == 1 then
			local mult = (i == 2 and -1 or 1);
			addX('float' .. getRandomInt(1, 6), 10 * mult);
		end
	end
end

function updateMove(e)
	if c.stopped then return; end
	
	checkMoveChar('A', 'left', e, function()
		c.pos[1] = c.pos[1] - 20;
		setDir('left');
		updateCharPos();
	end);
	
	checkMoveChar('D', 'right', e, function()
		c.pos[1] = c.pos[1] + 20;
		setDir('right');
		updateCharPos();
	end);
	
	checkFallChar(e);
end

function checkFallChar(e)
	for i = 1, 2 do
		local o = 'bottomBox' .. i;
		if not onBackdrop(o) then
			local n = 'fall' .. i;
			c[n] = c[n] + e;
			while c[n] >= 0.1 do
				c[n] = c[n] - 0.1;
				c.pos[2] = c.pos[2] + 10;
				updateCharPos();
			end
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
	c.offX = (d == 'right' and 1 or 0);
	setFlipX('marion', d == 'left');
end

local canOverlap = {
	'down', 'right'
};
function onBackdrop(o)
	for _, l in pairs(canOverlap) do
		if objectsOverlap(o, l) then return true; end
	end
	
	return false;
end

local timers = {
	['childLook'] = function()
		playAnim('kid', 'look');
	end,
	['childMask'] = function()
		setVis('kid', false);
		setVis('kid5', true);
	end,
	['childRest'] = function()
		for i = 1, 5 do
			playAnim('kid' .. i, 'rest');
		end
		
		kidMaskTime = 70;
		marMaskTime = 40;
		
		local p = c.pos;
		setPos('marion', p[1] - 16, (p[2] - 10) - 28);
		playAnim('marion', 'rest', true);
	end,
	
	['endScene'] = function()
		setAlpha('bug', 1);
		won = true; 
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
