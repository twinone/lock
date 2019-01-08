use <../gear.scad>
use <../kwikset.scad>

nut_r = 6.01/2+0.3;
nut_th = 2.15+0.3;

screw_r = 3.5/2;
screw_head_r = 5.5/2;

gears_h = 8;

motor_gear_teeth=6;
key_gear_teeth=16;


motor_shaft_to_screws = 20;

motor_screw_dst = 18;
motor_shaft_len = 8;
motor_shaft_to_edge = 10;

motor_size = [18.2, 22.4, 36.6];


case_pad = 1;
case_pad_side = 1;
case_h = gears_h + case_pad;

adapter_h = 15;
adapter_hole = 12;


key_holder_r = pitch_radius(key_gear_teeth) / 1.4;
echo("key holder r"); echo(key_holder_r);

function gearr2r() = pitch_radius(key_gear_teeth)+pitch_radius(motor_gear_teeth);




module nut_hole() {
    hull() {
        rotate([90,0,0])
        cylinder(r=nut_r, h=nut_th, $fn=6, center=true);
        
        translate([0,0,50]) 
        rotate([90,0,0])
        cylinder(r=nut_r, h=nut_th, $fn=6, center=true);
    }
}



module motor() {
    module shaft() {
        r=5.3/2+0.15;
        sq = 3.3+0.3;
        rotate(90)
        linear_extrude(motor_shaft_len)
        intersection() {
            circle(r=r, $fn=50);
            square([sq, 30], true);
        }
    }
    module body() {
        difference() {
            union() {
                cube(motor_size, true);
                translate([0,0,-26])
                scale(0.95)
                cube(motor_size, true);


                translate([motor_size[0]/2,0,motor_size[2]/2-motor_shaft_to_edge])
                rotate([0,90,0])
                shaft();
            }
            // screw holes
            translate([0,0,motor_size[2]/2-motor_shaft_to_edge-motor_shaft_to_screws]*1) {
                translate([0,-motor_screw_dst/2,0])
                rotate([0,90,0])
                cylinder(r=screw_r, h=100, center=true, $fn=20);
                
                translate([0,motor_screw_dst/2,0])
                rotate([0,90,0])
                cylinder(r=screw_r, h=100, center=true, $fn=20);
            }   
        }
    }
    
    
    translate([-motor_size[0]/2,0,-motor_size[2]/2+motor_shaft_to_edge])
    body();
}



module key_gear(h=gears_h) {
    box_size = [30, 3.5];
    brace_w = 0;
    
    
    // radius of the gear
    echo(pitch_radius(key_gear_teeth));
    
    module screw_hole() {
        rotate([-90,0,0]) cylinder(r=screw_r, h=200, $fn=30);
        rotate([-90,0,0]) translate([0,0,10]) cylinder(r=screw_head_r, h=200, $fn=30);
        // nut
        translate([0,5,0]) 
        hull() {
            rotate([90,0,0]) cylinder(r=nut_r, h=nut_th, $fn=6, center=true);
            translate([0,0,50]) rotate([90,0,0]) cylinder(r=nut_r, h=nut_th, $fn=6, center=true);
        }
    }
    
    module screw_holes() {
        dst=9.9;
        translate([dst,0,0])
        screw_hole();
        translate([-dst,0,0])
        screw_hole();
        
        screw_hole();
    }


    difference() {
        // the gear
        rotate(360/key_gear_teeth/2)
        translate([0,0,-h/2])
        linear_extrude(height=h) gear(num_teeth=key_gear_teeth);
        
        
        cylinder(r = key_holder_r, h=10, center=true, $fn=6);
        
        rotate([90,0,0])
        cylinder(r = screw_head_r, h=100, $fn=30);
        
    }
    

    
    // show the key
    translate([-3,0.5,-14])
    scale(25.4) //yeah, really, they used inch measurements
    rotate([90,90,0])
    %render() kwikset(teeth=[2, 5, 6, 2, 5]);
    
    
}


module key_adapter() {
        cylinder(r = key_holder_r-1, h=20, center=true, $fn=6);

}



module door_gear(nteeth=motor_gear_teeth, h=gears_h) {
    module shaft() {
        r=5.3/2+0.15;
        sq = 3.3+0.3;
        intersection() {
            circle(r=r, $fn=50);
            square([sq, 30], true);
        }
    }
    
    translate([0,0,-h/2])
    linear_extrude(height=h)
    difference() {
        gear(num_teeth=nteeth);
        shaft();
    }

    
}


module gears_circles(o) {
    $fn=100;
    circle(r=outside_radius(key_gear_teeth)+o);
    
    
    translate(-[gearr2r(),0,0])
    circle(r=outside_radius(motor_gear_teeth)+o);

}
module gears_box_2d(m, th) {
    difference() {
        gears_circles(m+th);
        gears_circles(m);
    }
}

module gears() {
    render() {
        key_gear();
    }
    
    translate(-[gearr2r(),0,0])
    door_gear();
}


    

bottom_th = 2;

screw_outer_r = screw_r+3;
screw_fn = 100;
module screw_positioning(which = [true, true, true, true, false]) {
    dst = 10;
    a = 28;
    module top() {
        // motor gear left screws
        if (which[0])
        translate([-gearr2r(),0,0])
        rotate(90){
            translate([-motor_screw_dst/2,motor_shaft_to_screws,0])
            rotate(90)
            children();
        }
        
        if (which[0])
        translate([-gearr2r(),-10,0])
        rotate(90){
            translate([-motor_screw_dst/2,motor_shaft_to_screws,0])
            rotate(90)
            children();
        }
        if (which[4])
        translate([-gearr2r(),-10,0])
        rotate(90){
            translate([-motor_screw_dst/2,motor_shaft_to_screws,0])
            rotate(90)
            children();
        }
        
        if (which[1])
        // key gear right screws
        rotate(a) translate([pitch_radius(key_gear_teeth)+dst,0,0]) children();
        // key gear left screws
        if (which[2])
        rotate(180-a) translate([pitch_radius(key_gear_teeth)+dst,0,0]) 
        rotate(-40)children();
        
        if (which[3])
        translate([pitch_radius(key_gear_teeth)+dst,0,0]) children();

    }
    
    top() children();
    mirror([0,1,0]) top() children();
}



module base() {
    difference() {
        union() {
            // wall
            translate([0,0,-case_h/2])
            linear_extrude(height=case_h)
            difference() {
                hull() {
                    gears_box_2d(2, 3);
                    screw_positioning() circle(r=screw_outer_r, $fn=screw_fn);
                }
                gears_circles(case_pad_side, outer_th);
                
            }
            
            
            // bottom
            translate([0,0,-case_h/2-bottom_th])
            linear_extrude(height=bottom_th)
            difference() {
                hull() {
                    gears_box_2d(-4, 9);
                    screw_positioning() circle(r=screw_outer_r, $fn=screw_fn);
                }
                gears_circles(-4, 9);
            }
        }
        rotate([90,0,0]) cylinder(r=screw_head_r+1, h=100);
    }
    
    
    
    
}

// attaches the base to the door, and goes underneath the existing
// metallic beautifier
module door_adapter() {
    h=adapter_h;
    hole = 0;
    w=56;
    th = 1.5;
    triangles_step = 2.5;
    triangles_w = 2.5;
    
    translate([0,0,-case_h/2-adapter_h/2-3])
    translate([0,0,3])
    screw_holes()
    translate([0,0,-3])
    translate([0,0,-h/2-hole]) {
        difference() {
            
            
            linear_extrude(height=h+hole) hull() 
                    screw_positioning([0,1,1,1]) circle(r=screw_r+2, $fn=screw_fn);
            
            
            translate([0,0,h/2+th])
            cube([w,100,h], true);
            
            
            
            translate([0,0,-50])
            linear_extrude(height=100, $fn=100)
            circle(r=10);
        }
        
        translate([0,0,th])
        difference() {
            for (i = [-w/2:triangles_step:w/2]) {
                intersection() {
                    translate([i,0,0])
                    rotate([0,45,0]) cube([triangles_w, 39,triangles_w], true);
                    translate([0,0,50]) cube(100, true);
                }
            }
            
            translate([0,0,-1])
            linear_extrude(height=h+3)
            circle(r=10);
        }
    }
}




module cap() {
    translate([0,0,case_h/2])
    
    linear_extrude(height=2)
    difference() {
        hull() {
            screw_positioning([0,1,0,1,0])
            circle(r=screw_outer_r, $fn=20);
            
            circle(r=outside_radius(key_gear_teeth) + 5);
        }
        
        hull() {
            circle(r=outside_radius(key_gear_teeth)-4);
            translate([-300,300]) circle(r=1);
            translate([-300,-300]) circle(r=1);
        }
    }
    
}

module electronics_box() {
    box_th = 3;
    w = 82;
    under_h = 15;
    h = under_h+case_h+bottom_th;
    pad_to_case = 0.5;
    
    box_extra_h = 10;
    
    inset = 1.8; // for left screws into wall

    
    module pcb() {
        //color("blue")
        cube([71, 51, 21], true);
    }
    
    %translate([-96,0,-9])
    pcb();
    
    module box() {
        // wall
        translate([0,0,-case_h/2-bottom_th - under_h])
        linear_extrude(h)
        difference() {
            hull()
            screw_positioning([1,0,0,0,0]) {
                translate([0,box_extra_h/2,0])
                circle(r=screw_outer_r+box_th);
                translate([w,box_extra_h/2,0]) circle(r=screw_outer_r+box_th);
            }
            hull()
            screw_positioning([1,0,0,0,0]) {
                translate([0,box_extra_h/2,0])
                circle(r=screw_outer_r);
                translate([w,box_extra_h/2,0]) circle(r=screw_outer_r);
            }
        }
        // bottom
        translate([0,0,-case_h/2-bottom_th - under_h])
        linear_extrude(bottom_th)
        hull()
        screw_positioning([1,0,0,0,0]) {
            translate([0,box_extra_h/2])
            circle(r=screw_outer_r+box_th);
            translate([w,box_extra_h/2,0]) circle(r=screw_outer_r+box_th);
        }
   
        // screw holders
        translate([0,0,-case_h/2-bottom_th - under_h])
        screw_positioning([0,0,0,0,1]) 
        difference() {
            linear_extrude(under_h-pad_to_case)
            circle(r=screw_outer_r+0.5);
            translate([0,0,under_h-pad_to_case]/2)
            screw();
        }
        
        // screw holders left
        o = 3;
        translate([0,0,-case_h/2-bottom_th+o])
        screw_positioning([0,0,0,0,1]) 
        translate([0,box_extra_h/2,0])
        translate([w+inset,inset,0])
        difference() {
            linear_extrude(case_h+bottom_th-o)
            circle(r=screw_outer_r+0.5);
            translate([0,0,under_h-pad_to_case-o-2]/2)
            rotate(180)
            screw();
        }
        
        // supports for left holders
        translate([0,0,-case_h/2-bottom_th+o])
        screw_positioning([0,0,0,0,1]) 
        translate([0,box_extra_h/2,0])
        translate([w+inset,inset,0])
        hull() {
            linear_extrude(0.1)
            circle(r=screw_outer_r+0.5);
            translate([screw_outer_r-1-inset,screw_outer_r-1-inset,-under_h/2])
            linear_extrude(0.1)
            circle(r=1);
        }  
    }
    
    module holes() {
       
        // the case
        hull() {
            screw_positioning() {
                translate([0,0,-case_h/2-bottom_th-pad_to_case])
                cylinder(r=screw_outer_r+pad_to_case, h=case_h+bottom_th+pad_to_case*2);
            }
            translate([0,0,-case_h/2-bottom_th])
            cylinder(r=outside_radius(key_gear_teeth) + 5 + pad_to_case, h=case_h+bottom_th);
        }
        // the motor
        translate([0,0,-1.5])
        scale([1,1.1,1.1])
        motor_positioning()
        motor();
        
        
        // the screw cylinders
        // right
        screw_positioning([0,0,0,0,1]) screw_only();
        // left 
        screw_positioning([0,0,0,0,1])
        translate([0,box_extra_h/2,0])
        translate([w+inset,inset,32]) screw_only();
        
        
        // the on/off switch
        // absolute positioning, i know i know
        switch_r = 6/2;
        translate([-95,0,-h/2+case_h/2-1.5])
        rotate([-90,0,0])
        cylinder(r=switch_r+0.2, h=50, $fn=20);
        
        // leds
        translate([-95,0,-h/2+case_h/2-1.5])
        rotate([-90,0,0])
        cylinder(r=switch_r+0.2, h=50, $fn=20);
        
        // input power cable
        translate([-140,0,-h+case_h/2+5])
        cube([20,7.5,5], true);
        
        // door state optical endstop cable
        translate([-50,0,-h+case_h/2+5])
        cube([20,6,4], true);
            
    }
    render()
    difference() {
        box();
        holes();
    }
}



module screw_only() {
    cylinder(h=100, r=screw_r, center=true, $fn=30);
}


// i know... but we use this more than the screw_only
module screw() {
    cylinder(h=100, r=screw_r, center=true, $fn=30);
    rotate([90,0,90]) nut_hole();
}


module screws() {
    screw_positioning() {
        screw();
    }
}

module screw_holes() {
    difference() {
        children();
        screws();
    }
}


module motor_positioning() {
    translate([-gearr2r(),0,gears_h/2+1])
    rotate([0,90,0]) children();
}





module main() {
    
    %
    screw_holes() base();
    %
    screw_holes() cap();


    %
    door_adapter();


    
    %
    motor_positioning()
    motor();
    
    %
    gears();
    
    electronics_box();
    
}



main();