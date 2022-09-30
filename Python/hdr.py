import numpy
import cv2
import math

n = 4

low = cv2.imread('Images/image_' + str(n) + '_low.png')
mid = cv2.imread('Images/image_' + str(n) + '_mid.png')
high = cv2.imread('Images/image_' + str(n) + '_high.png')

exp_time_low = math.log(0.000006548*(127-11*11)*4)
exp_time_mid = math.log(0.000006548*(127-11*10)*4)
exp_time_high = math.log(0.000006548*127*4)

g_red =[]
g_green =[]
g_blue =[]

with open('g_red', 'r') as f:
    for y in f.read().split('\n'):
        if y:
            g_red.append(float(y))

with open('g_green', 'r') as f:
    for y in f.read().split('\n'):
        if y:
            g_green.append(float(y))

with open('g_blue', 'r') as f:
    for y in f.read().split('\n'):
        if y:
            g_blue.append(float(y))

w = []
for i in range(2, 258):
    if(i < 128):
        w.append(4*(i - 1))
    else:
        w.append(258 -i)

#print(w)

lE = ([[[0 for c in range(3)]for h in range(640)]for v in range(480)])

for v in range(480):
    for h in range(640):
        s_red = ((w[low[v, h, 2]]) *(g_red[low[v, h, 2]]) - exp_time_low) + \
                ((w[mid[v, h, 2]]) *(g_red[mid[v, h, 2]]) - exp_time_mid) + \
                ((w[high[v, h, 2]]) *(g_red[high[v, h, 2]]) - exp_time_high) 

        s_green = ((w[low[v, h, 1]]) *(g_red[low[v, h, 1]]) - exp_time_low) + \
                ((w[mid[v, h, 1]]) *(g_red[mid[v, h, 1]]) - exp_time_mid) + \
                ((w[high[v, h, 1]]) *(g_red[high[v, h, 1]]) - exp_time_high) 
        
        s_blue = ((w[low[v, h, 0]]) *(g_red[low[v, h, 0]]) - exp_time_low) + \
                ((w[mid[v, h, 0]]) *(g_red[mid[v, h, 0]]) - exp_time_mid) + \
                ((w[high[v, h, 0]]) *(g_red[high[v, h, 0]]) - exp_time_high) 

        w_sum_red = w[low[v, h, 2]] + w[mid[v, h, 2]] + w[high[v, h, 2]]
        w_sum_green = w[low[v, h, 1]] + w[mid[v, h, 1]] + w[high[v, h, 1]] 
        w_sum_blue = w[low[v, h, 0]] + w[mid[v, h, 0]] + w[high[v, h, 0]]


        lE[v][h][2] = s_red/w_sum_red
        lE[v][h][1] = s_green/w_sum_green
        lE[v][h][0] = s_blue/w_sum_blue

glE = [0]*3

glE[0] = numpy.mean(lE[:][:][0])
glE[1] = numpy.mean(lE[:][:][1])
glE[2] = numpy.mean(lE[:][:][2])

#print(glE)

gE = numpy.exp(glE)
E = numpy.exp(lE)

lD = [[[0 for c in range(3)]for h in range(640)]for v in range(480)]

a = 2

for v in range(480):
    for h in range(640):
        lD[v][h][0] = 255/(1+gE[0]/(a*E[v, h, 0]))
        lD[v][h][1] = 255/(1+gE[1]/(a*E[v, h, 1]))
        lD[v][h][2] = 255/(1+gE[2]/(a*E[v, h, 2]))

#print(lD)

cv2.imshow('Python_hdr', numpy.uint8(lD))
cv2.waitKey()
filename = 'Images/image_' + str(n) + '_hdr_python.png'
cv2.imwrite(filename, numpy.uint8(lD))
cv2.waitKey(0)
