import psychlua.LuaUtils; // this whole script was rudy's doing, i just removed some parts that made .hx scripts load to commit to the bit
import backend.Paths;
import lime.app.Application;
import lime.graphics.Image;
import backend.DiscordClient;
import openfl.Lib;
import backend.Mods;
import flixel.util.FlxSave;
import backend.CoolUtil;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import haxe.format.JsonParser;
import sys.FileSystem;
import llua.Lua_helper;
import haxe.ds.StringMap;
import flixel.FlxCamera;
import psychlua.FunkinLua;

final autoPause:Bool = ClientPrefs.data.autoPause;

FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

final saveName:String = 'FNAF3';
final title:String = "Five Nights at Freddys 3";

var debugCam;

final luaFunctions:StringMap<Dynamic> = [ // Rudy cried here
	'switchState' => function(name) nextState(name)
    'exitGame' => function() exit()
	
	'killSounds' => function() killSounds()
	'stopGame' => function() stopGame()
	
	'bound' => function(x, a, b) return FlxMath.bound(x, a, b)
	'wrap' => function(x, a, b) return FlxMath.wrap(x, a, b)
	'lerp' => function(x, y, a) return FlxMath.lerp(x, y, a)
	
	'clAlph' => function(a) return 1. - (a / 255.)
	
	'Random' => function(n) return FlxG.random.int(1, n) - 1
	'pl' => function(n) return n / game.playbackRate
	
	'overlapPoint' => function(o, p, ?t) {
		t ??= 1;
		
		var obj = LuaUtils.getObjectDirectly(o);
		moverObj.offset.set(p[0], p[1]);
		return obj.pixelsOverlapPoint(moverObj.offset, t, getVar('mainCam'));
	},
	'pixPerfOverlap' => function(o, ob) {
		var objA = LuaUtils.getObjectDirectly(o);
		var objB = LuaUtils.getObjectDirectly(ob);
		
		return FlxG.pixelPerfectOverlap(objA, objB, 1, getVar('mainCam'));
	},
	'mouseOverlaps' => function(o, ?c) {
		var cam = debugCam;
		if (c != null) cam = getVar(c);
		
		return FlxG.mouse.overlaps(LuaUtils.getObjectDirectly(o, false), cam);
	},
	
	'setCam' => function(o, ?c) {
		c ??= 'mainCam';
		var cam = getVar(c);
		LuaUtils.getObjectDirectly(o).camera = cam;
	},
	
	'camScroll' => function(?c) {
		c ??= 'mainCam';
		var cam = getVar(c).scroll;
		return [cam.x, cam.y];
	},
	
	'setScroll' => function(?c, x, y) {
		var o = getVar(c);
		o ??= FlxG.camera;
		o.scroll.set(x, y);
	},
	
	'setBounds' => function(w, h) {
		FlxG.worldBounds.width = w + 20;
		FlxG.worldBounds.height = h + 20;
	},
	
	'camMouseX' => function() return FlxG.mouse.getScreenPosition(debugCam).x
	'camMouseY' => function() return FlxG.mouse.getScreenPosition(debugCam).y
	
	'getX' => function(o) return LuaUtils.getObjectDirectly(o).x
	'getY' => function(o) return LuaUtils.getObjectDirectly(o).y
	
	'setX' => function(o, x) LuaUtils.getObjectDirectly(o).x = x
	'setY' => function(o, y) LuaUtils.getObjectDirectly(o).y = y
	
	'addX' => function(o, x) LuaUtils.getObjectDirectly(o).x += x
	'addY' => function(o, y) LuaUtils.getObjectDirectly(o).y += y
	
	'setPos' => function(o, x, y) {
		var obj = LuaUtils.getObjectDirectly(o);
		if (obj != null) obj.setPosition(x, y); obj.last.set(x, y);
	},
	
	'getPos' => function(o) {
		var obj = LuaUtils.getObjectDirectly(o);
		return [obj.x, obj.y];
	},
	
	'setExists' => function(o, e) LuaUtils.getObjectDirectly(o).exists = e
	'setActive' => function(o, a) LuaUtils.getObjectDirectly(o).active = a
	
	'setAlpha' => function(o, a) {
		var obj = LuaUtils.getObjectDirectly(o);
		if (obj != null) obj.alpha = a;
	},
	'getAlpha' => function(o) return LuaUtils.getObjectDirectly(o).alpha
	
	'setColor' => function(o, c) LuaUtils.getObjectDirectly(o).color = c
	
	'getVis' => function(o) return LuaUtils.getObjectDirectly(o).visible
	'setVis' => function(o, v) LuaUtils.getObjectDirectly(o).visible = v
	
	'setVel' => function(o, x, y) LuaUtils.getObjectDirectly(o).velocity.set(x, y)
	'setVelX' => function(o, v) LuaUtils.getObjectDirectly(o).velocity.x = v
	'setVelY' => function(o, v) LuaUtils.getObjectDirectly(o).velocity.y = v
	
	'setFlipX' => function(o, x) LuaUtils.getObjectDirectly(o).flipX = x
	'setAnimFlipX' => function(o, a, x) LuaUtils.getObjectDirectly(o).animation.getByName(a).flipX = x
	
	'setFrame' => function(o, f) LuaUtils.getObjectDirectly(o).animation.curAnim.curFrame = f
	'getFrame' => function(o) return LuaUtils.getObjectDirectly(o).animation.curAnim.curFrame
	
	'animExists' => function(o, a) return LuaUtils.getObjectDirectly(o, false).animation.getByName(a) != null
	
	'setFrameRate' => function(o, a, f) {
		var obj = LuaUtils.getObjectDirectly(o, false);
		obj.animation.getByName(a).frameRate = f;
		
		for (fr in obj.frames.frames) {
			fr.duration = -1;
		}
	},
	
	'addToOffsets' => function(o, x, y) {
		var obj = LuaUtils.getObjectDirectly(o, false).offset;
		obj.x += x;
		obj.y += y;
	},
	
	'hideOnFin' => function(o) {
		var obj = LuaUtils.getObjectDirectly(o, false);
		obj.animation.finishCallback = function() { obj.alpha = 0; }
	}
	
	'grpVol' => function(g, v) getVar(g).volume = v
	'addToGrp' => function(o, g) getVar(g).add(LuaUtils.getObjectDirectly(o, false))
	'removeFromGrp' => function(o, g) getVar(g).remove(LuaUtils.getObjectDirectly(o, false))
	
	'doSound' => function(s, ?v, ?t, ?l, ?g) {
		if (s == null || s.length == 0) return;
		
		v ??= 1;
		l ??= false;
		
		var grp = null;
		if (g != null) grp = getVar(g);
		
		var so = FlxG.sound.load(Paths.sound(s), v, l, grp, true, false, null, function() {
			if (t != null && !l) {
				var s = game.modchartSounds.get(t);
				if (s != null) game.modchartSounds.remove(t);
	
				game.callOnLuas('onSoundFinished', [t]);
			}
		});
		so.pitch = game.playbackRate;
		if (t != null) {
			if (game.modchartSounds.exists(t)) game.modchartSounds.get(t).stop();
			
			game.modchartSounds.set(t, so);
		}
		so.play();
	}
];

function onCreatePost() {
    game.inCutscene = true;
    game.canPause = false;
	
	setVar('canEsc', true);

    // kills every object in playstate so that the draw and update calls are reduced
    for (obj in game.members) {
        obj.alive = false;
        obj.exists = false;
    }

    FlxG.autoPause = false;
    FlxG.mouse.visible = true;
	FlxG.mouse.useSystemCursor = true;
	
	FlxG.camera.active = true;
	FlxG.camera.bgColor = 0xFF000000;
	
    // if you wanna change the game's resolution
    resize(1024, 768);

    // in case you wanna add your own event listeners for key pressing
    FlxG.stage.removeEventListener("keyDown", game.onKeyPress);
    FlxG.stage.removeEventListener("keyUp", game.onKeyRelease);
	
	// would check if the image i want to change to is different than the one already as the icon but
    // you can't grab the application's icon image to my knowledge

    // common lime L :sob:
    final img:Image = Image.fromFile(Paths.modFolders('images/fnafIcon.png'));
    Application.current.window.setIcon(img);

    // resets the game to have only one camera
    FlxG.cameras.reset();
    FlxG.camera.active = true;

    game.luaDebugGroup.revive();

    // initializes the main save
    if (!game.modchartSaves.exists(saveName)) {
        final save:FlxSave = new FlxSave();
        save.bind(saveName, CoolUtil.getSavePath() + '/conCowPorts');
        game.modchartSaves.set(saveName, save);
    }

    if (Lib.application.window.title != title) Lib.application.window.title = title;

    for (func in luaFunctions.keys()) {
		for (file in game.luaArray) if (file.lua != null) Lua_helper.add_callback(file.lua, func, luaFunctions.get(func));
		
		FunkinLua.customFunctions.set(func, luaFunctions.get(func));
    }

	callStateFunction('create');
	
	debugCam = FlxG.cameras.add(new FlxCamera(), false);
	debugCam.bgColor = 0x00000000;
	game.luaDebugGroup.cameras = [debugCam];
}

function nextState(name:String) {
    game.modchartSaves.get(saveName).flush();

    PlayState.SONG = new JsonParser('{
        "notes": [],
        "events": [],
        "song": "' + name + '",
        "needsVoices": false
    }').doParse();
	
    FlxG.resetState();
}

function onUpdate(elapsed:Float) {
    if (FlxG.keys.justPressed.ESCAPE && getVar('canEsc')) exit();
}

function exit() {
    game.modchartSaves.get(saveName).flush();
    FlxG.autoPause = autoPause;
    FlxTransitionableState.skipNextTransIn = false;

    resize();

    Lib.application.window.title = "Friday Night Funkin': Psych Engine";
    FlxG.mouse.visible = false;
	FlxG.mouse.useSystemCursor = false;

    Mods.loadTopMod();
    FlxG.switchState(new states.FreeplayState());
    DiscordClient.resetClientID();
    FlxG.sound.playMusic(Paths.music('freakyMenu'));
    game.transitioning = true;
	
	Application.current.window.setIcon(Image.fromFile(Paths.modFolders('images/fnfIcon.png')));
}

function resize(?width:Int, ?height:Int) {
    width ??= 1280;
    height ??= 720;
	
	var originalWidth = FlxG.stage.stageWidth;
	var originalHeight = FlxG.stage.stageHeight;
	
	if (FlxG.initialWidth != width) {
		var sizeChangeX = originalWidth / FlxG.width;
		var sizeChangeY = originalHeight / FlxG.height;
		
		var windWidth = Math.floor(width * sizeChangeX);
		var windHeight = Math.floor(height * sizeChangeY);
		
		var xChange = Math.floor(((originalWidth - windWidth) / 2) * sizeChangeX);
		
		FlxG.stage.width = windWidth;
		FlxG.stage.height = windHeight;
		
		FlxG.initialWidth = FlxG.width = FlxG.camera.width = width;
		FlxG.initialHeight = FlxG.height = FlxG.camera.height = height;
		
		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(windWidth, windHeight);
		
		FlxG.worldBounds.width = width + 20;
		FlxG.worldBounds.height = height + 20;
		
		FlxG.scaleMode.scale.x = sizeChangeX;
		FlxG.scaleMode.scale.y = sizeChangeY;
		
		FlxG.game.x = FlxG.game.y = 0;
		
		Application.current.window.x += xChange;
	}
}

function stopGame() {
	for (obj in game.members) if (Std.isOfType(obj, FlxSprite) && obj.active) obj.active = false; // copy pasted this part from Rudy!!
	FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.active = false);
	
	killSounds();
}

function killSounds() {
	// manually destroying all of the sounds cuz `FlxG.sound.destroy(true);` crashes the game
	while (FlxG.sound.list.members.length > 0) {
		final sound:FlxSound = FlxG.sound.list.members[FlxG.sound.list.members.length - 1];

		if (sound == null) {
			FlxG.sound.list.members.remove(sound);
			continue;
		}

		sound.stop();
		FlxG.sound.list.members.pop();
	}
}

function callStateFunction(name:String, ?args:Array<Dynamic>) {
    args ??= [];
	
    for (script in game.luaArray) script.call(name, args);
}
