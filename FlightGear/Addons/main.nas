#==================================================
#	GUI
#==================================================

var GLOBAL_MODEL_LIST = [];

var load_markers_gui = func {
	markers_load_dialogs();
	var data = {
		label   : "Markers",
		name    : "markers",
		binding : { command : "dialog-show", "dialog-name" : "markers" }
	};
	props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);
	fgcommand("gui-redraw");
	print("Markers GUI loaded");
}

var markers_load_dialogs = func {
	var dialogs   = ["markers"];
	var filenames = ["markers-dialog"];
	forindex (var i; dialogs)
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", getprop("sim/addons/markers/path") ~ "/dialogs/" ~ filenames[i] ~ ".xml");
}

var init_markers_timer = func () {
	markers_values_handle('init');
	var markers_listener = _setlistener("/sim/addons/markers/enable", func {
		place_all_markers();
	});
	print("Markers CORE loaded");
}

var markers_values_handle = func (type) {
	if (type == 'init'){
		getMarkersPath();
		props.globals.initNode('sim/addons/markers/enable', 0, "BOOL");
	}
}

var markers_load_xmls = func {
	var path = getprop("/sim/addons/markers/path") ~ "/markerslist/";
	var modelsXml = [];
	var models_stg_rows = split(";", io.readfile(path ~ "models.stg"));
	for (var n = 0; n < (size(models_stg_rows) - 1); n += 1) {
		var infos = split(",", models_stg_rows[n]);
		var model_hash = {
			name : infos[0],
			lat : infos[3],
			lon : infos[2],
			alt : infos[4]
		};
		append(modelsXml, model_hash);
		print('Appended' ~ model_hash.name ~ ', lat: ' ~ model_hash.lat ~ '. lon: ' ~ model_hash.lon);
	}
	return modelsXml;
}

var getMarkersPath = func {
	listN = props.globals.getNode("addons").getChildren("addon");
	forindex (var n; listN) {
		splited = split('/', listN[n].getChild("path").getValue());
		if (splited[size(splited)-1] == "markers") {
			props.globals.initNode("/sim/addons/markers/path", listN[n].getChild("path").getValue());
			props.globals.initNode("/sim/addons/markers/namespace", '__addon[' ~ n ~ ']__');
		}
	}
}

var place_all_markers = func {
	var enabled = getprop("sim/addons/markers/enable");
	var modelList = markers_load_xmls();
	if (enabled == 0) { # remove markers
		setprop("sim/messages/pilot", "Removing Markers");
		for(var n = 0; n < (size(GLOBAL_MODEL_LIST)); n += 1){
			GLOBAL_MODEL_LIST[n].remove();
		}
		GLOBAL_MODEL_LIST = [];
	}else{ # place markers
		setprop("sim/messages/pilot", "Placing Markers");
		var mkpath = getprop("/sim/addons/markers/path");
		mkpath = string.trim(mkpath) ~ string.trim('/markerslist/');
		for(var n = 0; n < (size(modelList)); n += 1) {
			var path = mkpath ~ string.trim(modelList[n].name);
			print(path);
			var lat = modelList[n].lat;
			var lon = modelList[n].lon;
			var alt = modelList[n].alt;
			var model = geo.put_model(path, lat, lon, alt);
			append(GLOBAL_MODEL_LIST, model);
		}
	}
}

#--------------------------------------------------
var main = func ( root ) {
	var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
		removelistener(fdm_init_listener);
		init_markers_timer();
		load_markers_gui();
	});
};  # main ()