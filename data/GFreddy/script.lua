local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local fr = game .. 'GFreddy/';
local BOX = 'gameAssets/Cutscenes/block';

local ins = table.insert;

local sv = 'FNAF3';

local fromExtra = false;
local k3 = false;
local cake = false;

local gameStopped = false;
local won = false;
local wonTime = 0;

local gameScroll = {0, 0};

local c = {
	pos = {255, 505},
	
	rightTime = 0,
	leftTime = 0,
	
	fall1 = 0,
	fall2 = 0,
	
	offX = 1,
	dir = 'right',
	
	goingUp = false,
	grounded = false,
	canJump = true,
	landSnd = false,
	jumpNum = 0,
	jumpTime = 0
};
 
local moving = {};
local canOverlap = {
	'leftEdge', 'downEdge', 'upEdge', 'rightEdge', 'rightEdge2'
};

function create()
	luaDebugMode = true;
	
	fromExtra = getDataFromSave(sv, 'fromExtra', false);
	finBB = getDataFromSave(sv, 'bb', false);
	k3 = getDataFromSave(sv, 'k3', false);
	cake = getDataFromSave(sv, 'cake', false);
	
	setDataFromSave(sv, 'fromExtra', false);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb9', 1, 'bgMus', true);
	
	cacheSounds();
end

function makeGame()
	makeRoom();
	makeEdges();
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
	makeLuaSprite('title', fr .. 'title', 52, 26);
	addLuaSprite('title');
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
	
	makeLuaSprite('GFred', fr .. 'char');
	addLuaSprite('GFred');
	
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
	
	while p[2] > gameScroll[2] + 768 do
		gameScroll[2] = gameScroll[2] + 768;
		setScroll(nil, gameScroll[1], gameScroll[2]);
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
	
	setPos('GFred', p[1] - (71 + c.offX), (p[2] - 81) - 35);
	
	if objectsOverlap('GFred', 'exit') and pixPerfOverlap('GFred', 'exit') then
		gotGoal = true;
		
		killSounds();
		stopSprites();
		gameStopped = true;
		won = true;
		setAlpha('bug', 1);
	end
	
	if cake and objectsOverlap('charBox', 'cake') and pixPerfOverlap('charBox', 'cake') then
		cake = false;
		gameStopped = true;
		killSounds();
		setVis('cake', true);
		
		setDataFromSave(sv, 'k3', true);
		
		runTimer('childLook', pl(100 / 60));
		runTimer('endScene', pl(200 / 60));
	end
end

local stages = {
	{106, 132},
	{1146, 118},
	{2194, 114},
	{108, 884},
	{1154, 882},
	{2196, 882},
	{110, 1600},
	{1150, 1604},
	{2168, 1609}
};
function makeRoom()
	for i = 1, 9 do
		local p = stages[i];
		makeAStage(p[1], p[2], i ~= 3);
	end
end

local totStage = 1;
local kidPos = {
	{450, 534},
	{556, 536},
	{662, 536}
};
function makeAStage(x, y, m)
	local s = 'stageNum' .. totStage;
	
	local t1 = s .. 'left1';
	makeLuaSprite(t1, BOX, x, y);
	scaleObject(t1, 32, 538);
	addLuaSprite(t1);
	setColor(t1, 0x008b3f2b);
	ins(canOverlap, t1);
	
	local t2 = s .. 'down1';
	makeLuaSprite(t2, BOX, x, y + 536);
	scaleObject(t2, 762, 30);
	addLuaSprite(t2);
	setColor(t2, 0x008b3f2b);
	ins(canOverlap, t2);
	
	local t3 = s .. 'up1';
	makeLuaSprite(t3, BOX, x, y);
	scaleObject(t3, 762, 30);
	addLuaSprite(t3);
	setColor(t3, 0x008b3f2b);
	ins(canOverlap, t3);
	
	local t4 = s .. 'right1';
	makeLuaSprite(t4, BOX, x + 733, y + 2);
	scaleObject(t4, 32, 562);
	addLuaSprite(t4);
	setColor(t4, 0x008b3f2b);
	ins(canOverlap, t4);
	
	if m then
		local st = s .. 'stand';
		makeLuaSprite(st, BOX, x + (totStage > 0 and 6 or 28), y + (totStage > 0 and 446 or 448));
		scaleObject(st, 358, 92);
		addLuaSprite(st);
		setColor(st, 0x008b3f2b);
		ins(canOverlap, st);
		
		local c1 = s .. 'cloud1';
		makeLuaSprite(c1, main .. 'cloud', x + 72, y + 78);
		addLuaSprite(c1);
		
		local c2 = s .. 'cloud2';
		makeLuaSprite(c2, main .. 'cloud', x + 326, y + 36);
		addLuaSprite(c2);
		
		local c3 = s .. 'cloud3';
		makeLuaSprite(c3, main .. 'cloud', x + 460, y + 220);
		addLuaSprite(c3);
		
		local b = s .. 'bon';
		makeAnimatedLuaSprite(b, fr .. 'bon', (x + 280) - 65, (y + 354) - 91);
		addAnimationByPrefix(b, 'idle', 'Idle', 1);
		setFrameRate(b, 'idle', 1.8);
		playAnim(b, 'idle', true);
		addLuaSprite(b);
		ins(moving, b);
		
		for i = 1, 3 do
			if totStage ~= 6 or i ~= 2 then
				local t = s .. 'kid' .. i;
				local p = kidPos[i];
				makeAnimatedLuaSprite(t, fr .. 'kid', (x + p[1]) - 46, (y + p[2]) - 91);
				addAnimationByPrefix(t, 'idle', 'Idle', 6);
				setFrameRate(t, 'idle', (2 + Random(6)) * 0.6);
				playAnim(t, 'idle', true);
				addLuaSprite(t);
				ins(moving, t);
			end
		end
	end
	
	totStage = totStage + 1;
end

function makeEdges()
	makeLuaSprite('leftEdge', BOX, 0, -6);
	scaleObject('leftEdge', 32, 2316);
	setColor('leftEdge', 0x00000008);
	addLuaSprite('leftEdge');
	
	makeLuaSprite('downEdge', BOX, 0, 2272);
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
	
	makeLuaSprite('rightEdge2', BOX, 1008, -748);
	scaleObject('rightEdge2', 32, 2316);
	setColor('rightEdge2', 0x00000008);
	addLuaSprite('rightEdge2');
end

local canExit = false;
local zipUp = {
	{2188, 1939},
	{2190, 1727},
	{1881, 1713},
	{1308, 1380},
	{1912, 1120},
	{1912, 978},
	{1338, 584},
	{1158, 222}
};
function makeGoal()
	makeLuaSprite('leftMove', BOX, 319 - 203, 634 - 16);
	scaleObject('leftMove', 406, 32);
	addLuaSprite('leftMove');
	setVis('leftMove', false);
	
	makeLuaSprite('rightMove1', BOX, 2180 - 53, 452 - 108);
	scaleObject('rightMove1', 106, 216);
	addLuaSprite('rightMove1');
	setVis('rightMove1', false);
	
	makeLuaSprite('rightMove2', BOX, 2910 - 53, 410 - 108);
	scaleObject('rightMove2', 106, 216);
	addLuaSprite('rightMove2');
	setVis('rightMove2', false);
	
	for i, p in pairs(zipUp) do
		local t = 'upMove' .. i;
		makeLuaSprite(t, BOX, p[1] - 53, p[2] - 108);
		scaleObject(t, 106, 216);
		addLuaSprite(t);
		setVis(t, false);
	end
	
	if not k3 then
		makeAnimatedLuaSprite('kid', main .. 'secret/win/child', 2854 - 44, 598 - 45);
		addAnimationByPrefix('kid', 'idle', 'Child', 0);
		addAnimationByPrefix('kid', 'look', 'Look', 0);
		playAnim('kid', 'idle', true);
		addLuaSprite('kid');
		
		if cake then
			makeLuaSprite('cake', main .. 'secret/win/cake', 2732 - 79, 566 - 84);
			addLuaSprite('cake');
			setVis('cake', false);
		end
	end
	
	makeLuaSprite('exit', main .. 'exit', 2996 - 47, 2207 - 57);
	addLuaSprite('exit');
end

local tickRate = 0;
local frameSec = 1 / 60;

local zipAEl = 0;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateMove(e);
		updateGlitch(e);
		
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

function updateMove(e)
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
			c.jumpNum = 7;
			
			doSound('jump4', 1, 'gSnd');
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
	if c.jumpNum > 0 or c.goingUp then return; end
	
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
			
			if i == 1 then c.landSnd = false; end
			if i == 2 then c.grounded = false; end
		elseif i == 1 then
			if not c.landSnd then
				doSound('land', 1, 'gSnd');
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

local upZipEl = 0;
local rightZipEl = 0;
function updateGlitch(e)
	if objectsOverlap('GFred', 'leftMove') and pixPerfOverlap('GFred', 'leftMove') then
		zipAEl = zipAEl + e;
		while zipAEl >= 0.05 do
			zipAEl = zipAEl - 0.05;
			doSound('land', 1, 'gSnd');
			
			c.pos[1] = c.pos[1] - 10;
			updateCharPos();
		end
	end
	
	local onUp = false;
	for i = 1, 8 do
		local t = 'upMove' .. i;
		if objectsOverlap('GFred', t) and pixPerfOverlap('GFred', t) then
			
			onUp = true; break; 
		end
	end
	
	if onUp then
		upZipEl = upZipEl + e;
		while upZipEl >= 0.05 do
			upZipEl = upZipEl - 0.05;
			
			doSound('land', 1, 'gSnd');
			
			c.pos[2] = c.pos[2] - 10;
			updateCharPos();
		end
	end
	
	local onRight = false
	for i = 1, 2 do
		local t = 'rightMove' .. i;
		if objectsOverlap('GFred', t) and pixPerfOverlap('GFred', t) then
			
			onRight = true; break; 
		end
	end
	
	if onRight then
		rightZipEl = rightZipEl + e;
		while rightZipEl >= 0.05 do
			rightZipEl = rightZipEl - 0.05;
			
			doSound('land', 1, 'gSnd');
			
			c.pos[1] = c.pos[1] + 10;
			updateCharPos();
		end
	end
	
	c.goingUp = onUp;
end

function setDir(d)
	if c.dir == d then return; end
	c.dir = d;
	c.offX = (d == 'right' and 1 or 0);
	setFlipX('GFred', d == 'left');
end

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

function stopSprites()
	for _, s in pairs(moving) do
		setFrameRate(s, 'idle', 0);
	end
end

function cacheSounds()
	precacheSound('jump4');
	precacheSound('land');
end
