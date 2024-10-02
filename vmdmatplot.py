'''
This is the last file that needs to be run and can be modified to your liking 
in order to graph the sphere files and extract valid data.
'''

# This is the last file that can be modified to learn how to use matplotlib.
# this does not need to be edited but can be.

import matplotlib.pyplot as plt
import glob
import numpy as np
from icecream import ic
import operator


def readsphfile(sphfile):
    '''
    Takes in sph file that acts like a pdb and plots into graph

    Args:
        sphfile: sph file that is being read

    Returns:
        Numpy arrays of the radius and path along the x-axis
    '''
    fin = open(sphfile)
    radiuslist,zlist = [],[]

    for line in fin.readlines():
        if line[0:4] == "ATOM" :
            betacolumn = line[61:68]
            z = line[47:55]
            beta = float(betacolumn)
            if beta > 0:
                radiuslist.append(beta)
                zlist.append(float(z))
    fin.close()
    return (np.array(radiuslist), np.array(zlist))

def main():

    big_radius_lst,big_coordinate_lst = [],[]

    holelist = sorted(glob.glob("./sph_files/curved_trimer*sph"))
    fig, ax = plt.subplots(1,1)

    plt.title("Flattened BMC Shell Pore Radius (No Constant Ratio)")
    plt.ylabel("Hole Radius (Å)")
    plt.xlabel("Z coordinate")

    for sphfile in holelist:
        r, z = readsphfile(sphfile)
    for i in z:
        big_coordinate_lst.append(i)
    for x in r:
        big_radius_lst.append(x)
        #ax.scatter(z, r)

    list_zip = zip(big_coordinate_lst,big_radius_lst)

    list_zip = sorted(list_zip,key = operator.itemgetter(0))

    x_val = [z_coord[0] for z_coord in list_zip]
    y_val = [radius_dimensions[1] for radius_dimensions in list_zip]

    plt.plot(x_val,y_val)

    fig.savefig("flattened_trimer_all_frame.png")

if __name__ == "__main__":
    main()