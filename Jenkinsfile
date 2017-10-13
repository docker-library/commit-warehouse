pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        parallel(
          "Build community": {
            sh './build.sh -- bonita/$BONITA_MINOR_VERSION'
          },
          "Build subscription": {
            sh './build.sh -a $DOCKER_BUILD_ARGS_FILE -- bonita-subscription/$BONITA_MINOR_VERSION'
          },
          "Build perf-tool": {
            sh './build.sh -a $DOCKER_BUILD_ARGS_FILE -- bonita-perf-tool/$BONITA_MINOR_VERSION'
          }
        )
      }
    }
    stage('Test community') {
      steps {
        sh 'cd test && ./runTests.sh ../bonita/$BONITA_MINOR_VERSION'
      }
    }
    stage('Test subscription') {
      steps {
        sh 'cd test && ./runTests.sh ../bonita-subscription/$BONITA_MINOR_VERSION'
      }
    }
    stage('Archive artifacts') {
      steps {
        archiveArtifacts(artifacts: 'bonita*.tar.gz', onlyIfSuccessful: true)
      }
    }
  }
  environment {
    BONITA_MINOR_VERSION = '7.5'
    DOCKER_BUILD_ARGS_FILE = "$JENKINS_HOME/build_args"
  }
}
