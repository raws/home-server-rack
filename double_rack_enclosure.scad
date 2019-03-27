include <modules.scad>;

rack_width = 20.5;
rack_depth = 25;
rack_height = 27;

front_vent_depth = 3;

door_hinge_gap = 0.063;
door_handle_gap = 0.25;
door_top_gap = door_handle_gap;
door_bottom_gap = door_handle_gap;

profile_base_dimension = 1.5;
panel_thickness = 0.25;

// Derivatives
enclosure_width = (rack_width * 2) + (profile_base_dimension * 3);
enclosure_depth = rack_depth + front_vent_depth + (profile_base_dimension * 2);
enclosure_height = rack_height + (profile_base_dimension * 2);
enclosure_half_width = enclosure_width / 2;
profile_half_dimension = profile_base_dimension / 2;
parts_b_and_e_length = enclosure_depth - (profile_base_dimension * 2);
part_q_length = (enclosure_width - (profile_base_dimension * 7)) / 2;
rack_y_offset = profile_base_dimension + front_vent_depth;
top_frame_z_offset = enclosure_height - profile_base_dimension;
total_horizontal_door_gap = door_handle_gap + door_hinge_gap;
total_vertical_door_gap = door_top_gap + door_bottom_gap;
door_width = rack_width - total_horizontal_door_gap;
door_height = enclosure_height - (profile_base_dimension * 2) - total_vertical_door_gap;

// Rack Base
union() {
  server_rack_part_c();

  parts_b_and_e_y_offset = profile_base_dimension;

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

  part_c_rear_y_offset = parts_b_and_e_y_offset + parts_b_and_e_length;
  translate([0, part_c_rear_y_offset, 0]) server_rack_part_c();
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
    rear_legs_y_offset = enclosure_depth - (profile_base_dimension * 2);
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

// Panels
union() {
  side_panel_width = enclosure_depth - (profile_base_dimension * 3);
  side_panel_height = enclosure_height - profile_base_dimension;
  side_panel_left_x_offset = (profile_base_dimension / 2) + (panel_thickness / 2);
  side_panel_right_x_offset = enclosure_width - side_panel_left_x_offset;
  side_panel_y_offset = (profile_base_dimension * 2) - profile_half_dimension;

  // Left side panel
  translate([side_panel_left_x_offset, side_panel_y_offset, profile_half_dimension])
  rotate([90, 0, 90])
  enclosure_panel(side_panel_width, side_panel_height);

  // Right side panel
  translate([side_panel_right_x_offset, side_panel_y_offset, profile_half_dimension])
  rotate([90, 0, 90])
  enclosure_panel(side_panel_width, side_panel_height);
}
