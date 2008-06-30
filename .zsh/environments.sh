export LC_TIME=C

# PATH
if [ -d "/usr/local/bin" ] ; then
    export PATH="/usr/local/bin:$PATH"
fi
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# environment variables
export AUTHOR='Akinori Tomita'
