# Digital-System-Design-for-Image-Convolution
An image is just a matrix of pixels. In convolution, Kernels/Filter are used to read the patterns in
the image. A Kernel/Filter is a small matrix where each cell has certain value with which the
respective pixels values are multiplied and added and the convolved feature is extracted.
Convolution is the process of adding each element of the image to its local neighbors, weighted
by the kernel. This is related to a form of mathematical convolution. The matrix operation being
performed convolution is not traditional matrix multiplication, despite being similarly denoted by
*.
## Filter
The filter that we are using is the sharpen filter

$$
\begin{bmatrix}
0 & -1 & 0 \\
-1 & 5 & -1 \\
0 & -1 & 0 \\
\end{bmatrix}
$$

There are many different versions of sharping filters. We used this filter because of its better
results.
The border pixels are excluded from the image convolution, the output image is smaller than the input
image.

## Import Image in Verilog
Verilog cannot read images directly. To read an image of any format in Verilog, the
image is required to be converted from the given format to the COE format. This can be done by
an external environment (other than Xilinx) such as MATLAB or any C++ compiler.
However, MATLAB was used to convert the sample image of 28x28x3 dimension to COE format.
