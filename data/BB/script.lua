local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local bb = game .. 'BB/';
local BOX = 'gameAssets/Cutscenes/block';

local sv = 'FNAF3';

local fromExtra = false;
local k1 = false;
local cake = false;

local gameStopped = false;
local won = false;
local finBB = false;
local canExit = false;

local wonTime = 0;
local balloons = 8;

local totScore = 0;

local gameScroll = {0, 0};

local balloonCol = {};
for i = 1, 7 do balloonCol[i] = true; end

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

function create()
	luaDebugMode = true;
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	fromExtra = getDataFromSave(sv, 'fromExtra', false);
	finBB = getDataFromSave(sv, 'bb', false);
	k1 = getDataFromSave(sv, 'k1', false);
	cake = getDataFromSave(sv, 'cake', false);
	
	setDataFromSave(sv, 'fromExtra', false);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb4b', 1, 'bgMus', true);
	
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
	makeLuaSprite('title', bb .. 'title', 36, 28);
	addLuaSprite('title');
	
	makeLuaSprite('scoreIcon', bb .. 'icon', 641 - 17, 42 - 30);
	addLuaSprite('scoreIcon');
	
	makeCounterSpr('balCount', 698, 77, balloons, main .. 'hud/nums/scoreSmall/num');
	addLuaSprite('balCount');
	
	makeCounterSpr('scoreCount', 999, 103, totScore, main .. 'hud/nums/score/num');
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
	
	makeLuaSprite('bb', bb .. 'bb');
	addLuaSprite('bb');
	
	updateCharPos();
end

local gotGoal = false;
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
	setPos('bottomBox3', (p[1] + 3) - 26, (p[2] + 30) - 11);
	
	setPos('bb', p[1] - 56, (p[2] - 10) - 59);
	
	checkGetBalloon();
	
	if canExit and objectsOverlap('bb', 'exit') and pixPerfOverlap('bb', 'exit') then
		gotGoal = true;
		
		killSounds();
		gameStopped = true;
		won = true;
		setAlpha('bug', 1);
	end
	
	if not gotGoal and objectsOverlap('bb', 'getThis') and pixPerfOverlap('bb', 'getThis') then
		gotGoal = true;
		
		setDataFromSave(sv, 'bb', true);
		
		killSounds();
		gameStopped = true;
		won = true;
		setAlpha('bug', 1);
		setAlpha('getThis', 0);
	end
	
	if cake and objectsOverlap('charBox', 'cake') and pixPerfOverlap('charBox', 'cake') then
		cake = false;
		gameStopped = true;
		killSounds();
		setVis('cake', true);
		
		setDataFromSave(sv, 'k1', true);
		
		runTimer('childLook', pl(100 / 60));
		runTimer('endScene', pl(200 / 60));
	end
end

function checkGetBalloon()
	for i = 1, 7 do
		local t = 'collectB' .. i;
		if balloonCol[i] and objectsOverlap('bb', t) and pixPerfOverlap('bb', t) then
			setAlpha(t, 0);
			balloonCol[i] = false;
			
			balloons = balloons - 1;
			totScore = totScore + 100;
			
			doSound('collect', 1, 'bbSnd');
			
			if balloons == 1 then
				canExit = true;
				setAlpha('exit', 1);
			end
			
			updateCounterSpr('balCount', balloons);
			updateCounterSpr('scoreCount', totScore);
		end
	end
end

function makeRoom()
	LOST();
	
	makeLuaSprite('left1', BOX, 106, 342);
	scaleObject('left1', 32, 328);
	setColor('left1', 0x00335fb3);
	addLuaSprite('left1');
	
	makeLuaSprite('left2', BOX, 106, 131);
	scaleObject('left2', 32, 212);
	setColor('left2', 0x00335fb3);
	addLuaSprite('left2');
	
	makeLuaSprite('down1', BOX, 106, 668);
	scaleObject('down1', 762, 30);
	setColor('down1', 0x00335fb3);
	addLuaSprite('down1');
	
	makeLuaSprite('right1', BOX, 839, 134);
	scaleObject('right1', 32, 562);
	setColor('right1', 0x00335fb3);
	addLuaSprite('right1');
	
	makeLuaSprite('up1', BOX, 106, 132);
	scaleObject('up1', 762, 30);
	setColor('up1', 0x00335fb3);
	addLuaSprite('up1');
	
	
	makeLuaSprite('plat1', BOX, 610, 554);
	scaleObject('plat1', 164, 30);
	setColor('plat1', 0x00335fb3);
	addLuaSprite('plat1');
	
	makeLuaSprite('plat2', BOX, 346, 488);
	scaleObject('plat2', 164, 30);
	setColor('plat2', 0x00335fb3);
	addLuaSprite('plat2');
	
	makeLuaSprite('plat3', BOX, 134, 400);
	scaleObject('plat3', 164, 30);
	setColor('plat3', 0x00335fb3);
	addLuaSprite('plat3');
	
	makeLuaSprite('plat4', BOX, 434, 320);
	scaleObject('plat4', 164, 30);
	setColor('plat4', 0x00335fb3);
	addLuaSprite('plat4');
	
	makeLuaSprite('plat5', BOX, 700, 294);
	scaleObject('plat5', 164, 30);
	setColor('plat5', 0x00335fb3);
	addLuaSprite('plat5');
	
	makeLuaSprite('cloud1', main .. 'cloud', 566, 352);
	addLuaSprite('cloud1');
	
	makeLuaSprite('cloud2', main .. 'cloud', 186, 186);
	addLuaSprite('cloud2');
	
	makeLuaSprite('cloud3', main .. 'cloud', 462, 130);
	addLuaSprite('cloud3');
	
	
	
	makeLuaSprite('platChild', BOX, 1828, 1160);
	scaleObject('platChild', 762, 30);
	setColor('platChild', 0x00335fb3);
	addLuaSprite('platChild');
	
	
	
	
	makeLuaSprite('cloudOut1', main .. 'cloud', 2638, 1840);
	addLuaSprite('cloudOut1');
	
	makeLuaSprite('cloudOut2', main .. 'cloud', 2230, 1705);
	addLuaSprite('cloudOut2');
	
	makeLuaSprite('out1', BOX, 2180, 2198);
	scaleObject('out1', 762, 30);
	setColor('out1', 0x00335fb3);
	addLuaSprite('out1');
	
	makeLuaSprite('out2', BOX, 2180, 1986);
	scaleObject('out2', 32, 212);
	setColor('out2', 0x00335fb3);
	addLuaSprite('out2');
	
	makeLuaSprite('out3', BOX, 2180, 1662);
	scaleObject('out3', 32, 328);
	setColor('out3', 0x00335fb3);
	addLuaSprite('out3');
	
	makeLuaSprite('out4', BOX, 2180, 1652);
	scaleObject('out4', 762, 30);
	setColor('out4', 0x00335fb3);
	addLuaSprite('out4');
	
	makeLuaSprite('out5', BOX, 2910, 1652);
	scaleObject('out5', 32, 572);
	setColor('out5', 0x00335fb3);
	addLuaSprite('out5');
	
	
	makeLuaSprite('out6', BOX, 2334, 2096);
	scaleObject('out6', 164, 30);
	setColor('out6', 0x00335fb3);
	addLuaSprite('out6');
	
	makeLuaSprite('out7', BOX, 2536, 1992);
	scaleObject('out7', 164, 30);
	setColor('out7', 0x00335fb3);
	addLuaSprite('out7');
	
	makeLuaSprite('out8', BOX, 2758, 1904);
	scaleObject('out8', 164, 30);
	setColor('out8', 0x00335fb3);
	addLuaSprite('out8');
	
	makeLuaSprite('out9', BOX, 2466, 1828);
	scaleObject('out9', 164, 30);
	setColor('out9', 0x00335fb3);
	addLuaSprite('out9');
end

local crying = {
	{1284, 2212},
	{1470, 2215},
	{1840, 2215}
};
function LOST()
	makeLuaSprite('grey1', bb .. 'out/grey', -2, 1538);
	addLuaSprite('grey1');
	
	makeLuaSprite('grey2', bb .. 'out/grey', 1020, 1538);
	addLuaSprite('grey2');
	
	
	makeLuaSprite('tree', bb .. 'out/tree', 1258, 1635);
	addLuaSprite('tree');
	
	for i = 1, 3 do
		local t = 'crying' .. i;
		local p = crying[i];
		makeLuaSprite(t, bb .. 'out/lost', p[1] - 56, p[2] - 59);
		addLuaSprite(t);
	end
end

local balloonPos = {
	{65, 1130},
	{340, 1240},
	{656, 1328},
	{860, 1270},
	{1050, 1222},
	{1242, 1168},
	{1464, 1166},
	{1698, 1166}
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
end

local collect = {
	{646, 482},
	{742, 484},
	{388, 416},
	{188, 332},
	{474, 254},
	{548, 252},
	{786, 230}
};
function makeGoal()
	if not k1 then
		makeAnimatedLuaSprite('kid', main .. 'secret/win/child', 2484 - 44, 1106 - 45);
		addAnimationByPrefix('kid', 'idle', 'Child', 0);
		addAnimationByPrefix('kid', 'look', 'Look', 0);
		playAnim('kid', 'idle', true);
		addLuaSprite('kid');
		
		if cake then
			makeLuaSprite('cake', main .. 'secret/win/cake', 2326 - 79, 1076 - 84);
			addLuaSprite('cake');
			setVis('cake', false);
		end
	end
	
	makeAnimatedLuaSprite('getThis', bb .. 'balloon/get', 2540 - 34, 1754 - 57);
	addAnimationByPrefix('getThis', 'glow', 'Glow', 3);
	addLuaSprite('getThis');
	
	makeLuaSprite('exit', main .. 'exit', 198 - 47, 601 - 57);
	addLuaSprite('exit');
	setAlpha('exit', 0.00001);
	
	for i = 1, 7 do
		local t = 'collectB' .. i;
		local p = collect[i];
		makeLuaSprite(t, bb .. 'balloon/collect', p[1] - 34, p[2] - 57);
		addLuaSprite(t);
	end
end

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateMove(e, ti);
		
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
			c.jumpNum = 7;
			
			doSound('jump', 1, 'bbSnd');
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
				doSound('land', 1, 'bbSnd');
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
	setFlipX('bb', d == 'left');
end

function onAnything(o)
	return onBackdrop(o) or onBalloon(o);
end

local canOverlap = {
	'left1', 'down1', 'right1', 'up1',
	'plat1', 'plat2', 'plat3', 'plat4', 'plat5',
	'leftEdge', 'downEdge', 'upEdge', 'rightEdge',
	'platChild',
	'out1', 'out3', 'out4', 'out5', 'out6', 'out7', 'out8', 'out8', 'out9'
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
	precacheSound('jump');
	precacheSound('collect');
	precacheSound('land');
end
