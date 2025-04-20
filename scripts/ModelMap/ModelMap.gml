function ModelMap() : AssetMap() constructor {
	queue = ds_map_create()
	
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
#region Load .bbmod File
		var _bbmod_file = mod_find_file("models/" + _name + ".bbmod")
		
		if _bbmod_file == "" {
			print($"! ModelMap.load: '{_name}' not found")
			
			exit
		}
		
		var _buffer = buffer_load(_bbmod_file)
		var _has_minor_version = false
		
		// Header
		switch buffer_read(_buffer, buffer_string) {
			case "bbmod": break
			
			case "BBMOD":
				_has_minor_version = true
			break
			
			default:
				show_error($"!!! ModelMap.load: '{_name}' does not have BBMOD header", true)
		}
		
		// Major version
		var _major_version = buffer_read(_buffer, buffer_u8)
		
		if _major_version != 3 {
			show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD major version {_major_version}, expected 3", true)
		}
		
		// Minor version
		var _minor_version = 0
		
		if _has_minor_version {
			_minor_version = buffer_read(_buffer, buffer_u8)
			
			if _minor_version < 3 or _minor_version > 21 {
				show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD minor version {_minor_version}, expected range [3, 21]", true)
			}
		}
		
		// Submodels
		var _submodel_count = buffer_read(_buffer, buffer_u32)
		var _submodels = array_create(_submodel_count)
		var i = 0
		
		repeat _submodel_count {
			var _submodel = new Submodel()
			
			with _submodel {
				// Store the material index for later use
				material_index = buffer_read(_buffer, buffer_u32)
				
				// Bounding box
				repeat 6 {
					buffer_read(_buffer, buffer_f32)
				}
				
				/* Vertex format
				   
				   PNEngine only needs the following attributes:
				   - Position
				   - Normals
				   - UVs
				   - Secondary UVs
				   - Colors
				   - Bone Indices
				   - Bone Weights
				   
				   TODO: Add support for tangents?
						 Normal maps would be nice... */
				var _position = buffer_read(_buffer, buffer_bool)
				var _normals = buffer_read(_buffer, buffer_bool)
				var _uvs = buffer_read(_buffer, buffer_bool)
				var _uvs2 = buffer_read(_buffer, buffer_bool)
				var _color = buffer_read(_buffer, buffer_bool)
				var _tangents = buffer_read(_buffer, buffer_bool)
				var _bones = buffer_read(_buffer, buffer_bool)
				var _id = buffer_read(_buffer, buffer_bool)
				
				// Primitive type
				buffer_read(_buffer, buffer_u32)
				
				vbo = vertex_create_buffer()
				vertex_begin(vbo, global.vbo_format)
				
				// Vertices
				var _vertex_count = buffer_read(_buffer, buffer_u32)
				
				repeat _vertex_count {
					// Position
					if _position {
						var _x = buffer_read(_buffer, buffer_f32)
						var _y = buffer_read(_buffer, buffer_f32)
						var _z = buffer_read(_buffer, buffer_f32)
						
						vertex_position_3d(vbo, _x, _y, _z)
					} else {
						vertex_position_3d(vbo, 0, 0, 0)
					}
					
					// Normals
					if _normals {
						var _nx = buffer_read(_buffer, buffer_f32)
						var _ny = buffer_read(_buffer, buffer_f32)
						var _nz = buffer_read(_buffer, buffer_f32)
						
						vertex_normal(vbo, _nx, _ny, _nz)
					} else {
						vertex_normal(vbo, 0, 0, 1)
					}
					
					// UVs
					if _uvs {
						var _u = buffer_read(_buffer, buffer_f32)
						var _v = buffer_read(_buffer, buffer_f32)
						
						vertex_texcoord(vbo, _u, _v)
					} else {
						vertex_texcoord(vbo, 0, 0)
					}
					
					// UVs 2
					if _uvs2 {
						var _u = buffer_read(_buffer, buffer_f32)
						var _v = buffer_read(_buffer, buffer_f32)
						
						vertex_texcoord(vbo, _u, _v)
					} else {
						vertex_texcoord(vbo, 0, 0)
					}
					
					// Color
					if _color {
						var _r = buffer_read(_buffer, buffer_u8)
						var _g = buffer_read(_buffer, buffer_u8)
						var _b = buffer_read(_buffer, buffer_u8)
						var _a = buffer_read(_buffer, buffer_u8)
						
						vertex_color(vbo, make_color_rgb(_r, _g, _b), _a * COLOR_INVERSE)
					} else {
						vertex_color(vbo, c_white, 1)
					}
					
					// Tangents
					if _tangents {
						repeat 4 {
							buffer_read(_buffer, buffer_f32)
						}
					}
					
					// Bones
					if _bones {
						var _bone1 = buffer_read(_buffer, buffer_f32)
						var _bone2 = buffer_read(_buffer, buffer_f32)
						var _bone3 = buffer_read(_buffer, buffer_f32)
						var _bone4 = buffer_read(_buffer, buffer_f32)
						var _weight1 = buffer_read(_buffer, buffer_f32)
						var _weight2 = buffer_read(_buffer, buffer_f32)
						var _weight3 = buffer_read(_buffer, buffer_f32)
						var _weight4 = buffer_read(_buffer, buffer_f32)
						
						vertex_float4(vbo, _bone1, _bone2, _bone3, _bone4)
						vertex_float4(vbo, _weight1, _weight2, _weight3, _weight4)
					} else {
						vertex_float4(vbo, 0, 0, 0, 0)
						vertex_float4(vbo, 0, 0, 0, 0)
					}
					
					// ID
					if _id {
						buffer_read(_buffer, buffer_f32)
					}
				}
				
				vertex_end(vbo)
				vertex_freeze(vbo)
			}
			
			_submodels[i++] = _submodel
		}
		
		// Nodes
		var _node_count = buffer_read(_buffer, buffer_u32)
		var _root_node = new Node().from_buffer(_buffer)
		
		// Bone offsets
		var _bone_count = buffer_read(_buffer, buffer_u32)
		var _bone_offsets = array_create(_bone_count * 8)
		
		repeat _bone_count {
			i = buffer_read(_buffer, buffer_f32) * 8
			
			repeat 8 {
				_bone_offsets[i++] = buffer_read(_buffer, buffer_f32)
			}
		}
		
		// Materials
		var _material_count = buffer_read(_buffer, buffer_u32)
		var _materials = array_create(_material_count)
		
		i = 0
		
		repeat _material_count {
			var _material_name = buffer_read(_buffer, buffer_string)
			
			_materials[i++] = global.materials.fetch(_material_name)
		}
		
		buffer_delete(_buffer)
		i = 0
		
		repeat _submodel_count {
			with _submodels[i++] {
				materials = [_materials[material_index]]
			}
		}
		
		var _model = new Model()
		
		with _model {
			name = _name
			submodels = _submodels
			submodels_amount = _submodel_count
			root_node = _root_node
			nodes_amount = _node_count
			bone_offsets = _bone_offsets
			bones_amount = _bone_count
		}
#endregion
		
#region Load JSON File
		var _json = json_load(mod_find_file("models/" + _name + ".json"))
		
		if is_struct(_json) {
#region Collider
			var _collider_info = force_type_fallback(_json[$ "collider"], "struct")
			
			if _collider_info != undefined {
				var _collider = new Collider()
				
#region Triangles
				var _triangles = _collider.triangles
				var _get_triangles = _collider_info[$ "triangles"]
				var _xmin = infinity
				var _ymin = infinity
				var _xmax = -infinity
				var _ymax = -infinity
				
				if is_array(_get_triangles) {
					i = 0
					
					repeat array_length(_get_triangles) {
						var _batch = force_type(_get_triangles[i++], "struct")
						var _batch_name = force_type(_batch[$ "batch"], "string")
						var _batch_filename = mod_find_file("colliders/" + _batch_name + ".col")
						
						if _batch_filename == "" {
							show_error($"!!! ModelMap.load: '{_name}' batch file '{_batch_name}' not found", true)
						}
						
						var _batch_surface = floor(force_type_fallback(_batch[$ "surface"], "number", 0))
						var _batch_flags = CollisionFlags.ALL
						
						if not force_type_fallback(_batch[$ "collide_body"], "bool", true) {
							_batch_flags &= ~CollisionFlags.BODY
						}
						
						if not force_type_fallback(_batch[$ "collide_bullet"], "bool", true) {
							_batch_flags &= ~CollisionFlags.BULLET
						}
						
						if not force_type_fallback(_batch[$ "collide_vision"], "bool", true) {
							_batch_flags &= ~CollisionFlags.VISION
						}
						
						if not force_type_fallback(_batch[$ "collide_camera"], "bool", true) {
							_batch_flags &= ~CollisionFlags.CAMERA
						}
						
						if not force_type_fallback(_batch[$ "collide_shadow"], "bool", true) {
							_batch_flags &= ~CollisionFlags.SHADOW
						}
						
						if not force_type_fallback(_batch[$ "sticky"], "bool", false) {
							_batch_flags &= ~CollisionFlags.STICKY
						}
						
						if not force_type_fallback(_batch[$ "slippery"], "bool", false) {
							_batch_flags &= ~CollisionFlags.SLIPPERY
						}
						
						var _batch_layer = _batch[$ "layer"]
						var _batch_mask = 0
						
						switch typeof(_batch_layer) {
							case "undefined": _batch_mask = CollisionLayers.ALL break
							case "real": _batch_mask = 1 << _batch_layer break
							
							case "array":
								var j = 0
								
								repeat array_length(_batch_layer) {
									_batch_mask |= 1 << _batch_layer[j++]
								}
								
								break
							
							default:
								show_error($"!!! ModelMap.load: '{_name}' batch '{_batch_name}' has invalid layer '{_batch_layer}', expected real or array", true)
						}
						
						_buffer = buffer_load(_batch_filename)
						
						if buffer_read(_buffer, buffer_string) != "PNECOL" {
							show_error($"!!! ModelMap.load: '{_name}' batch '{_batch_name}' has no PNECOL header", true)
						}
						
						repeat buffer_read(_buffer, buffer_u32) {
							var _triangle = array_create(TriangleData.__SIZE)
							var _x1 = buffer_read(_buffer, buffer_f32)
							var _y1 = buffer_read(_buffer, buffer_f32)
							var _z1 = buffer_read(_buffer, buffer_f32)
							var _x2 = buffer_read(_buffer, buffer_f32)
							var _y2 = buffer_read(_buffer, buffer_f32)
							var _z2 = buffer_read(_buffer, buffer_f32)
							var _x3 = buffer_read(_buffer, buffer_f32)
							var _y3 = buffer_read(_buffer, buffer_f32)
							var _z3 = buffer_read(_buffer, buffer_f32)
							
							_xmin = min(_xmin, _x1, _x2, _x3)
							_ymin = min(_ymin, _y1, _y2, _y3)
							_xmax = max(_xmax, _x1, _x2, _x3)
							_ymax = max(_ymax, _y1, _y2, _y3)
							_triangle[TriangleData.X1] = _x1
							_triangle[TriangleData.Y1] = _y1
							_triangle[TriangleData.Z1] = _z1
							_triangle[TriangleData.X2] = _x2
							_triangle[TriangleData.Y2] = _y2
							_triangle[TriangleData.Z2] = _z2
							_triangle[TriangleData.X3] = _x3
							_triangle[TriangleData.Y3] = _y3
							_triangle[TriangleData.Z3] = _z3
							_triangle[TriangleData.NX] = buffer_read(_buffer, buffer_f32)
							_triangle[TriangleData.NY] = buffer_read(_buffer, buffer_f32)
							_triangle[TriangleData.NZ] = buffer_read(_buffer, buffer_f32)
							_triangle[TriangleData.SURFACE] = _batch_surface
							_triangle[TriangleData.FLAGS] = _batch_flags
							_triangle[TriangleData.LAYERS] = _batch_mask
							ds_list_add(_triangles, _triangle)
						}
						
						buffer_delete(_buffer)
					}
				}
#endregion
				
#region Layers
				var _active_layers = _collider_info[$ "active_layers"]
				
				switch typeof(_active_layers) {
					case "undefined": break
					case "real": _collider.layer_mask = 1 << _active_layers break
					
					case "array":
						var _mask = 0
						var j = 0
						
						repeat array_length(_active_layers) {
							_mask |= 1 << _active_layers[j++]
						}
						
						_collider.layer_mask = _mask
						
						break
					
					default:
						show_error($"!!! ModelMap.load: '{_name}' collider has invalid active layers '{_active_layers}', expected real or array", true)
				}
#endregion
				
#region Subdivision
				with _collider {
					x1 = _xmin
					y1 = _ymin
					x2 = _xmax
					y2 = _ymax
					
					var _width = ceil((_xmax - _xmin) * COLLIDER_REGION_SIZE_INVERSE)
					var _height = ceil((_ymax - _ymin) * COLLIDER_REGION_SIZE_INVERSE)
					var _triangles_n = ds_list_size(triangles)
					
					ds_grid_resize(grid, _width, _height)
					i = 0
					
					repeat _width {
						var j = 0
						
						repeat _height {
							/* Try to create a region for each new grid cell.
							   If there are no triangles in this region, the cell will redirect
							   to noone (empty). */
							var _region = ds_list_create()
							var _rx1 = _xmin + i * COLLIDER_REGION_SIZE
							var _ry1 = _ymin + j * COLLIDER_REGION_SIZE
							var _rx2 = _rx1 + COLLIDER_REGION_SIZE
							var _ry2 = _ry1 + COLLIDER_REGION_SIZE
							var k = 0
							
							repeat _triangles_n {
								var _triangle = triangles[| k++]
								
								var _tx1 = _triangle[TriangleData.X1]
								var _ty1 = _triangle[TriangleData.Y1]
								var _tx2 = _triangle[TriangleData.X2]
								var _ty2 = _triangle[TriangleData.Y2]
								var _tx3 = _triangle[TriangleData.X3]
								var _ty3 = _triangle[TriangleData.Y3]
								
								// Check if this triangle is within the region.
								// (rectangle_in_triangle doesn't work)
								if point_in_rectangle(_tx1, _ty1, _rx1, _ry1, _rx2, _ry2)
									or point_in_rectangle(_tx2, _ty2, _rx1, _ry1, _rx2, _ry2)
									or point_in_rectangle(_tx3, _ty3, _rx1, _ry1, _rx2, _ry2)
									or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx1, _ry1, _rx2, _ry1)
									or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx2, _ry1, _rx2, _ry2)
									or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx2, _ry2, _rx1, _ry2)
									or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx1, _ry2, _rx1, _ry1)
									or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx1, _ry1, _rx2, _ry1)
									or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx2, _ry1, _rx2, _ry2)
									or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx2, _ry2, _rx1, _ry2)
									or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx1, _ry2, _rx1, _ry1)
									or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx1, _ry1, _rx2, _ry1)
									or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx2, _ry1, _rx2, _ry2)
									or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx2, _ry2, _rx1, _ry2)
									or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx1, _ry2, _rx1, _ry1) {
									ds_list_add(_region, _triangle)
								}
							}
							
							if ds_list_empty(_region) {
								ds_list_destroy(_region)
								grid[# i, j] = -1
							} else {
								grid[# i, j] = _region
								ds_list_add(regions, _region)
								ds_list_mark_as_list(regions, ds_list_size(regions) - 1)
							}
							
							++j
						}
						
						++i
					}
				}
#endregion
				
				_model.collider = _collider
			}
#endregion
			
#region Points
			with _model {
				points = force_type_fallback(_json[$ "points"], "struct")
				
				if points != undefined {
					var _names = struct_get_names(points)
					
					i = 0
					
					repeat struct_names_count(points) {
						var _point = force_type(points[$ _names[i++]], "array")
						
						_point[3] = get_node_id(force_type_fallback(_point[3], "string"))
					}
				}
				
				var _torso_bone = force_type_fallback(_json[$ "torso_bone"], "string")
				
				if _torso_bone != undefined {
					torso_bone = get_node_id(_torso_bone)
				}
				
				var _hold_bone = force_type_fallback(_json[$ "hold_bone"], "string")
				
				if _hold_bone != undefined {
					hold_bone = get_node_id(_hold_bone)
				}
			}
#endregion
			
#region Lightmap
			var _lightmap = force_type_fallback(_json[$ "lightmap"], "string")
			
			if _lightmap != undefined {
				_model.lightmap = _lightmap
				ds_map_add(queue, _name, _model)
				
				if global.images.load(_lightmap) == undefined {
					_model.lightmap = undefined
				}
			}
#endregion
		}
#endregion
		
		ds_map_add(assets, _name, _model)
		print($"ModelMap.load: Added '{_name}' ({_model})")
	}
}

global.models = new ModelMap()