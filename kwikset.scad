module wedge() {
    // An extruded right triangle
    polyhedron(points=[[0,0,0],     // right-angle corner at origin
                        [0,1,0],     //
                        [0,0,1],     // ^2 forms a triangle
                        [1,0,0],     //
                        [1,1,0],     //
                        [1,0,1]],    //^2 form same triangle transd on X
                faces=[[2,1,0],      // Triangle face
                       [3,4,5],      // Triangle face
                       [5,2,0,3],    // Face along the XZ
                       [4,1,2,5],    // Diagonal plane
                       [0,1,4,3]], convexity=10);  // Bottom face on XY
}

module keyshaft(key_length, key_padding, key_height) {
    // The 'business-end' of the key, blank without keying
    key_total_length = key_padding + key_length;
    difference() {
        translate([-(key_padding), 0, 0]) {
            difference() {
                // main shaft of the key, pointed away from origin
            
                cube([key_total_length, 0.0765, key_height]);
                
                translate([0, 0, .02]) // Bottom-most slit out of the key
                    cube([key_total_length, .04, .06]);
                
                translate([0, 0.027, .115]) // Bottom-most slit out of the key    
                    difference() {
                        cube([key_total_length, .05, .06]);
                        translate([0, 0, .06])
                            rotate([270, 0, 0])
                                scale([key_total_length, .01, .01])
                                    wedge();
                    }
                
                // Cut out bit next to the teeth
                translate([0, 0, .19]) cube([key_total_length, 0.03, 0.14]); 
                    
                // Slanted bit below the above cutout
                translate([0, 0, .19])
                    rotate([270, 0, 0])
                        scale([key_total_length, .02, .02])
                            wedge();
            }
        }
               
        // Slanted cutout on the bottom underside of the key tip
        translate([key_length + 0.02, 0, -0.14])
            rotate([0, -45, 0])
                cube([.5, .1, .2]);
        
        // Slanted cutout on the top side of the key tip
        translate([key_length - 0.27, 0, 0.4])
            rotate([0, 45, 0])
                cube([.5, .1, .2]); 
    }
}

module bit(position=0, value=0) {
    // A shape matching kwikset KW1's tooth cutter
    translate([0.247 + (position * .15), // key tooth position
              0,
              -(.023 * value)]) // key tooth depth
    translate([0, 0.15, (0.33 - 0.042)])
        rotate([90, 0, 0])
            difference() {
                rotate([0, 0, 45])
                    cube([.5, .5, .5]); // cutter body
                translate([-0.042, -0.042, 0])
                    cube([.084, .084, .6]); // Flat on cutter edge
            }
}

module keyhilt(hilt_rad, key_height) {
    // A circular grip to hold the key, with a little keychain ring
    keyring_rad = 0.09;
    // calculate height of hilt arc to create flat matching key height
    flat_offset = hilt_rad - sqrt(pow(hilt_rad, 2) - pow(key_height / 2, 2));
    $fs=0.01;
    translate([-(hilt_rad-flat_offset), 0, .167])
        rotate([0, 90, 90])
            difference() {
                cylinder(h=.0765, r=hilt_rad);
                translate([-0.5, -(hilt_rad + .5 - flat_offset), 0])
                    cube([1, .5, .0765]);
                translate([0, hilt_rad - keyring_rad - 0.12, 0])
                    cylinder(h=.0765, r=keyring_rad);
            }
}
module kwikset(teeth=[1,2,3,4,5], // Kwikset combination digits, hilt to tip
           key_length=1.1,  // How long the key is (KW1)
           key_height=0.329,  // How tall the key is (KW1)
           key_padding=0.15,  // Space between hilt and actual key
           hilt_rad=0.38  // How large the key's hilt is
) { 
    rotate([-90, 0, 0]) translate([0, -.0765, 0]) union() {
        difference() {
            keyshaft(key_length, key_padding, key_height); // Blank shaft of the key        
            for(i = [0:4]) {
                bit(i, teeth[i]); // Cut each tooth
            }
        }
        translate([-(key_padding - .0001), 0, 0])
            keyhilt(key_height=key_height, hilt_rad=hilt_rad); // key "handle"
    }
}

/*
scale(3)
translate([0, -1, 0])
    key(teeth=[2, 5, 6, 2, 5]);
translate([0, 0, 0])
    key(teeth=[6, 4, 1, 1, 5]);
translate([0, 1, 0])
    key(teeth=[6, 3, 1, 4, 6]);

*/