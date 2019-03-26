// Parameters
rack_width = 20.25;
rack_depth = 25;
rack_height = 27;
enclosure_width = 45;
enclosure_depth = 31;
profile_base_dimension = 1.5;

// Derivatives
enclosure_half_width = enclosure_width / 2;
profile_half_dimension = profile_base_dimension / 2;

module extrude_8020(profile, length) {
  linear_extrude(height = length, center = true) {
    import(str("vendor/8020/", profile, ".dxf"));
  }
}

module server_rack() {
  rack_frame_dimension = 1.5;
  wall_thickness = 0.125;
  fudge_factor = 0.01;

  color("Gray", alpha = 1)
  difference() {
    cube([rack_width, rack_depth, rack_height]);
    
    // Cut out front and back
    translate([rack_frame_dimension, -(fudge_factor / 2), rack_frame_dimension]) {
      cube([
        (rack_width - (rack_frame_dimension * 2)),
        (rack_depth + fudge_factor),
        (rack_height - (rack_frame_dimension * 2))
      ]);
    }
    
    // Cut out left and right
    translate([-(fudge_factor / 2), rack_frame_dimension, rack_frame_dimension]) {
      cube([
        (rack_width + fudge_factor),
        (rack_depth - (rack_frame_dimension * 2)),
        (rack_height - (rack_frame_dimension * 2))
      ]);
    }
    
    // Cut out top and bottom
    translate([rack_frame_dimension, rack_frame_dimension, -(fudge_factor / 2)]) {
      cube([
        (rack_width - (rack_frame_dimension * 2)),
        (rack_depth - (rack_frame_dimension * 2)),
        (rack_height + fudge_factor)
      ]);
    }
    
    // Cut interior to emulate L-profile frame
    translate([wall_thickness, wall_thickness, wall_thickness]) {
      cube([
        (rack_width - (wall_thickness * 2)),
        (rack_depth - (wall_thickness * 2)),
        (rack_height - (wall_thickness * 2))
      ]);
    }
  }
}

module server_rack_part_a() {
  translate([enclosure_half_width, profile_base_dimension, profile_half_dimension])
  rotate([90, 0, 90])
  extrude_8020("1530-LS", enclosure_width);
}

module server_rack_part_b() {
  length = enclosure_depth - (profile_base_dimension * 7);
  
  color("DodgerBlue")
  translate([profile_base_dimension, (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020("1530-LS", length);
}

module server_rack_part_c() {
  color("LimeGreen")
  translate([enclosure_half_width, profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020("1515-LS", enclosure_width);
}

module server_rack_part_d() {
  color("Violet")
  translate([profile_half_dimension, 1.5, profile_half_dimension])
  rotate([0, 90, 90])
  extrude_8020("1515-LS", 3);
}

module server_rack_part_e() {
  length = enclosure_depth - (profile_base_dimension * 7);
  width = profile_base_dimension * 3;
  
  color("Tomato")
  translate([(width / 2), (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020("1545-S", length);
}

module server_rack_part_g() {
  length = rack_height;
  
  color("SlateBlue")
  translate([profile_half_dimension, profile_half_dimension, (length / 2)])
  extrude_8020("1515-LS", length);
}

// Front Vent Base
union() {
  server_rack_part_c();
  
  for (x = [profile_base_dimension, (enclosure_half_width + profile_half_dimension), enclosure_width]) {
    translate([(x - profile_base_dimension), profile_base_dimension, 0]) server_rack_part_d();
  }
}

// Rack Base
union() {
  translate([0, (profile_base_dimension * 3), 0]) server_rack_part_a();
  translate([0, (enclosure_depth - (profile_base_dimension * 2)), 0]) server_rack_part_a();
  
  for (x = [(profile_base_dimension * 2), enclosure_width]) {
    translate([(x - profile_base_dimension * 2), (profile_base_dimension * 5), 0]) server_rack_part_b();
  }
  
  translate([(enclosure_width / 2 - (profile_base_dimension * 3 / 2)), (profile_base_dimension * 5), 0]) {
    server_rack_part_e();
  }
}

// Legs
translate([0, 0, profile_base_dimension]) {
  union() {
    evenly_spaced_offsets = [
      0,
      (enclosure_half_width - profile_half_dimension),
      (enclosure_width - profile_base_dimension)
    ];
    
    // Rear
    translate([0, (enclosure_depth - profile_base_dimension), 0]) {
      for (x = evenly_spaced_offsets) {
        translate([x, 0, 0]) server_rack_part_g();
      }
    }
    
    // Front
    for (x = evenly_spaced_offsets) {
      translate([x, 0, 0]) server_rack_part_g();
    }
  }
}

// Racks
fudge_factor = 0.01; // To eliminate z-fighting
translate([0, (profile_base_dimension * 3), profile_base_dimension + fudge_factor]) {
  translate([profile_base_dimension, 0, 0]) server_rack();
  translate([(enclosure_width - rack_width - profile_base_dimension), 0, 0]) server_rack();
}
