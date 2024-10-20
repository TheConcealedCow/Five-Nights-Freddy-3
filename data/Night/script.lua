local night = 'gameAssets/night/';
local hud = night .. 'hud/';
local office = night .. 'office/';
local panel = night .. 'panel/';
local sysHud = panel .. 'restart/hud/';
local viewHud = panel .. 'cams/hud/';
local HITBOX = 'hitboxes/HITBOX';

local bit = require('bit');
local band = bit.band;
local lshift = bit.lshift;
local rshift = bit.rshift;

local min = math.min;
local max = math.max;
local ins = table.insert;
local floor = math.floor;

local sv = 'FNAF3';

local frameActive = false;
local canMove = true;

local doing6AM = false;
local canUpdateWin = false;

local canMute = false;

viewingAPanel = false;
inAPanel = false;

marionActive = false;

local lastNear = 0;
nearPhase = 0;

local viewTrig = false;
viewingLittle = false;

local sysTrig = false;
viewingCams = false;

local clickOffice = true;

local seeDown = true;
local seeRight = false;

local curHour = 12;
curNight = 1;
curSealed = 0;

local ventTime = 0;
local goingToSeal = 0;
local ventSec = 0;

breatheNum = 0;

AI = 0;
timeLimit = 0;
scareCooled = true;

curCam = 2;
curVent = 11;

actualLooking = curCam;

local randSpecial = false;
local lookingVents = false;

local canCloseSys = true;
local rebooting = false;
local rebootAll = false;
local rebootTime = 1;
local rebootSec = 0;
local rebootProg = 0;

picRand = '1';

cameraProps = {};
ventProps = {};

cheats = {
	fast = false, -- Fast Nights
	radar = true, -- Radar
	hyper = false, -- Hyper
	noErr = false -- No Errors
};

blackout = {
	started = false,
	setTime = 0,
	alph = 0,
};

frozen = false;
local shaking = false;
local scrollShake = {
	started = false,
	
	dir = 256,
	off = 512,
	cal = 0,
};

local offKeyPos = {
	{875, 475}, {939, 476}, {1003, 478},
	{875, 542}, {939, 545}, {1003, 545},
	{875, 606}, {939, 611}, {1003, 614}
};
local arcadeKeyPos = {
	{1534, 345}, {1557, 339},
	{1530, 364}, {1554, 359}
};

local cupInCam = {
	[2] = true,
	[3] = true,
	[4] = true,
	[6] = true
};
local totCups = 4;

local timeSubVent = {[2] = 12, [3] = 10, [4] = 9, [5] = 8, [6] = 6};
local scriptToAdd = {'marionette', 'goldenFreddy', 'mangle', 'chica', 'foxy', 'bb', 'springtrap'};
function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		import flixel.sound.FlxSoundGroup;
		import flixel.group.FlxTypedSpriteGroup;
		import psychlua.LuaUtils;
		
		var shad = game.createRuntimeShader('panorama');
		var perspShader = new ShaderFilter(shad);
		
		var mainCam = FlxG.cameras.add(new FlxCamera(-8, -8, 1048, 790), false);
		mainCam.scroll.set(-8, -8);
		mainCam.setFilters([perspShader]);
		mainCam.pixelPerfectRender = true;
		mainCam.antialiasing = false;
		setVar('mainCam', mainCam);
		
		var marionCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		marionCam.bgColor = 0x00000000;
		marionCam.pixelPerfectRender = true;
		marionCam.antialiasing = false;
		setVar('marionCam', marionCam);
		
		var hudCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		hudCam.bgColor = 0x00000000;
		hudCam.pixelPerfectRender = true;
		hudCam.antialiasing = false;
		setVar('hudCam', hudCam);
		
		var panelCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		panelCam.bgColor = 0x00000000;
		panelCam.pixelPerfectRender = true;
		panelCam.antialiasing = false;
		setVar('panelCam', panelCam);
		
		var sysCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		sysCam.bgColor = 0x00000000;
		sysCam.pixelPerfectRender = true;
		sysCam.antialiasing = false;
		sysCam.alpha = 0.00001;
		setVar('sysCam', sysCam);
		
		var camCam = FlxG.cameras.add(new FlxCamera(-976, 0, 1024, 768), false);
		camCam.bgColor = 0x00000000;
		camCam.pixelPerfectRender = true;
		camCam.antialiasing = false;
		camCam.alpha = 0.00001;
		setVar('camCam', camCam);
		
		
		var flickCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		flickCam.bgColor = 0x00000000;
		flickCam.pixelPerfectRender = true;
		flickCam.antialiasing = false;
		setVar('flickCam', flickCam);
		
		var blackCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		blackCam.bgColor = 0xFF000008;
		blackCam.alpha = 0;
		setVar('blackCam', blackCam);
		
		var flashCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		flashCam.bgColor = 0x00000000;
		flashCam.pixelPerfectRender = true;
		flashCam.antialiasing = false;
		setVar('flashCam', flashCam);
		
		var winCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		winCam.bgColor = 0xFF000000;
		winCam.pixelPerfectRender = true;
		winCam.antialiasing = false;
		winCam.alpha = 0.00001;
		setVar('winCam', winCam);
		
		var mainCamsGrp:FlxTypedSpriteGroup<FlxSprite>;
		mainCamsGrp = new FlxTypedSpriteGroup();
		setVar('mainCamsGrp', mainCamsGrp);
		
		var ventCamsGrp:FlxTypedSpriteGroup<FlxSprite>;
		ventCamsGrp = new FlxTypedSpriteGroup();
		setVar('ventCamsGrp', ventCamsGrp);
		
		
		var mainCamsMark:FlxTypedSpriteGroup<FlxSprite>;
		mainCamsMark = new FlxTypedSpriteGroup();
		setVar('mainCamsMark', mainCamsMark);
		
		var ventCamsMark:FlxTypedSpriteGroup<FlxSprite>;
		ventCamsMark = new FlxTypedSpriteGroup();
		setVar('ventCamsMark', ventCamsMark);
		
		var lureGrp:FlxTypedSpriteGroup<FlxSprite>;
		lureGrp = new FlxTypedSpriteGroup();
		setVar('lureGrp', lureGrp);
		
		var channel8 = new FlxSoundGroup(1.);
		setVar('channel8', channel8);
		
		function updateScroll(x) {
			x -= 512;
			
			mainCam.scroll.x = x - 8;
			
			flickCam.scroll.x = x;
			panelCam.scroll.x = x;
			sysCam.scroll.x = x;
			camCam.scroll.x = x;
			marionCam.scroll.x = x;
		}
		
		createCallback('setFinFunc', function(o, f, ?p) {
			var obj = LuaUtils.getObjectDirectly(o, false);
			obj.animation.finishCallback = function(n) {
				parentLua.call(f, [obj.animation.curAnim.reversed, p]);
			}
		});
		
		createCallback('killOnFin', function(o) {
			var obj = LuaUtils.getObjectDirectly(o, false);
			obj.animation.finishCallback = function(n) {
				parentLua.call('removeLuaSprite', [o]);
			}
		});
		
		createGlobalCallback('getMainVar', function(v) {
			return parentLua.call('varMain', [v]);
		});
		
		createGlobalCallback('setMainVar', function(v, f) {
			parentLua.call('varSetMain', [v, f]);
		});

		createGlobalCallback('runMainFunc', function(v, ?n) {
			n ??= [];
			n.insert(0, v);
			
			return parentLua.call('mainFunc', n);
		});
		
		createGlobalCallback('setCamProp', function(c, n, a, v) {
			parentLua.call('setInCam', [c, n, a, v]);
		});
	]]);
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	cheats.fast = getDataFromSave(sv, 'fast', false);
	cheats.radar = getDataFromSave(sv, 'radar', false);
	cheats.hyper = getDataFromSave(sv, 'hyper', false);
	cheats.noErr = getDataFromSave(sv, 'noErr', false);
	
	curNight = getDataFromSave(sv, 'night', 1);
	
	calcAI();
	
	checkHalloween();
	makeOffice();
	makeScares();
	makePanel();
	makeHud();
	makeWinScreen();
	
	doSound('Desolate_Underworld2', 1, 'bgMus', true);
	doSound('tablefan', 1, 'fanSnd', true);
	doSound('danger2b', 0, 'dangerSnd', true);
	doSound('breathing', 0, 'breatheSnd', true);
	
	timeLimit = max(100 - ((curNight - 1) * 10), 50);
	
	for _, script in ipairs(scriptToAdd) do
		addLuaScript('scripts/night/animatronics/' .. script);
	end
	
	checkHour();
	
	picRand = (getRandomBool() and '2' or '1');
	randSpecial = (Random(10000) == 1);
	
	cacheSounds();
	
	runTimer('hideStuff', pl(0.1));
	runTimer('stopMoveTemp', pl(0.2));
	runTimer('startFrame', pl(1));
	runTimer('startShaking', pl(3));
	
	runTimer('thsi', pl(0.36), 0);
	runTimer('fiv', pl(0.5), 0);
	runTimer('sec', pl(1), 0);
	runTimer('ten', pl(10), 0);
	runTimer('twen', pl(20), 0);
	runTimer('min', pl(60), 0);
	
	setVar('gotYou', 0);
	
	if curNight > 1 then
		if curNight < 7 then
			local v = timeSubVent[curNight];
			runTimer('subVents', pl(v), 0);
		end
	else
		systems.audio.prog = -3 - Random(4);
		systems.video.prog = -3 - Random(4);
		systems.vent.prog = -2 - Random(4);
	end
	
	local h = (curNight == 1 and 40 or 60) / (cheats.fast and 2 or 1);
	runTimer('addHour', pl(h), 0);
end

local isHalloween = false;
function checkHalloween()
	local d = os.date('*t');
	local month = d.month;
	local day = d.day;
	
	isHalloween = (month == 10 and day == 31); -- this is halloween
end

local fg = {
	sndTime = 0,
	
	blinkPhase = false,
	blinkTime = 0,
	
	blinkW = 0,
	
	ended = true
};
foxyPos = {1284 - 586, 450 + 318};
function makeOffice()
	makeLuaSprite('bg', office .. 'backdrop');
	setCam('bg');
	addLuaSprite('bg');
	
	makeLuaSprite('springWindow', office .. 'o/a/b/spWindow', 1476, 414);
	addToOffsets('springWindow', 149, 357);
	setCam('springWindow');
	addLuaSprite('springWindow');
	setAlpha('springWindow', 0.00001);
	
	makeLuaSprite('mangleWindow', office .. 'o/a/b/mangleWindow', 1118, 512);
	addToOffsets('mangleWindow', 83, 103);
	setCam('mangleWindow');
	addLuaSprite('mangleWindow');
	setAlpha('mangleWindow', 0.00001);
	
	makeAnimatedLuaSprite('springWalk', office .. 'o/a/b/spRun', 1476 - 291, 414 + 348);
	addAnimationByPrefix('springWalk', 'run', 'Run', 30);
	addToOffsets('springWalk', 125, 767);
	playAnim('springWalk', 'run', true);
	setCam('springWalk');
	addLuaSprite('springWalk');
	setAlpha('springWalk', 0.00001);
	
	makeAnimatedLuaSprite('freddyWalk', office .. 'o/a/b/fWalk', 599, 414 - 297);
	addAnimationByPrefix('freddyWalk', 'walk', 'Walk', 18);
	addAnimationByPrefix('freddyWalk', 'fall', 'Fall', 24, false);
	playAnim('freddyWalk', 'walk', true);
	setFinFunc('freddyWalk', 'fredFinFall');
	setCam('freddyWalk');
	addLuaSprite('freddyWalk');
	setAlpha('freddyWalk', 0.00001);
	
	
	makeAnimatedLuaSprite('office', office .. 'office');
	addAnimationByPrefix('office', 'office', 'Office', 1);
	addAnimationByPrefix('office', 'red', 'Red', 1);
	playAnim('office', 'office', true);
	setCam('office');
	addLuaSprite('office');
	
	makeButtonOffice();
	
	makeAnimatedLuaSprite('fan', office .. 'o/fan', 1284 - 106, 450 - 170);
	addAnimationByPrefix('fan', 'fan', 'Fan', 30);
	playAnim('fan', 'fan', true);
	setCam('fan');
	addLuaSprite('fan');
	
	makeLuaSprite('cupcake', office .. 'o/a/cupcake', 1756 - 34, 406 - 53);
	setCam('cupcake');
	addLuaSprite('cupcake');
	
	if curNight == 5 then
		makeLuaSprite('dark', office .. 'o/a/dark', 1819 - 27, 387 - 83);
		setCam('dark');
		addLuaSprite('dark');
	end
	
	
	makeAnimatedLuaSprite('springHide', office .. 'o/a/hide', 445, 415);
	addAnimationByPrefix('springHide', 'hide', 'Hide', 30, false);
	addOffset('springHide', 'hide', 269, 275);
	playAnim('springHide', 'hide', true);
	setCam('springHide');
	hideOnFin('springHide');
	addLuaSprite('springHide');
	setAlpha('springHide', 0.00001);
	
	makeLuaSprite('springHead', office .. 'o/a/head', 128 + 3, 292 - 110);
	setCam('springHead');
	addLuaSprite('springHead');
	setAlpha('springHead', 0.00001);
	
	makeLuaSprite('shadowFreddy', office .. 'o/a/shadowFreddy', -1, 770 - 544);
	setCam('shadowFreddy');
	addLuaSprite('shadowFreddy');
	setAlpha('shadowFreddy', 0.00001);
	
	makePaperpals();
	makeHalloween();
	
	makeAnimatedLuaSprite('foxyOffice', 'gameAssets/Jumpscares/foxy', foxyPos[1] - 156, foxyPos[2] - 708);
	addAnimationByPrefix('foxyOffice', 'idle', 'Idle', 1);
	addAnimationByPrefix('foxyOffice', 'scare', 'Scare', 24, false);
	playAnim('foxyOffice', 'idle', true);
	setFinFunc('foxyOffice', 'endScareFoxy');
	setCam('foxyOffice');
	addLuaSprite('foxyOffice');
	setAlpha('foxyOffice', 0.00001);
	
	makeAnimatedLuaSprite('chicaOffice', 'gameAssets/Jumpscares/chica', 4, 2);
	addAnimationByPrefix('chicaOffice', 'idle', 'Idle', 1);
	addAnimationByPrefix('chicaOffice', 'scare', 'Scare', 24, false);
	addOffset('chicaOffice', 'idle', -202, -114);
	addOffset('chicaOffice', 'scare', -19, 0);
	playAnim('chicaOffice', 'idle', true);
	setFinFunc('chicaOffice', 'endScareChica');
	setCam('chicaOffice');
	addLuaSprite('chicaOffice');
	setAlpha('chicaOffice', 0.00001);
	
	makeAnimatedLuaSprite('bbOffice', 'gameAssets/Jumpscares/bb', 0, 450 - 442);
	addAnimationByPrefix('bbOffice', 'idle', 'Idle', 1);
	addAnimationByPrefix('bbOffice', 'scare', 'Scare', 30, false);
	addOffset('bbOffice', 'idle', -302, -95);
	addOffset('bbOffice', 'scare', 0, 0);
	playAnim('bbOffice', 'idle', true);
	setFinFunc('bbOffice', 'endScareBB');
	setCam('bbOffice');
	addLuaSprite('bbOffice');
	setAlpha('bbOffice', 0.00001);
	
	makeAnimatedLuaSprite('bigScare', 'gameAssets/Jumpscares/sp/bigScare');
	addAnimationByPrefix('bigScare', 'scare', 'Scare', 30, false);
	playAnim('bigScare', 'scare', true);
	hideOnFin('bigScare');
	setCam('bigScare');
	addLuaSprite('bigScare');
	setAlpha('bigScare', 0.00001);
	
	makeAnimatedLuaSprite('scare1', 'gameAssets/Jumpscares/sp/s/scare1');
	addAnimationByPrefix('scare1', 'scare', 'Scare', 36, false);
	playAnim('scare1', 'scare', true);
	setFinFunc('scare1', 'endOfScare');
	setCam('scare1', 'marionCam');
	addLuaSprite('scare1');
	setAlpha('scare1', 0.00001);
	
	makeAnimatedLuaSprite('scare2', 'gameAssets/Jumpscares/sp/s/scare2');
	addAnimationByPrefix('scare2', 'scare', 'Scare', 36, false);
	playAnim('scare2', 'scare', true);
	setFinFunc('scare2', 'endOfScare');
	setCam('scare2', 'marionCam');
	addLuaSprite('scare2');
	setAlpha('scare2', 0.00001);
	
	makeLuaSprite('scrnCen', 'active', xCam, 382 - 15);
	setCam('scrnCen');
	addLuaSprite('scrnCen');
	setVis('scrnCen', false);
	
	makeLuaSprite('noseBox', HITBOX, 672 - 6, 270 - 6);
	scaleObject('noseBox', 13, 13);
	setCam('noseBox');
end

function makeButtonOffice()
	if curNight ~= 4 then return; end
	
	for i = 1, #offKeyPos do
		local t = 'keyOffice' .. i;
		local p = offKeyPos[i];
		
		makeLuaSprite(t, nil, p[1] - 30, p[2] - 30);
		makeGraphic(t, 1, 1, '000008');
		scaleObject(t, 64, 64);
		setCam(t, 'mainCam');
		addLuaSprite(t);
		setAlpha(t, 0.00001);
	end
end

function makePaperpals()
	makeLuaSprite('paperpal1', office .. 'o/a/p/paperpal1', 1758 - 59, 197 - 164);
	setCam('paperpal1');
	addLuaSprite('paperpal1');
	setAlpha('paperpal1', 0.00001);
	
	makeLuaSprite('paperpal2', office .. 'o/a/p/paperpal2', 677 - 41, 335 - 151);
	setCam('paperpal2');
	addLuaSprite('paperpal2');
	setAlpha('paperpal2', 0.00001);
end

function makeHalloween()
	if not isHalloween then return; end -- its almost spooky month time to get spooky
	
	makeAnimatedLuaSprite('pumpsuki', office .. 'o/h/pump', 1632 - 73, 461 - 154);
	addAnimationByPrefix('pumpsuki', 'pumpkin', 'Pump', 15);
	playAnim('pumpsuki', 'pumpsuki', true);
	setCam('pumpsuki');
	addLuaSprite('pumpsuki');
	
	makeLuaSprite('lightsH', office .. 'o/h/lights');
	setCam('lightsH');
	addLuaSprite('lightsH');
end

function makeScares()
	makeAnimatedLuaSprite('fredScare', 'gameAssets/Jumpscares/freddy');
	addAnimationByPrefix('fredScare', 'unFin', 'Scare0001', 1);
	addAnimationByPrefix('fredScare', 'scare', 'Scare', 30, false);
	addOffset('fredScare', 'scare', 41, 2);
	playAnim('fredScare', 'unFin', true);
	setFinFunc('fredScare', 'endScareFred');
	setCam('fredScare');
	addLuaSprite('fredScare');
	setAlpha('fredScare', 0.00001);
	
	makeAnimatedLuaSprite('puppetHead', night .. 'fx/puppet', 512, 770);
	addAnimationByPrefix('puppetHead', 'left', 'Left', 1);
	addAnimationByPrefix('puppetHead', 'lookRight', 'LookRight', 30, false);
	addAnimationByPrefix('puppetHead', 'right', 'Right', 1);
	addOffset('puppetHead', 'left', 400, 768);
	addOffset('puppetHead', 'lookRight', 400, 768);
	addOffset('puppetHead', 'right', 400, 768);
	playAnim('puppetHead', 'left', true);
	setCam('puppetHead', 'marionCam');
	addLuaSprite('puppetHead');
	setAlpha('puppetHead', 0.00001);
	
	
	makeAnimatedLuaSprite('whiteFlash', night .. 'fx/flash');
	addAnimationByPrefix('whiteFlash', 'freddy', 'Freddy', 0);
	addAnimationByPrefix('whiteFlash', 'chica', 'Chica', 0);
	addAnimationByPrefix('whiteFlash', 'foxy', 'Foxy', 0);
	addAnimationByPrefix('whiteFlash', 'bb', 'BB', 0);
	playAnim('whiteFlash', 'freddy', true);
	setCam('whiteFlash', 'flashCam');
	addLuaSprite('whiteFlash');
	setAlpha('whiteFlash', 0.00001);
end

function makePanel()
	makeSys();
	makeView();
end

function makeSys()
	makeAnimatedLuaSprite('panelSys', panel .. 'restart/panel', 552, 780);
	addAnimationByPrefix('panelSys', 'flip', 'Opening', 30, false);
	addAnimationByPrefix('panelSys', 'open', 'Opened', 1);
	addOffset('panelSys', 'flip', 499, 610);
	addOffset('panelSys', 'open', 499, 610);
	playAnim('panelSys', 'open', true);
	setFinFunc('panelSys', 'panelSysFin');
	setCam('panelSys', 'panelCam');
	addLuaSprite('panelSys');
	setAlpha('panelSys', 0.00001);
	
	makeSysHud();
end

systems = {
	audio = {
		prog = 0,
		
		lureNum = 1,
		lureTime = 0,
		
		shownErr = false
	},
	video = {
		prog = 0,
		
		inCamTime = 0,
		
		hidCams = false
	},
	vent = {
		prog = 0,
		
		maxTime = 0,
		addTime = 0,
		
		offNum = 0,
		offTime = 0,
		offToSub = 0,
		
		expoTime = 0,
		
		startedHigh = false,
		highTime = 0,
		
		shownErr = false
	},
};
function makeSysHud()
	makeLuaSprite('restTitle', sysHud .. 'sysreset', 116, 260 - 36);
	setCam('restTitle', 'sysCam');
	addLuaSprite('restTitle');
	
	
	makeLuaSprite('sel', sysHud .. 'cursor', 157, 380);
	addToOffsets('sel', 36, 15);
	setCam('sel', 'sysCam');
	addLuaSprite('sel');
	
	
	makeLuaSprite('audioSys', sysHud .. 'audio', 206, 376 - 19);
	setCam('audioSys', 'sysCam');
	addLuaSprite('audioSys');
	
	makeLuaSprite('videoSys', sysHud .. 'cam', 206, 437 - 20);
	setCam('videoSys', 'sysCam');
	addLuaSprite('videoSys');
	
	makeLuaSprite('ventSys', sysHud .. 'vent', 206, 490 - 19);
	setCam('ventSys', 'sysCam');
	addLuaSprite('ventSys');
	
	makeLuaSprite('allSys', sysHud .. 'all', 206, 597 - 19);
	setCam('allSys', 'sysCam');
	addLuaSprite('allSys');
	
	
	makeAnimatedLuaSprite('errAudSys', sysHud .. 'err', 506, 379 - 17);
	addAnimationByPrefix('errAudSys', 'err', 'Err', 6);
	playAnim('errAudSys', 'err', true);
	setCam('errAudSys', 'sysCam');
	addLuaSprite('errAudSys');
	setAlpha('errAudSys', 0.00001);
	
	makeAnimatedLuaSprite('errVidSys', sysHud .. 'err', 506, 435 - 17);
	addAnimationByPrefix('errVidSys', 'err', 'Err', 6);
	playAnim('errVidSys', 'err', true);
	setCam('errVidSys', 'sysCam');
	addLuaSprite('errVidSys');
	setAlpha('errVidSys', 0.00001);
	
	makeAnimatedLuaSprite('errVentSys', sysHud .. 'err', 506, 492 - 17);
	addAnimationByPrefix('errVentSys', 'err', 'Err', 6);
	playAnim('errVentSys', 'err', true);
	setCam('errVentSys', 'sysCam');
	addLuaSprite('errVentSys');
	setAlpha('errVentSys', 0.00001);
	
	
	makeAnimatedLuaSprite('sysProg', sysHud .. 'progress', 157 + 355, 380);
	addAnimationByPrefix('sysProg', 'prog', 'Prog', 6);
	addOffset('sysProg', 'prog', 0, 22);
	playAnim('sysProg', 'prog', true);
	setCam('sysProg', 'sysCam');
	addLuaSprite('sysProg');
	setAlpha('sysProg', 0.00001);
	
	
	makeLuaSprite('exitSys', sysHud .. 'exit', 206, 646 - 19);
	setCam('exitSys', 'sysCam');
	addLuaSprite('exitSys');
end

function makeView()
	makeAnimatedLuaSprite('panelView', panel .. 'cams/panel', 1024, 382);
	addAnimationByPrefix('panelView', 'flip', 'Opening', 30, false);
	addAnimationByPrefix('panelView', 'open', 'Opened', 1);
	addOffset('panelView', 'flip', 873, 307);
	addOffset('panelView', 'open', 873, 307);
	playAnim('panelView', 'open', true);
	setFinFunc('panelView', 'panelViewFin');
	setCam('panelView', 'panelCam');
	addLuaSprite('panelView');
	setAlpha('panelView', 0.00001);
	
	makeViewHud();
end

local static = {
	A = 0,
	B = 0,
	E = 0,
	F = 0
};
function makeViewHud()
	makeCams();
	makeArcadeKey();
	makeCups();
	
	makeLuaSprite('bbPeek', viewHud .. 'cams/bb', 1148, 90);
	setCam('bbPeek', 'camCam');
	addLuaSprite('bbPeek');
	
	makeAnimatedLuaSprite('static', viewHud .. 'static', 1144, 88);
	addAnimationByPrefix('static', 'static', 'Static', 30);
	playAnim('static', 'static', true);
	setCam('static', 'camCam');
	addLuaSprite('static');
	
	makeAnimatedLuaSprite('blip', viewHud .. 'blip', 1144, 88);
	addAnimationByPrefix('blip', 'blip', 'Blip', 30, false);
	playAnim('blip', 'blip', true);
	hideOnFin('blip');
	setCam('blip', 'camCam');
	addLuaSprite('blip');
	setAlpha('blip', 0.00001);
	
	makeAnimatedLuaSprite('map', viewHud .. 'map', 1770 - 211, 560 - 200);
	addAnimationByPrefix('map', 'main', 'Cam', 1);
	addAnimationByPrefix('map', 'vent', 'Vent', 1);
	setFrameRate('map', 'main', 1.8);
	setFrameRate('map', 'vent', 1.8);
	playAnim('map', 'main', true);
	setCam('map', 'camCam');
	addLuaSprite('map');
	
	makeLuaSprite('sealInfoTxt', viewHud .. 'click', 1527, 334);
	addToGrp('sealInfoTxt', 'ventCamsMark');
	
	makeLuaSprite('sealTxt', viewHud .. 'seal', 1528, 336);
	addToGrp('sealTxt', 'ventCamsMark');
	setAlpha('sealTxt', 0.00001);
	
	makeAnimatedLuaSprite('sealProg', sysHud .. 'progress', 1799, 717 - 22);
	addAnimationByPrefix('sealProg', 'prog', 'Prog', 6);
	playAnim('sealProg', 'prog', true);
	addToGrp('sealProg', 'ventCamsMark');
	setAlpha('sealProg', 0.00001);
	
	
	makeLuaSprite('bbDouble', HITBOX, 1217 - 21, 324 - 21);
	scaleObject('bbDouble', 42, 42);
	setCam('bbDouble', 'camCam');
	
	makeLuaSprite('puppetDouble', HITBOX, 1809 - 18, 241 - 23);
	scaleObject('puppetDouble', 37, 46);
	setCam('puppetDouble', 'camCam');
	
	
	makeAnimatedLuaSprite('audErrView', viewHud .. 'err/audio', 1190, 143 + 16);
	addAnimationByPrefix('audErrView', 'err', 'Audio', 3);
	playAnim('audErrView', 'err', true);
	setCam('audErrView', 'camCam');
	addLuaSprite('audErrView');
	setAlpha('audErrView', 0.00001);
	
	makeAnimatedLuaSprite('vidErrView', viewHud .. 'err/video', 1190, 176 + 16);
	addAnimationByPrefix('vidErrView', 'err', 'Video', 3);
	playAnim('vidErrView', 'err', true);
	setCam('vidErrView', 'camCam');
	addLuaSprite('vidErrView');
	setAlpha('vidErrView', 0.00001);
	
	makeAnimatedLuaSprite('ventErrView', viewHud .. 'err/vent', 1190, 209 + 16);
	addAnimationByPrefix('ventErrView', 'err', 'Vent', 3);
	playAnim('ventErrView', 'err', true);
	setCam('ventErrView', 'camCam');
	addLuaSprite('ventErrView');
	setAlpha('ventErrView', 0.00001);
	
	makeSelView();
	makeMarkers();
end

function makeArcadeKey()
	if curNight ~= 2 then return; end
	
	for i = 1, 4 do
		local b = arcadeKeyPos[i];
		local t = 'keyArc' .. i;
		
		makeLuaSprite(t, viewHud .. 'cams/circ', b[1] - 11, b[2] - 9);
		addToGrp(t, 'mainCamsGrp');
		setAlpha(t, 0.00001);
	end
end

local cupToMake = {
	{3, 1, {1678 - 30, 360 - 59}},
	{6, 1, {1440 - 30, 314 - 59}},
	{2, 3, {1552 - 15, 426 - 30}},
	{4, 4, {1456 - 20, 430 - 39}}
};
function makeCups()
	if curNight ~= 3 then 
		for i in pairs(cupInCam) do
			cupInCam[i] = false;
		end
		
		return;
	end
	
	for i = 1, #cupToMake do
		local c = cupToMake[i];
		local t = 'cupScrn' .. c[1];
		
		makeLuaSprite(t, viewHud .. 'cams/cup/' .. c[2], c[3][1], c[3][2]);
		addToGrp(t, 'mainCamsGrp');
		setAlpha(t, 0.00001);
	end
end

local addForCam = {
	[1] = function(c)
		addAnimationByPrefix(c, '', 'ExitGlow', 0);
		addAnimationByPrefix(c, 'SP', 'Spring', 0);
	end,
	[2] = function(c)
		addAnimationByPrefix(c, '', 'Flicker', 3);
		addAnimationByPrefix(c, 'special', 'Special', 3);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 3);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 3);
	end,
	[3] = function(c)
		addAnimationByPrefix(c, '', 'Cam', 0);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 0);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 0);
	end,
	[4] = function(c)
		addAnimationByPrefix(c, '', 'Cam', 0);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 0);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 0);
		addAnimationByPrefix(c, 'specialA', 'SpecialA', 0);
		addAnimationByPrefix(c, 'specialB', 'SpecialB', 0);
		addAnimationByPrefix(c, 'mangle', 'Mangle', 0);
	end,
	[5] = function(c)
		addAnimationByPrefix(c, '', 'Flicker', 30);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 30);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 30);
	end,
	[6] = function(c)
		addAnimationByPrefix(c, '', 'Flicker', 30);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 30);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 30);
	end,
	[7] = function(c)
		addAnimationByPrefix(c, '', 'Flicker', 15);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 15);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 15);
		addAnimationByPrefix(c, 'chica', 'Chica', 15);
	end,
	[8] = function(c)
		addAnimationByPrefix(c, '', 'Flicker', 15);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 15);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 15);
		addAnimationByPrefix(c, 'puppet', 'Puppet', 15);
	end,
	[9] = function(c)
		addAnimationByPrefix(c, '', 'Cam', 0);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 0);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 0);
	end,
	[10] = function(c)
		addAnimationByPrefix(c, '', 'Cam', 0);
		addAnimationByPrefix(c, 'SP1', 'SpringA', 0);
		addAnimationByPrefix(c, 'SP2', 'SpringB', 0);
		addAnimationByPrefix(c, 'special', 'Special', 0);
	end
};
function makeCams()
	setCam('mainCamsGrp', 'camCam');
	addLuaSprite('mainCamsGrp');
	
	setCam('ventCamsGrp', 'camCam');
	addLuaSprite('ventCamsGrp');
	
	for i = 1, 15 do
		local isVent = i >= 11;
		local cam = 'camScreen' .. i;
		makeAnimatedLuaSprite(cam, viewHud .. 'cams/cams/' .. i, 1144, 88);
		
		if not isVent then
			local toAdd = addForCam[i];
			if toAdd then toAdd(cam); end
		else
			addAnimationByPrefix(cam, '', 'Cam', 0);
			addAnimationByPrefix(cam, 'SP', 'Spring', 0);
		end
		
		playAnim(cam, '', true);
		addToGrp(cam, (isVent and 'ventCamsGrp' or 'mainCamsGrp'));
		setAlpha(cam, 0.00001);
		
		if isVent then
			ins(ventProps, i, {
				hallu = false,
				
				spIn = false,
				sealed = false,
				trails = 0,
				trailTime = 0
			});
		else
			ins(cameraProps, {
				hallu = false,
				
				spIn = false,
				curIn = '';
				trails = 0,
				trailTime = 0
			});
		end
	end
end

function makeSelView()
	setCam('lureGrp', 'camCam');
	addLuaSprite('lureGrp');
	
	makeLuaSprite('selAud', viewHud .. 'cams/markers/pressBig', 1507 - 57, 578 - 34);
	addToGrp('selAud', 'lureGrp');
	setAlpha('selAud', 0.00001);
	
	makeLuaSprite('audTxt', viewHud .. 'cams/markers/names/play', 1461 + 3, 555 + 2);
	addToGrp('audTxt', 'lureGrp');
	setAlpha('audTxt', 0.00001);
	
	makeAnimatedLuaSprite('audInd', viewHud .. 'cams/markers/play', 1434, 577 + 22);
	addAnimationByPrefix('audInd', 'try', 'Try', 0, false);
	playAnim('audInd', 'try', true);
	addToGrp('audInd', 'lureGrp');
	
	
	makeLuaSprite('selVent', viewHud .. 'cams/markers/pressBig', 1507 - 57, 659 - 34);
	setCam('selVent', 'camCam');
	addLuaSprite('selVent');
	
	makeLuaSprite('ventTxt', viewHud .. 'cams/markers/names/toggle', 1458 + 3, 635 + 2);
	setCam('ventTxt', 'camCam');
	addLuaSprite('ventTxt');
end

local markerPos = {
	{
		mark = {1644, 676},
		name = {1619, 662},
		arrow = {'RIGHT', 1672, 677}
	},
	{
		mark = {1859, 648},
		name = {1835, 634},
		arrow = {'UP', 1846, 636}
	},
	{
		mark = {1940, 606},
		name = {1916, 592},
		arrow = {'LEFT', 1915, 608}
	},
	{
		mark = {1940, 541},
		name = {1917, 527},
		arrow = {'LEFT', 1917, 541}
	},
	{
		mark = {1776, 557},
		name = {1753, 543}
	},
	{
		mark = {1637, 565},
		name = {1614, 551},
		arrow = {'RIGHT', 1661, 565}
	},
	{
		mark = {1637, 499},
		name = {1614, 485},
		arrow = {'RIGHT', 1662, 501}
	},
	{
		mark = {1742, 477},
		name = {1719, 463},
		arrow = {'DOWN', 1737, 493}
	},
	{
		mark = {1808, 434},
		name = {1785, 421},
		arrow = {'DOWN', 1803, 450}
	},
	{
		mark = {1916, 470},
		name = {1894, 456},
		arrow = {'LEFT', 1892, 474}
	},
	
	{
		mark = {1641, 406},
		name = {1619, 392},
		arrow = {'DOWN', 1644, 421},
		seal = {1616, 465}
	},
	{
		mark = {1703, 524},
		name = {1681, 510},
		arrow = {'LEFT', 1678, 523},
		seal = {1645, 537}
	},
	{
		mark = {1788, 584},
		name = {1767, 570},
		arrow = {'LEFT', 1766, 587},
		seal = {1737, 597}
	},
	{
		mark = {1873, 504},
		name = {1850, 490},
		arrow = {'RIGHT', 1899, 504},
		seal = {1925, 568}
	},
	{
		mark = {1898, 644},
		name = {1875, 630},
		seal = {1847, 668}
	}
};
local arrowOff = {
	['LEFT'] = {26, 10},
	['DOWN'] = {11, 14},
	['UP'] = {10, 26},
	['RIGHT'] = {13, 10}
};
function makeMarkers()
	setCam('mainCamsMark', 'camCam');
	addLuaSprite('mainCamsMark');
	
	setCam('ventCamsMark', 'camCam');
	addLuaSprite('ventCamsMark');
	
	for i = 1, 15 do
		local isVent = i >= 11;
		local grp = (isVent and 'ventCamsMark' or 'mainCamsMark');
		local curMark = markerPos[i];
		
		if curMark.arrow then
			local arrow = curMark.arrow;
			local dir = arrow[1];
			local off = arrowOff[dir];
			
			local t = 'arrow' .. i;
			makeLuaSprite(t, viewHud .. 'cams/markers/arrows/' .. dir, arrow[2], arrow[3]);
			addToOffsets(t, off[1], off[2]);
			addToGrp(t, grp);
		end
		
		if curMark.seal then
			local s = 'ventSeal' .. i;
			local seal = curMark.seal;
			makeAnimatedLuaSprite(s, viewHud .. 'cams/markers/ventSeal', seal[1], seal[2]);
			addAnimationByPrefix(s, 'open', 'Grn', 0);
			addAnimationByPrefix(s, 'close', 'Red', 0);
			addOffset(s, 'open', 20, 13);
			addOffset(s, 'close', 20, 13);
			playAnim(s, 'open', true);
			addToGrp(s, grp);
		end
		
		local m = 'mark' .. i;
		local marker = curMark.mark;
		makeAnimatedLuaSprite(m, viewHud .. 'cams/markers/marker', marker[1] - 29, marker[2] - 19);
		addAnimationByPrefix(m, 'idle', 'Idle', 0);
		addAnimationByPrefix(m, 'glow', 'Glow', 0);
		playAnim(m, 'idle', true);
		addToGrp(m, grp);
		
		local n = 'markName' .. i;
		local name = curMark.name;
		makeLuaSprite(n, viewHud .. 'cams/markers/names/cams/' .. i, name[1] + (i >= 10 and 1 or 2), name[2] + 2);
		addToGrp(n, grp);
	end
	
	makeAnimatedLuaSprite('lureSpr', viewHud .. 'cams/markers/radar', 1500, 200);
	addAnimationByPrefix('lureSpr', 'lure', 'Radar', 1, false);
	addOffset('lureSpr', 'lure', 108, 43);
	setFrameRate('lureSpr', 'lure', 1.8);
	playAnim('lureSpr', 'lure', true);
	hideOnFin('lureSpr');
	addToGrp('lureSpr', 'mainCamsMark');
	
	if cheats.radar then
		makeLuaSprite('spPos', viewHud .. 'spPos', 1300, 200);
		addToOffsets('spPos', 6, 6);
		setCam('spPos', 'camCam');
		addLuaSprite('spPos');
	end
end

function makeHud()
	makeLuaSprite('flipRight', hud .. 'flip/flip', 200 - 46, 233 - 140);
	setCam('flipRight', 'flickCam');
	addLuaSprite('flipRight');
	setAlpha('flipRight', 0.00001);
	
	makeLuaSprite('flipDown', hud .. 'flip/flip2', 426 - 126, 725 - 27);
	setCam('flipDown', 'flickCam');
	addLuaSprite('flipDown');
	setAlpha('flipDown', clAlph(150));
	
	
	
	makeLuaSprite('nightTxt', hud .. 'txt/night', 914, 14);
	setCam('nightTxt', 'hudCam');
	addLuaSprite('nightTxt');
	
	makeCounterSpr('night', 1002, 32, curNight);
	setCam('night', 'hudCam');
	addLuaSprite('night');
	
	
	makeLuaSprite('amTxt', hud .. 'txt/am', 980, 49);
	setCam('amTxt', 'hudCam');
	addLuaSprite('amTxt');
	
	makeCounterSpr('hour', 968, 65, curHour);
	setCam('hour', 'hudCam');
	addLuaSprite('hour');
	
	if curNight < 7 then
		makeLuaSprite('muteButton', hud .. 'mute', 114 - 96, 44 - 22);
		setCam('muteButton', 'hudCam');
		addLuaSprite('muteButton');
		setAlpha('muteButton', clAlph(150));
		
		canMute = true;
		
		doSound('call/' .. curNight, 1, 'callSfx');
		runTimer('hideMute', pl(30));
	end
	
	makeLuaSprite('clock', hud .. 'clock', 986 - 20, 733 - 18);
	setCam('clock', 'hudCam');
	addLuaSprite('clock');
end

local tickRate = 0;
local frameSec = 1 / 60;

local waitingDouble = false;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	if doing6AM then
		if canUpdateWin then update6AM(e, ti); end
	
		return Function_StopLua;
	end
	
	if frameActive and canMute and mouseClicked() and mouseOverlaps('muteButton') then
		canMute = false;
		doSound('stop', 1, 'callSfx');
		setVis('muteButton', false);
	end
	
	if marionActive then blackout.setTime = 100; end
	
	if cheats.noErr then
		local sys = systems;
		
		sys.audio.prog = 0;
		sys.video.prog = 0;
		sys.vent.prog = 0;
	end
	
	updateGotYou(e, ti);
	moveCam(e, ti);
	updateReboot(e, ti);
	updateSystems(e, ti);
	updateStatic(e, ti);
	updateBreathing(e, ti);
	updateBlackout(e, ti);
	updateOffice(e, ti);
	
	local ticks = 0;
	tickRate = tickRate + e;
	while (tickRate >= frameSec) do
		tickRate = tickRate - frameSec;
		ticks = ticks + 1;
	end
	
	callOnLuas('updateFunc', {e, ti, ticks});
	
	if nearPhase > 0 and not getVar('springEerie') and not getVar('goldenEerie') and not getVar('chicaEerie') then
		nearPhase = 0;
	end
	
	if lastNear ~= nearPhase then
		lastNear = nearPhase;
		
		setSoundVolume('dangerSnd', 0.5 * nearPhase);
	end
	
	if mouseClicked() then waitingDouble = true; runTimer('clickDoubleOff', 0.3); end
	
	return Function_StopLua;
end

local startedGot = false;
local madeScare = false;
function updateGotYou(e, t)
	local got = getVar('gotYou');
	if got == 0 then return; end
	
	if not madeScare then
		madeScare = true;
		
		callOnLuas('stopEverything');
		
		canMute = false;
		setAlpha('muteButton', 0);
		
		if got == 1 then
			setAlpha('scare1', 1);
			playAnim('scare1', 'scare', true);
		else
			setAlpha('scare2', 1);
			playAnim('scare2', 'scare', true);
			setX('scare2', 1024);
		end
	end
	
	frozen = false;
	dropItAll();
	
	if not startedGot then
		startedGot = true;
		runTimer('startScream', pl(2 / 6));
	end
	
	hitMid();
	
	if got == 1 then
		if xCam > 512 then
			xCam = max(xCam - (20 * t), 512);
		end
		
		local vent = systems.vent;
		vent.prog = 0;
		vent.offNum = 0;
	end
	
	if blackout.alph > 0 then
		blackout.alph = max(blackout.alph - (10 * t), 0);
	end
end

function updateShake(t)
	local sc = scrollShake;
	
	if not sc.started then return; end
	
	local speedShift = floor(60 * t * 32);
	local x = (sc.off * 65536) + band(sc.cal, 0x0000FFFF);
	x = x + (sc.dir * speedShift);
	
	sc.cal = band(x, 0x0000FFFF);
	sc.off = floor(x / 65536);
end

function addTrailOnCam(i)
	local cam = (i > 10 and ventProps[i] or cameraProps[i]);
	
	cam.trails = cam.trails + 1;
end

function staticAddMove()
	static.E = static.E + 100;
	static.F = 50 + Random(100);
	
	setAlpha('static', 1);
	
	updateACam();
end

function setStaticProp(p, e)
	static[p] = e;
end

function updateStatic(e, t)
	local s = static;
	
	s.F = s.F - t;
	
	if s.E > 0 then
		s.E = s.E - t;
	end
	if s.E > 5 then
		s.E = s.E - (t * 5);
	end
	
	s.E = max(s.E, 0);
	
	if s.F > 0 then
		if actualLooking == getVar('springCam') then
			s.E = 200;
		end
		
		local toLook = (actualLooking > 10 and ventProps[curVent] or cameraProps[curCam]);
		if toLook.trails > 0 then s.E = 250; end
	end
	
	for i = 1, 15 do
		local cam = (i > 10 and ventProps[i] or cameraProps[i]);
		if cam.trails > 0 then
			cam.trailTime = cam.trailTime + e;
			while cam.trailTime >= 5 do
				cam.trailTime = cam.trailTime - 5;
				cam.trails = cam.trails - 1;
				callOnLuas('subTrail');
			end
		end
	end
	
	if viewingCams then
		local al = Random(30) + s.B + s.E + 30;
		s.A = al;
		
		setAlpha('static', clAlph(250 - al));
	end
end

xCam = 512;
local lastCamX = 0;

local lastMX = -384;
local marionX = -384;
local camMoves = {
	{
		x = 242,
		p = -8
	},
	
	{
		x = 352,
		p = 0
	},
	
	{
		x = 664,
		p = 8
	},
	{
		x = 756,
		p = 16
	}
};
function moveCam(e, t)
	updateShake(t);
	
	if frozen then
		local frX = bound(scrollShake.off, 512, 1488);
		
		runHaxeFunction('updateScroll', {frX});
	elseif viewingAPanel then
		updatePanel(e, t);
	elseif frameActive then
		if getVar('gotYou') == 0 then
			local camSpd = -16; -- so we can ignore the first one :)
			local m = camMouseX();
			
			for i = 1, #camMoves do
				if m > camMoves[i].x then
					camSpd = camMoves[i].p;
				else break; end
			end
			
			if marionActive then camSpd = camSpd / 4; end
			
			xCam = bound(xCam + (camSpd * t), 512, 1488);
			
			if lastCamX ~= xCam then
				lastCamX = xCam;
				checkHitSides();
			end
		end
		
		runHaxeFunction('updateScroll', {xCam});
		
		if clickOffice and mouseClicked() then officeClick(); end
	end
	
	if marionActive and blackout.alph > 210 then
		if marionX < xCam - 25 then
			marionX = marionX + (25 * t);
		end
		
		if marionX > xCam + 25 then
			marionX = marionX - (25 * t);
		end
		
		if lastMX ~= marionX then
			lastMX = marionX;
			
			setX('puppetHead', marionX);
		end
	end
end

function officeClick()
	if not frameActive then return; end
	
	if seeDown and mouseOverlaps('flipDown') then
		triggerSysPanel();
	elseif seeRight and mouseOverlaps('flipRight', 'mainCam') then
		triggerViewPanel();
	else
		checkHitOffice();
	end
end

local clickDark = 0;
local codeOffice = {
	3,
	9,
	5,
	2,
	4,
	8
};
local curCodeOff = {};
local codeNum = 1;
local nightClickOffice = {
	[4] = function()
		for i = 1, #offKeyPos do
			local t = 'keyOffice' .. i;
			if mouseOverlaps(t, 'mainCam') then
				setVis(t, true);
				runTimer('visButton_' .. t, pl(5 / 60));
				
				if i == 3 then codeNum = 1; end
				clickCodeOffice(i);
				
				break;
			end
		end
	end,
	[5] = function()
		if mouseOverlaps('dark', 'mainCam') then
			clickDark = clickDark + 1;
			if waitingDouble and clickDark >= 2 then
				switchState('RWQFSFASXC');
			end
		else
			clickDark = 0;
		end
	end
};
function checkHitOffice()
	if mouseOverlaps('noseBox', 'mainCam') then
		doSound('PartyFavorraspyPart_AC01__3', 1, 'honkSnd');
		return;
	end
	
	local n = nightClickOffice[curNight];
	if n then n(); end
end

function clickCodeOffice(i)
	curCodeOff[codeNum] = i;
	codeNum = (codeNum % 6) + 1;
	
	checkCodeOffice();
end

function checkCodeOffice()
	if #curCodeOff < 6 then return; end
	
	for i = 1, 6 do
		if curCodeOff[i] ~= codeOffice[i] then return; end
	end
	
	switchState('GFreddy');
end

function updatePanel(e, t)
	if viewingLittle then
		updateSys(e, t);
	elseif viewingCams then
		updateView(e, t);
	end
end

local toCheckHover = {'audioSys', 'videoSys', 'ventSys', 'allSys', 'exitSys'};
local errName = {'errAudSys', 'errVidSys', 'errVentSys'};
local hoverNum = 1;
local curHover = 'audioSys';

local beepSec = 0;
local progSec = 0;
function updateSys(e, t)
	if not rebooting then
		for i = 1, #toCheckHover do
			local check = toCheckHover[i];
			if curHover ~= check and mouseOverlaps(check) then
				hoverNum = i;
				selSys(check);
				
				break;
			end
		end
		
		if keyboardJustPressed('UP') or keyboardJustPressed('W') then 
			hoverNum = wrap(hoverNum - 1, 1, #toCheckHover);
			selSys(toCheckHover[hoverNum]);
		elseif keyboardJustPressed('DOWN') or keyboardJustPressed('S') then
			hoverNum = wrap(hoverNum + 1, 1, #toCheckHover);
			selSys(toCheckHover[hoverNum]);
		end
	end
	
	if mouseClicked() then
		if canCloseSys and mouseOverlaps('exitSys') then
			triggerSysPanel();
		
			return;
		end
		
		if not rebooting and mouseOverlaps(curHover) then
			rebootASystem(curHover);
		end
	end
end

function selSys(i)
	local addY = 0;
	if i == 'videoSys' then addY = 1; end
	
	curHover = i;
	
	setY('sel', getY(curHover) + 19 + addY);
	
	doSound('select', 1, 'sysSnd', false, 'channel8');
end

function rebootASystem(i)
	if i == 'allSys' then
		rebootTime = 2;
		rebootAll = true;
	else
		rebootTime = 1;
		rebootAll = false;
		setAlpha(errName[hoverNum], 0);
	end
	
	setAlpha('sysProg', 1);
	setY('sysProg', getY('sel'));
	
	grpVol('channel8', 0.5);
	doSound('wait', 1, 'sysSnd', false, 'channel8');
	
	rebooting = true;
	canCloseSys = false;
end

function updateReboot(e, t)
	if rebooting then
		rebootSec = rebootSec + e;
		while rebootSec >= rebootTime do
			rebootSec = rebootSec - rebootTime;
			rebootProg = rebootProg + (1 + Random(2));
			
			if rebootProg >= 10 then
				local sys = systems;
				rebootProg = 0;
				canCloseSys = true;
				rebooting = false;
				
				if rebootAll then
					rebootAll = false;
					sys.audio.prog = 0;
					sys.video.prog = 0;
					sys.vent.prog = 0;
				else
					if hoverNum == 1 then
						sys.audio.prog = 0;
					elseif hoverNum == 2 then
						sys.video.prog = 0;
					else
						sys.vent.prog = 0;
					end
				end
				
				setAlpha('sysProg', 0);
			end
		end
		
		progSec = progSec + e;
		while progSec >= 1 do
			progSec = progSec - 1;
			setFrameRate('sysProg', 'prog', (2 + Random(10)) * 0.6);
		end
		
		beepSec = beepSec + e;
		while beepSec >= 2 do
			beepSec = beepSec - 2;
			
			doSound('wait', 1, 'sysSnd', false, 'channel8');
		end
	end
end

local totTapCam = 0;
local camTapped = 0;
local toggleCooled = true;

local arcCode = 0;

local bbClick = 0;
local pupClick = 0;
local updateFuncView = {
	[2] = function()
		if cupInCam[2] and mouseClicked() and mouseOverlaps('cupScrn2', 'mainCam') then
			killACake(2);
		end
	end,
	[3] = function()
		if mouseClicked() then
			if mouseOverlaps('puppetDouble', 'mainCam') then
				pupClick = pupClick + 1;
				if waitingDouble and pupClick >= 2 then
					switchState('Marion');
				end
			else
				pupClick = 0;
			end
			
			if cupInCam[3] and mouseOverlaps('cupScrn3', 'mainCam') then
				killACake(3);
			end
		end
	end,
	[4] = function(e, t)
		if cupInCam[4] and mouseClicked() and mouseOverlaps('cupScrn4', 'mainCam') then
			killACake(4);
		end
		
		if cameraProps[4].curIn == 'mangle' then
			mangleUpdateView(e, t);
		end
	end,
	[6] = function()
		if mouseClicked() and cupInCam[6] and mouseOverlaps('cupScrn6', 'mainCam') then
			killACake(6);
		end
	end,
	[7] = function(e, t)
		if curNight == 2 and mouseClicked() then
			for i = 1, 4 do
				local t = 'keyArc' .. i;
				if mouseOverlaps(t, 'mainCam') then
					setExists(t, true);
					runTimer('visButton_' .. t, pl(4 / 60));
					
					if i == 1 then arcCode = 1; end
					checkCodeArc(i);
					
					break;
				end
			end
		end
		
		if cameraProps[7].curIn == 'chica' then
			chicaUpdateView(e, t);
		end
	end,
	[8] = function(e, t)
		if mouseClicked() then
			if mouseOverlaps('bbDouble', 'mainCam') then
				bbClick = bbClick + 1;
				if waitingDouble and bbClick >= 2 then
					switchState('BB');
				end
			else
				bbClick = 0;
			end
		end
		
		if cameraProps[8].curIn == 'puppet' then
			marionUpdateView(e, t);
		end
	end
};
function updateView(e, t)
	if mouseClicked() then
		if mouseOverlaps('flipRight', 'mainCam') then
			triggerViewPanel();
			
			return;
		end
		
		mouseClickView();
	end
	
	ventProgUpdate(e, t);
	
	local up = updateFuncView[curCam];
	if up then up(e, t); end
	
	setSoundVolume('statSnd', (static.A / (curNight == 1 and 8 or 5)) / 100);
end

local funcArcKey = {
	[2] = function()
		arcCode = (arcCode == 2 and 3 or 0);
	end,
	[3] = function()
		arcCode = (arcCode == 1 and 2 or 0);
	end,
	[4] = function()
		if arcCode == 3 then switchState('Mangle'); end
	end
};
function checkCodeArc(i)
	if i == 1 then return; end
	funcArcKey[i]();
end

function killACake(i)
	removeLuaSprite('cupScrn' .. i);
	
	static.E = 200;
	cupInCam[i] = false;
	totCups = totCups - 1;
	if totCups == 0 then switchState('ToyChica'); end
end

function mouseClickView()
	if toggleCooled and mouseOverlaps('selVent', 'camCam') then
		toggleCooled = false;
		runTimer('coolToggle', pl(2 / 6));
		
		doSound('select', 1, 'toggleSnd');
		
		toggleView();
		
		return;
	end
	
	if not lookingVents and mouseOverlaps('selAud', 'camCam') then
		local aud = systems.audio;
		if aud.lureNum == 7 and aud.prog > -10 then
			aud.lureNum = 1;
			aud.prog = aud.prog - AI;
			
			setFrame('audInd', 0);
			setAlpha('audInd', 1);
			setAlpha('selAud', 0);
			setAlpha('audTxt', 0);
			
			doSound('echo/' .. getRandomInt(1, 3), 1, 'lureSnd');
			
			tryLure(curCam);
			
			return;
		end
	end
	
	local tappedACam = false;
	local beg = (lookingVents and 11 or 1);
	local en = (lookingVents and 15 or 10);
	
	for i = beg, en do
		if mouseOverlaps('mark' .. i, 'camCam') then
			tappedACam = true;
			
			if beg > 10 then
				if camTapped == i then
					totTapCam = totTapCam + 1;
					if totTapCam >= 2 and waitingDouble then
						totTapCam = 0;
						
						trySealCam(i);
						break;
					end
				else
					camTapped = i;
					totTapCam = 1;
				end
			end
			
			trySwitchCam(i);
			
			break;
		end
	end
	if not tappedACam then totTapCam = 0; end
end

function toggleView()
	lookingVents = not lookingVents;
	
	local view = not lookingVents;
	local vent = lookingVents;
	setVis('ventCamsGrp', vent);
	setVis('ventCamsMark', vent);
	
	setVis('mainCamsGrp', view);
	setVis('mainCamsMark', view);
	setVis('lureGrp', view);
	
	actualLooking = (view and curCam or curVent);
	
	stopSeal();
	updateACam();
	
	playAnim('map', (vent and 'vent' or 'main'));
end

function trySwitchCam(i)
	camBlip();
	
	local cam = (lookingVents and curVent or curCam);
	
	if cam == i then return; end
	
	callOnLuas('onChangeCam', {i});
	switchCamAndOld(i, cam);
	
	if lookingVents then
		curVent = i;
	else
		curCam = i;
	end
	
	actualLooking = i;
	
	updateACam();
end

function trySealCam(i)
	ventTime = 100 + Random(100);
	goingToSeal = i;
	
	setAlpha('sealTxt', 1);
	setAlpha('sealInfoTxt', 0);
	
	doSound('done', 1, 'ventSnd', false, 'channel8');
	
	setAlpha('sealProg', 1);
end

function ventProgUpdate(e, t)
	if ventTime > 0 then
		ventTime = ventTime - t;
		if ventTime <= 0 then
			if curSealed > 0 then playAnim('ventSeal' .. curSealed, 'open', true); end
			
			curSealed = goingToSeal;
			
			playAnim('ventSeal' .. goingToSeal, 'close', true);
			doSound('glitch2', 1, 'ventSnd', false, 'channel8');
			
			stopSeal();
			
			return;
		end
		
		ventSec = ventSec + e;
		while ventSec >= 1 do
			ventSec = ventSec - 1;
			
			doSound('wait', 1, 'ventSnd', false, 'channel8');
			
			setFrameRate('sealProg', 'prog', (2 + Random(10)) * 0.6);
		end
	end
end

function stopSeal()
	goingToSeal = 0;
	ventTime = 0;
	
	setAlpha('sealProg', 0);
	setAlpha('sealTxt', 0);
	setAlpha('sealInfoTxt', 1);
end

function switchCamAndOld(c, o)
	setAlpha('camScreen' .. o, 0);
	setAlpha('camScreen' .. c, 1);
	
	playAnim('mark' .. o, 'idle');
	playAnim('mark' .. c, 'glow');
	
	if cupInCam[o] then setAlpha('cupScrn' .. o, 0); end
	if cupInCam[c] then setAlpha('cupScrn' .. c, 1); end
end

function updateACam()
	if lookingVents then
		local cam = ventProps[curVent];
		playAnim('camScreen' .. curVent, ((cam.spIn or cam.hallu) and 'SP' or ''));
	else
		local cam = cameraProps[curCam];
		local foundAnim = false;
		local name = 'camScreen' .. curCam;
		local str = '';
		local tries = 0;
		local hasRand = (curCam > 1 and curCam < 11);
		local hallu = cam.hallu;
		local randSee = (hasRand and (hallu and '1' or picRand) or '');
		
		local order = {cam.curIn, ((cam.spIn or hallu) and ('SP' .. randSee) or ''), (randSpecial and 'special' or '')};
		
		while not foundAnim and tries < #order do
			str = '';
			
			for i = 1, #order - tries do
				str = str .. tostring(order[i]);
			end
			
			if animExists(name, str) then
				foundAnim = true;
				playAnim(name, str);
			end
			
			tries = tries + 1;
		end
	end
end

function camBlip()
	setAlpha('blip', 1);
	playAnim('blip', 'blip', true);
	
	static.E = 250;
	setAlpha('static', 1);
end

function tryLure(i)
	local mark = getPos('mark' .. i);
	setPos('lureSpr', mark[1] + 29, mark[2] + 19);
	playAnim('lureSpr', 'lure', true);
	setAlpha('lureSpr', 1);
	
	if getRandomInt(1, 7) > 1 then
		callOnLuas('getLured', {i});
	end
end

function startHallucinating()
	for i = 1, 15 do
		if i < 11 then
			cameraProps[i].hallu = (Random(3) == 1);
		else
			ventProps[i].hallu = (Random(3) == 1);
		end
	end
end

function stopHallucinating()
	for i = 1, 15 do
		if i < 11 then
			cameraProps[i].hallu = false;
		else
			ventProps[i].hallu = false;
		end
	end
	
	static.E = 200;
	if viewingCams then updateACam(); end
end

function dropItAll()
	if viewingLittle then triggerSysPanel(); end
	if viewingCams then triggerViewPanel(); end
end

function triggerViewPanel()
	viewTrig = not viewTrig;
	viewingAPanel = true;
	
	setAlpha('panelView', 1);
	playAnim('panelView', 'flip', true, not viewTrig);
	
	if viewTrig then
		doSound('crank1', 1, 'panelSnd');
	else
		closeView();
	end
end

function panelViewFin(r)
	if r then
		setAlpha('panelView', 0);
		viewingAPanel = false;
	else
		initView();
	end
end

function initView()
	inAPanel = true;
	viewingCams = true;
	
	callOnLuas('enterCams');
	
	doSound('static_sound', 1, 'statSnd', true);
	
	playAnim('panelView', 'open', true);
	setAlpha('camCam', 1);
	setAlpha('flipRight', clAlph(200));
	
	updateACam();
	
	setAlpha('paperpal2', getRandomInt(1, 10000) == 1);
	setAlpha('shadowFreddy', getRandomInt(1, 10000) == 1);
end

function closeView()
	inAPanel = false;
	viewingCams = false;
	
	stopSeal();
	
	doSound('crank2', 1, 'panelSnd');
	doSound('stop', 1, 'statSnd', false);
	
	randSpecial = (Random(10000) == 1);
	
	callOnLuas('onCloseCams');
	
	setAlpha('camCam', 0);
	setAlpha('flipRight', clAlph(150));
end

function triggerSysPanel()
	sysTrig = not sysTrig;
	viewingAPanel = true;
	
	setAlpha('panelSys', 1);
	playAnim('panelSys', 'flip', true, not sysTrig);
	
	if sysTrig then
		doSound('lever1', 1, 'panelSnd');
	else
		closeSys();
	end
end

function panelSysFin(r)
	if r then
		setAlpha('panelSys', 0);
		viewingAPanel = false;
	else
		initSys();
	end
end

function initSys()
	inAPanel = true;
	viewingLittle = true;
	hoverNum = 1;
	
	callOnLuas('enterSys');
	selSys('audioSys');
	
	playAnim('panelSys', 'open', true);
	setAlpha('sysCam', 1);
	setVis('flipDown', false);
	
	setAlpha('paperpal1', getRandomInt(1, 10000) == 1);
	setAlpha('cupcake', getRandomInt(1, 10000) == 1);
end

function closeSys()
	inAPanel = false;
	viewingLittle = false;
	
	callOnLuas('onCloseSys');
	
	doSound('lever2', 1, 'panelSnd');
	doSound('stop', 1, 'statSnd');
	
	setAlpha('sysCam', 0);
	setVis('flipDown', true);
end

function checkHitSides()
	if not frameActive then return; end
	
	if marionActive then
		hitMid();
	else
		if xCam <= 512 then
			hitLeft();
		elseif xCam >= 1488 then
			hitRight();
		else
			hitMid();
		end
	end
end

function hitLeft()
	setVis('flipDown', true);
	seeDown = true;
end

function hitRight()
	setVis('flipRight', true);
	seeRight = true;
end

function hitMid()
	setVis('flipRight', false);
	setVis('flipDown', false);
	
	seeDown = false;
	seeRight = false;
end

local lastBreathe = 0;
local breatheEl = 0;
function updateBreathing(e, t)
	if breatheNum > 0 then
		breatheEl = breatheEl + e;
		while breatheEl >= 0.03 do
			breatheEl = breatheEl - 0.03;
			breatheNum = breatheNum - 1;
		end
		
		if lastBreathe ~= breatheNum then
			lastBreathe = breatheNum;
			
			updateForBreath();
		end
	end
end

local numVol = {
	[1] = 0.1,
	[100] = 0.25,
	[200] = 0.5,
	[300] = 1
};
function updateForBreath()
	local b = max(breatheNum, 0);
	local vol = 0;
	
	for i in pairs(numVol) do
		if b >= i then
			vol = numVol[i];
		end
	end
	
	setSoundVolume('breatheSnd', vol);
end

function updateBlackout(e, t)
	if getVar('gotYou') == 0 then
		local v = systems.vent;
		
		if blackout.setTime > 0 then
			local fiv = (5 * t);
			
			if not blackout.started then
				blackout.alph = blackout.alph + fiv;
				
				if blackout.alph > 255 then 
					blackout.started = true;
				end
			end
			
			if blackout.started then
				if blackout.alph > 0 then
					blackout.alph = blackout.alph - fiv;
				end
				
				if blackout.alph <= 150 then
					blackout.started = false;
				end
			end
		end
		
		if v.expoTime > 2000 - v.addTime then
			if not blackout.started then
				blackout.alph = blackout.alph + t;
				
				if blackout.alph > 255 then 
					blackout.started = true;
				end
			end
			
			if blackout.started then
				if blackout.alph > 0 then
					blackout.alph = blackout.alph - t;
				end
				
				if blackout.alph <= 100 then
					blackout.started = false;
				end
			end
		end
		
		if v.prog > -10 and blackout.setTime <= 0 and blackout.alph > 0 then
			blackout.started = false;
			blackout.alph = blackout.alph - t;
		end
	end
	
	blackout.setTime = blackout.setTime - t;
	
	setAlpha('blackCam', blackout.alph / 255);
end

function springBlackout()
	blackout.alph = 249;
	blackout.started = true;
end

function updateOffice(e, t)
	fg.blinkTime = fg.blinkTime - t;
	fg.sndTime = fg.sndTime - t;
	
	if fg.blinkTime > 0 then
		fg.ended = false;
		
		fg.blinkW = fg.blinkW + e;
		
		while fg.blinkW >= 0.25 do
			fg.blinkW = fg.blinkW - 0.25;
			fg.blinkPhase = not fg.blinkPhase;
			
			playAnim('office', (fg.blinkPhase and 'red' or 'office'));
			
			if fg.blinkPhase and fg.sndTime > 0 then
				doSound('alarm', 1, 'beepSnd');
			end
		end
	elseif not fg.ended then
		fg.ended = true;
		playAnim('office', 'office');
	end
end

function updateSystems(e, t)
	local aud = systems.audio;
	if aud.prog <= -10 then
		if not aud.shownErr then
			aud.shownErr = true;
			setAlpha('errAudSys', 1);
			setAlpha('audErrView', 1);
		end
	elseif aud.shownErr then
		aud.shownErr = false;
		setAlpha('errAudSys', 0);
		setAlpha('audErrView', 0);
	end
	
	if aud.lureNum < 7 then
		aud.lureTime = aud.lureTime + e;
		while aud.lureTime >= 1.5 do
			aud.lureTime = aud.lureTime - 1.5;
			
			setFrame('audInd', aud.lureNum);
			aud.lureNum = min(aud.lureNum + 1, 7);
			
			if aud.lureNum == 7 then
				setAlpha('audInd', 0);
				setAlpha('selAud', 1);
				setAlpha('audTxt', 1);
			end
		end
	end
	
	local vid = systems.video;
	if vid.prog <= -10 then
		if not vid.hidCams then
			vid.hidCams = true;
			
			setAlpha('errVidSys', 1);
			setAlpha('vidErrView', 1);
			setExists('mainCamsGrp', false);
			setExists('ventCamsGrp', false);
		end
	elseif vid.hidCams then
		vid.hidCams = false;
		
		setAlpha('errVidSys', 0);
		setAlpha('vidErrView', 0);
		setExists('mainCamsGrp', true);
		setExists('ventCamsGrp', true);
		
		if lookingVents then setVis('ventCamsGrp', true); end
	end
	
	local vent = systems.vent;
	if not viewingAPanel then
		vent.offTime = vent.offTime + e;
		while vent.offTime >= 1 do
			vent.offTime = vent.offTime - 1;
			vent.offNum = vent.offNum + 1;
		end
		
		if vent.offNum > 10 and curNight > 1 then
			vent.offToSub = vent.offToSub + e;
			while vent.offToSub >= 1 do
				vent.offToSub = vent.offToSub - 1;
				
				vent.prog = vent.prog - 1;
			end
		end
	else
		vent.offNum = 0;
	end
	
	if vent.prog <= -10 then
		vent.expoTime = vent.expoTime + t;
		
		if vent.expoTime > vent.maxTime then
			vent.highTime = vent.addTime + Random(200);
		end
		
		if not vent.shownErr then
			vent.shownErr = true;
		
			setAlpha('errVentSys', 1);
			setAlpha('ventErrView', 1);
		end
	elseif vent.shownErr then
		vent.shownErr = false;
		vent.expoTime = 0;
		
		setAlpha('errVentSys', 0);
		setAlpha('ventErrView', 0);
	end
	
	vent.highTime = vent.highTime - t;
	
	if vent.highTime > 0 then
		if not vent.startedHigh then
			vent.startedHigh = true;
			
			startHallucinating();
			fg.sndTime = 400;
		end
		
		fg.blinkTime = 50;
	elseif vent.startedHigh then
		vent.startedHigh = false;
		
		stopHallucinating();
	end
end

function calcAI()
	if curNight < 2 then
		AI = curNight - 1;
	elseif curNight >= 6 then
		AI = 7;
	else
		AI = curNight;
	end
	
	systems.vent.maxTime = 1000 - (AI * 100);
	systems.vent.addTime = (AI * 200);
end

function fredFinFall() callOnLuas('freddyFallFin'); end

function endScareFred()
	setAlpha('fredScare', 0);
	frozen = false;
	runTimer('scareEndCool', pl(10));
	
	checkHitSides();
	doFlash('freddy');
end

function endScareFoxy()
	setAlpha('foxyOffice', 0);
	frozen = false;
	runTimer('scareEndCool', pl(10));
	doFlash('foxy');
end

function endScareChica()
	setAlpha('chicaOffice', 0);
	frozen = false;
	runTimer('scareEndCool', pl(10));
	
	callOnLuas('chicaFinScare');
	doFlash('chica');
end

function endScareBB()
	setAlpha('bbOffice', 0);
	frozen = false;
	runTimer('scareEndCool', pl(10));
	doFlash('bb');
end

function endOfScare()
	if getVar('gotYou') > 0 then
		runTimer('toGameOver', pl(4 / 60));
	end
end

function doFlash(f)
	setAlpha('whiteFlash', 1);
	playAnim('whiteFlash', f);
	
	systems.vent.prog = -10;
	systems.vent.expoTime = 2000;
	
	blackout.started = true;
	blackout.alph = 255;
	
	breatheNum = 500;
	
	doTweenAlpha('flashFade', 'whiteFlash', 0, pl(51 / 60));
end

function checkHour()
	updateCounterSpr('hour', curHour);
	
	if curHour == 6 then
		start6AM();
	else callOnLuas('onHour', {curHour}); end
end

function makeWinScreen()
	makeAnimatedLuaSprite('5Spr', 'gameAssets/Win/6', 359, 341);
	addAnimationByPrefix('5Spr', '5', 'Five', 0);
	addAnimationByPrefix('5Spr', '6', 'Bright', 30);
	playAnim('5Spr', '5', true);
	setCam('5Spr', 'winCam');
	addLuaSprite('5Spr');
	
	makeAnimatedLuaSprite('lineCache', 'gameAssets/Win/greenLine');
	setCam('lineCache', 'winCam');
	addLuaSprite('lineCache');
	
	makeLuaSprite('blackGo');
	makeGraphic('blackGo', 1, 1, '000000');
	scaleObject('blackGo', 1024, 768);
	setCam('blackGo', 'winCam');
	addLuaSprite('blackGo');
	setAlpha('blackGo', 0);
end

function start6AM()
	stopGame();
	
	doing6AM = true;
	
	removeLuaSprite('lineCache');
	
	doSound('Clocks_Chimes_Cl_02480702', 1);
	doTweenAlpha('winIn', 'winCam', 1, pl(1.01));
	runTimer('pOne', pl(0.1), 0);
	
	setActive('5Spr', true);
	setActive('blackGo', true);
	
	setDataFromSave(sv, 'scene', curNight);
	curNight = curNight + 1;
	setDataFromSave(sv, 'night', min(curNight, 5));
	
	setDataFromSave(sv, 'cine', true);
	
	if curNight == 7 then
		setDataFromSave(sv, 'beat6', true);
		
		if cheats.hyper and not cheats.radar and not cheats.fast and not cheats.noErr then
			setDataFromSave(sv, '4thStar', true);
		end
	elseif curNight == 6 then
		setDataFromSave(sv, 'beatGame', true);
	elseif curNight == 8 and getDataFromSave(sv, 'all20', false) then
		setDataFromSave(sv, 'beat7', true);
	end
	
	local cus = getDataFromSave(sv, 'doingCustom', 0);
	if cus > 0 then
		setDataFromSave(sv, 'c' .. cus, 1);
	end
end

local lineChance = 0;
local hit6 = false;
function update6AM(e, t)
	if not hit6 then
		lineChance = min(lineChance + t, 100);
		
		if lineChance >= 100 then
			hit6 = true;
			
			playAnim('5Spr', '6');
			doSound('CROWD_SMALL_CHIL_EC049202', 1);
			runTimer('goNextScreen', pl(5));
		end
	elseif lineChance > 0 then
		lineChance = max(lineChance - t, 0);
	end
end

local lineYWin = {
	317,
	335,
	355,
	378,
	392,
	411
};
local totLines = 0;
function makeALine()
	totLines = totLines + 1;
	local t = 'lineWin' .. totLines;
	
	makeAnimatedLuaSprite(t, 'gameAssets/Win/greenLine', 0, (lineYWin[getRandomInt(1, 6)] + 1));
	addAnimationByPrefix(t, 'fade', 'Fade', 12, false);
	addOffset(t, 'fade', 0, 15);
	playAnim(t, 'fade', true);
	killOnFin(t);
	setCam(t, 'winCam');
	addLuaSprite(t);
	setBlendMode(t, 'add');
end

function setInCam(c, n, a, v)
	_G[c][n][a] = v;
end

function varMain(v)
	return _G[v];
end

function varSetMain(v, n)
	_G[v] = n;
end

function mainFunc(f, ...)
	return _G[f](...);
end

local timers = {
	['hideStuff'] = function()
		setAlpha('springWindow', 0);
		setAlpha('springWalk', 0);
		setAlpha('springHide', 0);
		setAlpha('springHead', 0);
		
		setAlpha('scare1', 0);
		setAlpha('scare2', 0);
		
		if curNight == 1 then
			setPos('spPos', 0, 0);
			setAlpha('spPos', 0);
		end
		
		setAlpha('mangleWindow', 0);
		
		setAlpha('foxyOffice', 1);
		setVis('foxyOffice', false);
		
		setAlpha('chicaOffice', 0);
		
		setVis('bbPeek', false);
		
		setAlpha('bbOffice', 0);
		setX('bbOffice', 1284 - 282);
		
		setAlpha('cupcake', 0);
		setAlpha('shadowFreddy', 0);
		
		setAlpha('paperpal1', 0);
		setAlpha('paperpal2', 0);
		
		setAlpha('sysCam', 0);
		setAlpha('camCam', 0);
		
		setAlpha('fredScare', 0);
		
		setX('puppetHead', marionX);
		setAlpha('puppetHead', 0);
		
		setAlpha('whiteFlash', 0);
		
		setAlpha('lureSpr', 0);
		
		setX('camCam', 0);
		
		setVis('ventCamsGrp', false);
		setVis('ventCamsMark', false);
		
		setAlpha('selAud', 0);
		setAlpha('audTxt', 0);
		
		setAlpha('freddyWalk', 0);
		
		setAlpha('sealTxt', 0);
		setAlpha('sealProg', 0);
		
		setAlpha('panelSys', 0);
		setAlpha('panelView', 0);
		setX('panelView', 2000);
		
		setAlpha('audErrView', 0);
		setAlpha('vidErrView', 0);
		setAlpha('ventErrView', 0);
		
		setAlpha('errAudSys', 0);
		setAlpha('errVidSys', 0);
		setAlpha('errVentSys', 0);
		
		setAlpha('sysProg', 0);
		
		setAlpha('flipRight', clAlph(150));
		setX('flipRight', 1920 - 46);
		
		setAlpha('winCam', 0);
		
		if curNight == 2 then
			for i = 1, 4 do
				local t = 'keyArc' .. i;
				setAlpha(t, clAlph(190));
				setExists(t, false);
			end
		elseif curNight == 4 then
			for i = 1, #offKeyPos do
				local t = 'keyOffice' .. i;
				setAlpha(t, clAlph(120));
				setVis(t, false);
			end
		end
		
		for i = 1, 15 do
			if i == curCam or i == curVent then
				setAlpha('camScreen' .. i, 1);
				playAnim('mark' .. i, 'glow');
				if cupInCam[i] then setAlpha('cupScrn' .. i, 1); end
			else
				setAlpha('camScreen' .. i, 0);
				if cupInCam[i] then setAlpha('cupScrn' .. i, 0); end
			end
		end
	end,
	
	['clickDoubleOff'] = function() waitingDouble = false; end,
	
	['stopMoveTemp'] = function()
		canMove = false;
	end,
	['startFrame'] = function()
		frameActive = true;
		canMove = true;
		
		setAlpha('clock', 0);
	end,
	
	['startShaking'] = function()
		runTimer('shakeRandom', pl(0.03), 0);
	end,
	['shakeRandom'] = function()
		scrollShake.started = true;
		scrollShake.cal = 0;
		scrollShake.off = tonumber(xCam);
		
		scrollShake.dir = 256 * getRandomInt(-1, 1);
	end,
	
	['thsi'] = function()
		if Random(5) == 1 then
			static.E = 100;
		end
	end,
	['fiv'] = function()
		static.B = Random(5) * 10;
	end,
	['sec'] = function()
		if Random(10) == 1 then
			static.E = 200;
		end
		
		if viewingCams then
			local vid = systems.video;
			vid.inCamTime = vid.inCamTime + 1;
			if vid.inCamTime >= 12 then
				vid.inCamTime = 0;
				
				vid.prog = vid.prog - AI;
			end
		end
	end,
	['ten'] = function()
		if viewingCams and cameraProps[curCam].spIn then return; end
		
		picRand = (getRandomBool() and '2' or '1');
	end,
	
	['startScream'] = function()
		doSound('scream3', 1, 'scareSpring');
	end,
	
	['coolToggle'] = function()
		toggleCooled = true;
	end,
	
	['scareEndCool'] = function()
		scareCooled = true;
	end,
	
	['hideMute'] = function()
		canMute = false;
		setAlpha('muteButton', 0);
	end,
	
	['addHour'] = function()
		curHour = (curHour % 12) + 1;
		checkHour();
	end,
	
	['toGameOver'] = function()
		switchState('static');
	end
};
local timersWin = {
	['pOne'] = function()
		if Random(100) < lineChance then makeALine(); end
	end,
	
	['goNextScreen'] = function()
		doTweenAlpha('winOut', 'blackGo', 1, pl(0.9));
	end
};
function onTimerCompleted(t)
	if doing6AM then
		if timersWin[t] then timersWin[t](); end
	
		return Function_StopLua;
	end
	
	if t:find('visButton_') then
		local o = t:gsub('visButton_', '');
		if o:find('keyArc') then
			setExists(o, false);
		else
			setVis(o, false);
		end
		
		return;
	end
	
	if timers[t] then timers[t](); end
end

local tweensWin = {
	['winIn'] = function() canUpdateWin = true; end,
	['winOut'] = function()
		if curNight >= 5 and getDataFromSave(sv, 'isDemo', false) then
			switchState('DemoEnd');
		else
			switchState('Load');
		end
	end
};
function onTweenCompleted(t)
	if doing6AM then
		if tweensWin[t] then tweensWin[t](); end
	
		return Function_StopLua;
	end
end

function cacheSounds()
	for i = 1, 7 do
		if i < 3 then
			precacheSound('crank' .. i);
			precacheSound('lever' .. i);
		end
		
		if i < 4 then
			precacheSound('echo/' .. i);
		end
		
		precacheSound('walk/' .. i);
	end
	
	precacheSound('glitch2');
	precacheSound('done');
	precacheSound('wait');
	precacheSound('select');
	
	precacheSound('scream3');
	precacheSound('alarm');
	
	precacheSound('static_sound');
	
	precacheSound('mask');
	precacheSound('garble1');
	
	precacheSound('stop');
	
	precacheSound('PartyFavorraspyPart_AC01__3');
	
	precacheSound('Clocks_Chimes_Cl_02480702');
	precacheSound('CROWD_SMALL_CHIL_EC049202');
end
