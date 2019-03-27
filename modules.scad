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

module server_rack_part_b() {
  profile = "1530-LS";
  length = parts_b_and_e_length;
  echo("B", profile, length);

  color("DodgerBlue")
  translate([profile_base_dimension, (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020(profile, length);
}

module server_rack_part_c() {
  profile = "1515-LS";
  length = enclosure_width;
  echo("C", profile, length);

  color("LimeGreen")
  translate([enclosure_half_width, profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020(profile, length);
}

module server_rack_part_e() {
  profile = "1545-S";
  length = parts_b_and_e_length;
  width = profile_base_dimension * 3;
  echo("E", profile, length);

  color("Tomato")
  translate([(width / 2), (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020(profile, length);
}

module server_rack_part_g() {
  profile = "1530-LS";
  length = rack_height;
  echo("G", profile, length);

  color("MediumSlateBlue")
  translate([profile_half_dimension, profile_base_dimension, (length / 2)])
  rotate([0, 0, 90])
  extrude_8020(profile, length);
}

module server_rack_part_i() {
  profile = "1515-LS";
  length = enclosure_depth - (profile_base_dimension * 2);
  echo("I", profile, length);

  color("LightCoral")
  translate([profile_half_dimension, (length / 2), profile_half_dimension])
  rotate([90, 0, 0])
  extrude_8020(profile, length);
}

module server_rack_part_j() {
  profile = "1515-LS";
  length = rack_height - total_vertical_door_gap;
  echo("J", profile, length);

  translate([profile_half_dimension, profile_half_dimension, (length / 2)])
  extrude_8020(profile, length);
}

module server_rack_part_k() {
  profile = "1515-LS";
  length = rack_width - total_horizontal_door_gap - (profile_base_dimension * 2);
  echo("K", profile, length);

  translate([(length / 2), profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020(profile, length);
}

module server_rack_part_q() {
  profile = "1515-LS";
  length = part_q_length;
  echo("Q", profile, length);

  color("Violet")
  translate([(length / 2), profile_half_dimension, profile_half_dimension])
  rotate([0, 90, 0])
  extrude_8020(profile, length);
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

module enclosure_panel(width, height) {
  color("Gray", 0.5)
  cube([width, height, panel_thickness]);
}
