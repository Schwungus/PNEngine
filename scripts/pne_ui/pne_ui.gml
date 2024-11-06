enum UIInputs {
	UP_DOWN,
	LEFT_RIGHT,
	CONFIRM,
	BACK,
	MOUSE_X,
	MOUSE_Y,
	MOUSE_CONFIRM,
	__SIZE,
}

enum OUIValues {
	UNDEFINED,
	OFF_ON,
	NO_YES,
	LEVEL,
	RESOLUTION,
	FRAMERATE,
	TEXTURE,
	MIPMAP,
	ANTIALIAS,
	SENSITIVITY,
	VOLUME,
	LANGUAGE,
	__SIZE,
}

var _oui_values = array_create(OUIValues.__SIZE)

_oui_values[OUIValues.UNDEFINED] = ["value.undefined"]
_oui_values[OUIValues.OFF_ON] = ["value.off", "value.on"]
_oui_values[OUIValues.NO_YES] = ["value.no", "value.yes"]
_oui_values[OUIValues.LEVEL] = ["value.low", "value.high"]

_oui_values[OUIValues.RESOLUTION] = [
	"value.resolution.s240", "value.resolution.w240",
	"value.resolution.s270", "value.resolution.w270",
	"value.resolution.s480", "value.resolution.w480",
	"value.resolution.s540", "value.resolution.w540",
	"value.resolution.s720", "value.resolution.w720",
	"value.resolution.s900", "value.resolution.w900",
	"value.resolution.s1080", "value.resolution.w1080",
	"value.resolution.s1440", "value.resolution.w1440",
	"value.resolution.s2160", "value.resolution.w2160",
]

_oui_values[OUIValues.FRAMERATE] = [
	"value.framerate.f30",
	"value.framerate.f60",
	"value.framerate.f75",
	"value.framerate.f120",
	"value.framerate.f144",
	"value.framerate.f165",
	"value.framerate.f240",
]

_oui_values[OUIValues.TEXTURE] = [
	"value.texture.none",
	"value.texture.linear",
]

_oui_values[OUIValues.MIPMAP] = [
	"value.mipmap.sharp",
	"value.mipmap.smooth",
]

_oui_values[OUIValues.ANTIALIAS] = [
	"value.antialias.none",
	"value.antialias.x2",
	"value.antialias.x4",
	"value.antialias.x8",
]

_oui_values[OUIValues.SENSITIVITY] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
_oui_values[OUIValues.VOLUME] = ["0%", "5%", "10%", "15%", "20%", "25%", "30%", "35%", "40%", "45%", "50%", "55%", "60%", "65%", "70%", "75%", "80%", "85%", "90%", "95%", "100%"]

global.ui = undefined
global.ui_input = array_create(UIInputs.__SIZE)
global.oui_values = _oui_values