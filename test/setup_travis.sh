#!/bin/bash
set -x
toplevel=$(git rev-parse --show-toplevel)

function setup_chrome {
    # install the appropriate chromedriver version (for chrome stable & beta)
    chrome_version=$("${BROWSER}" --product-version | cut -d . -f 1-3)
    chromedriver_version_url=https://chromedriver.storage.googleapis.com/LATEST_RELEASE_"${chrome_version}"
    chromedriver_version=$(wget "${chromedriver_version_url}" -q -O -)
    chromedriver_url=https://chromedriver.storage.googleapis.com/"${chromedriver_version}"/chromedriver_linux64.zip

    echo "Setting up chromedriver ${chromedriver_version} for ${1} ${chrome_version}"

    wget -O /tmp/chromedriver.zip ${chromedriver_url}
    sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/
    sudo chmod a+x /usr/local/bin/chromedriver
}

function setup_firefox {
    #version=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep tag_name | cut -d '"' -f 4)
    # hard-code latest version, since apparently the above `curl` is fucking up in travis
    version="v0.26.0"
    url="https://github.com/mozilla/geckodriver/releases/download/${version}/geckodriver-${version}-linux64.tar.gz"
    wget -O /tmp/geckodriver.tar.gz ${url}
    sudo tar -xvf /tmp/geckodriver.tar.gz -C /usr/local/bin/
    sudo chmod a+x /usr/local/bin/geckodriver
}

function browser_setup {
  # install python stuff
  pip3 install -r ${toplevel}/test/selenium/requirements.txt
}

function setup_lint {
  pushd ${toplevel}/utils/eslint
    npm install
  popd
}

function setup_unittests {
  pushd ${toplevel}/chromium
    npm install
  popd
}

function setup_docker {
  docker build -t httpse .
}

case $TEST in
  *chrome*)
    setup_chrome "$TEST"
    browser_setup
    ;;
  *firefox*) # Install the latest version of geckodriver
    setup_firefox
    browser_setup
    ;;
  *lint*)
    setup_lint
    ;;
  *unittests*)
    setup_unittests
    ;;
  *validations*|*fetch*)
    setup_docker
    ;;
  *preloaded*)
    ;;
  *)
    echo "bad TEST variable, got $TEST"
    exit 1
    ;;
esac
