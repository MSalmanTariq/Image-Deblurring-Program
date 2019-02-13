PImage img;
PImage img2;
PImage org;
PImage grayed;
PImage dsp1;
PImage dsp2;
PImage dsp3;



ChildApplet child; 

int generation=1;                    // generation count
boolean done=false;      
boolean imageSelected=false;
int m=20;                           // initial population (input)
int n=10;                           // no of child (input)
int sizeX;                          // picture width
int sizeY;                          // picture height
String filename="";
float blurValue = 1.5;              // blur value from 0.0 - 10.0 (input)
float stopingSD = 0.3;            // Stoping Critera in Standard Deviation (input)
float bestSD;

String rootAddress="C:\\Users\\Salman\\Documents\\Processing\\final_project";         // program root address

float [][] individual = new float[m+1][10];


public void settings() {
  size(256, 256);         //initial screen
  smooth();
}


void setup() {
  selectInput("Select an image to process", "imageSelected");

  child = new ChildApplet();               
  noLoop();
}

void imageSelected(File selection) {             // function for image selection
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    filename=selection.getName();
    img=loadImage(selection.getAbsolutePath());
    img2=loadImage(selection.getAbsolutePath());
    org=loadImage(selection.getAbsolutePath());
    org.save(filename.split("\\.")[0]+"\\Original.jpg");
    grayed=loadImage(selection.getAbsolutePath());



    img.filter(GRAY);
    img2.filter(GRAY);
    img.filter(BLUR, blurValue);
    grayed.filter(BLUR, blurValue);
    img2.filter(BLUR, blurValue);
    grayed.save(filename.split("\\.")[0]+"\\Filtered.jpg");
    img2.save(filename.split("\\.")[0]+"\\Filtered(greyscaled).jpg");
    dsp1=img;
    // img.save("me.jpg");
    surface.setSize(sizeX, sizeY);



    sizeX=img2.width;
    sizeY=img2.height;


    child.changeSize(sizeX, sizeY);
    imageSelected=true;
    redraw();
  }
}


void draw() {


  if (imageSelected==true) {            // if iamge is selected by user

    initialize();                       // initialize population

    for (int i=0; i<m; i++) {
      individual[i][9]=fitness(individual[i]);           // calculate function of each individual in initial population
    }

    while (individual[0][9]>=stopingSD) {                  // while stoping critera doesnt match
      print("Generation: "+generation);
      float [][] tempArr = new float[m+n][10];
      arrayCopy(individual, tempArr);
      int arrayLoc=m;
      for (int i=0; i<n/2; i++) {


        //crossover
        int ran1=int(random(m));
        int ran2=int(random(m));

        while (ran1==ran2) {

          ran1=int(random(m));
          ran2=int(random(m));
        }

        float [] child1 = new float[10];
        float [] child2 = new float[10];

        for (int x=0; x<5; x++) {

          child1[x]=individual[ran1][x];             
          child2[x]=individual[ran2][x];
        }

        for (int x=5; x<9; x++) {
          child1[x]=individual[ran2][x];
          child2[x]=individual[ran1][x];
        }

        //mutation
        //child1

        int point=int(random(9));
        if (random(100)<=75) {                                 //mutate
          float mute = mutationConstant();
          if (random(100)<=50) {                              //mutate +ve
            child1[point]=child1[point]+mute;
          } else {                                               //muatate -ve
            child1[point]=child1[point]-mute;
          }
        }


        //child2

        point=int(random(9));
        if (random(100)<=75) {                      //mutate
          float mute = mutationConstant();
          if (random(100)<=50) {                   //mutate +ve
            child2[point]=child2[point]+mute;
          } else {                                    //muatate -ve
            child2[point]=child2[point]-mute;
          }
        }
        // calculating fitness of new population

        //fitness for child1

        child1[9]=fitness(child1);
        for (int j=0; j<10; j++) {
          tempArr[arrayLoc][j]=child1[j];
        }
        arrayLoc++;


        //fitness for child2

        child2[9]=fitness(child2);
        for (int j=0; j<10; j++) {
          tempArr[arrayLoc][j]=child1[j];
        }
        arrayLoc++;
      }


      float [][] sortedArray = sortArr(tempArr);          // selected best 'm' individual from population
      for (int i=0; i<m; i++) {
        individual[i][0]=sortedArray[i][0];
        individual[i][1]=sortedArray[i][1];
        individual[i][2]=sortedArray[i][2];
        individual[i][3]=sortedArray[i][3];
        individual[i][4]=sortedArray[i][4];
        individual[i][5]=sortedArray[i][5];
        individual[i][6]=sortedArray[i][6];
        individual[i][7]=sortedArray[i][7];
        individual[i][8]=sortedArray[i][8];
        individual[i][9]=sortedArray[i][9];
      }
      generation++;
      print("\tStandard Deviation "+individual[0][9]+"\n");
      bestSD=individual[0][9];
    }

    generateEdgeImage();
    done=true;
  } else {
  }
}


float mutationConstant() {                  // random mutation value generator
  return random(0.0000, 1.000000);
  //return randomGaussian();
}


void initialize() {                          // initialize population function
  for (int i=0; i<m; i++) {
    for (int j=0; j<9; j++) {
      individual[i][j]=random(-15, 16);
    }
  }
}

float SD(float pixel[])                             // Standard deviation calculator
{
  int lengthArr=pixel.length;
  float sum = 0.0, standardDeviation = 0.0;

  for (float num : pixel) {
    sum += num;
  }

  float mean = sum/lengthArr;

  for (float num : pixel) {
    standardDeviation += pow(num - mean, 2);
  }
  float s = sqrt(standardDeviation/(lengthArr-1));
  return abs(s-stopingSD);
}

float fitness(float[] chromosome) {                 // fitness function


  float[][] kernel_fy = {{ chromosome[0], chromosome[1], chromosome[2]}, //fy  (kernal for Y-axis)
    {chromosome[3], chromosome[4], chromosome[5]}, 
    { chromosome[6], chromosome[7], chromosome[8]}};

  float[][] kernel_fx = {{ chromosome[2], chromosome[5], chromosome[8]}, //fx  (kernal for X-axis) 
    {chromosome[1], chromosome[4], chromosome[7]}, 
    { chromosome[0], chromosome[3], chromosome[6]}};



  float [] pixelArray=new float[sizeX*sizeY];


  // for fy
  // Loop through every pixel in the image
  for (int y = 1; y < sizeY-1; y++) {                        // Skip top and bottom edges
    for (int x = 1; x < sizeX-1; x++) {                      // Skip left and right edges
      float sum = 0;                                         // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*sizeX + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = alpha(img2.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel_fy[ky+1][kx+1] * val;
          sum= abs(sum);
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      pixelArray[y*sizeX + x] = (sum);
    }
  }
  //for fx

  // Loop through every pixel in the image
  for (int y = 1; y < sizeY-1; y++) {                         // Skip top and bottom edges
    for (int x = 1; x < sizeX-1; x++) {                        // Skip left and right edges
      float sum = 0;                                           // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*sizeX + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = alpha(img2.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel_fx[ky+1][kx+1] * val;
          sum= abs(sum);
        }
      }

      pixelArray[y*sizeX + x] = (sum);
    }
  }

  float sd = SD(pixelArray);
  return sd;
}



float[][] sortArr(float Arr[][]) {                            //  function to sort Array

  float[]tempArr = new float[10];
  float[][] childArr = new float[m+n][10]; 
  arrayCopy(Arr, childArr);
  for (int u = 0; u < (m+n); u++) 
  {
    for (int v = u + 1; v < (m+n); v++) 
    {
      if (childArr[u][9] > childArr[v][9]) 
      {

        tempArr[0] = childArr[u][0];
        tempArr[1] = childArr[u][1];
        tempArr[2] = childArr[u][2];
        tempArr[3] = childArr[u][3];
        tempArr[4] = childArr[u][4];
        tempArr[5] = childArr[u][5];
        tempArr[6] = childArr[u][6];
        tempArr[7] = childArr[u][7];
        tempArr[8] = childArr[u][8];
        tempArr[9] = childArr[u][9];


        childArr[u][0] = childArr[v][0];
        childArr[u][1] = childArr[v][1];
        childArr[u][2] = childArr[v][2];
        childArr[u][3] = childArr[v][3];
        childArr[u][4] = childArr[v][4];
        childArr[u][5] = childArr[v][5];
        childArr[u][6] = childArr[v][6];
        childArr[u][7] = childArr[v][7];
        childArr[u][8] = childArr[v][8];
        childArr[u][9] = childArr[v][9];

        childArr[v][0] =  tempArr[0];
        childArr[v][1] =  tempArr[1];
        childArr[v][2] =  tempArr[2];
        childArr[v][3] =  tempArr[3];
        childArr[v][4] =  tempArr[4];
        childArr[v][5] =  tempArr[5];
        childArr[v][6] =  tempArr[6];
        childArr[v][7] =  tempArr[7];
        childArr[v][8] =  tempArr[8];
        childArr[v][9] =  tempArr[9];
      }
    }
  }

  return childArr;
}

void generateEdgeImage() {
  float[][] kernel_fy = {{ individual[0][0], individual[0][1], individual[0][2]}, 
    {individual[0][3], individual[0][4], individual[0][5]}, 
    {individual[0][6], individual[0][7], individual[0][8]}};

  float[][] kernel_fx = {{ individual[0][2], individual[0][5], individual[0][8]}, 
    {individual[0][1], individual[0][4], individual[0][7]}, 
    { individual[0][0], individual[0][3], individual[0][6]}};





  PImage edgeImg = createImage(sizeX, sizeY, RGB);

  // Loop through every pixel in the image
  for (int y = 1; y < sizeY-1; y++) {   // Skip top and bottom edges
    for (int x = 1; x < sizeX-1; x++) {  // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*sizeX + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(img2.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel_fy[ky+1][kx+1] * val;
          sum= abs(sum);
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*sizeX + x] = color(sum);
      // pixelArray[y*img.width + x] = sum;
    }
  }
  // State that there are changes to edgeImg.pixels[]
  edgeImg.updatePixels();


  // Loop through every pixel in the image
  for (int y = 1; y < sizeY-1; y++) {   // Skip top and bottom edges
    for (int x = 1; x < sizeX-1; x++) {  // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*sizeX + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val =red(img2.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel_fx[ky+1][kx+1] * val;
          sum= abs(sum);
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*sizeX + x] = color(sum);
      // pixelArray[y*img.width + x] = sum;
      //  print(sum+"\n");
    }
  }
  edgeImg.updatePixels();
  edgeImg.save(filename.split("\\.")[0]+"\\Edgemask.jpg");
}


















class ChildApplet extends PApplet {

  boolean imageSelected=false;

  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }


  public void changeSize(int x, int y) {
    if (sizeX>=256||sizeY>=256) {                // if image is larger than 256x256 so resize image for display window
      surface.setSize((256*3)+4, (256*2)+2);
      imageSelected=true;
    } else {
      surface.setSize((x*3)+4, (y*2)+2);
      imageSelected=true;
    }
  }
  public void settings() {
    size(256, 256);
    smooth();
  }
  public void setup() { 
    surface.setTitle("Display Window");
  }

  public void draw() {
    if (imageSelected==true) {

      if (sizeX>=256||sizeY>=256) {
        org.resize(256, 256);
        image(org, 0, 0);                   // Displays Original image
        org.loadPixels();



        grayed.resize(256, 256);
        image(grayed, grayed.width+2, 0); // Displays filtered image
        grayed.loadPixels();



        dsp1.resize(256, 256);
        image(dsp1, (grayed.width*2)+4, 0); // Displays filtered grayscaled image
        dsp1.loadPixels();
      } else {

        image(org, 0, 0);                      // Displays Original image
        org.loadPixels();




        image(grayed, sizeX+2, 0);             // Displays filtered image
        grayed.loadPixels();




        image(dsp1, (sizeX*2)+4, 0);         // Displays filtered grayscaled image
        dsp1.loadPixels();
      }









      //  loadPixels();

      float[][] kernel_fy = {{ individual[0][0], individual[0][1], individual[0][2]}, 
        {individual[0][3], individual[0][4], individual[0][5]}, 
        {individual[0][6], individual[0][7], individual[0][8]}};

      float[][] kernel_fx = {{ individual[0][2], individual[0][5], individual[0][8]}, 
        {individual[0][1], individual[0][4], individual[0][7]}, 
        { individual[0][0], individual[0][3], individual[0][6]}};

      PImage edgeImg = createImage(sizeX, sizeY, RGB);
      // Loop through every pixel in the image
      for (int y = 1; y < sizeY-1; y++) {   // Skip top and bottom edges
        for (int x = 1; x < sizeX-1; x++) {  // Skip left and right edges
          float sum = 0; // Kernel sum for this pixel
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              // Calculate the adjacent pixel for this kernel point
              int pos = (y + ky)*sizeX + (x + kx);
              // Image is grayscale, red/green/blue are identical
              float val = blue(img2.pixels[pos]);
              // Multiply adjacent pixels based on the kernel values
              sum += kernel_fy[ky+1][kx+1] * val;
              sum= abs(sum);
            }
          }
          // For this pixel in the new image, set the gray value
          // based on the sum from the kernel
          edgeImg.pixels[y*sizeX + x] = color(sum);
          // pixelArray[y*img.width + x] = sum;
        }
      }
      // State that there are changes to edgeImg.pixels[]
      // updatePixels();
      edgeImg.updatePixels();

      // Loop through every pixel in the image
      for (int y = 1; y < sizeY-1; y++) {   // Skip top and bottom edges
        for (int x = 1; x < sizeX-1; x++) {  // Skip left and right edges
          float sum = 0; // Kernel sum for this pixel
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              // Calculate the adjacent pixel for this kernel point
              int pos = (y + ky)*sizeX + (x + kx);
              // Image is grayscale, red/green/blue are identical
              float val = blue(img2.pixels[pos]);
              // Multiply adjacent pixels based on the kernel values
              sum += kernel_fx[ky+1][kx+1] * val;
              sum= abs(sum);
            }
          }
          // For this pixel in the new image, set the gray value
          // based on the sum from the kernel
          edgeImg.pixels[y*sizeX + x] = color(sum);
          // pixelArray[y*img.width + x] = sum;
          //  print(sum+"\n");
        }
      }
      edgeImg.updatePixels();


      dsp2=edgeImg;


      if (sizeX>=256||sizeY>=256) {
        dsp2.resize(256, 256);
        image(dsp2, 0, (256)+2);        // display edge mask
      } else {
        image(dsp2, 0, (sizeY)+2);      // display edge mask
      }
    } else {
    }

    if (done==true) {
      print("\n\nCompleted!... Generations==> "+generation+" ... Standard Deviation==> "+bestSD);
      blendImage(this); 
      noLoop();
    }
  }
  void blendImage(ChildApplet a1) {                 // function to blend edge mask over orignal image and produce deblur image

    PImage p1 = loadImage(rootAddress+"\\"+filename.split("\\.")[0]+"\\Filtered.jpg");
    PImage p2 = loadImage(rootAddress+"\\"+filename.split("\\.")[0]+"\\Edgemask.jpg");
    PImage p3 = loadImage(rootAddress+"\\"+filename.split("\\.")[0]+"\\Filtered(greyscaled).jpg");
    PImage p4 = loadImage(rootAddress+"\\"+filename.split("\\.")[0]+"\\Edgemask.jpg");


    p1.blend(p2, 0, 0, sizeX, sizeY, 0, 0, sizeX, sizeY, SOFT_LIGHT );            //blend filterd + edge mask
    p1.save(rootAddress+"\\"+filename.split("\\.")[0]+"\\RESULT.jpg");

    p3.blend(p4, 0, 0, sizeX, sizeY, 0, 0, sizeX, sizeY, SOFT_LIGHT );            //blend filterd (grayscaled) + edge mask
    p3.save(rootAddress+"\\"+filename.split("\\.")[0]+"\\RESULT (Greyscaled).jpg");



    if (sizeX>=256||sizeY>=256) {
      p1.resize(256, 256);
      p3.resize(256, 256);
      image(p3, (256)+2, (256)+2);          //display result(greyscaled)

      image(p1, (256*2)+4, (256)+2);        //display result (colored)
    } else {
      a1.image(p3, (sizeX)+2, (sizeY)+2);      //display result(greyscaled)

      a1.image(p1, (sizeX*2)+4, (sizeY)+2);     //display result (colored)
    }
  }
}
