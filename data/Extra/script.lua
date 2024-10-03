local title = 'gameAssets/title/';
local ex = 'gameAssets/extra/';

local sv = 'FNAF3';

local min = math.min;

local beat6 = true;
local beatGood = true;

local curSel = -1;
local curOptions = 0;

local curUi = -1;
local curChose = -1;
local set = {'fastTxt', 'radarTxt', 'aggroTxt', 'noErrTxt'};
local dataCheck = {
	'fast',
	'radar',
	'aggro',
	'noErr'
};
function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		var mainCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		mainCam.pixelPerfectRender = false;
		mainCam.antialiasing = false;
		setVar('mainCam', mainCam);
		
		var viewCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		viewCam.pixelPerfectRender = false;
		viewCam.antialiasing = false;
		viewCam.bgColor = 0x00000000;
		setVar('viewCam', viewCam);
		
		var scareCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		scareCam.pixelPerfectRender = false;
		scareCam.antialiasing = false;
		scareCam.bgColor = 0x00000000;
		setVar('scareCam', scareCam);
		
		var uiCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		uiCam.pixelPerfectRender = false;
		uiCam.antialiasing = false;
		uiCam.bgColor = 0x00000000;
		setVar('uiCam', uiCam);
	]]);
	
	setVar('canEsc', false);
	
	beatGood = getDataFromSave(sv, 'goodEnd', false);
	beat6 = getDataFromSave(sv, 'beat6', false);
	
	makeExtra();
	doSound('Desolate_Underworld2', 1, 'bgMus', true);
	
	runTimer('hideStuff', 0.1);
	
	precacheSound('select');
	precacheSound('scream3');
end

function makeExtra()
	makeBG();
	makeView();
	makeUI();
end

local scLine = {
	{460, 61},
	{0, 158},
	{0, 221},
	{0, 284},
	{0, 453}
};
function makeBG()
	makeLuaSprite('bg', ex .. 'bg');
	setCam('bg');
	addLuaSprite('bg');
	
	for i = 1, 5 do
		local p = scLine[i];
		local t = 'scanLine' .. i;
		makeAnimatedLuaSprite(t, title .. 'line', p[1], p[2] - 15);
		addAnimationByPrefix(t, 'line', 'Vcr', 6);
		setFrameRate(t, 'line', (2 + Random(6)) * 0.6);
		playAnim(t, 'line', true);
		setBlendMode(t, 'add');
		setCam(t);
		addLuaSprite(t);
		setAlpha(t, clAlph(150));
	end
	
	makeAnimatedLuaSprite('static', title .. 'static');
	addAnimationByPrefix('static', 'static', 'Static', 59);
	setFrameRate('static', 'static', 59.4);
	playAnim('static', 'static', true);
	setCam('static');
	addLuaSprite('static');
	setAlpha('static', clAlph(225));
end

local markY = {
	204,
	267,
	333,
	400
};
function makeView()
	makeAnimatedLuaSprite('viewAnims', ex .. 'view', 656, 766);
	for i = 1, 7 do addAnimationByPrefix('viewAnims', i, 'View000' .. i, 0); end
	addOffset('viewAnims', '1', 384, 767);
	addOffset('viewAnims', '2', 384, 767);
	addOffset('viewAnims', '3', 170, 566);
	addOffset('viewAnims', '4', 489, 740);
	addOffset('viewAnims', '5', 368, 750);
	addOffset('viewAnims', '6', 384, 767);
	addOffset('viewAnims', '7', 186, 589);
	playAnim('viewAnims', '1', true);
	setCam('viewAnims', 'viewCam');
	addLuaSprite('viewAnims');
	setVis('viewAnims', false);
	
	makeLuaText('viewName', 'Text', 570, 416 + 2, 694 + 5);
	setTextSize('viewName', 37);
	setTextFont('viewName', 'tahomaBold.ttf');
	setTextAlignment('viewName', 'right');
	setProperty('viewName.borderSize', -1000000);
	setCam('viewName', 'viewCam');
	addLuaText('viewName');
	setVis('viewName', false);
	
	if beatGood then
		makeAnimatedLuaSprite('miniView', ex .. 'icons', 642 - 199, 286 - 149);
		addAnimationByPrefix('miniView', 'mini', 'Mini', 0);
		setCam('miniView', 'viewCam');
		addLuaSprite('miniView');
		setVis('miniView', false);
		
		makeLuaSprite('play', ex .. 'play', 654 - 113, 488 - 20);
		setBlendMode('play', 'add');
		setCam('play', 'uiCam');
		addLuaSprite('play');
		setVis('play', false);
		
		makeLuaSprite('fastTxt', ex .. 'fast', 469, 211 - 21);
		setBlendMode('fastTxt', 'add');
		setCam('fastTxt', 'uiCam');
		addLuaSprite('fastTxt');
		setVis('fastTxt', false);
		
		makeLuaSprite('radarTxt', ex .. 'radar', 469, 278 - 21);
		setBlendMode('radarTxt', 'add');
		setCam('radarTxt', 'uiCam');
		addLuaSprite('radarTxt');
		setVis('radarTxt', false);
		
		makeLuaSprite('aggroTxt', ex .. 'aggro', 469, 345 - 21);
		setBlendMode('aggroTxt', 'add');
		setCam('aggroTxt', 'uiCam');
		addLuaSprite('aggroTxt');
		setVis('aggroTxt', false);
		
		makeLuaSprite('noErrTxt', ex .. 'noErr', 469, 412 - 21);
		setBlendMode('noErrTxt', 'add');
		setCam('noErrTxt', 'uiCam');
		addLuaSprite('noErrTxt');
		setVis('noErrTxt', false);
	end
	
	for i = 1, 4 do
		local y = markY[i];
		local t = 'mark' .. i;
		makeLuaSprite(t, ex .. 'check', 787 - 31, y - 35);
		setBlendMode(t, 'add');
		setCam(t, 'uiCam');
		addLuaSprite(t);
		setVis(t, getDataFromSave(sv, dataCheck[i], false));
		setAlpha(t, 0);
	end
	
	if beat6 then makeScares(); end
end

function makeScares()
	makeAnimatedLuaSprite('scare1', 'gameAssets/Jumpscares/sp/s/scare1', 170, -4);
	addAnimationByPrefix('scare1', 'scare', 'Scare', 36, false);
	playAnim('scare1', 'scare', true);
	setCam('scare1', 'scareCam');
	addLuaSprite('scare1');
	setAlpha('scare1', 0.00001);
	
	makeAnimatedLuaSprite('scare2', 'gameAssets/Jumpscares/sp/s/scare2', 20, -6);
	addAnimationByPrefix('scare2', 'scare', 'Scare', 36, false);
	playAnim('scare2', 'scare', true);
	setCam('scare2', 'scareCam');
	addLuaSprite('scare2');
	setAlpha('scare2', 0.00001);
	
	makeAnimatedLuaSprite('scare3', 'gameAssets/Jumpscares/chica');
	addAnimationByPrefix('scare3', 'scare', 'Scare', 36, false);
	addOffset('scare3', 'scare', -19, 0);
	playAnim('scare3', 'scare', true);
	setCam('scare3', 'scareCam');
	addLuaSprite('scare3');
	setAlpha('scare3', 0.00001);
	
	makeAnimatedLuaSprite('scare4', 'gameAssets/Jumpscares/foxy', 506 - 647, 764 - 766);
	addAnimationByPrefix('scare4', 'scare', 'Scare', 24, false);
	playAnim('scare4', 'scare', true);
	setCam('scare4', 'scareCam');
	addLuaSprite('scare4');
	setAlpha('scare4', 0.00001);
	
	makeAnimatedLuaSprite('scare5', 'gameAssets/Jumpscares/freddy');
	addAnimationByPrefix('scare5', 'scare', 'Scare', 30, false);
	addOffset('scare5', 'scare', 41, 2);
	playAnim('scare5', 'scare', true);
	setCam('scare5', 'scareCam');
	addLuaSprite('scare5');
	setAlpha('scare5', 0.00001);
	
	makeAnimatedLuaSprite('scare6', 'gameAssets/Jumpscares/bb');
	addAnimationByPrefix('scare6', 'scare', 'Scare', 30, false);
	playAnim('scare6', 'scare', true);
	setCam('scare6', 'scareCam');
	addLuaSprite('scare6');
	setAlpha('scare6', 0.00001);
end

function makeUI()
	makeLuaSprite('extra', title .. 'extra', 36, 62 - 24);
	setBlendMode('extra', 'add');
	setCam('extra', 'uiCam');
	addLuaSprite('extra');
	
	makeLuaSprite('anims', ex .. 'anims', 72, 159 - 21);
	setBlendMode('anims', 'add');
	setCam('anims', 'uiCam');
	addLuaSprite('anims');
	
	makeLuaSprite('mini', ex .. 'mini', 72, 221 - 21);
	setBlendMode('mini', 'add');
	setCam('mini', 'uiCam');
	addLuaSprite('mini');
	
	makeLuaSprite('scares', ex .. 'scares', 72, 283 - 21);
	setBlendMode('scares', 'add');
	setCam('scares', 'uiCam');
	addLuaSprite('scares');
	
	makeLuaSprite('cheats', ex .. 'cheats', 72, 345 - 21);
	setBlendMode('cheats', 'add');
	setCam('cheats', 'uiCam');
	addLuaSprite('cheats');
	
	
	makeLuaSprite('exit', ex .. 'exit', 72, 454 - 21);
	setBlendMode('exit', 'add');
	setCam('exit', 'uiCam');
	addLuaSprite('exit');
	
	
	makeAnimatedLuaSprite('sel', title .. 'sel', 50 - 16, 157 - 24);
	addAnimationByPrefix('sel', 'sel', 'Beep', 12);
	setBlendMode('sel', 'add');
	setCam('sel', 'uiCam');
	addLuaSprite('sel');
	
	for i = 1, 7 do
		local t = 'butView' .. i;
		makeLuaSprite(t, ex .. 'nums/' .. i, (413 + (65 * i)) - 24, 62 - 25);
		setBlendMode(t, 'add');
		setCam(t, 'uiCam');
		addLuaSprite(t);
		setVis(t, false);
	end
	
	makeLuaSprite('uiSel', ex .. 'box', 0, 62 - 25);
	addToOffsets('uiSel', 6, 6);
	setBlendMode('uiSel', 'add');
	setCam('uiSel', 'uiCam');
	addLuaSprite('uiSel');
	
	if not beat6 then
		setAlpha('scares', clAlph(200));
	end
	
	if not beatGood then
		setAlpha('mini', clAlph(200));
		setAlpha('cheats', clAlph(200));
	end
	
	setSel(0);
	setUiSel(1, false);
	onChoose(false);
end

function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if keyboardJustPressed('ESCAPE') then
		switchState('Title');
		return Function_StopLua;
	end
	
	updateSel();
	updateSelUI();
	
	return Function_StopLua;
end

local selSpr = {
	[0] = 'anims',
	'mini',
	'scares',
	'cheats',
	'exit'
};
function setSel(i)
	if i < 0 then i = 4; end
	if i > 4 then i = 0; end
	
	curSel = i;
	setY('sel', getY(selSpr[i]) - 3);
end

function updateSel()
	if keyboardJustPressed('DOWN') then
		setSel(curSel + 1);
		onChoose(false);
	end
	if keyboardJustPressed('UP') then
		setSel(curSel - 1);
		onChoose(false);
	end
	
	if mouseClicked() then
		for i = 0, 4 do
			if mouseOverlaps(selSpr[i]) and i ~= curSel then
				setSel(i);
				onChoose(true);
				if curSel == 4 then hitEnter(); end
				
				break;
			end
		end
		
		if curChose == 3 and beatGood then
			for i = 1, 4 do
				if mouseOverlaps(set[i]) then
					local d = dataCheck[i];
					local nS = (not getDataFromSave(sv, d, false));
					setDataFromSave(sv, d, nS);
					setVis('mark' .. i, nS);
					return;
				end
			end
		end
	end
	
	if curSel == 4 and keyboardJustPressed('ENTER') then hitEnter(); end
end

function hitEnter()
	doSound('select', 1, 'selSnd');
	switchState('title');
end

local selFunc = {
	[0] = function()
		for i = 1, 7 do setVis('butView' .. i, true); end
		setVis('uiSel', true);
		setVis('viewName', true);
		setVis('viewAnims', true);
		setUiSel(1, false);
		
		curOptions = 7;
	end,
	[1] = function()
		if not beatGood then return; end
		for i = 1, 5 do setVis('butView' .. i, true); end
		setVis('uiSel', true);
		setVis('miniView', true);
		setVis('play', true);
		setUiSel(1, false);
		
		curOptions = 5;
	end,
	[2] = function()
		if not beat6 then return; end
		for i = 1, 6 do setVis('butView' .. i, true); end
		setVis('uiSel', true);
		setUiSel(1, false);
		
		curOptions = 6;
	end,
	[3] = function()
		if not beatGood then return; end
		setVis('fastTxt', true);
		setVis('radarTxt', true);
		setVis('aggroTxt', true);
		setVis('noErrTxt', true);
		
		for i = 1, 4 do setAlpha('mark' .. i, 1); end
	end
};
local onLeave = {
	[0] = function()
		for i = 1, 7 do setVis('butView' .. i, false); end
		setVis('uiSel', false);
		setVis('viewName', false);
		setVis('viewAnims', false);
		curUi = -1;
		curOptions = 0;
	end,
	[1] = function()
		if not beatGood then return; end
		for i = 1, 5 do setVis('butView' .. i, false); end
		setVis('uiSel', false);
		setVis('miniView', false);
		setVis('play', false);
		curUi = -1;
		curOptions = 0;
	end,
	[2] = function()
		if not beat6 then return; end
		for i = 1, 6 do setVis('butView' .. i, false); setAlpha('scare' .. i, 0); end
		setVis('uiSel', false);
		curUi = -1;
		curOptions = 0;
	end,
	[3] = function()
		if not beatGood then return; end
		setVis('fastTxt', false);
		setVis('radarTxt', false);
		setVis('aggroTxt', false);
		setVis('noErrTxt', false);
		
		for i = 1, 4 do setAlpha('mark' .. i, 0); end
	end
};
function onChoose(s)
	if curChose == curSel then return; end
	
	local l = onLeave[curChose];
	if l then l(); end
	
	if s then doSound('select', 1, 'selSnd'); end
	
	curChose = curSel;
	
	local s = selFunc[curChose];
	if s then s(); end
end

local selName = {
	'Springtrap',
	'Springtrap',
	'Phantom Foxy',
	'Phantom BB',
	'Phantom Chica',
	'Phantom Freddy',
	'Phantom Puppet',
};
function setUiSel(i, s)
	if s then doSound('select', 1, 'selSnd'); end
	
	if curUi == i then return; end
	if beat6 and curSel == 2 then
		doSound('scream3', 1, 'scareSnd');
		if curUi > 0 then setAlpha('scare' .. curUi, 0); end
		setAlpha('scare' .. i, 1);
		playAnim('scare' .. i, 'scare', true);
	end
	curUi = i;
	
	playAnim('viewAnims', i);
	setTextString('viewName', selName[i]);
	if beatGood then setFrame('miniView', min(i - 1, 5)); end
	
	setX('uiSel', getX('butView' .. i));
end

local games = {'BB', 'Mangle', 'ToyChica', 'GFreddy', 'RWQFSFASXC'};
function updateSelUI()
	if curOptions < 1 then return; end
	
	if mouseClicked() then
		for i = 1, curOptions do
			if mouseOverlaps('butView' .. i) then
				setUiSel(i, true);
				
				return;
			end
		end
		
		if curChose == 1 and mouseOverlaps('play') then
			switchState(games[curUi]);
		end
	end
end

local timers = {
	['hideStuff'] = function()
		for i = 1, 6 do
			if curChose ~= 2 or curUi ~= i then
				setAlpha('scare' .. i, 0);
			end
		end
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end