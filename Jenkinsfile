pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        parallel(
          "Build community": {
            sh './build.sh bonita/$BONITA_MINOR_VERSION'
          },
          "Build subscription": {
            sh './build.sh bonita-subscription/$BONITA_MINOR_VERSION --build-arg BASE_URL=https://jenkins.cloud.bonitasoft.com/userContent/resources --build-arg ORACLE_URL=https://jenkins.cloud.bonitasoft.com/userContent/resources --build-arg BONITA_DBTOOL_URL=https://jenkins.cloud.bonitasoft.com/userContent/resources'
          }
//        "Build perf-tool": {
//          sh './build.sh bonita-perf-tool/$BONITA_MINOR_VERSION'
//        }
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
  }
}
