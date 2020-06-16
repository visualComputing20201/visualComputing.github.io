import processing.video.*;
Movie video;
int alto,ancho, selector=5;
PGraphics pg1,pg2;
float k = 1.0/9;
float k2 = 1.0/16;
float[][] sharpenKernel = { { -1, -1, -1 },{ -1,  9, -1 },{ -1, -1, -1 } };
float[][] blurKernel = { { k, k, k },{ k, k, k },{ k, k, k } };
float[][] gaussianBlurKernel = { { k2, 2*k2, k2 },{ 2*k2 ,4*k2 ,2*k2 }, { k2, 2*k2, k2 } };
float [][] edgeKernel = {{-1, -1, -1},{-1, 8, -1},{-1, -1, -1}};
char[] ascii;
int resolution = 4;
PrintWriter fps_registro;
void setup() {
  size(1300,520);   
  fps_registro = createWriter("fps_registro_software.txt");
  video = new Movie(this, "launch2.mp4");
  video.loop();
  ancho = 600;
  alto = 400;
  pg1 = createGraphics(ancho,alto);
  pg2 = createGraphics(ancho,alto);
  ascii = new char[256];
  String letters = "`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$";
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letters.length()));
    ascii[i] = letters.charAt(index);
  }
  PFont mono = createFont("Courier", resolution+2);
  textFont(mono);
 
}

void draw() {  
  if (video.available()) {
      video.read();
  }
  pg1.beginDraw();
  pg1.image(video,5,40,ancho,alto);
  pg1.endDraw();
  image(pg1,5,40);

  
  escoger_opcion();
  switch(selector) {
    case 1: 
      pg1.beginDraw();
      escala_grises(pg1);
      pg1.endDraw();
      image(pg1,ancho+95,40);
      break;
    case 2:
      pg1.beginDraw();
      luma(pg1);
      pg1.endDraw();
      image(pg1,ancho+95,40);
      break;
    case 3: 
      pg2.beginDraw();
      convolucion(blurKernel,pg1,pg2,3);
      pg2.endDraw();
      image(pg2,ancho+95,40);
      break;
    case 4:
      pg2.beginDraw();
      convolucion(sharpenKernel,pg1,pg2,3);
      pg2.endDraw();
      image(pg2,ancho+95,40);
      break;
    case 5:
      pg2.beginDraw();
      convolucion(edgeKernel,pg1,pg2,3);
      pg2.endDraw();
      image(pg2,ancho+95,40);
      break;
    case 6:
      pg2.beginDraw();
      convolucion(gaussianBlurKernel,pg1,pg2,3);
      pg2.endDraw();
      image(pg2,ancho+95,40);
      break;
    case 7:
      pg2.beginDraw();
      pg2.clear();
      fill(255);
      rect(ancho+90, 40, ancho, alto);
      fill(0);
      to_ascii(pg1,pg2);
      pg2.endDraw();
      image(pg2,ancho+95,40);
      break;
  }
  fps_registro.println(frameRate);
  
}
void to_ascii(PImage original, PImage destino) {
  destino = original;
  destino.filter(GRAY);
  destino.loadPixels();
  for (int y = 0; y < destino.height; y += resolution) {
    for (int x = 0; x < destino.width; x += resolution) {
      color pixel = destino.pixels[y * destino.width + x];
      text(ascii[int(brightness(pixel))], x+ancho+90, y+40);
    }
  }
  destino.updatePixels();

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
      color c = aplicar_kernel(x,y,kernel, tamanio_kernel,original);
      int loc = x + y*original.width;
      destino.pixels[loc] = c;
    }
  }
  destino.updatePixels();
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
  text("Ascii", 612, 300);
  text("Frame Rate", 612, 340);
  text(str(frameRate), 612, 380);
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
  else if(mouseX > 610 && mouseX < 690 && mouseY > 280 && mouseY < 310) 
    selector = 7;
}
