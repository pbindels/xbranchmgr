PROJECT=$1
BRANCH=$2
ENV=$3
BRANCHMGR_ROOT=/okl/branchmgr
JENKINS_ROOT=/okl/build/jenkins
JENKINS_TMPL_DIR=$BRANCHMGR_ROOT/jenkins/jobs
JENKINS_JOB_DIR=$JENKINS_ROOT/jobs
USE_CLI=hudson
JENKINS_URL=http://localhost:9180/jenkins/cli ; export JENKINS_URL
HUDSON_URL=http://localhost:9180/jenkins/cli ; export HUDSON_URL
REL_CONFIG_FILE="all_rel_config.xml.tmpl"
ALL_CONFIG_FILE="all_config.xml.tmpl"
LATEST_CONFIG_FILE="latest_config.xml.tmpl"

if [[ "$PROJECT" == "babar" ]] || [[ "$PROJECT" == "imp" ]] || [[ "$PROJECT" == "elysium" ]] || [[ "$PROJECT" == "colorapi" ]] || [[ "$PROJECT" == "searchpro" ]] || [[ "$PROJECT" == "catalog_service" ]] || [[ "$PROJECT" == "mobilerouter" ]]
    REL_CONFIG_FILE="qdeploy_all_rel_config.xml.tmpl"
    ALL_CONFIG_FILE="qdeploy_all_config.xml.tmpl"
fi

reltag=`echo ${BRANCH}|cut -d'_' -f1`

if [[ "$ENV" != "" ]]
then
    DEPLOY="ssh sfo-ops-adm-01 \/opt\/qdeploy\/default\/bin\/dccontrol -a install -c \/okl\/$PROJECT\/qdeploy\/etc\/$PROJECT.conf -r \${JOB_NAME}_\${BUILD_NUMBER}.zip -e $ENV -U oklrelease"
else
    DEPLOY=""
fi

function create_jenkins_job {
	
     printf "\n--- Creating Jenkins Job '$PROJECT-$BRANCH'\n"

     JENKINS_JOB=$PROJECT-$BRANCH
     JENKINS_JOB_DIR=$JENKINS_ROOT/jobs/$JENKINS_JOB

     printf "\n--- Creating Job Config\n"

     printf "mkdir -p  $JENKINS_JOB_DIR/builds\n"
     mkdir -p  $JENKINS_JOB_DIR/builds

     printf "Generating $JENKINS_JOB_DIR/config.xml...\n"
     if  [[ $reltag == "release" ]]  && [[ $BRANCH == "king" ]]; then
       sed -e "s/__BRANCH_NAME__/$BRANCH/g"  -e "s/__PROJECT_NAME__/$PROJECT/g" -e "s/__DEPLOY__/$DEPLOY/g" $JENKINS_TMPL_DIR/$REL_CONFIG_FILE > $JENKINS_JOB_DIR/config.xml
     #elif [[ $PROJECT == "elysium" ]] || [[ $PROJECT == "imp" ]]; then
     #  sed -e "s/__BRANCH_NAME__/$BRANCH/g" -e "s/__PROJECT_NAME__/$PROJECT/g" -e "s/__DEPLOY__/$DEPLOY/g" $JENKINS_TMPL_DIR/$LATEST_CONFIG_FILE > $JENKINS_JOB_DIR/config.xml
     else
       sed -e "s/__BRANCH_NAME__/$BRANCH/g" -e "s/__PROJECT_NAME__/$PROJECT/g" -e "s/__DEPLOY__/$DEPLOY/g" $JENKINS_TMPL_DIR/$ALL_CONFIG_FILE > $JENKINS_JOB_DIR/config.xml
     fi
     printf "Generating $JENKINS_JOB_DIR/nextBuildNumber\n"
     echo "1"  > $JENKINS_JOB_DIR/nextBuildNumber

     printf "Registering Jenkins Job $PROJECT\-$BRANCH\n"
     curl -u oklmanage:5db4001caa8567f24f1092e5b2bd9721  -X POST http://jenkins.newokl.com/jenkins/reload
#     java \
#           -jar /okl/build/tomcat/domains/$USE_CLI/webapps/$USE_CLI/WEB-INF/$USE_CLI-cli.jar \
#           reload-configuration \
#           --username XXX \
#           --password XXX 
}

create_jenkins_job
