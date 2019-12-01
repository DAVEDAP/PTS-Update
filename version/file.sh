#!/bin/bash
#
# Title:      PTS-Update
# Author(s):  MrDoobPG
# GNU:        General Public License v3.0
################################################################################
mainstart() {
  echo ""
  echo "💬  Pulling Update Files - Please Wait"
  file="/opt/pgstage/place.holder"
  waitvar=0
  while [ "$waitvar" == "0" ]; do
    sleep .5
    if [ -e "$file" ]; then waitvar=1; fi
  done

  pgnumber=$(cat /var/plexguide/pg.number)
  # latest=$(cat /opt/pgstage/versions.sh | head -n1)
  versions=$(cat /opt/pgstage/versions.sh)
  # dev=$(cat /opt/pgstage/versions.sh | sed -n 2p)
  release="$(curl -s https://api.github.com/repos/PTS-Team/PTS-Team/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂  Update Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$versions

Installed : $pgnumber

[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  break=no
  read -p '🌍  TYPE master | dev or preview | PRESS ENTER: ' typed
  storage=$(grep $typed /opt/pgstage/versions.sh)

  parttwo
}

parttwo() {
  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then
    echo ""
    touch /var/plexguide/exited.upgrade
    exit
  fi

  if [ "$storage" != "" ]; then
    break=yes
    echo -e $storage >/var/plexguide/pg.number
    ansible-playbook /opt/ptsupdate/version/choice.yml

    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  SYSTEM MESSAGE: Installing Version - $typed - Standby!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 2
    touch /var/plexguide/new.install

    file="/var/plexguide/community.app"
    if [ -e "$file" ]; then rm -rf /var/plexguide/community.app; fi

    exit
  else
    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  SYSTEM MESSAGE: Version $typed does not exist! - Standby!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 2
    mainstart
  fi
}

base(){
rm -rf /opt/pgstage && mkdir -p /opt/pgstage
ansible-playbook /opt/ptsupdate/stage/pgstage.yml #&>/de v/null &
}

##$functionsstart

base
mainstart
