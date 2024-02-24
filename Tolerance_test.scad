// Tolerance Tester
// Design inspired by jczuba (https://www.printables.com/model/740643-tolerance-test)
// Parameterized version by argoolsbee (https://www.printables.com/model/779616-tolerance-test-parameterized)

/* [Dimensions] */
// List of tolerance offsets
test_tolerances = [-0.1, 0, 0.1, 0.15, 0.2, 0.33, 0.4, 0.5];
// Size of test holes
test_size = 3;
// Spacing around test holes
test_hole_margin = 2;
// Thickness of base
base_height = 3.0;

/* [Options] */
// Include horizontal plane
horizontal = true;
// Include vertical plane
vertical = true;
// Count of each orientation 
peg_count = 1;
// Count of each orientation 
peg_storage_count = 1;

/* [Advanced] */
$fn = 64;

/* [Hidden] */
eps = 0.01;
PERPENDICULAR = "PERPENDICULAR";
PARALLEL = "PARALLEL";

test_count = len(test_tolerances);
base_unit_width = test_size + (test_hole_margin * 2);
base_depth = (test_hole_margin * 5) + (test_size * 2);

module parallel_symbol() {
    square([test_size / 2.5, test_size / 8]);
    
    translate([0, test_size / 4, 0])
        square([test_size / 2.5, test_size / 8]);
}

module perpendicular_symbol() {
    square([test_size / 2.5, test_size / 8]);
    
    translate([test_size / 3.75, 0, 0])
        rotate([0, 0, 90])
            square([test_size / 2.5, test_size / 8]);
}

module base(test_tolerances, test_size, test_hole_margin, base_height, orientation) {
    difference() {
        for(i = [0 : 1 : test_count - 1]) {
            test_tolerance = test_tolerances[i];
            test_hole = test_size + (test_tolerance * 2);
            
            translate([base_unit_width * i, 0, 0]) {
                difference() {
                    cube([base_unit_width, base_depth, base_height]);
                    // square
                    translate([test_hole_margin - test_tolerance, base_depth - test_hole_margin - test_hole, 0 - eps])
                        cube([test_hole, test_hole, base_height + (2 * eps)]);
                    // text
                    translate([base_unit_width / 2, base_depth / 2,  3 - 1 + eps])
                        linear_extrude(1)
                            text(str(test_tolerance), size = test_hole_margin * 1.33333, halign = "center", valign = "center");
                    // circle 
                    translate([test_hole_margin + (test_hole / 2) - test_tolerance, test_hole_margin + (test_hole / 2), 0 - eps])
                        cylinder(h = base_height + (2 * eps), d = test_hole);
                }
            }
        }
        
        // orientation symbols
        if(orientation == PARALLEL) {
            translate([0.3, 0.3, -eps])
                linear_extrude(base_height + (eps * 2))
                    parallel_symbol();
        } else if(orientation == PERPENDICULAR) {
            translate([0.3, 0.3, -eps])
                linear_extrude(base_height + (eps * 2))
                    perpendicular_symbol();
        }
        
        // test size text 
        translate([base_unit_width / 2, base_depth / 2, 1 - eps])
            rotate([0, 180, 0])
                linear_extrude(1)
                    text(str(test_size), size = test_hole_margin * 1.33333, halign = "center", valign = "center");
    }
    
    // peg storage
    peg_storage_offset = 0.2;
    for(i = [1 : 1 : peg_storage_count]) {
        translate([base_unit_width * (test_count + i - 1), 0, 0])
            difference() {
                cube([base_unit_width, base_depth, base_height]);
                
                translate([test_hole_margin - (peg_storage_offset / 2), test_hole_margin - (peg_storage_offset / 2), base_height + (test_size / 2)])
                    rotate([-90, 0, 0])
                        peg(offset = peg_storage_offset);
                
                translate([test_hole_margin + (test_size / 2), test_hole_margin + (test_size / 2), 0 - eps])
                    cylinder(h = base_height + eps, d = test_size + (peg_storage_offset));
            }
    }

}

module peg(offset = 0, orientation) {
    peg_width = test_size + offset;
    peg_depth = test_size + offset;
    peg_length = (test_size * 2) + (test_hole_margin * 3) + offset;
    segment_length = peg_length / 3;
    
    difference() {
        union() {
            // square
            cube([peg_width, peg_depth, segment_length]);
            // circle
            translate([peg_width / 2, peg_depth / 2, segment_length - eps])
                cylinder(d = peg_width, h = segment_length + eps);
            // hexigon
            translate([peg_width / 2, peg_depth / 2, (segment_length * 2) - eps])
                cylinder(d = peg_width, h = segment_length + eps, $fn=6);
            
            
        }
        
        // test size text
        if(orientation) {
            translate([(test_size / 2), (test_size / 2), 1 - eps])
                    rotate([0, 180, 0])
                        linear_extrude(1)
                            text(str(test_size), size = test_size * .66, halign = "center", valign = "center");
        }
        
        // orientation symbols
        if(orientation == PARALLEL) {
            translate([(test_size / 3.3333), (test_size / 3.25), peg_length - 0.6])
                linear_extrude(0.6 + eps)
                    parallel_symbol();
        } else if(orientation == PERPENDICULAR) {          
            translate([(test_size / 3.3333), (test_size / 3.25), peg_length - 0.6])
                linear_extrude(0.6 + eps)
                    perpendicular_symbol();
        }
    }
}

// base
difference() {
    union() {
        if(horizontal) {
            base(test_tolerances, test_size, test_hole_margin, base_height, PERPENDICULAR);
        }
        
        if(vertical && !horizontal) {
            translate([0, base_height, 0])
                rotate([90, 0, 0])
                    base(test_tolerances, test_size, test_hole_margin, base_height, PARALLEL);
        }
    
        if(horizontal && vertical) {
            translate([0, base_depth + base_height, base_height])
                rotate([90, 0, 0])
                    base(test_tolerances, test_size, test_hole_margin, base_height, PARALLEL);
        
            translate([0, base_depth, 0])
                cube([(base_unit_width * test_count) + (base_unit_width * peg_storage_count), base_height, base_height]);
        }
    }
}

// pegs
for(i = [0 : 1 : peg_count - 1]) {
    translate([-test_size - test_size, i * (test_size + (test_hole_margin * 2)), 0])
        peg(orientation = PARALLEL);
    
    translate([-(test_size * 3), i * (test_size + (test_hole_margin * 2)), test_size])
        rotate([-90, 0, 90])
            peg(orientation = PERPENDICULAR);
}
