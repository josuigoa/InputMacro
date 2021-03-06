package io;

import haxe.Json;
import io.InputMacro.Action;
import snow.input.Keycodes;
#if macro
import sys.io.File;
#end

@:build(io.InputMacro.buildInput())
class InputManager {}

@:allow(io.InputRemapper)
class InputAction {
	var _keys: Array<Int>;
	
	public function new(keys_: Array<String>) {	
		Reflect.field(Keycodes, "up");
		_reMap(keys_);
	}
	
	public function pressed(): Bool {
		for (k in _keys) {
			if (Luxe.input.keypressed(k)) return true;
		}
		return false;
	}
	
	public function released(): Bool {
		for (k in _keys) {
			if (Luxe.input.keyreleased(k)) return true;
		}
		return false;
	}
	
	public function down(): Bool {
		for (k in _keys) {
			if (Luxe.input.keydown(k)) return true;
		}
		return false;
	}
	
	function _reMap(keys: Array<String>) {
		_keys = new Array<Int>();
		for (k in keys) {
			if (k == null) continue;
			var code: Int = Reflect.field(snow.input.Keycodes, k);
			if (code == 0) {
				throw "invalid key-name: " + k;
			}
			_keys.push(code);
		}
	}
}

class InputRemapper {
	static public function reMap() {
		#if !web
		var actions: Array<Action>;
		try {
			actions = cast Json.parse(File.getContent("input.json")).actions;
		}
		catch (e: Dynamic) {
			throw "input.json is invalid";
		}
		for (a in actions) {
			var field: InputAction = Reflect.field(InputManager, a.name);
			if (field != null) {
				field._reMap(a.codes);
			}
			else {
				throw "input.json contains invalid action: " + a.name;
			}
		}
		#else
		throw "input remapping currently unavailable on web targets";
		#end
	}
}