#!/bin/ksh
################################################################################
# Simple script to GET stats about network cards
# Should work on hme and qfe. Will NOT change anything.
# Will report on speed and config of all network interfaces.
# Paul Bates 27.03.2000
# James Council 26.09.2001
#       - Changed output to one liners.
#       - Added IPversion check.
# James Council 10.10.2002 (jamescouncil@yahoo.com)
#       - Added test for Cassini Gigabit-Ethernet card (ce_).
#       - Added test for GEM Gigabit-Ethernet (ge_)
#       - Added test for eri Fast-Ethernet (eri_).
#       - Added "Ethernet Address" field.
#       - Removed "IPversion" field.
#       - Removed checking of a port more than once (i.e. qfe0 qfe0:1)
# James Council 10.25.2002 (jamescouncil@yahoo.com)
#       - Fixed 1GB check on ge device.
# James Council 04.02.2003 (jamescouncil@yahoo.com)
#       - Added dmfe check (suggested by John W. Rudick, & Erlend Tronsmoen)
# Octave Orgeron 02.06.2004 (unixconsole@yahoo.com)
#       - Added bge check (bge_).
# Octave Orgeron 05.18.2005 (unixconsole@yahoo.com)
#       - Corrected CE check to use kstat, which is required in Solaris 10.
# Octave Orgeron 12.13:2005 (unixconsole@yahoo.com)
#       - Corrected CE and DMFE check. Added IPGE check. Special thanks to
#         Paul Bates, Christian Jose, and Bill Qualye for suggesting fixes and
#         for keeping me on my toes;)
# Octave Orgeorn 02.07.2007 (unixconsole@yahoo.com)
#       - Added support for the Intel e1000g interfaces.
#       - Cleaned up script. Housecleaning.
#       - Tested against Fujitsu Quad GigE Nic's (FJGI)
# Paul Bates 10.03.2008  (sun@paulbates.org)
#       - included NXGE interfaces, Thanks Jorg Weiss and Randy Latimer !!
#       - Just tidied up code a little more, removed some fluff
#
# NOTE: For further updates or comments please feel free to contact me via
#       email.  James Council or Octave Orgeron or Paul Bates
#
################################################################################

NDD=/usr/sbin/ndd
KSTAT=/usr/bin/kstat
IFC=/sbin/ifconfig
DLADM=/usr/sbin/dladm

typeset -R10 LINK
typeset -R8 AUTOSPEED
typeset -R8 STATUS
typeset -R8 SPEED
typeset -R8 MODE
typeset -R18 ETHER

# Function to test that the user is root.

Check_ID()
{
ID=$(/usr/ucb/whoami)
if [ $ID != "root" ]; then
   echo "$ID, you must be root to run this program."
   exit 1
fi
}

# Function to test Quad Fast-Ethernet, Fast-Ethernet, and
# Gigabit-Ethernet (i.e. qfe_, hme_, ge_, fjgi_)

Check_NIC()
{
${NDD} -set /dev/${1} instance ${2}

if [ $type = "ge" ];then
   autospeed=`${NDD} -get /dev/${1} adv_1000autoneg_cap`
else
   autospeed=`${NDD} -get /dev/${1} adv_autoneg_cap`
fi

case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${NDD} -get /dev/${1} link_status`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${NDD} -get /dev/${1} link_speed`
case $speed in
   1000) SPEED=1GB      ;;
   1) SPEED=100MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${NDD} -get /dev/${1} link_mode`
case $mode in
   1) MODE=FDX          ;;
   0) MODE=HDX          ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test the Davicom Fast Ethernet, DM9102A, devices
# on the Netra X1 and SunFire V100 (i.e. dmfe_)

Check_DMF_NIC()
{
autospeed=`${NDD} -get /dev/${1}${2} adv_autoneg_cap`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${NDD} -get /dev/${1}${2} link_status`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${NDD} -get /dev/${1}${2} link_speed`
case $speed in
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${NDD} -get /dev/${1}${2} link_mode`
case $mode in
   2) MODE=FDX          ;;
   1) MODE=HDX          ;;
   0) MODE=UNKOWN       ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test a Cassini Gigabit-Ethernet (i.e. ce_).

Check_CE()
{
autospeed=`${KSTAT} -m ce -i $num -s cap_autoneg | grep cap_autoneg | awk '{print $2}'`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${KSTAT} -m ce -i $num -s link_up | grep link_up | awk '{print $2}'`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${KSTAT} -m ce -i $num -s link_speed | grep link_speed | awk '{print $2}'`
case $speed in
   1000) SPEED=1GB      ;;
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${KSTAT} -m ce -i $num -s link_duplex | grep link_duplex | awk '{print $2}'`
case $mode in
   2) MODE=FDX          ;;
   1) MODE=HDX          ;;
   0) MODE=UNKNOWN      ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test Sun BGE interface on Sun Fire V210 and V240.
# The BGE is a Broadcom BCM5704 chipset. There are four interfaces
# on the V210 and V240. (i.e. bge_)

Check_BGE_NIC()
{
autospeed=`${NDD} -get /dev/${1}${2} adv_autoneg_cap`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${NDD} -get /dev/${1}${2} link_status`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${NDD} -get /dev/${1}${2} link_speed`
case $speed in
   1000) SPEED=1GB      ;;
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${NDD} -get /dev/${1}${2} link_duplex`
case $mode in
   2) MODE=FDX          ;;
   1) MODE=HDX          ;;
   0) MODE=UNKNOWN      ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test a Intel 82571-based ethernet controller port (i.e. ipge_).

Check_IPGE()
{
autospeed=`${KSTAT} -m ipge -i $num -s cap_autoneg | grep cap_autoneg | awk '{print $2}'`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${KSTAT} -m ipge -i $num -s link_up | grep link_up | awk '{print $2}'`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${KSTAT} -m ipge -i $num -s link_speed | grep link_speed | awk '{print $2}'`
case $speed in
   1000) SPEED=1GB      ;;
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${KSTAT} -m ipge -i $num -s link_duplex | grep link_duplex | awk '{print $2}'`
case $mode in
   2) MODE=FDX          ;;
   1) MODE=HDX          ;;
   0) MODE=UNKNOWN      ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test a Intel 82571-based ethernet controller port (i.e. e1000g_).

Check_E1KG()
{
autospeed=`${KSTAT} -m e1000g -i $num -s cap_autoneg | grep cap_autoneg | awk '{print $2}'`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${KSTAT} -m e1000g -i $num -s link_up | grep link_up | uniq |awk '{print $2}'`
case $status in
   1) STATUS=UP         ;;
   0) STATUS=DOWN       ;;
   *) STATUS=ERROR      ;;
esac

speed=`${KSTAT} -m e1000g -i $num -s link_speed | grep link_speed | awk '{print $2}'`
case $speed in
   1000) SPEED=1GB      ;;
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${KSTAT} -m e1000g -i $num -s link_duplex | grep link_duplex | awk '{print $2}'`
case $mode in
   2) MODE=FDX          ;;
   1) MODE=HDX          ;;
   0) MODE=UNKNOWN      ;;
   *) MODE=ERROR        ;;
esac
}

# Function to test Sun NXGE interface on Sun Fire Tx000.

Check_NXGE_NIC()
{
autospeed=`${NDD} -get /dev/${1}${2} adv_autoneg_cap`
case $autospeed in
   1) AUTOSPEED=ON      ;;
   0) AUTOSPEED=OFF     ;;
   *) AUTOSPEED=ERROR   ;;
esac

status=`${DLADM} show-dev ${1}${2} 2> /dev/null | awk '{print $3;}'`
case $status in
   up) STATUS=UP            ;;
   down) STATUS=DOWN        ;;
   unknown) STATUS=UNKNOWN  ;;
   *) STATUS=ERROR          ;;
esac

speed=`${DLADM} show-dev ${1}${2} 2> /dev/null | awk '{print $5;}'`
case $speed in
   1000) SPEED=1GB      ;;
   100) SPEED=100MB     ;;
   10) SPEED=10MB       ;;
   0) SPEED=10MB        ;;
   *) SPEED=ERROR       ;;
esac

mode=`${DLADM} show-dev ${1}${2} 2> /dev/null | awk '{print $NF;}'`
case $mode in
   full) MODE=FDX     ;;
   half) MODE=HDX     ;;
   unknown) MODE=---  ;;
   *) MODE=ERROR      ;;
esac
}

#############################################
# Start
#############################################

Check_ID

echo "\n      Link:  Auto-Neg:   Status:   Speed:    Mode:  Ethernet Address:"
echo "---------------------------------------------------------------------"

# Create a uniq list of network ports configured on the system.
# NOTE: This is done to avoid multiple references to a single network port
# (i.e. qfe0 and qfe0:1).

NICS=`${IFC} -a| egrep -v "lo|be|dman|lpfc|jnet"| awk -F: '/^[a-z,A-z]/ {print $1}'| sort -u`

for LINK in $NICS
do
   if [ `echo $LINK | grep e1000g` ]
   then
      type=e1000g
      num=$(echo $LINK | cut -f2 -d"g")
   else
      type=$(echo $LINK | sed 's/[0-9]//g')
      num=$(echo $LINK | sed 's/[a-z,A-Z]//g')
   fi

# Here we reference the functions above to set the variables for each port which
# will be outputed below.

   case ${type} in
      bge)      Check_BGE_NIC $type $num  ;;
      ce)       Check_CE $type $num       ;;
      dmfe)     Check_DMF_NIC $type $num  ;;
      ipge)     Check_IPGE $type $num     ;;
      e1000g)   Check_E1KG $type $num     ;;
      nxge)     Check_NXGE_NIC $type $num ;;
      *)        Check_NIC $type $num      ;;
   esac

# Set ethernet variable and output all findings for a port to the screen.

   ETHER=`$IFC $LINK| awk '/ether/ {print $2}'`
   echo "$LINK   $AUTOSPEED  $STATUS $SPEED $MODE $ETHER"
done

#############################################
# End
#############################################

