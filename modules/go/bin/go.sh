# From BuildEnv:modules/go/bin/go.sh

if [[ "$CGO_ENABLED" = "0" ]]
then
   GOBIN="/usr/local/go/bin/go-static"
else
   GOBIN="/usr/local/go/bin/go"
fi

if [[ "$1" = "build" ]] || [[ "$1" = "install" ]]
then
   BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD)
   BUILD_COMMIT=$(git log --format="%H" -1)
   BUILD_DATE="$(git log --format="%ai" -1 | sed 's/ /_/g')"
   GIT_TAG="$(git tag -l --points-at HEAD | grep -v latest)"

   BUILD_TAG=false
   if [[ "$GIT_TAG" != "" ]]
   then
      if [[ -f version.go ]]
      then
         if [[ "$(grep $GIT_TAG version.go)" != "" ]]
         then
            BUILD_TAG=true
         fi
      else
         BUILD_TAG=true
      fi
   fi
   if [[ $BUILD_TAG = true ]]
   then
      echo "##### Building official $GIT_TAG #####"
   fi
   BUILD_FLAGS="$1 -ldflags '-X main.build_branch=$BUILD_BRANCH -X main.build_commit=$BUILD_COMMIT -X main.build_date=$BUILD_DATE -X main.build_tag=$BUILD_TAG'"
   shift
fi

docker_run $BE_PROJECT-go-env $GOBIN $BUILD_FLAGS "$@"
