exec env -i GEM_HOME="$GEM_HOME" \
    REQUEST_METHOD=GET \
    SERVER_NAME=test \
    SERVER_PORT=9292 \
    HTTP_VERSION=1.1 \
    PATH_INFO=/ \
  `which ruby` "$@"
