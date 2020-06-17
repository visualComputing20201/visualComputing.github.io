PGraphics  p_graphics_histograma;

PImage img, 
    img_escala_gris, 
    img_luma, 
    img_segmentacion_brightness, 
    img_kernel_sharpen, 
    img_kernel_blur, 
    img_deteccion_limite, 
    img_kernel_gaussian_blur, 
    img_ascii;
int alto,ancho, selector = 5;
int pgraphics_original_x, pgraphics_original_y, pgraphics_generado_x, pgraphics_generado_y, hist[];
float k = 1.0/9;
float k2 = 1.0/16;
float seg_s=-1.0, seg_e=-1.0;
float[][] sharpenKernel = { { -1, -1, -1 },{ -1,  9, -1 },{ -1, -1, -1 } };
float[][] blurKernel = { { k, k, k },{ k, k, k },{ k, k, k } };
float[][] gaussianBlurKernel = { { k2, 2*k2, k2 },{ 2*k2 ,4*k2 ,2*k2 }, { k2, 2*k2, k2 } };
float [][] edgeKernel = {{-1, -1, -1},{-1, 8, -1},{-1, -1, -1}};
char[] ascii;
int resolution = 9;

void setup() {
  size(1300,520);
  img = loadImage("p1.png");
  hist = histogram(img);
  img_escala_gris = loadImage("p1.png");
  img_luma = loadImage("p1.png");
  img_ascii = loadImage("p1.png");
  img_segmentacion_brightness = createImage(img.width, img.height, RGB);
  img_kernel_sharpen = createImage(img.width, img.height, RGB);
  img_kernel_blur = createImage(img.width, img.height, RGB);
  img_deteccion_limite = createImage(img.width, img.height, RGB);
  img_kernel_gaussian_blur = createImage(img.width, img.height, RGB);
  pgraphics_original_x = 5;
  pgraphics_original_y = 40;
  pgraphics_generado_x = img.width+90+pgraphics_original_x;
  pgraphics_generado_y = 40;
  p_graphics_histograma = createGraphics(img.width, img.height);
  ascii = new char[256];
  ancho = 600;
  alto = 400;
  String letters = "`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$";
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letters.length()));
    ascii[i] = letters.charAt(index);
  };
  PFont mono = createFont("Courier", resolution+2);
  textFont(mono);
}

void draw() {
  escoger_opcion();
  switch(selector) {
    case 1: 
        image(img, pgraphics_original_x, pgraphics_original_y);
        escala_grises(img_escala_gris);
        image(img_escala_gris, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 2: 
        image(img, pgraphics_original_x, pgraphics_original_y);
        luma(img_luma);
        image(img_luma, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 3: 
        image(img, pgraphics_original_x, pgraphics_original_y);
        convolucion(blurKernel, img, img_kernel_blur,3);
        image(img_kernel_blur, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 4:
        image(img, pgraphics_original_x, pgraphics_original_y);   
        convolucion(sharpenKernel, img, img_kernel_sharpen, 3);
        image(img_kernel_sharpen, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 5:
        image(img, pgraphics_original_x, pgraphics_original_y);
        convolucion(edgeKernel, img, img_deteccion_limite, 3);
        image(img_deteccion_limite, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 6:
        image(img, pgraphics_original_x, pgraphics_original_y);
        convolucion(gaussianBlurKernel, img, img_kernel_gaussian_blur, 3);
        image(img_kernel_gaussian_blur, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 7:
        image(img, pgraphics_original_x, pgraphics_original_y);
        p_graphics_histograma.beginDraw();
        dibujar_histograma(hist, p_graphics_histograma);
        p_graphics_histograma.endDraw();
        image(p_graphics_histograma, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 8:
        image(img, pgraphics_original_x, pgraphics_original_y);
        umbral_brillo_segmentacion(img, img_segmentacion_brightness, min(seg_s,seg_e), max(seg_s,seg_e));
        image(img_segmentacion_brightness, pgraphics_generado_x, pgraphics_original_y);
        break;
    case 9:
        image(img, pgraphics_original_x, pgraphics_original_y);
        fill(255);
        rect( ancho + 95, 35, ancho, 325);
        fill(0);
        convertir_ascii(img_ascii);
        break;
  }
}

void escala_grises(PImage img) {  
  for(int i=0; i<img.width; i++){
    for(int j=0; j<img.height; j++){
      color c = img.get(i,j);
      c = color(Math.round((red(c) + green(c) + blue(c))/3));
      img.set(i,j,c);      
    }
  }
}

void luma(PImage img) {  
  for(int i=0; i<img.width; i++){
    for(int j=0; j<img.height; j++){
      color c = img.get(i,j);
      c = color(Math.round((0.299*red(c) + 0.587*green(c) + 0.114*blue(c))));
      img.set(i,j,c);      
    }
  }
}

int [] histogram(PImage img){
  int[] hist = new int[256];
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      int bright = int(brightness(img.get(i, j)));
      hist[bright]++; 
    }
  }
  return hist;
}

void dibujar_histograma(int[] hist, PGraphics p_graphics_histograma){
  int histMax = max(hist);
  for (int i = 0; i < p_graphics_histograma.width; i += 2) {
    int which = int(map(i, 0, p_graphics_histograma.width, 0, 255));
    int y = int(map(hist[which], 0, histMax, p_graphics_histograma.height, 0));
    p_graphics_histograma.line(i, p_graphics_histograma.height, i, y);
  }
}

void umbral_brillo_segmentacion (PImage original, PImage destino, float comienzo, float fin){
  if (comienzo ==-1.0 || fin == -1.0){
    comienzo = 5;
    fin = 150;
  }
  else{
    comienzo  = map(comienzo, 0, p_graphics_histograma.width, 0, 255);
    fin = map(fin, 0, p_graphics_histograma.width, 0, 255);
  }
  original.loadPixels();
  destino.loadPixels();
  
  for (int x = 0; x < original.width; x++) {
    for (int y = 0; y < destino.height; y++ ) {
      int loc = x + y*original.width;
      float b = brightness(original.pixels[loc]);
      if (b > comienzo && b < fin) {        
        destino.pixels[loc]  = color(255); 
      }  
      else {
        destino.pixels[loc]  = color(0);   
      }
    }
  }
  destino.updatePixels();
}

color aplicar_kernel(int x, int y, float[][] kernel, int tamanio_kernel, PImage img) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = tamanio_kernel / 2;
  for (int i = 0; i < tamanio_kernel; i++){
    for (int j= 0; j < tamanio_kernel; j++){
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      loc = constrain(loc,0,img.pixels.length-1);
      rtotal += (red(img.pixels[loc]) * kernel[i][j]);
      gtotal += (green(img.pixels[loc]) * kernel[i][j]);
      btotal += (blue(img.pixels[loc]) * kernel[i][j]);
    }
  }
  rtotal = constrain(rtotal,0,255);
  gtotal = constrain(gtotal,0,255);
  btotal = constrain(btotal,0,255);
  return color(rtotal,gtotal,btotal);
}

void convolucion(float[][] kernel, PImage original, PImage destino, int tamanio_kernel){
  original.loadPixels();
  destino.loadPixels();
  for (int x = 0; x < original.width; x++) {
    for (int y = 0; y < destino.height; y++ ) {
      color c = aplicar_kernel(x,y,kernel, tamanio_kernel,img);
      int loc = x + y*img.width;
      destino.pixels[loc] = c;
    }
  }
  destino.updatePixels();
}

void convertir_ascii(PImage img) { 
    img.filter(GRAY);
    img.loadPixels();
    for (int y = 0; y < img.height; y += resolution) {
        for (int x = 0; x < img.width; x += resolution) {
        color pixel = img.pixels[y * img.width + x];
        text(ascii[int(brightness(pixel))], x + ancho + 95, y+46);
        }
    };
    //mg.updatePixels();
}

void escoger_opcion(){
  fill(255);
  rect(610, 40, 80, 30);
  rect(610, 80, 80, 30);
  rect(610, 120, 80, 30);
  rect(610, 160, 80, 30);
  rect(610, 200, 80, 30);
  rect(610, 240, 80, 30);
  rect(610, 280, 80, 30);
  rect(610, 320, 80, 30);
  rect(610, 360, 80, 30);
  fill(0);
  text("Grises", 612, 60);
  text("Luma", 612, 100);
  text("Blur", 612, 140);
  text("Sharpen", 612, 180);
  text("Edge", 612, 220);
  text("Gaussian Blur", 612, 260);
  text("Histograma", 612, 300);
  text("Segmentación", 612, 340);
  text("ASCII", 612, 380);
  textSize(10);
  noFill();
}

void mouseClicked() {
  background(200);
  if(mouseX > 610 && mouseX < 725 && mouseY > 40 && mouseY < 70)
    selector = 1;
  if(mouseX > 610 && mouseX < 725 && mouseY > 80 && mouseY < 110)
    selector = 2;
  else if(mouseX > 610 && mouseX < 690 && mouseY > 120 && mouseY < 150) 
    selector = 3;
  else if(mouseX > 610 && mouseX < 690 && mouseY > 160 && mouseY < 190) 
    selector = 4;
  else if(mouseX > 610 && mouseX < 690 && mouseY > 200 && mouseY < 230) 
    selector = 5;
  else if(mouseX > 610 && mouseX < 690 && mouseY > 240 && mouseY < 270) 
    selector = 6;
  else if(mouseX > 610 && mouseX < 690 && mouseY > 280 && mouseY < 310) {
    selector = 7;
    seg_s=-1.0;
    seg_e=-1.0;
  }
  else if(mouseX > 610 && mouseX < 690 && mouseY > 320 && mouseY < 350) 
    selector = 8;
  else if(selector == 7 && mouseX > pgraphics_generado_x && mouseX < pgraphics_generado_x + img.width && mouseY > pgraphics_original_y && mouseY < pgraphics_original_y + img.height){
    if(seg_s == -1.0){
      seg_s = mouseX-pgraphics_generado_x;
      line(mouseX, pgraphics_original_y, mouseX, pgraphics_original_y + p_graphics_histograma.height);
    }else if(seg_e == -1.0){
      seg_e = mouseX-pgraphics_generado_x;
      line(seg_s+pgraphics_generado_x, pgraphics_original_y, seg_s+pgraphics_generado_x, pgraphics_original_y + p_graphics_histograma.height);
      line(mouseX, pgraphics_original_y, mouseX, pgraphics_original_y + p_graphics_histograma.height);
    }
  }
  else if (mouseX > 610 && mouseX < 690 && mouseY > 360 && mouseY < 390)
    selector = 9;
}