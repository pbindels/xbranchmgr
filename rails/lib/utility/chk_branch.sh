#!/bin/bash

BRANCHMGR_ROOT=/okl/branchmgr/git_repos
REPO_CONFIG=/okl/branchmgr/git_repos/repo.config
PRODUCT=$1
BRANCH=$2
BRANCH_OFF=$3

function create_branches {

   GITREPOS=`grep ^$PRODUCT $REPO_CONFIG|cut -d"=" -f2`
   echo "--- Repos for project \"$PRODUCT\" are:    $GITREPOS"

   for repo in $GITREPOS
   do
      echo ""
      echo "--- Creating branch \"$BRANCH\" in $repo"
      echo " "

      if [ ! -d $BRANCHMGR_ROOT/$repo ]; then
         echo "-> cd $BRANCHMGR_ROOT"
         cd $BRANCHMGR_ROOT
      echo " Return Status $? for cd $BRANCHMGR_ROOT "

         echo "--- $repo repo doesn't exists, cloning $repo"
         echo "\$> git clone git\@github.com\:okl\/$repo $repo"
         git clone git@github.com:okl/$repo $repo
      echo " Return Status $? for git clone git@github.com:okl/$repo $repo "

         echo " "
      fi

      echo "\$> cd $BRANCHMGR_ROOT/$repo"
      cd $BRANCHMGR_ROOT/$repo
      echo " Return Status $? for cd $BRANCHMGR_ROOT/$repo "

      echo " "

      if [ -z "$BRANCH_OFF" ]; then
           BRANCH_OFF="master"
      fi

      echo "\$> git branch \| grep \"\^\*"
      git branch | grep "^*"
      echo " Return Status $? for git branch \| grep \"\^\*\" "

      echo " "

      echo "\$> git checkout $BRANCH_OFF"
      git checkout $BRANCH_OFF
      echo " Return Status $? for git checkout $BRANCH_OFF "

      echo "\$> git branch \| grep \"\^\*"
      git branch | grep "^*"
      echo " Return Status $? for git branch \| grep \"\^\*\" "

      echo " "
       

      echo "\$> git pull"
      git pull
      echo " Return Status $? for git pull "
      
      echo " "

      echo "\$> git branch $BRANCH"
      git branch $BRANCH
      echo " Return Status $? for git branch $BRANCH "

      echo " "

      echo "\$> git branch \| grep \"\^\*"
      git branch | grep "^*"
      echo " Return Status $? for git branch \| grep \"\^\*\" "

      echo " "

      echo "\$> git checkout $BRANCH"
      git checkout $BRANCH
      echo " Return Status $? for git checkout $BRANCH "

      echo " "

      echo "\$> git push origin $BRANCH"
      git push origin $BRANCH
      echo " Return Status $? for git push origin $BRANCH "

      echo " "

      echo "\$> git tag \"build-${BRANCH}_0\""
      git tag "build-${BRANCH}_0"
      echo " Return Status $? for git tag \"build-${BRANCH}_0\" "

      echo " "

      echo "\$> git push --tags"
      git push --tags
      echo " Return Status $? for git push --tags "

      echo " "

   done

}
 
create_branches
