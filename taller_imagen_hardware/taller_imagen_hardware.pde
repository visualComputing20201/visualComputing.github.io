PGraphics pg1,pg2;
PImage img;
PShape texImg;
PShader lumaShader, grayShader,convolutionShader;

PrintWriter image_registro;

int alto,ancho, selector=5;
final int pg_x=600, pg_y=400;

float k = 1.0/9;
float k2 = 1.0/16;
float[] sharpenKernel = { -1, -1, -1 , -1,  9, -1 , -1, -1, -1  };
float[] blurKernel = { k, k, k , k, k, k , k, k, k  };
float[] gaussianBlurKernel = {  k2, 2*k2, k2 , 2*k2 ,4*k2 ,2*k2 ,  k2, 2*k2, k2  };
float [] edgeKernel = {-1, -1, -1,-1, 8, -1,-1, -1, -1};


void setup() {
    ancho = 600;
    alto = 400;
    size(1300,520,P2D);
    pg1 = createGraphics(ancho,alto,P2D);
    pg2 = createGraphics(ancho,alto,P2D); 
    img = loadImage("principito.png");
    texImg = createShapeT(img, ancho,alto);  
    image_registro = createWriter("image_registro_hardware.txt");
    
    lumaShader = loadShader("luma.glsl");
    grayShader = loadShader("gray.glsl");
    convolutionShader = loadShader("convolution.glsl");
}

void draw() {  
    pg1.beginDraw();
    pg1.shape(texImg);
    pg1.endDraw();
    escoger_opcion();
    switch(selector) {
        case 1: 
        pg2.beginDraw();
        pg2.shader(grayShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
        case 2:
        pg2.beginDraw();
        pg2.shader(lumaShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
        case 3: 
        convolutionShader.set("kernel", blurKernel);
        pg2.beginDraw();
        pg2.shader(convolutionShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
        case 4:
        convolutionShader.set("kernel", sharpenKernel);
        pg2.beginDraw();
        pg2.shader(convolutionShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
        case 5:
        convolutionShader.set("kernel", edgeKernel);
        pg2.beginDraw();
        pg2.shader(convolutionShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
        case 6:
        convolutionShader.set("kernel", gaussianBlurKernel);
        pg2.beginDraw();
        pg2.shader(convolutionShader);
        pg2.shape(texImg);
        pg2.endDraw();
        break;
    }
  image(pg1, 5, 40);
  image(pg2, ancho+95, 40);
  image_registro.println("");
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
  fill(0);
  text("Grises", 612, 60);
  text("Luma", 612, 100);
  text("Blur", 612, 140);
  text("Sharpen", 612, 180);
  text("Edge", 612, 220);
  text("Gaussian Blur", 612, 260);
  text("Frame Rate", 612, 300);
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

PShape createShapeT(PImage tex, int x, int y) {
  textureMode(NORMAL);
  PShape shape = createShape();
  shape.beginShape();
  shape.noStroke();  
  shape.texture(tex);
  shape.vertex(0, 0, 0, 0);
  shape.vertex(x, 0, 1, 0);
  shape.vertex(x, y, 1, 1);
  shape.vertex(0, y, 0, 1);
  
  shape.endShape();
  return shape;
}
