function screenshot_canvas(_canvas = new Canvas(1, 1)) {
	var _width = window_get_width()
	var _height = window_get_height()
	
	_canvas.Resize(_width, _height)
	_canvas.Start()
	draw_clear(c_black)
	
	var _players_active = global.players_active
	var _num_active = ds_list_size(_players_active)
	var _camera_man = global.camera_man
	
	if instance_exists(_camera_man) {
		_camera_man.render(_width, _height, true).Draw(0, 0)
	} else {
		var _camera_active = global.camera_active
		
		if instance_exists(_camera_active) {
			_camera_active.render(_width, _height, true).Draw(0, 0)
		} else {
			var _camera_demo = global.camera_demo
			
			if instance_exists(_camera_demo) {
				_camera_demo.render(_width, _height, true).Draw(0, 0)
			} else {
				var _netgame = global.netgame
				
				if _netgame != undefined and _netgame.active and _netgame.local_player != undefined {
					with _netgame.local_player {
						if instance_exists(camera) {
							camera.render(_width, _height, true).Draw(0, 0)
						}
					}
				} else {
					switch _num_active {
						case 1: {
							with _players_active[| 0] {
								if instance_exists(camera) {
									camera.render(_width, _height, true).Draw(0, 0)
								}
							}
							
							break
						}
						
						case 2: {
							_height *= 0.5
							
							var _y = 0
							var i = 0
							
							repeat _num_active {
								with _players_active[| i] {
									if instance_exists(camera) {
										camera.render(_width, _height, i == 0).Draw(0, _y)
									}
								}
								
								_y += _height;
								++i
							}
							
							break
						}
						
						case 3:
						case 4: {
							_width *= 0.5
							_height *= 0.5
							
							var _x = 0
							var _y = 0
							var i = 0
							
							repeat _num_active {
								with _players_active[| i] {
									if instance_exists(camera) {
										camera.render(_width, _height, i == 0).Draw(_x, _y)
									}
								}
								
								_x += _width
								
								if _x > _width {
									_x = 0
									_y += _height
								}
								
								++i
							}
							
							break
						}
					}
				}
			}
		}
	}
	
	_canvas.Finish()
	
	return _canvas
}