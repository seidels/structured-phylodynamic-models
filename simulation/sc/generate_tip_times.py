import numpy as np
import sys

# command line argument can provide seed, otw set seed to 1
if len(sys.argv) < 2:
    np.random.seed(1)
else:
    np.random.seed(int(sys.argv[1]))


# generate 100 random tip times between 0-10.
tipDates=np.random.uniform(0, 10, 101)


with open('randomTipTimes.txt', 'w') as text_file:

    for i in range(1,101):
        text_file.write(str(i) + '\t' + str(tipDates[i]) + '\n')


