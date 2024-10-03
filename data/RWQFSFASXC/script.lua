local game = 'gameAssets/Minigames/';
local main = game .. 'Global/';
local bb = game .. 'BB/';
local mang = game .. 'Mangle/';
local chic = game .. 'ToyChica/';
local fr = game .. 'GFreddy/';
local rw = game .. 'RWQ/';
local BOX = 'gameAssets/Cutscenes/block';

local floor = math.floor;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;

local sv = 'FNAF3';

local fromExtra = false;
local k4 = false;
local cake = true;

local gameStopped = false;
local won = false;
local wonTime = 0;

local curRoom = 0;

local gameScroll = {0, 0};

local c = {
	pos = {207, 501},
	
	offX = 1,
	
	rightTime = 0,
	leftTime = 0,
	
	fall1 = 0,
	fall2 = 0,
	
	dir = 'right',
	
	isMoving = false;
	jumpNum = 0,
	jumpTime = 0
};

local canOverlap = {
	'stageLeft', 'stageDown', 'stageUp', 'stageRight', 'stage',
	'chicaLeft', 'chicaDown', 'chicaUp', 'chicaRight', 'platChi1', 'platChi2',
	'leftBB2', 'downBB', 'upBB', 'rightBB', 'platBB1', 'platBB2', 'platBB3', 'platBB4', 'platBB5',
	'mangLeft', 'mangDown', 'mangUp', 'mangRight', 'platMang1', 'platMang2', 'platMang3', 'platMang4',
	'lostLeft', 'lostDown', 'lostUp', 'lostRight'
};

function create()
	luaDebugMode = true;
	
	fromExtra = getDataFromSave(sv, 'fromExtra', false);
	k4 = getDataFromSave(sv, 'k4', false);
	cake = getDataFromSave(sv, 'cake', false);
	
	setDataFromSave(sv, 'fromExtra', false);
	
	setBounds(3072, 2304);
	
	makeGame();
	doSound('mb1', 1, 'bgMus', true);
	
	runTimer('randRoom', pl(0.1), 0);
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
	
	makeAnimatedLuaSprite('shadow', rw .. 'shadow');
	addAnimationByPrefix('shadow', 'left', 'Idle', 0);
	addAnimationByPrefix('shadow', 'right', 'Idle', 0);
	addAnimationByPrefix('shadow', 'leftWalk', 'Bug', 6);
	addAnimationByPrefix('shadow', 'rightWalk', 'Bug', 6);
	setAnimFlipX('shadow', 'left', true);
	setAnimFlipX('shadow', 'leftWalk', true);
	playAnim('shadow', c.dir, true);
	addLuaSprite('shadow');
	
	updateCharPos();
end

function updateCharPos()
	local a = c.pos;
	local p = {gameScroll[1] + a[1], gameScroll[2] + a[2]};
	
	setPos('charBox', p[1] - 23, p[2] - 23);
	setPos('leftBox', (p[1] - 33) - 14, (p[2] - 3) - 27);
	setPos('rightBox', (p[1] + 39) - 14, (p[2] - 3) - 27);
	setPos('topBox', (p[1] + 5) - 20, (p[2] - 31) - 11);
	
	setPos('bottomBox1', (p[1] + 3) - 25, (p[2] + 41) - 11);
	setPos('bottomBox2', (p[1] + 3) - 25, (p[2] + 60) - 11);
	
	setPos('shadow', p[1] - (64 + c.offX), (p[2] - 35) - 91);
	
	if objectsOverlap('shadow', 'exit') and pixPerfOverlap('shadow', 'exit') then
		gotGoal = true;
		
		killSounds();
		stopAnims();
		gameStopped = true;
		won = true;
		setAlpha('bug', 1);
	end
	
	if cake and objectsOverlap('charBox', 'kid') and pixPerfOverlap('charBox', 'kid') then
		cake = false;
		gameStopped = true;
		stopAnims();
		killSounds();
		setVis('cake', true);
		
		c.isMoving = false;
		c.jumpNum = 0;
		
		setDataFromSave(sv, 'k4', true);
		
		runTimer('childLook', pl(100 / 60));
		runTimer('endScene', pl(200 / 60));
	end
end

function stopAnims()
	setFrameRate('shadow', 'leftWalk', 0);
	setFrameRate('shadow', 'rightWalk', 0);
	
	setFrameRate('fred', 'idle', 0);
	setFrameRate('bon', 'idle', 0);
	for i = 1, 3 do setFrameRate('kidStage' .. i, 'idle', 0); end
end

function makeRoom()
	makeStage();
	makeChica();
	makeBB();
	makeMangle();
	LOST();
end

local kidStage = {
	{556, 666},
	{662, 668},
	{768, 668}
};
function makeStage()
	makeLuaSprite('stageLeft', BOX, 106, 132);
	scaleObject('stageLeft', 32, 538);
	setColor('stageLeft', 0x008b3f2b);
	addLuaSprite('stageLeft');
	
	makeLuaSprite('stageDown', BOX, 106, 668);
	scaleObject('stageDown', 762, 30);
	setColor('stageDown', 0x008b3f2b);
	addLuaSprite('stageDown');
	
	makeLuaSprite('stageUp', BOX, 106, 132);
	scaleObject('stageUp', 762, 30);
	setColor('stageUp', 0x008b3f2b);
	addLuaSprite('stageUp');
	
	makeLuaSprite('stageRight', BOX, 839, 134);
	scaleObject('stageRight', 32, 562);
	setColor('stageRight', 0x008b3f2b);
	addLuaSprite('stageRight');
	
	makeLuaSprite('stage', BOX, 134, 580);
	scaleObject('stage', 358, 92);
	setColor('stage', 0x008b3f2b);
	addLuaSprite('stage');
	
	
	makeLuaSprite('stageC1', main .. 'cloud', 178, 210);
	addLuaSprite('stageC1');
	
	makeLuaSprite('stageC2', main .. 'cloud', 432, 168);
	addLuaSprite('stageC2');
	
	makeLuaSprite('stageC3', main .. 'cloud', 566, 352);
	addLuaSprite('stageC3');
	
	
	makeAnimatedLuaSprite('fred', rw .. 'fred', 300 - 71, 495 - 81);
	addAnimationByPrefix('fred', 'idle', 'Idle', 6);
	addLuaSprite('fred');
	
	makeAnimatedLuaSprite('bon', fr .. 'bon', 418 - 65, 486 - 91);
	addAnimationByPrefix('bon', 'idle', 'Idle', 1);
	setFrameRate('bon', 'idle', 1.8);
	playAnim('bon', 'idle', true);
	addLuaSprite('bon');
	
	for i = 1, 3 do
		local p = kidStage[i];
		local t = 'kidStage' .. i;
		makeAnimatedLuaSprite(t, fr .. 'kid', p[1] - 46, p[2] - 91);
		addAnimationByPrefix(t, 'idle', 'Idle', 6);
		setFrameRate(t, 'idle', (2 + Random(6)) * 0.6);
		playAnim(t, 'idle', true);
		addLuaSprite(t);
	end
end

function makeChica()
	makeLuaSprite('chicaWin1', chic .. 'window', 1241, 236);
	addLuaSprite('chicaWin1');
	
	makeLuaSprite('chicaWin2', chic .. 'window', 1433, 238);
	addLuaSprite('chicaWin2');
	
	makeLuaSprite('chicaLeft', BOX, 1132, 118);
	scaleObject('chicaLeft', 32, 562);
	setColor('chicaLeft', 0x000f8b0b);
	addLuaSprite('chicaLeft');
	
	makeLuaSprite('chicaDown', BOX, 1132, 648);
	scaleObject('chicaDown', 766, 32);
	setColor('chicaDown', 0x000f8b0b);
	addLuaSprite('chicaDown');
	
	makeLuaSprite('chicaUp', BOX, 1132, 112);
	scaleObject('chicaUp', 766, 32);
	setColor('chicaUp', 0x000f8b0b);
	addLuaSprite('chicaUp');
	
	makeLuaSprite('chicaRight', BOX, 1866, 114);
	scaleObject('chicaRight', 32, 562);
	setColor('chicaRight', 0x000f8b0b);
	addLuaSprite('chicaRight');
	
	
	makeLuaSprite('platChi1', BOX, 1484, 452);
	scaleObject('platChi1', 164, 30);
	setColor('platChi1', 0x000f8b0b);
	addLuaSprite('platChi1');
	
	makeLuaSprite('platChi2', BOX, 1706, 508);
	scaleObject('platChi2', 164, 30);
	setColor('platChi2', 0x000f8b0b);
	addLuaSprite('platChi2');
	
	makeLuaSprite('chiCup', chic .. 'cup', 1780 - 41, 470 - 38);
	addLuaSprite('chiCup');
	
	makeLuaSprite('chica', chic .. 'chica', 1346 - 56, 574 - 73);
	addLuaSprite('chica');
	
	makeLuaSprite('cupSmall', chic .. 'cupSmall', 1388 - 18, 541 - 16);
	addLuaSprite('cupSmall');
	
	
	makeAnimatedLuaSprite('chiKid', chic .. 'kid', 1604 - 46, 648 - 91);
	addAnimationByPrefix('chiKid', 'idle', 'Cry', 0);
	playAnim('chiKid', 'idle');
	addLuaSprite('chiKid');
end

local collect = {
	{2734, 462},
	{2830, 464},
	{2476, 396},
	{2276, 312},
	{2562, 234},
	{2636, 232},
	{2874, 210}
};
function makeBB()
	makeLuaSprite('leftBB1', BOX, 2194, 111);
	scaleObject('leftBB1', 32, 212);
	setColor('leftBB1', 0x00335fb3);
	addLuaSprite('leftBB1');
	
	makeLuaSprite('leftBB2', BOX, 2194, 322);
	scaleObject('leftBB2', 32, 328);
	setColor('leftBB2', 0x00335fb3);
	addLuaSprite('leftBB2');
	
	makeLuaSprite('downBB', BOX, 2194, 648);
	scaleObject('downBB', 762, 30);
	setColor('downBB', 0x00335fb3);
	addLuaSprite('downBB');
	
	makeLuaSprite('upBB', BOX, 2194, 112);
	scaleObject('upBB', 762, 30);
	setColor('upBB', 0x00335fb3);
	addLuaSprite('upBB');
	
	makeLuaSprite('rightBB', BOX, 2927, 114);
	scaleObject('rightBB', 32, 562);
	setColor('rightBB', 0x00335fb3);
	addLuaSprite('rightBB');
	
	
	makeLuaSprite('platBB1', BOX, 2698, 534);
	scaleObject('platBB1', 164, 30);
	setColor('platBB1', 0x00335fb3);
	addLuaSprite('platBB1');
	
	makeLuaSprite('platBB2', BOX, 2434, 468);
	scaleObject('platBB2', 164, 30);
	setColor('platBB2', 0x00335fb3);
	addLuaSprite('platBB2');
	
	makeLuaSprite('platBB3', BOX, 2222, 380);
	scaleObject('platBB3', 164, 30);
	setColor('platBB3', 0x00335fb3);
	addLuaSprite('platBB3');
	
	makeLuaSprite('platBB4', BOX, 2522, 300);
	scaleObject('platBB4', 164, 30);
	setColor('platBB4', 0x00335fb3);
	addLuaSprite('platBB4');
	
	makeLuaSprite('platBB5', BOX, 2788, 274);
	scaleObject('platBB5', 164, 30);
	setColor('platBB5', 0x00335fb3);
	addLuaSprite('platBB5');
	
	makeLuaSprite('cloudBB1', main .. 'cloud', 2654, 322);
	addLuaSprite('cloudBB1');
	
	makeLuaSprite('cloudBB2', main .. 'cloud', 2274, 166);
	addLuaSprite('cloudBB2');
	
	makeLuaSprite('cloudBB3', main .. 'cloud', 2550, 110);
	addLuaSprite('cloudBB3');
	
	makeLuaSprite('bb', bb .. 'bb', 2547 - 56, 587 - 59);
	addLuaSprite('bb');
	
	for i = 1, 7 do
		local t = 'collectB' .. i;
		local p = collect[i];
		makeLuaSprite(t, bb .. 'balloon/collect', p[1] - 34, p[2] - 57);
		addLuaSprite(t);
	end
end

function makeMangle()
	makeLuaSprite('mangWin1', mang .. 'window', 220, 920);
	addLuaSprite('mangWin1');
	
	makeLuaSprite('mangWin2', mang .. 'windowMoon', 462, 923);
	addLuaSprite('mangWin2');
	
	
	makeLuaSprite('mangLeft', BOX, 102, 896);
	scaleObject('mangLeft', 32, 546);
	setColor('mangLeft', 0x008b378f);
	addLuaSprite('mangLeft');
	
	makeLuaSprite('mangDown', BOX, 103, 1410);
	scaleObject('mangDown', 802, 32);
	setColor('mangDown', 0x008b378f);
	addLuaSprite('mangDown');
	
	makeLuaSprite('mangUp', BOX, 103, 878);
	scaleObject('mangUp', 802, 32);
	setColor('mangUp', 0x008b378f);
	addLuaSprite('mangUp');
	
	makeLuaSprite('mangRight', BOX, 873, 890);
	scaleObject('mangRight', 32, 546);
	setColor('mangRight', 0x008b378f);
	addLuaSprite('mangRight');
	
	
	makeLuaSprite('platMang1', BOX, 382, 1288);
	scaleObject('platMang1', 164, 30);
	setColor('platMang1', 0x008b378f);
	addLuaSprite('platMang1');
	
	makeLuaSprite('platMang2', BOX, 132, 1194);
	scaleObject('platMang2', 164, 30);
	setColor('platMang2', 0x008b378f);
	addLuaSprite('platMang2');
	
	makeLuaSprite('platMang3', BOX, 422, 1136);
	scaleObject('platMang3', 164, 30);
	setColor('platMang3', 0x008b378f);
	addLuaSprite('platMang3');
	
	makeLuaSprite('platMang4', BOX, 714, 1150);
	scaleObject('platMang4', 164, 30);
	setColor('platMang4', 0x008b378f);
	addLuaSprite('platMang4');
	
	
	makeLuaSprite('head', mang .. 'mangle/char/head2', 227 - 76, 1157 - 85);
	addLuaSprite('head');
	
	
	makeAnimatedLuaSprite('kidMang', mang .. 'kid', 777, 1324);
	addAnimationByPrefix('kidMang', 'right', 'Kid', 6);
	addAnimationByPrefix('kidMang', 'left', 'Kid', 6);
	setAnimFlipX('kidMang', 'left', true);
	playAnim('kidMang', 'left', true);
	addLuaSprite('kidMang');
end

function LOST()
	makeLuaSprite('purple', rw .. 'purple', 1023, 766);
	addLuaSprite('purple');
	
	
	makeLuaSprite('lostLeft', BOX, 1144, 894);
	scaleObject('lostLeft', 32, 546);
	setColor('lostLeft', 0x008b378f);
	addLuaSprite('lostLeft');
	
	makeLuaSprite('lostDown', BOX, 1145, 1408);
	scaleObject('lostDown', 802, 32);
	setColor('lostDown', 0x008b378f);
	addLuaSprite('lostDown');
	
	makeLuaSprite('lostUp', BOX, 1145, 876);
	scaleObject('lostUp', 802, 32);
	setColor('lostUp', 0x008b378f);
	addLuaSprite('lostUp');
	
	makeLuaSprite('lostRight', BOX, 1915, 888);
	scaleObject('lostRight', 32, 546);
	setColor('lostRight', 0x008b378f);
	addLuaSprite('lostRight');
end

function makeEdges()
	makeLuaSprite('leftEdge', BOX, 8 - 11, 385 - 395);
	scaleObject('leftEdge', 22, 790);
	addLuaSprite('leftEdge');
	setVis('leftEdge', false);
	
	makeLuaSprite('downEdge', BOX, 511 - 514, 759 - 12);
	scaleObject('downEdge', 1028, 24);
	addLuaSprite('downEdge');
	setVis('downEdge', false);
	
	makeLuaSprite('upEdge', BOX, 513 - 514, 6 - 12);
	scaleObject('upEdge', 1028, 24);
	addLuaSprite('upEdge');
	setVis('upEdge', false);
	
	makeLuaSprite('rightEdge', BOX, 1012 - 11, 389 - 395);
	scaleObject('rightEdge', 22, 790);
	addLuaSprite('rightEdge');
	setVis('rightEdge', false);
end

local canExit = false;
function makeGoal()
	if not k4 then
		makeAnimatedLuaSprite('kid', rw .. 'child', 1084 - 44, 1474 - 45);
		addAnimationByPrefix('kid', 'idle', 'Idle', 0);
		addAnimationByPrefix('kid', 'look', 'Look', 0);
		playAnim('kid', 'idle', true);
		addLuaSprite('kid');
		
		if cake then
			makeLuaSprite('cake', main .. 'secret/win/cake', 1210 - 79, 1440 - 84);
			addLuaSprite('cake');
			setVis('cake', false);
		end
	end
	
	makeLuaSprite('exit', main .. 'exit', 772 - 47, 227 - 57);
	addLuaSprite('exit');
end

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not won and not gameStopped then
		updateMove(e);
		updateKid(e);
		
		callOnLuas('updateFunc', {e});
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

local kidPos = {777, 1324};
local kidMoveX = 0;
local kidMoveY = 0;
local kidMult = 1;
local kidOff = {['left'] = 84, ['right'] = 82};
local kidDir = 'left';
local atKid = atan2(-3, -519);
local kidTrig = {cos(atKid), sin(atKid)};
local kidVel = floor(25 * 7.487569464755777);
function updateKid(e)
	if gameStopped then return; end
	
	local vel = (kidVel * e) * kidMult;
	kidMoveX = kidMoveX + (vel * kidTrig[1]);
	kidMoveY = kidMoveY + (vel * kidTrig[2]);
	if kidMoveX < -519 then
		local addX = kidMoveX + 519;
		local addY = kidMoveY + 3;
		kidMoveX = kidMoveX - addX;
		kidMoveY = kidMoveY - addY;
		kidMult = -1;
		kidDir = 'right';
		playAnim('kidMang', kidDir);
	elseif kidMoveX > 0 then
		kidMoveX = -kidMoveX;
		kidMoveY = -kidMoveY;
		kidMult = 1;
		kidDir = 'left';
		playAnim('kidMang', kidDir);
	end
	
	setPos('kidMang', floor((kidPos[1] - kidOff[kidDir]) + kidMoveX), floor((kidPos[2] - 84) + kidMoveY));
end

local sideShift = {
	{30, 0},
	{0, -30},
	{0, 30},
	{-30, 0}
};
function updateMove(e)
	c.isMoving = false;
	
	if lastRoom ~= curRoom and keyboardPressed('S') then
		setRoom();
	end
	
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
	
	if keyboardPressed('W') and not onBackdrop('topBox') then
		c.jumpNum = 2;
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
	
	for i, s in pairs({'left', 'down', 'up', 'right'}) do
		if objectsOverlap('charBox', s .. 'Edge') then
			local s = sideShift[i];
			c.pos[1] = c.pos[1] + s[1];
			c.pos[2] = c.pos[2] + s[2];
			
			updateCharPos();
		end
	end
	
	playAnim('shadow', c.dir .. ((c.jumpNum == 0 and not c.isMoving) and '' or 'Walk'));
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
		end
	end
end

function checkMoveChar(d, b, e, f)
	local t = b .. 'Time';
	if keyboardPressed(d) then
		c.isMoving = true;
		if not onBackdrop(b .. 'Box') then
			c[t] = c[t] + e;
			while c[t] >= 0.1 do
				c[t] = c[t] - 0.1;
				f();
			end
		end
	end
end

function setDir(d)
	if c.dir == d then return; end
	c.dir = d;
	c.offX = (d == 'right' and 1 or 0);
	playAnim('shadow', d);
end

local lastRoom = curRoom;
function setRoom()
	if curRoom == lastRoom then return; end
	local x = curRoom % 3;
	local y = floor(curRoom / 3);
	local lX = lastRoom % 3;
	local lY = floor(lastRoom / 3);
	local xDif = x - lX;
	local yDif = y - lY;
	
	local newX = xDif * 1024;
	local newY = yDif * 768;
	
	for _, s in pairs({'leftEdge', 'downEdge', 'upEdge', 'rightEdge'}) do
		addX(s, newX);
		addY(s, newY);
	end
	
	lastRoom = curRoom;
	gameScroll = {x * 1024, y * 768};
	setScroll(nil, gameScroll[1], gameScroll[2]);
	
	updateCharPos();
end

function onAnything(o)
	return onBackdrop(o) or onBalloon(o);
end

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
	end,
	
	['randRoom'] = function()
		if getRandomBool() then
			curRoom = Random(5);
		end
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
