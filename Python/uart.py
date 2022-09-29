import serial
import cv2
import numpy

ser = serial.Serial(
        port = '/dev/ttyUSB1',
        baudrate = 115200,
        parity = serial.PARITY_NONE,
        stopbits = serial.STOPBITS_ONE,
        bytesize = serial.EIGHTBITS,
        timeout = None
)

ser.close()
ser.open()
A = ser.read(2457600)
ser.close()

hdr = (len(A) != 614400)

print('Received' + str(len(A)/614400) + 'image(s)')

n = []
with open('name', 'r') as f_name:
    while 1:
        byte_s = f_name.read(1)
        if not byte_s:
            break
        n.append(byte_s)

name = "" 
for i in range(len(n)-1):
    name = name + n[i]


byte_list = []

#with open("pic_12.txt", "rb") as f:
#    while 1:
#        byte_s = f.read(1)
#        if not byte_s:
#            break
##        print(ord(byte_s))
#        byte_list.append(format((ord(byte_s)), '08b'))

for i in range (len(A)):
    byte_list.append(format(A[i], '08b'))


RED = []
GREEN = []
BLUE = []

for i in range (0, len(byte_list), 2):
    RED.append(int(byte_list[i][0:5], 2))
    GREEN.append(int(byte_list[i][5:8]+byte_list[i+1][0:3], 2))
    BLUE.append(int(byte_list[i+1][3:8], 2))


rgb_low = [[[0 for c in range(3)]for h in range(640)]for v in range(480)]
if hdr:
    rgb_mid = [[[0 for c in range(3)]for h in range(640)]for v in range(480)]
    rgb_high = [[[0 for c in range(3)]for h in range(640)]for v in range(480)]
    rgb_hdr = [[[0 for c in range(3)]for h in range(640)]for v in range(480)]
k = 0;

for v in range (0, 480):
    for h in range (0, 640):
        rgb_low[v][h][2] = 255*RED[k]/31
        rgb_low[v][h][1] = 255*GREEN[k]/63
        rgb_low[v][h][0] = 255*BLUE[k]/31
        if(hdr):
            rgb_mid[v][h][2] = 255*RED[k + 307200]/31
            rgb_mid[v][h][1] = 255*GREEN[k + 307200]/63
            rgb_mid[v][h][0] = 255*BLUE[k + 307200]/31

            rgb_high[v][h][2] = 255*RED[k + 614400]/31
            rgb_high[v][h][1] = 255*GREEN[k + 614400]/63
            rgb_high[v][h][0] = 255*BLUE[k + 614400]/31

            rgb_hdr[v][h][2] = 255*RED[k + 921600]/31
            rgb_hdr[v][h][1] = 255*GREEN[k + 921600]/63
            rgb_hdr[v][h][0] = 255*BLUE[k + 921600]/31
        k = k + 1;

if hdr:
    filename_low = 'Images/image_' + name + '_low.png'
    filename_mid = 'Images/image_' + name + '_mid.png'
    filename_high = 'Images/image_' + name + '_high.png'
    filename_hdr = 'Images/image_' + name + '_hdr.png'
    cv2.imwrite(filename_low, numpy.array(rgb_low))
    cv2.imwrite(filename_mid, numpy.array(rgb_mid))
    cv2.imwrite(filename_high, numpy.array(rgb_high))
    cv2.imwrite(filename_hdr, numpy.array(rgb_hdr))
else:
    filename_low = 'Images/image_' + name + '.png'
    cv2.imwrite(filename_low, numpy.array(rgb_low))


f_name = open('name', 'w')
f_name.write(str(int(name) + 1))
f_name.close()
