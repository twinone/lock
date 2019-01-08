// Parametric Involute Spur Gear by GregFrost
// It is licensed under the Creative Commons - GNU GPL license.
// © 2010 by GregFrost

module gear(
num_teeth=8,
circular_pitch=10,
pressure_angle=20,
involute_facets=7,
clearance=0.5,
backlash=0.5)
{   
    root_radius=root_radius(num_teeth,circular_pitch,clearance);
    base_radius=base_radius(num_teeth,circular_pitch,pressure_angle);
    pitch_radius=pitch_radius(num_teeth,circular_pitch);
    outside_radius=outside_radius(num_teeth,circular_pitch,clearance);
    
    //Create the involute curve with even steps from the root radius to the outside radius

    //First calculate the radii that we will compute points for.
    radius_list=[for(i=[0:involute_facets]) max(root_radius,base_radius)+(outside_radius-max(root_radius,base_radius))*i/involute_facets];

    //Compute the involute angle associated with that radius.
    involute_angle=[for(i=[0:involute_facets]) involute_angle(radius_list[i],base_radius)];

    //For each of those involute angles, calculate the involute points, adding a root point if needed.
    involute_points=concat((base_radius>root_radius)?[[root_radius,0]]:[],
                           [for(i=[0:involute_facets]) involute_point(base_radius,involute_angle[i])]);

    //Calculate the involute point on the pitch circle and determine its rotation.
    pitch_involute_angle=involute_angle(pitch_radius,base_radius);
    pitch_involute_point=involute_point(base_radius,pitch_involute_angle);
    pitch_rotation=atan2(pitch_involute_point[1],pitch_involute_point[0]);
    
    //Calculate the backlash angle. This is 1/4 of the backlash because it is applied on both 
    //sides of the tooth and is assumed to be applied to both meshing gears.
    backlash_angle=backlash/(circular_pitch*num_teeth)*360/4;
    
    //Calculate the angular span of half a tooth taking backlash into account.
    half_tooth_angle=360/num_teeth/4-backlash_angle;
    
    //Rotate the tooth edge so the it where it should be to make the tooth straddle the X Axis.
    first_tooth_half=rotate_list(pitch_rotation+half_tooth_angle,involute_points);

    //The second half of the tooth will bjust be mirrored about the x axis.
    second_tooth_half=[for(i=[0:len(first_tooth_half)-1]) [first_tooth_half[len(first_tooth_half)-1-i][0],
                                                -first_tooth_half[len(first_tooth_half)-1-i][1]]];

    tooth=concat(first_tooth_half,second_tooth_half);

    // Create all teeth.
    gear_points=flatten([for(i=[0:num_teeth-1]) rotate_list(-360/num_teeth*i,tooth)]);
    polygon(gear_points);
}

module rack(
num_teeth=8,
circular_pitch=10,
pressure_angle=20,
involute_facets=7,
clearance=0.5,
backlash=0.5,
rack_thickness=4)
{
  addendum=addendum(circular_pitch=circular_pitch,clearance=clearance);
  dedendum=dedendum(circular_pitch=circular_pitch,clearance=clearance);;
  top_land_width=circular_pitch/2-backlash/2-2*tan(pressure_angle)*addendum;
  root_width=circular_pitch/2-backlash/2+2*tan(pressure_angle)*dedendum;
    
  tooth_profile=[[-root_width/2,-dedendum],[-top_land_width/2,addendum],[top_land_width/2,addendum],[root_width/2,-dedendum]];
    
  rack=concat(flatten([for (i=[0:num_teeth]) translate_list([circular_pitch*i,0],tooth_profile)]),
              [[num_teeth*circular_pitch+root_width/2,-dedendum-rack_thickness],
               [-root_width/2,-dedendum-rack_thickness]]);
  polygon(rack);
}

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function rotate_list(angle,list)=
  [for(i=[0:len(list)-1]) rotate_point(angle,list[i])];
      
function translate_list(translation,list)=
  [for(i=[0:len(list)-1]) [list[i][0]+translation[0],list[i][1]+translation[1]]];

function involute_angle(target_radius,base_radius)=
    sqrt(pow(target_radius/base_radius,2)-1)*180/PI;

function involute_point(base_radius,involute_angle) = 
[
	base_radius*(cos(involute_angle)+involute_angle*PI/180*sin(involute_angle)),
	base_radius*(sin(involute_angle)-involute_angle*PI/180*cos(involute_angle)),
];

function rotate_point(rotate, coord) =
[
	cos(rotate)*coord[0]+sin(rotate)*coord[1],
	cos(rotate)*coord[1]-sin(rotate)*coord[0]
];

// The radius of the gear's pitch circle.
function pitch_radius(
    num_teeth=12,
    circular_pitch=10)=
    num_teeth*circular_pitch/(2*PI);

// Calculate the base radius (that the involute curve unwinds from).
function base_radius(
    num_teeth=12,
    circular_pitch=10,
    pressure_angle=20)=
    pitch_radius(num_teeth,circular_pitch)*cos(pressure_angle);

// The addendum is the distance from the pitch circle to the outer circle (the top of the teeth).
function addendum(
    circular_pitch=10,
    clearance=0.5)=
  circular_pitch/PI-clearance/2;

// The distance from the pitch circle to tooth root (the bottom of the teeth).
function dedendum(
    circular_pitch=10,
    clearance=0.5)=
  addendum(circular_pitch=circular_pitch,clearance=clearance)+clearance/2;

// The radius of the top of the teeth.
function outside_radius(
    num_teeth=12,
    circular_pitch=10,
    clearance=0.5)=
        pitch_radius(num_teeth,circular_pitch)+
        addendum(circular_pitch=circular_pitch,clearance=clearance);
    
// The radius of the tooth depth.
function root_radius(
    num_teeth=12,
    circular_pitch=10,
    clearance=0.5)=
        pitch_radius(num_teeth,circular_pitch)-
        dedendum(circular_pitch=circular_pitch,clearance=clearance);
  
 