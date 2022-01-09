/// @desc Layout

var b = layout.Box("Camera");

b.Button().Label("Reset Camera").Operator(function() {
	CAMERA3D.SetLocation(0, 400, 100);
	CAMERA3D.LookAt(0, 0, 100);
});

b.Button().Label("Show Debug Info").DefineControl(self, "debug").toggle_on_click = true;

var b = layout.Box("Sue");
var r = b.Row();
var e;

e = r.Real("X").DefineControl(fighter, "x");
e.valueprecision = 1;
e.valuestep = 1;
e = r.Real("Y").DefineControl(fighter, "y");
e.valueprecision = 1;
e.valuestep = 1;
b.Bool().Label("Infinite Dash").DefineControl(self, "infinitedash");
b.Bool().Label("Infinite Power").DefineControl(self, "infinitepower");
