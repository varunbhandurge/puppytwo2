class_name ControllerGlyphs extends RefCounted

## Controller Glyphs & Multi-Device Input Icon Mapping System
## Provides dynamic button prompts and iconography for Xbox, PlayStation DualSense,
## Nintendo Switch, and PC Keyboard/Mouse split-screen configurations.

enum DeviceType {
	KEYBOARD_MOUSE,
	XBOX,
	PLAYSTATION,
	NINTENDO,
	AUTO
}

# Standard Button Glyph Lookups
const GLYPH_MAP: Dictionary = {
	"p1_jump": {
		DeviceType.KEYBOARD_MOUSE: "[Space]",
		DeviceType.XBOX: "[A]",
		DeviceType.PLAYSTATION: "[✕]",
		DeviceType.NINTENDO: "[B]"
	},
	"p1_interact": {
		DeviceType.KEYBOARD_MOUSE: "[E]",
		DeviceType.XBOX: "[X]",
		DeviceType.PLAYSTATION: "[□]",
		DeviceType.NINTENDO: "[Y]"
	},
	"p1_bark": {
		DeviceType.KEYBOARD_MOUSE: "[F]",
		DeviceType.XBOX: "[B]",
		DeviceType.PLAYSTATION: "[○]",
		DeviceType.NINTENDO: "[A]"
	},
	"p1_special": {
		DeviceType.KEYBOARD_MOUSE: "[Q]",
		DeviceType.XBOX: "[Y]",
		DeviceType.PLAYSTATION: "[△]",
		DeviceType.NINTENDO: "[X]"
	},
	"p1_sprint": {
		DeviceType.KEYBOARD_MOUSE: "[Shift]",
		DeviceType.XBOX: "[RT]",
		DeviceType.PLAYSTATION: "[R2]",
		DeviceType.NINTENDO: "[ZR]"
	},
	"p1_move": {
		DeviceType.KEYBOARD_MOUSE: "[W,A,S,D]",
		DeviceType.XBOX: "[Left Stick]",
		DeviceType.PLAYSTATION: "[Left Stick]",
		DeviceType.NINTENDO: "[Left Stick]"
	},
	
	# Player 2 (Milo) mappings
	"p2_jump": {
		DeviceType.KEYBOARD_MOUSE: "[Up Arrow]",
		DeviceType.XBOX: "[A]",
		DeviceType.PLAYSTATION: "[✕]",
		DeviceType.NINTENDO: "[B]"
	},
	"p2_interact": {
		DeviceType.KEYBOARD_MOUSE: "[K]",
		DeviceType.XBOX: "[X]",
		DeviceType.PLAYSTATION: "[□]",
		DeviceType.NINTENDO: "[Y]"
	},
	"p2_bark": {
		DeviceType.KEYBOARD_MOUSE: "[L]",
		DeviceType.XBOX: "[B]",
		DeviceType.PLAYSTATION: "[○]",
		DeviceType.NINTENDO: "[A]"
	},
	"p2_special": {
		DeviceType.KEYBOARD_MOUSE: "[J]",
		DeviceType.XBOX: "[Y]",
		DeviceType.PLAYSTATION: "[△]",
		DeviceType.NINTENDO: "[X]"
	},
	"p2_sprint": {
		DeviceType.KEYBOARD_MOUSE: "[R-Ctrl]",
		DeviceType.XBOX: "[RT]",
		DeviceType.PLAYSTATION: "[R2]",
		DeviceType.NINTENDO: "[ZR]"
	},
	"p2_move": {
		DeviceType.KEYBOARD_MOUSE: "[Arrows]",
		DeviceType.XBOX: "[Left Stick]",
		DeviceType.PLAYSTATION: "[Left Stick]",
		DeviceType.NINTENDO: "[Left Stick]"
	}
}

## Detects the physical device type of a connected gamepad index
static func detect_device_type(device_index: int = 0) -> DeviceType:
	var joypads = Input.get_connected_joypads()
	if joypads.is_empty() or device_index >= joypads.size():
		return DeviceType.KEYBOARD_MOUSE
		
	var joy_id = joypads[device_index]
	var joy_name = Input.get_joy_name(joy_id).to_lower()
	
	if "playstation" in joy_name or "dualsense" in joy_name or "dualshock" in joy_name or "sony" in joy_name:
		return DeviceType.PLAYSTATION
	elif "switch" in joy_name or "joy-con" in joy_name or "nintendo" in joy_name or "pro controller" in joy_name:
		return DeviceType.NINTENDO
	elif "xbox" in joy_name or "xinput" in joy_name or "microsoft" in joy_name:
		return DeviceType.XBOX
	else:
		# Fallback to Xbox glyph standard for generic XInput/DirectInput controllers
		return DeviceType.XBOX

## Returns the text glyph string for a specified action and device
static func get_glyph(action: String, device_type: DeviceType = DeviceType.AUTO) -> String:
	var resolved_dev = device_type
	if resolved_dev == DeviceType.AUTO:
		resolved_dev = detect_device_type(0)
		
	if not GLYPH_MAP.has(action):
		return "[%s]" % action.to_upper()
		
	var action_dict: Dictionary = GLYPH_MAP[action]
	if action_dict.has(resolved_dev):
		return action_dict[resolved_dev]
		
	return action_dict.get(DeviceType.XBOX, "[?]")

## Formats a string template substituting {action_name} tokens with dynamic controller glyphs
static func format_prompt(template_text: String, device_type: DeviceType = DeviceType.AUTO) -> String:
	var resolved_dev = device_type
	if resolved_dev == DeviceType.AUTO:
		resolved_dev = detect_device_type(0)
		
	var result = template_text
	for action in GLYPH_MAP.keys():
		var token = "{" + action + "}"
		if token in result:
			var glyph = get_glyph(action, resolved_dev)
			result = result.replace(token, glyph)
			
	return result

## Returns descriptive device name
static func get_device_name(device_type: DeviceType) -> String:
	match device_type:
		DeviceType.KEYBOARD_MOUSE:
			return "Keyboard & Mouse"
		DeviceType.XBOX:
			return "Xbox Wireless Controller"
		DeviceType.PLAYSTATION:
			return "PlayStation DualSense"
		DeviceType.NINTENDO:
			return "Nintendo Switch Pro Controller"
		DeviceType.AUTO:
			return "Auto-Detect"
		_:
			return "Unknown Controller"
