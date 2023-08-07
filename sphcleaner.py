import glob
import sys
import os

def readsphfile(sphfile): 
    '''
    Cleans sph files getting rid of the bad sph lines from HOLE2
    
    Args:
        sphfile: Sph file that is being read
    
    Returns: 
        None
    '''

    fi = open(sphfile, 'r')
    lines = fi.readlines()
    fi = open(sphfile, 'w')

    for line in lines:
        if line[0:4] == 'ATOM' and line[21:26] != 'S-888': 
            fi.write(line)
    fi.close()

def main():

    os.chdir(f'{sys.argv[1]}/HH-Results/sph-folder')
    holelist = sorted(glob.glob('*.sph'))

    for sphfile in holelist:
        readsphfile(sphfile)
        
if __name__ == '__main__':
    main()  
