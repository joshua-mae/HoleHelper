import glob
import subprocess

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
    user_name = subprocess.run(['whoami'],shell=True, capture_output=True,text=True)
    readable_user_name = user_name.stdout
    cleaned_user_name = readable_user_name.strip()
    cli_func = subprocess.run([f'find /home/{cleaned_user_name} -type d -name "HH-Results" ! -path "/home/*/*.*"'],shell=True, capture_output=True,text=True)
    sph_path = cli_func.stdout
    sph_path = sph_path.strip()
    sph_path += "/sph-folder/"
    holelist = sorted(glob.glob(f'{sph_path}*.sph'))

    for sphfile in holelist:
        readsphfile(sphfile)
        
if __name__ == '__main__':
    main()  
