pad=0.4;
inner_r = 10;
outer_r = 20;
th = 2;
h=20;

epsilon = 0.001; // to avoid z fighting while previewing

//function num_balls(inner_r, outer_r, th) = 


module pairwise_hull() {
    for (i = [0:$children-2]) {
        hull() {
            children(i);
            children(i+1);
        }
    }
}

module bearing(ir = inner_r, or=outer_r, pad=pad, h=h) {
    rd = or - ir;
    difference() {
        square([rd, h], center=true);
        square([rd-th*2*2, h+epsilon], center=true);
        hull() {
            square([rd-th*2, h-th*2*2+epsilon], center=true);
            square([rd-th*2*2, h-th*2+epsilon], center=true);
        }

    }
    module cuts(p) {
        difference() {
            square([rd, h], center=true);
            square([rd-th*2*2+p*2, h+epsilon], center=true);
            hull() {
                square([rd-th*2+p*2, h-th*2*2+epsilon], center=true);
                square([rd-th*2*2+p*2, h-th*2+epsilon], center=true);
            }

        }
    }
    
    cuts(p=0);
}
bearing();
