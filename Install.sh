#!/bin/bash

kmer="" # --kmer-len in kraken2-build
min_l="" # --minimizer-len in kraken2-build
min_s="" # --minimizer-spaces in kraken2-build
read_len=75 # the read length in bracken-build

condapath=~/miniconda3
while getopts t:p:k:m:s:r: option # user can ingore -c and -p if conda has been already installed in the home directory
do
    case "${option}" in
        t) threads=${OPTARG};;
        p) condapath=${OPTARG};; # path to miniconda/anaconda (default is in home directory: ~/miniconda3)
        k) kmer=${OPTARG};; # --kmer-len in kraken2-build
        m) min_l=${OPTARG};; # --minimizer-len in kraken2-build
        s) min_s=${OPTARG};; # --minimizer-spaces in kraken2-build
        r) read_len=${OPTARG};; # the read length in bracken-build 
    esac
done

# get MTD folder place; same as Install.sh script file path (in the MTD folder)
dir=$(dirname $(readlink -f $0))
cd $dir # MTD folder place

touch condaPath
echo "$condapath" > $dir/condaPath

source $condapath/etc/profile.d/conda.sh

conda deactivate

echo 'installing conda environments...'
conda env create -f Installation/MTD.yml
conda env create -f Installation/py2.yml
conda env create -f Installation/halla0820.yml
conda env create -f Installation/R412.yml

echo 'MTD installation progress:'
echo '>>                  [10%]'

# conda activate py2 # install dependencies of py2 in case pip does work in conda yml
# pip install backports-functools-lru-cache==1.6.1 biom-format==2.0.1 cycler==0.10.0 h5py==2.10.0 hclust2==1.0.0 kiwisolver==1.1.0 matplotlib==2.2.5 numpy==1.16.6 pandas==0.24.2 pyparsing==2.4.7 pyqi==0.3.2 python-dateutil==2.8.1 pytz==2021.1 scipy==1.2.3 six==1.15.0 subprocess32==3.5.4
# conda deactivate

conda activate halla0820 # install dependencies of halla
R -e 'install.packages(c("XICOR","mclust","BiocManager"), repos="http://cran.us.r-project.org")'
R -e 'BiocManager::install("preprocessCore", ask = FALSE)'
R -e 'install.packages("eva", INSTALL_opts = "--no-lock", repos="http://cran.us.r-project.org")'
conda deactivate
echo 'conda environments installed'



echo 'MTD installation progress:'
echo '>>>>>>>>>>>>>>>>>>  [90%]'
echo 'installing R packages...'
# install R packages
conda activate R412
# debug in case libcurl cannot be located in the conda R environment
wget https://cloud.r-project.org/src/contrib/curl_4.3.2.tar.gz
# if /usr/lib/x86_64-linux-gnu/pkgconfig/libcurl.pc exists, use it
if [ -f /usr/lib/x86_64-linux-gnu/pkgconfig/libcurl.pc ]; then
    locate_lib=/usr/lib/x86_64-linux-gnu/pkgconfig
    else 
    locate_lib=$(dirname $(locate libcurl | grep '\.pc'))
fi
R CMD INSTALL --configure-vars='LIB_DIR='"$locate_lib" curl_4.3.2.tar.gz

Rscript $dir/Installation/R_packages_installation.R

chmod +x MTD.sh

echo 'MTD installation progress:'
echo '>>>>>>>>>>>>>>>>>>>>[100%]'
echo "MTD installation is finished"
