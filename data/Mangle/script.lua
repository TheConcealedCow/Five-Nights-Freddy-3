local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local mang = game .. 'Mangle/';
local BOX = 'gameAssets/Cutscenes/block';

local sv = 'FNAF3';

local fromExtra = false;
local cake = false;

local gameStopped = false;
local takenApart = false;
local won = false;
local finBB = false;

local wonTime = 0;
local totParts = 0;
local totScore = 0;

local floor = math.floor;

local gameScroll = {0, 0};

local partCol = {};
for i = 1, 4 do partCol[i] = true; end

local kidPos = {2741, 586};
local kidMoveX = 0;
local kidMult = 1;
local kidOff = {['left'] = 84, ['right'] = 82};
local kidDir = 'left';
local kidVel = floor(25 * 7.487569464755777);

local c = {
	pos = {445, 595},
	
	rightTime = 0,
	leftTime = 0,
	
	fall1 = 0,
	fall2 = 0,
	
	dir = 'right',
	xOff = 37,
	
	grounded = false,
	canJump = true,
	landSnd = false,
	jumpNum = 0,
	jumpTime = 0
};

local parts = {
	{'bod', {673, 504}, {69, 41}, {['left'] = {74, 61}, ['right'] = {37, -61}}},
	{'leg', {1393, 471}, {51, 29}, {['left'] = {65, 25}, ['right'] = {46, -25}}},
	{'head2', {2191, 419}, {85, 17}, {['left'] = {35, 21}, ['right'] = {76, -21}}},
	{'arm', {1801, 334}, {30, 27}, {['left'] = {3, 47}, ['right'] = {67, -47}}}
};
function create()
	luaDebugMode = true;
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	fromExtra = getDataFromSave(sv, 'fromExtra', false);
	finBB = getDataFromSave(sv, 'bb', false);
	cake = getDataFromSave(sv, 'cake', false);
	
	setDataFromSave(sv, 'fromExtra', false);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb5', 1, 'bgMus', true);
	
	cacheSounds();
end

function makeGame()
	makeRoom();
	makeEdges();
	makeBalloons();
	makeGoal();
	makeChar();
	makeKid();
	
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
	makeLuaSprite('title', mang .. 'title', 54, 32);
	setScrollFactor('title');
	addLuaSprite('title');
	
	makeCounterSpr('scoreCount', 999, 103, totScore, main .. 'hud/nums/score/num');
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
	
	
	makeLuaSprite('mangle', mang .. 'mangle/char/head');
	addLuaSprite('mangle');
	
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
		activeExit();
	end
	
	while p[2] < gameScroll[2] do
		gameScroll[2] = gameScroll[2] - 768;
		setScroll(nil, gameScroll[1], gameScroll[2]);
		activeExit();
	end
	
	setPos('charBox', p[1] - 23, p[2] - 23);
	setPos('leftBox', (p[1] - 33) - 14, (p[2] - 3) - 27);
	setPos('rightBox', (p[1] + 39) - 14, (p[2] - 3) - 27);
	setPos('topBox', (p[1] + 5) - 20, (p[2] - 31) - 11);
	
	local botPos = {p[1] + 3, p[2] + 41};
	setPos('bottomBox1', botPos[1] - 25, botPos[2] - 11);
	setPos('bottomBox2', (p[1] + 3) - 25, (p[2] + 60) - 11);
	setPos('bottomBox3', (p[1] + 3) - 26, (p[2] + 30) - 11);
	
	setPos('shadow', botPos[1] - 34, botPos[2] - 4);
	setPos('mangle', p[1] - c.xOff, (p[2] - 69) - 45);
	
	checkGetPart();
	checkUpdateParts();
	
	if canExit then for i = 1, 2 do
		if objectsOverlap('charBox', 'exit' .. i) and pixPerfOverlap('charBox', 'exit' .. i) then
			gotGoal = true;
			
			killSounds();
			gameStopped = true;
			won = true;
			setAlpha('bug', 1);
			
			setFrameRate('kid', kidDir, 0);
		end
	end end
	
	if not cake and objectsOverlap('charBox', 'cake') and pixPerfOverlap('charBox', 'cake') then
		cake = true;
		gameStopped = true;
		won = true;
		
		setVis('cake', false);
		setDataFromSave(sv, 'cake', true);
		stopStars();
		
		setAlpha('bug', 1);
		killSounds();
	end
end

function activeExit()
	if not canExit then
		canExit = true;
		setAlpha('exit1', 1);
		setAlpha('exit2', 1);
	end
end

function checkGetPart()
	for i = 1, 4 do
		local t = 'part' .. i;
		if partCol[i] and objectsOverlap('charBox', t) and pixPerfOverlap('charBox', t) then
			partCol[i] = false;
			
			totParts = totParts + 1;
			totScore = totScore + 100;
			
			setFlipX(t, c.dir == 'left');
			
			doSound('get', 1, 'mangSnd');
			
			if totParts == 4 then
				activeExit();
			end
			
			updateCounterSpr('scoreCount', totScore);
		end
	end
end

function checkUpdateParts()
	local h = c.pos;
	for i = 1, 4 do
		if not partCol[i] then
			local p = parts[i];
			local x = p[4][c.dir];
			local y = p[3];
			local newPos = {x[1] - x[2], y[1] - y[2]};
			
			setPos('part' .. i, h[1] - newPos[1], h[2] - newPos[2] - 45);
		end
	end
end

function makeRoom()
	LOST();
	
	makeStars();
	
	makeLuaSprite('window1', mang .. 'window', 1132, 196);
	addLuaSprite('window1');
	
	makeLuaSprite('window2', mang .. 'window', 1382, 196);
	addLuaSprite('window2');
	
	makeLuaSprite('window3', mang .. 'window', 1698, 432);
	addLuaSprite('window3');
	
	makeLuaSprite('window4', mang .. 'window', 2184, 182);
	addLuaSprite('window4');
	
	makeLuaSprite('window5', mang .. 'windowMoon', 2426, 185);
	addLuaSprite('window5');
	
	
	makeLuaSprite('cloud1', main .. 'cloud', 186, 186);
	setColor('cloud1', 0x0023437f);
	addLuaSprite('cloud1');
	
	makeLuaSprite('cloud2', main .. 'cloud', 460, 152);
	setColor('cloud2', 0x0023437f);
	addLuaSprite('cloud2');
	
	makeLuaSprite('cloud3', main .. 'cloud', 768, 268);
	setColor('cloud3', 0x0023437f);
	addLuaSprite('cloud3');
	
	
	makeLuaSprite('left1', BOX, 106, 342);
	scaleObject('left1', 32, 328);
	setColor('left1', 0x008b378f);
	addLuaSprite('left1');
	
	makeLuaSprite('left2', BOX, 106, 134);
	scaleObject('left2', 32, 208);
	setColor('left2', 0x008b378f);
	addLuaSprite('left2');
	
	makeLuaSprite('down1', BOX, 106, 668);
	scaleObject('down1', 2736, 30);
	setColor('down1', 0x008b378f);
	addLuaSprite('down1');
	
	makeLuaSprite('right1', BOX, 2838, 340);
	scaleObject('right1', 32, 358);
	setColor('right1', 0x008b378f);
	addLuaSprite('right1');
	
	makeLuaSprite('right2', BOX, 2838, 132);
	scaleObject('right2', 32, 208);
	setColor('right2', 0x008b378f);
	addLuaSprite('right2');
	
	makeLuaSprite('up1', BOX, 106, 132);
	scaleObject('up1', 2736, 30);
	setColor('up1', 0x008b378f);
	addLuaSprite('up1');
	
	
	makeLuaSprite('plat1', BOX, 610, 554);
	scaleObject('plat1', 164, 30);
	setColor('plat1', 0x008b378f);
	addLuaSprite('plat1');
	
	makeLuaSprite('plat2', BOX, 1106, 422);
	scaleObject('plat2', 164, 30);
	setColor('plat2', 0x008b378f);
	addLuaSprite('plat2');
	
	makeLuaSprite('plat3', BOX, 1334, 552);
	scaleObject('plat3', 164, 30);
	setColor('plat3', 0x008b378f);
	addLuaSprite('plat3');
	
	makeLuaSprite('plat4', BOX, 1392, 342);
	scaleObject('plat4', 164, 30);
	setColor('plat4', 0x008b378f);
	addLuaSprite('plat4');
	
	makeLuaSprite('plat5', BOX, 1694, 374);
	scaleObject('plat5', 164, 30);
	setColor('plat5', 0x008b378f);
	addLuaSprite('plat5');
	
	makeLuaSprite('plat6', BOX, 2096, 456);
	scaleObject('plat6', 164, 30);
	setColor('plat6', 0x008b378f);
	addLuaSprite('plat6');
	
	makeLuaSprite('plat7', BOX, 2346, 550);
	scaleObject('plat7', 164, 30);
	setColor('plat7', 0x008b378f);
	addLuaSprite('plat7');
	
	makeLuaSprite('plat8', BOX, 2386, 398);
	scaleObject('plat8', 164, 30);
	setColor('plat8', 0x008b378f);
	addLuaSprite('plat8');
	
	makeLuaSprite('plat9', BOX, 2678, 412);
	scaleObject('plat9', 164, 30);
	setColor('plat9', 0x008b378f);
	addLuaSprite('plat9');
	
	
	makeLuaSprite('moon', mang .. 'moon', 148, 810);
	addLuaSprite('moon');
end

function LOST()
	makeLuaSprite('red1', mang .. 'out/red', -2, 1538);
	addLuaSprite('red1');
	
	makeLuaSprite('red2', mang .. 'out/red', 2048, 1536);
	addLuaSprite('red2');
	
	makeLuaSprite('red3', mang .. 'out/red', 2048, 768);
	addLuaSprite('red3');
	
	
	makeLuaSprite('crying', mang .. 'out/lost', 2040, 1564);
	addLuaSprite('crying');
end

local starPos = {
	{1184, 1640},
	{1306, 1778},
	{1452, 1688},
	{1604, 1652},
	{1520, 1736},
	{1236, 970},
	{1590, 1116},
	{1848, 916},
	{1412, 844},
	{1124, 894},
	{1938, 1064},
	{1136, 1094},
	{862, 930},
	{749, 848},
	{626, 1006},
	{128, 922},
	{70, 1048},
	{938, 878},
	{1790, 866},
	{1984, 836},
	{1864, 1740},
	{1108, 1718},
};
function makeStars()
	for i, s in pairs(starPos) do
		local t = 'starMini' .. i;
		makeAnimatedLuaSprite(t, mang .. 'star', s[1] - 7, s[2] - 7);
		addAnimationByPrefix(t, 'star', 'Glow', 30);
		setFrameRate(t, 'star', getRandomInt(1, 10) * 0.6);
		playAnim(t, 'star', true);
		addLuaSprite(t);
	end
end

function stopStars()
	for i in pairs(starPos) do
		setFrameRate('starMini' .. i, 'star', 0);
	end
end

local balloonPos = {
	{1320, 2150},
	{1134, 2006},
	{1418, 1932},
	{1716, 1862},
	{1952, 1726},
	{1738, 1624},
	{1542, 1526},
	{1270, 1422},
	{1016, 1305},
	{909, 1305},
	{658, 1304},
	{414, 1412}
};
local totPlatforms = 0;
function makeBalloons()
	if not finBB then return; end
	
	for i, p in pairs(balloonPos) do
		local t = 'balloon' .. i;
		makeLuaSprite(t, main .. 'secret/platform', p[1] - 65, p[2] - 57);
		addLuaSprite(t);
		
		totPlatforms = totPlatforms + 1;
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

local canExit = false;
function makeGoal()
	makeLuaSprite('shadow', mang .. 'mangle/shadow');
	addLuaSprite('shadow');
	
	for i, p in pairs(parts) do
		local t = 'part' .. i;
		
		makeLuaSprite(t, mang .. 'mangle/char/' .. p[1], p[2][1] - p[4].right[1], p[2][2] - p[3][1]);
		addLuaSprite(t);
	end
	
	if not cake then
		makeLuaSprite('cake', main .. 'secret/win/cake', 413 - 79, 1301 - 84);
		addLuaSprite('cake');
	end
	
	makeLuaSprite('exit1', main .. 'exit', 2722 - 47, 600 - 57);
	addLuaSprite('exit1');
	setAlpha('exit1', 0.00001);
	
	makeLuaSprite('exit2', main .. 'exit', 150 - 47, 2207 - 57);
	addLuaSprite('exit2');
	setAlpha('exit2', 0.00001);
end

function makeKid()
	makeAnimatedLuaSprite('kid', mang .. 'kid', 2741, 586);
	addAnimationByPrefix('kid', 'right', 'Kid', 6);
	addAnimationByPrefix('kid', 'left', 'Kid', 6);
	setAnimFlipX('kid', 'left', true);
	playAnim('kid', 'left', true);
	addLuaSprite('kid');
end

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateKid(e, ti);
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

function updateKid(e, t)
	local vel = (kidVel * e) * kidMult;
	kidMoveX = kidMoveX - vel;
	if kidMoveX < -1395 then
		local addX = kidMoveX + 1395;
		kidMoveX = kidMoveX - addX;
		kidMult = -1;
		kidDir = 'right';
		playAnim('kid', kidDir);
	elseif kidMoveX > 0 then
		kidMoveX = -kidMoveX;
		kidMult = 1;
		kidDir = 'left';
		playAnim('kid', kidDir);
	end
	
	setPos('kid', floor((kidPos[1] - kidOff[kidDir]) + kidMoveX), floor(kidPos[2] - 84));
	
	if objectsOverlap('kid', 'charBox') and pixPerfOverlap('kid', 'charBox') then
		setFrameRate('kid', kidDir, 0);
		
		takenApart = true;
		gameStopped = true;
		won = true;
		
		setAlpha('bug', 1);
		mangleTakeApart();
	end
end

local apartOff = {
	{-145, -45},
	{67, -133},
	{-79, -145},
	{163, -33},
};
function mangleTakeApart()
	local h = c.pos;
	for i = 1, 4 do
		if not partCol[i] then
			local p = parts[i];
			local x = p[4][c.dir];
			local a = apartOff[i];
			local y = p[3];
			local newPos = {x[1] - a[1], y[1] - a[2]};
			
			setPos('part' .. i, h[1] - newPos[1], h[2] - newPos[2]);
		end
	end
end

function updateMove(e, t)
	if takenApart then return; end
	
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
			
			if onBalloon('bottomBox2') then
				c.jumpNum = 10;
			else
				c.jumpNum = 7;
			end
			
			doSound('jump2', 1, 'mangSnd');
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
				doSound('land', 1, 'mangSnd');
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
	c.xOff = (d == 'right' and 37 or 79);
	
	for i = 1, 4 do
		if not partCol[i] then
			setFlipX('part' .. i, d == 'left');
		end
	end
	
	setFlipX('mangle', d == 'left');
end

function onAnything(o)
	return onBackdrop(o) or onBalloon(o);
end

local canOverlap = {
	'leftEdge', 'downEdge', 'upEdge', 'rightEdge',
	'left1', 'down1', 'up1', 'right1',
	'plat1', 'plat2', 'plat3', 'plat4', 'plat5', 'plat6', 'plat7', 'plat8', 'plat9'
};
function onBackdrop(o)
	for _, l in pairs(canOverlap) do
		if objectsOverlap(o, l) then return true; end
	end
	
	return false;
end

function onBalloon(o)
	if not finBB then return false; end
	
	for i = 1, totPlatforms do
		local t = 'balloon' .. i;
		if objectsOverlap(o, t) and pixPerfOverlap(o, t) then return true; end
	end
	
	return false;
end

function toFrame()
	if fromExtra then
		switchState('Extra');
	else
		switchState('WhatDay');
	end
end

function cacheSounds()
	precacheSound('jump2');
	precacheSound('get');
	precacheSound('land');
end
