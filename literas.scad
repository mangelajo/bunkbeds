// vigas:
// 12x6 http://www.maderasnavalcarnero.com/producto/836/viga-laminada-de-abeto-secc-12-x-6-cm.php
//      http://www.hguillen.com/2011/03/vigas-cuartones-y-listones/
// 10x10


// parámetros de los materiales:

ancho_viga = 12;
fondo_viga = 4;

ancho_liston = 6;
fondo_liston = 4;
grosor_tabla = 1.9;


// parámetros de la cama:

fondo_colchon_ = 80; 
largo_colchon_ = 200;

margen_colchon = 1; // margen del colchon por cada lateral

alto_colchon = 20;

alto_vigas = 200;
alto_litera = 120;

soportes_inferiores = 8;

output_materials = false;

// parámetros calculados en función de otros:
fondo_colchon =  80 + margen_colchon * 2;
largo_colchon = 200 + margen_colchon * 2;
_fondo_cama = fondo_colchon + fondo_viga*2;


module viga(len, invert=false) {
     if (invert) {
        color("BurlyWood") cube([fondo_viga,ancho_viga,len]);
     } else {
        color("BurlyWood") cube([ancho_viga,fondo_viga,len]);
     }
     if (output_materials) echo("viga longitud: ", len);
}

module liston(len, invert=false) {
     if (invert) {
        color("BurlyWood") cube([fondo_liston,ancho_liston,len]);
     } else {
        color("BurlyWood") cube([ancho_liston,fondo_liston,len]);
     }
     if (output_materials) echo("liston longitud: ", len);
}

module tabla(ancho, alto) {
    color("SaddleBrown") cube([grosor_tabla, ancho, alto]);
    if (output_materials) echo("tabla: ",ancho," x ",alto," x ", grosor_tabla);
}




module colchon() {
    translate([margen_colchon, margen_colchon, 0]) color ("white") cube([largo_colchon_, fondo_colchon_, alto_colchon]);
}
module cama() {
    // patas que suben
    for (i=[0:1]) {
         translate([i * (largo_colchon - ancho_viga), 0, 0]) {
            viga(alto_vigas);
            translate([0,fondo_viga + fondo_colchon ,0]) {
                 viga(alto_vigas);
            }
        }

         // refuerzos de las patas
         color("red") {
             translate([i * (largo_colchon - ancho_viga), 
                        +fondo_viga,
                         0]) viga(26);
             translate([i * (largo_colchon - ancho_viga),
                         fondo_viga + fondo_colchon -fondo_viga,
                           0]) viga(26);
            
        }
    }

    // frontal litera
    translate([ancho_viga, grosor_tabla, alto_litera + alto_colchon+20]) rotate([0, 0, -90 ]) tabla(largo_colchon-ancho_viga*2, 40);

    // refuerzos estructurales
    for(j=[0:1]) {
        for(i=[0:1]) {
            
            translate([(largo_colchon-fondo_viga)*j, fondo_viga, 70+40*i]) 
                rotate([-90, -90, 0]) viga(fondo_colchon);
        }
        // refuerzo inferior estructural
        translate([(largo_colchon-fondo_viga)*j, fondo_viga, 14]) 
                rotate([-90, -90, 0]) viga(fondo_colchon);
    }
    

    // camas 
    for (i=[0:1]) {
        translate([0, 0, alto_litera * i]) {
         
            // colchon   
            translate([0,fondo_viga,30]) { colchon(); }
            
            for (j=[0:soportes_inferiores-1]) {
                // soportes inferiores colchon
                translate([ancho_viga + j*((largo_colchon-ancho_viga)/(soportes_inferiores-1)), fondo_viga ,18+ancho_viga]) {
                    rotate([0,90,90]) viga(fondo_colchon, true);
                }
            }

            // panel trasero
            translate([ancho_viga, 
                       fondo_colchon + fondo_viga*2,
                       alto_colchon + 24]) { rotate([0, 0, -90 ]) 
                                             tabla(largo_colchon-ancho_viga*2, 30);}
            
            // vigas a los laterales del colchon
            translate([ancho_viga, 0 ,24+ancho_viga]) {
                rotate([0,90,0]) viga(largo_colchon-ancho_viga * 2);
            }
                
            // viga posterior
            translate([ancho_viga, fondo_colchon+fondo_viga,24+ancho_viga]) {
                rotate([0,90,0]) viga(largo_colchon-ancho_viga * 2);
            }
            
        }
    }
}

peldanos_escalera = 4;
largo_escalera = 90;
ancho_escalera = 46-grosor_tabla;
alto_peldano=30;

_largo_peldano = largo_escalera / peldanos_escalera;
_alto_escalera = peldanos_escalera * alto_peldano;

//cama();
// escalera ========

// peldaños 

module peldanos() {
    translate([0,grosor_tabla,0]) rotate([-90,-90,0]) tabla(ancho_escalera, largo_escalera - grosor_tabla);
        
    for (i=[0:peldanos_escalera-1]) {
         translate([0,largo_escalera ,grosor_tabla + (i+1) * alto_peldano])
            rotate([90,90,0]) tabla(ancho_escalera, largo_escalera - (i*_largo_peldano)-grosor_tabla);
        
    }

    translate([0, largo_escalera, 0]) {
        rotate([90,0,90]) tabla(_alto_escalera + grosor_tabla, ancho_escalera);
    }
    translate([0, 0, 0]) {
        rotate([90,0,90]) {
            tabla(alto_peldano + grosor_tabla, ancho_escalera);
        }
    }
    // resto de tablas frontales peldaños
    for(i=[1:peldanos_escalera-1])  {
        translate([0, _largo_peldano*i, alto_peldano*i+grosor_tabla]) {
            rotate([90,0,90]) tabla(alto_peldano, ancho_escalera);
        }
    }
     tabla(largo_escalera, alto_peldano+grosor_tabla);
       for(i=[1:peldanos_escalera-1]) {
        translate([0,_largo_peldano*i,grosor_tabla + alto_peldano*i]) tabla(largo_escalera-_largo_peldano*i+grosor_tabla,alto_peldano);
    }
    
    // refuerzos peldanos
    // bajo
    translate([0,largo_escalera/2,grosor_tabla])
        rotate([90,0,90]) tabla(alto_peldano-grosor_tabla,ancho_escalera);
    // siguiente
    translate([0,_largo_peldano*(peldanos_escalera-1),grosor_tabla+alto_peldano])
        rotate([90,0,90]) tabla(alto_peldano-grosor_tabla,ancho_escalera);
    
    // pie barandilla 0
    translate([ancho_escalera,0,alto_peldano+grosor_tabla]) rotate([0,0,90]) viga(50);
    
    // pie barandilla 1
    translate([ancho_escalera,largo_escalera-ancho_viga+grosor_tabla,alto_peldano*(peldanos_escalera)+grosor_tabla]) rotate([0,0,90]) viga(75);
    
    // pie barandilla 2
    translate([ancho_escalera, _largo_peldano*1, alto_peldano*(2)+grosor_tabla]) rotate([0,0,90]) liston(50);
    translate([ancho_escalera, _largo_peldano*1.6, alto_peldano*(2)+grosor_tabla]) rotate([0,0,90]) liston(60);
    
    
    // pie barandilla 3
    translate([ancho_escalera, _largo_peldano*2.25, alto_peldano*(3)+grosor_tabla]) rotate([0,0,90]) liston(50);
    // pie barandilla 3
    translate([ancho_escalera, _largo_peldano*3-ancho_liston, alto_peldano*(3)+grosor_tabla]) rotate([0,0,90]) liston(70);
    
    // barandilla
    translate([ancho_escalera, 0, alto_peldano+50+grosor_tabla]) rotate([-35,0,0]) rotate([0,0,90]) viga(150);
    
    // union barandilla <-> cama x3 
    for (i=[1:3]) {
        translate([0,
                   largo_escalera-fondo_viga,
                   alto_peldano*peldanos_escalera+i*(75/3)]) 
            rotate([0, 90, 0]) viga(ancho_escalera-fondo_viga);
    }
}

cama();
translate([largo_colchon,0,0]) peldanos();

