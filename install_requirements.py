import os
import sys
import subprocess

# List of packages to install
packages = [
    "numpy",
    "opencv-python",
    "matplotlib",
    "tensorflow",
    "scipy",
    "scikit-learn"
]

# Function to install packages
def install_packages():
    for package in packages:
        print(f"\n Installing {package} ...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
    print("\n All packages installed successfully!")

if __name__ == "__main__":
    install_packages()
    

# To run this script, open your terminal (with the virtual environment activated):
# python install_requirements.py

