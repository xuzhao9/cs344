// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Grean and Blue is in it.
//The 'A' stands for Alpha and is used for transparency, it will be
//ignored in this homework.

//Each channel Red, Blue, Green and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "utils.h"

__device__
int next_power_of_2(int sz) {
}

__device__
int _pixel_coordinate_to_offset(int x, int y, int numRows, int numCols) {

}

__device__
void _transform(const uchar4* const rgbaImage,
                unsigned char* const greyImage,
                int pixel_offset) {
  greyImage[pixel_offset] = rgbaImage[pixel_offset].R * 0.299f + \
                            rgbaImage[pixel_offset].G * 0.587f + \
                            rgbaImage[pixel_offset].B * 0.114f;
}

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  //TODO
  //Fill in the kernel to convert from color to greyscale
  //the mapping from components of a uchar4 to RGBA is:
  // .x -> R ; .y -> G ; .z -> B ; .w -> A
  //
  //The output (greyImage) at each pixel should be the result of
  //applying the formula: output = .299f * R + .587f * G + .114f * B;
  //Note: We will be ignoring the alpha channel for this conversion

  //First create a mapping from the 2D block and grid locations
  //to an absolute 2D location in the image, then use that to
  //calculate a 1D offset

  //Suppose the image format is row-major
  // get number of pixels per threads
  numRowsRounded = next_power_of_2(numRows);
  numColsRounded = next_power_of_2(numCols);
  rowSize = numRowsRounded / (blockDim.x * gridDim.x);
  colSize = numColsRounded / (blockDim.y * gridDim.y);
  //get the top-left location id
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int idy = blockIdx.y * blockDim.y + threadIdx.y;
  //calculate the top-left coordinate
  int top_left_pixel_x = numCols * idx;
  int top_left_pixel_y = colSize * idy;
  //traverse each pixel
  for (int i = 0; i < rowSize; i ++) {
    for (int j = 0; j < colSize; j ++) {
      int pixelx = top_left_pixel_x + i;
      int pixely = top_left_pixel_y + i;
      int pixel_offset = _pixel_coordinate_to_offset(pixelx, pixely, numRows, numCols);
      if (pixelx < numRows && pixely < numCols) {
        _transform(rgbaImage, greyImage, pixel_offset);
      }
    }
  }
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  //You must fill in the correct sizes for the blockSize and gridSize
  //currently only one block with one thread is being launched
  const dim3 blockSize(1, 1, 1);  //TODO
  const dim3 gridSize( 1, 1, 1);  //TODO
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());

}
