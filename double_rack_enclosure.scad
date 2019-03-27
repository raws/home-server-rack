rack_width = 20.25;
rack_depth = 25;
rack_height = 27;

front_vent_depth = 3;

door_hinge_gap = 0.063;
door_handle_gap = 0.25;
door_top_gap = door_handle_gap;
door_bottom_gap = door_handle_gap;

profile_base_dimension = 1.5;

enclosure_width = 45;
enclosure_depth = rack_depth + front_vent_depth + (profile_base_dimension * 2);
enclosure_height = rack_height + (profile_base_dimension * 2);

// Derivatives
enclosure_half_width = enclosure_width / 2;
profile_half_dimension = profile_base_dimension / 2;
parts_b_and_e_length = enclosure_depth - (profile_base_dimension * 3);
part_q_length = (enclosure_width - (profile_base_dimension * 7)) / 2;
rack_y_offset = profile_base_dimension + front_vent_depth;
top_frame_z_offset = enclosure_height - profile_base_dimension;
total_horizontal_door_gap = door_handle_gap + door_hinge_gap;
total_vertical_door_gap = door_top_gap + door_bottom_gap;
door_width = rack_width - total_horizontal_door_gap;
door_height = enclosure_height - (profile_base_dimension * 2) - total_vertical_door_gap;

module extrude_8020(profile, length) {
  linear_extrude(height = length, center = true) {
    import(str("vendor/8020/", profile, ".dxf"));
  }
}

module server_rack() {
  rack_frame_dimension = 1.5;
  wall_thickness = 0.125;
  fudge_factor = 0.01; // To eliminate z-fighting

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
  length = parts_b_and_e_length;
  
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

module server_rack_part_e() {
  length = parts_b_and_e_length;
  width = profile_base_dimension * 3;
  
  color("Tomato")
  translate([(width / 2), (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020("1545-S", length);
}

module server_rack_part_g() {
  length = rack_height;
  
  color("MediumSlateBlue")
  translate([profile_half_dimension, profile_half_dimension, (length / 2)])
  extrude_8020("1515-LS", length);
}

module server_rack_part_i() {
  length = enclosure_depth - (profile_base_dimension * 2);
  
  color("LightCoral")
  translate([profile_half_dimension, (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020("1515-LS", length);
}

module server_rack_part_j() {
  length = rack_height - total_vertical_door_gap;
  
  translate([profile_half_dimension, profile_half_dimension, (length / 2)])
  extrude_8020("1515-LS", length);
}

module server_rack_part_k() {
  length = rack_width - total_horizontal_door_gap - (profile_base_dimension * 2);
  
  translate([(length / 2), profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020("1515-LS", length);
}

module server_rack_part_q() {
  length = part_q_length;

  color("Violet")
  translate([(length / 2), profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020("1515-LS", length);
}

module server_rack_door() {
  top_bottom_frame_x_offset = profile_base_dimension;
  bottom_frame_z_offset = door_height - profile_base_dimension;
  right_frame_x_offset = door_width - profile_base_dimension;
  
  // Frame top and bottom
  translate([top_bottom_frame_x_offset, 0, bottom_frame_z_offset]) server_rack_part_k();
  translate([top_bottom_frame_x_offset, 0, 0]) server_rack_part_k();
  
  // Frame left and right
  server_rack_part_j();
  translate([right_frame_x_offset, 0, 0]) server_rack_part_j();
}

module server_rack_front_doors() {
  door_z_offset = profile_base_dimension + door_bottom_gap;
  left_door_x_offset = profile_base_dimension + door_hinge_gap;
  right_door_x_offset = enclosure_width - profile_base_dimension - door_hinge_gap;
  translate([left_door_x_offset, 0, door_z_offset]) server_rack_door();
  translate([right_door_x_offset, 0, door_z_offset]) mirror([1, 0, 0]) server_rack_door();
}

// Rack Base
union() {
  server_rack_part_c();

  parts_b_and_e_y_offset = profile_base_dimension;
  part_a_y_offset = parts_b_and_e_y_offset + parts_b_and_e_length;

  for (x = [(profile_base_dimension * 2), enclosure_width]) {
    translate([(x - profile_base_dimension * 2), parts_b_and_e_y_offset, 0]) server_rack_part_b();
  }

  translate([(enclosure_width / 2 - (profile_base_dimension * 3 / 2)), parts_b_and_e_y_offset, 0]) {
    server_rack_part_e();
  }

  part_q_left_x_offset = profile_base_dimension * 2;
  part_q_right_x_offset = enclosure_width - (profile_base_dimension * 2) - part_q_length;
  part_q_y_offset = profile_base_dimension + front_vent_depth;
  translate([part_q_left_x_offset, part_q_y_offset, 0]) server_rack_part_q();
  translate([part_q_right_x_offset, part_q_y_offset, 0]) server_rack_part_q();

  translate([0, part_a_y_offset, 0]) server_rack_part_a();
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
    rear_legs_y_offset = enclosure_depth - profile_base_dimension;
    translate([0, rear_legs_y_offset, 0]) {
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
translate([0, rack_y_offset, profile_base_dimension + fudge_factor]) {
  translate([profile_base_dimension, 0, 0]) server_rack();
  translate([(enclosure_width - rack_width - profile_base_dimension), 0, 0]) server_rack();
}

// Top Frame
translate([0, 0, top_frame_z_offset]) {
  union() {
    server_rack_part_c();
    translate([0, (enclosure_depth - profile_base_dimension), 0]) server_rack_part_c();
    
    translate([0, profile_base_dimension, 0]) {
      for (x = [0, (enclosure_width / 2 - profile_half_dimension), (enclosure_width - profile_base_dimension)]) {
        translate([x, 0, 0]) server_rack_part_i();
      }
    }
  }
}

// Doors
union() {
  server_rack_front_doors();
  translate([0, (enclosure_depth - profile_base_dimension), 0]) server_rack_front_doors();
}
