local title = 'gameAssets/title/';

local randInt;
local min = math.min;
local max = math.max;

local sv = 'FNAF3';

local gameStopped = false;
local adGoing = true;

local spBug = false;
local statAlph = 0;

local curNight = 1;

local totOptions = 1;
local curOption = -1;
function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		var mainCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		mainCam.pixelPerfectRender = true;
		mainCam.antialiasing = false;
		setVar('mainCam', mainCam);
		
		var adCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		adCam.pixelPerfectRender = true;
		adCam.antialiasing = false;
		adCam.bgColor = 0x00000000;
		adCam.alpha = 0;
		setVar('adCam', adCam);
	]]);
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	randInt = getRandomInt;
	
	curNight = min(getDataFromSave(sv, 'night', 1), 5);
	
	makeSP();
	makeUI();
	makeTop();
	
	runTimer('pof', pl(0.04), 0);
	runTimer('thre', pl(0.3), 0);
	runTimer('sec', pl(1), 0);
	runTimer('two', pl(2), 0);
	
	doSound('titlemusic', 1, 'bgMus', true);
	precacheSound('select');
end

function makeTop()
	makeAnimatedLuaSprite('static', title .. 'static');
	addAnimationByPrefix('static', 'static', 'Static', 59);
	setFrameRate('static', 'static', 59.4);
	playAnim('static', 'static', true);
	setCam('static');
	addLuaSprite('static');
	
	
	makeLuaSprite('ad', 'gameAssets/ad/ad');
	setCam('ad', 'adCam');
	addLuaSprite('ad');
	
	makeLuaSprite('blackAd');
	makeGraphic('blackAd', 1, 1, '000000');
	scaleObject('blackAd', 1050, 768);
	setCam('blackAd', 'adCam');
	addLuaSprite('blackAd');
	setAlpha('blackAd', 0);
end

local starPos = {
	{182, 86},
	{259, 86},
	{220, 136},
	{297, 136}
};
local dataCheck = {
	'beatGame',
	'beat6',
	'goodEnd',
	'4thStar'
};
function makeUI()
	makeLuaSprite('holdDel', title .. 'hold', 376, 734);
	setCam('holdDel');
	addLuaSprite('holdDel');
	
	makeAnimatedLuaSprite('blip', title .. 'blip');
	addAnimationByPrefix('blip', 'blip', 'Blip', 3);
	setCam('blip');
	addLuaSprite('blip');
	
	
	makeLuaSprite('scanLine', nil, 26 -26);
	makeGraphic('scanLine', 1, 1, '5f9b00');
	scaleObject('scanLine', 1024, 20);
	setCam('scanLine');
	addLuaSprite('scanLine');
	setAlpha('scanLine', 55 / 255);
	startTween('scanLineTwn', 'scanLine', {y = 768 - 26}, pl(20.7567), {type = 'LOOPING'});
	
	
	makeLuaSprite('title', title .. 'title', 118 - 16, 172 - 113);
	setBlendMode('title', 'add');
	setCam('title');
	addLuaSprite('title');
	
	if getDataFromSave(sv, 'isDemo', false) then
		makeLuaSprite('demoTxt', title .. 'demoTxt', 102, 305);
		setBlendMode('demoTxt', 'add');
		setCam('demoTxt');
		addLuaSprite('demoTxt');
	end
	
	makeLuaSprite('ver', title .. 'ver', 916, 706);
	setCam('ver');
	addLuaSprite('ver');
	
	makeLuaSprite('copy', title .. 'copy', 924 - 91, 731);
	setCam('copy');
	addLuaSprite('copy');
	
	for i = 1, 4 do
		local p = starPos[i];
		local t = 'star' .. i;
		makeLuaSprite(t, title .. 'star', p[1] - 27, p[2] - 28);
		setBlendMode(t, 'add');
		setCam(t);
		addLuaSprite(t);
		setVis(t, getDataFromSave(sv, dataCheck[i], false));
	end
	
	makeButtons();
	makeScanLines();
end

local canSel = {
	[0] = 'new',
	'cont',
	'sixth',
	'extra'
};
function makeButtons()
	makeLuaSprite('new', title .. 'new', 97, 452 - 24);
	setBlendMode('new', 'add');
	setCam('new');
	addLuaSprite('new');
	
	makeLuaSprite('cont', title .. 'load', 97, 524 - 24);
	setBlendMode('cont', 'add');
	setCam('cont');
	addLuaSprite('cont');
	
	makeCounterSpr('night', 363, 547, curNight);
	setCam('night');
	addLuaSprite('night');
	setVis('night', false);
	
	if getDataFromSave(sv, 'beatGame', false) then
		totOptions = 3;
		
		makeLuaSprite('sixth', title .. 'sixth', 97, 596 - 24);
		setBlendMode('sixth', 'add');
		setCam('sixth');
		addLuaSprite('sixth');
		
		makeLuaSprite('extra', title .. 'extra', 96, 665 - 24);
		setBlendMode('extra', 'add');
		setCam('extra');
		addLuaSprite('extra');
	end
	
	makeAnimatedLuaSprite('sel', title .. 'sel', 54 - 16, 525 - 24);
	addAnimationByPrefix('sel', 'sel', 'Beep', 6);
	setCam('sel');
	addLuaSprite('sel');
	
	setSel(1, false);
end

local scanA = {
	79,
	127,
	173,
	217,
	261,
	
	451,
	523,
	592,
	661
};
local scanB = {705, 740};
function makeScanLines()
	for i = 1, 9 do
		local t = 'scanLeft' .. i;
		makeAnimatedLuaSprite(t, title .. 'line', 0, scanA[i] - 15);
		addAnimationByPrefix(t, 'line', 'Vcr', 6);
		setFrameRate(t, 'line', (2 + Random(10)) * 0.6);
		playAnim(t, 'line', true);
		setBlendMode(t, 'add');
		setCam(t);
		addLuaSprite(t);
	end
	
	for i = 1, 2 do
		local t = 'scanRight' .. i;
		makeAnimatedLuaSprite(t, title .. 'line', -1, scanB[i] - 15);
		addAnimationByPrefix(t, 'line', 'Vcr', 6);
		setFrameRate(t, 'line', (2 + Random(10)) * 0.6);
		playAnim(t, 'line', true);
		setBlendMode(t, 'add');
		setFlipX(t, true);
		setCam(t);
		addLuaSprite(t);
	end
end

function makeSP()
	makeAnimatedLuaSprite('sp', title .. 'sp');
	addAnimationByPrefix('sp', 'idle', 'Title', 0);
	addAnimationByPrefix('sp', 'bug1', 'BugA', 0);
	addAnimationByPrefix('sp', 'bug2', 'BugB', 0);
	addAnimationByPrefix('sp', 'bug3', 'BugC', 0);
	addAnimationByPrefix('sp', 'bug4', 'BugD', 0);
	playAnim('sp', 'idle');
	setCam('sp');
	addLuaSprite('sp');
end

local tickRate = 0;
local frameSec = 1 / 60;
local delTime = 0;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if not gameStopped then
		if statAlph > 0 then
			statAlph = max(statAlph - (2 * ti), 0);
		end
		
		if delTime < 1 and keyboardPressed('DELETE') then
			delTime = delTime + e;
			if delTime >= 1 then
				doSound('select', 1, 'selSnd');
				deleteSave();
			end
		end
		
		updateSel();
		
		local ticks = 0;
		tickRate = tickRate + e;
		while (tickRate >= frameSec) do
			tickRate = tickRate - frameSec;
			ticks = ticks + 1;
			
			onTick();
		end
	elseif not adGoing and keyboardJustPressed('ESCAPE') or keyboardJustPressed('ENTER') or mouseClicked() then
		adGoing = true;
		
		doTweenAlpha('blackIn', 'blackAd', 1, pl(2));
	end
	
	return Function_StopLua;
end

function onTick()
	if spBug then
		local r = Random(5);
		if r > 3 then
			playAnim('sp', 'idle');
		else
			playAnim('sp', 'bug' .. r);
		end
	end
end

function newGame()
	setDataFromSave(sv, 'night', 1);
	setDataFromSave(sv, 'bb', false);
	setDataFromSave(sv, 'cake', false);
	setDataFromSave(sv, 'k1', false);
	setDataFromSave(sv, 'k2', false);
	setDataFromSave(sv, 'k3', false);
	setDataFromSave(sv, 'k4', false);
end

function startAd()
	gameStopped = true;
	setVar('canEsc', false);
	
	stopT();
	stopAnims();
	doTweenAlpha('adIn', 'adCam', 1, pl(2));
end

local curMouseSel = curOption;
function updateSel()
	if keyboardJustPressed('DOWN') then
		setSel(curOption + 1, true);
	end
	if keyboardJustPressed('UP') then
		setSel(curOption - 1, true);
	end
	
	local hoveringOn = false;
	for i = 0, totOptions do
		if mouseOverlaps(canSel[i]) then
			hoveringOn = true;
			if i ~= curMouseSel then
				curMouseSel = i;
				setSel(i, true);
			end
		end
	end
	
	if not hoveringOn then curMouseSel = -1; end
	
	if mouseClicked() then
		if mouseOverlaps(canSel[curOption]) then
			onChoose();
		end
	end
	if keyboardJustPressed('ENTER') then
		onChoose();
	end
end

local optionFunc = {
	[0] = function()
		newGame();
		startAd();
	end,
	[1] = function()
		switchState('WhatDay');
	end,
	[2] = function()
		setDataFromSave(sv, 'night', 6);
		switchState('WhatDay');
	end,
	[3] = function()
		switchState('Extra');
	end
};
function onChoose()
	local o = optionFunc[curOption];
	if o then o(); end
end

function setSel(i, s)
	if i < 0 then i = totOptions; end
	if i > totOptions then i = 0; end
	curOption = i;
	
	if s then doSound('select', 1, 'selSnd'); end
	
	setVis('night', curOption == 1);
	setY('sel', getY(canSel[i]));
end

local timers = {
	['pof'] = function()
		local a = (200 + Random(100)) - statAlph;
		setAlpha('static', clAlph(a));
	end,
	['thre'] = function()
		setAlpha('sp', clAlph(Random(50)));
		setVis('blip', Random(3) == 1);
	end,
	['sec'] = function()
		spBug = Random(5) == 1;
		if not spBug then playAnim('sp', 'idle'); end
		
		setFrameRate('scanLeft' .. randInt(1, 9), 'line', (2 + Random(10)) * 0.6);
		setFrameRate('scanRight' .. randInt(1, 2), 'line', (2 + Random(10)) * 0.6);
		setAlpha('blip', clAlph(200 + Random(150)));
	end,
	['two'] = function()
		statAlph = Random(3) * 25;
	end
};
function onTimerCompleted(t)
	if not gameStopped then
		local ti = timers[t];
		if ti then ti(); end
	elseif t == 'forceGo' then
		if not adGoing then
			adGoing = true;
			
			doTweenAlpha('blackIn', 'blackAd', 1, pl(2));
		end
	end
end

local tweens = {
	['adIn'] = function()
		runTimer('forceGo', pl(9));
		adGoing = false;
	end,
	['blackIn'] = function()
		switchState('whatDay');
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end

function deleteSave()
	updateCounterSpr('night', 1);
	
	for i = 1, 4 do setVis('star' .. i, false); end
	
	if getDataFromSave(sv, 'beatGame', false) then
		setVis('sixth', false);
		setVis('extra', false);
	end
	setSel(curOption, false);
	totOptions = 1;
	
	setDataFromSave(sv, 'night', 1);
	setDataFromSave(sv, 'bb', false);
	setDataFromSave(sv, 'cake', false);
	setDataFromSave(sv, 'k1', false);
	setDataFromSave(sv, 'k2', false);
	setDataFromSave(sv, 'k3', false);
	setDataFromSave(sv, 'k4', false);
	
	setDataFromSave(sv, 'beatGame', false);
	setDataFromSave(sv, 'goodEnd', false);
	setDataFromSave(sv, 'beat6', false);
	setDataFromSave(sv, 'beat7', false);
	setDataFromSave(sv, '4thStar', false);
	
	setDataFromSave(sv, 'fast', false);
	setDataFromSave(sv, 'radar', false);
	setDataFromSave(sv, 'aggro', false);
	setDataFromSave(sv, 'noErr', false);
end
