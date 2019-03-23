#!/bin/sh
# Copyright (C) 2018 Wesley Tanaka
#
# This file is part of docker-xenial-uid
#
# docker-xenial-uid is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# docker-xenial-uid is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with docker-xenial-uid.  If not, see
# <http://www.gnu.org/licenses/>.

# From http://www.etalabs.net/sh_tricks.html
save () {
  for i do printf %s\\n "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/" ; done
  echo " "
}
quote () {
  printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" ;
}

usercommand=$(save "$@")

HOSTUSERNAME=hostuser
HOSTGROUPNAME=hostgroup
HOSTHOMEDIR="/home/$HOSTUSERNAME"
if [ -z "$WORKDIR" ]; then
  WORKDIR=/work
fi

COMMAND="$usercommand"
if [ -d "$WORKDIR" ]; then
  COMMAND="; ${COMMAND}"
  COMMAND=$(quote "$WORKDIR")"$COMMAND"
  COMMAND="cd $COMMAND"
fi

if [ -n "$HOSTUID" ]; then
  mkdir "$HOSTHOMEDIR"
  CHOWNGROUP="$HOSTUSERNAME"
  CHOWNUSER="$HOSTUIDNAME"
  USERADDCMD=$(quote useradd)
  USERADDCMD="$USERADDCMD "$(quote '-u')
  USERADDCMD="$USERADDCMD "$(quote "$HOSTUID")
  if [ -n "$HOSTGID" ]; then
    CHOWNGROUP="$HOSTGID"
    groupadd -f -g "$HOSTGID" "$HOSTGROUPNAME"
    USERADDCMD="$USERADDCMD "$(quote '-g')
    USERADDCMD="$USERADDCMD "$(quote "$HOSTGID")
  fi
  USERADDCMD="$USERADDCMD "$(quote "$HOSTUSERNAME")
  eval "$USERADDCMD"
  chown -R "$HOSTUSERNAME":"$HOSTGID" "$HOSTHOMEDIR"
  if command -v sudo 2>&1 > /dev/null; then
    # Add user to sudo group if sudo command exists
    usermod -a -G sudo "$HOSTUSERNAME"
    # Enable passwordless sudo
    printf "%s ALL=(ALL) NOPASSWD:ALL" "$HOSTUSERNAME" > \
      /etc/sudoers.d/"$HOSTUSERNAME"
  fi
fi

if [ -n "$HOSTUID" ]; then
  exec env HOME="$HOSTHOMEDIR" \
    USER="$HOSTUSERNAME" \
    LOGNAME="$HOSTUSERNAME" \
    PATH=/bin:/usr/bin \
    su -m "$HOSTUSERNAME" -c "cd $HOSTHOMEDIR; $COMMAND"
else
  eval "$COMMAND"
fi
