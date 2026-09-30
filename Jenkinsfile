// Jenkinsfile — taskflow-mobile (Flutter)

def notify(String status) {
  def color = (status == 'SUCCESS') ? 'good' : 'danger'
  def msg   = "${status}: ${env.JOB_NAME} #${env.BUILD_NUMBER} (branch ${env.BRANCH_NAME}) ${env.BUILD_URL}"
  try {
    slackSend(channel: '#ci', color: color, message: msg)
  } catch (err) {
    echo "Slack notification failed (${err}) — falling back to email"
    mail(to: 'team@example.com', subject: "[Jenkins] ${status} ${env.JOB_NAME}", body: msg)
  }
}

pipeline {
  agent {
    kubernetes {
      defaultContainer 'flutter'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: flutter
      image: ghcr.io/cirruslabs/flutter:stable
      command: ['cat']
      tty: true
      resources:
        requests: { cpu: '1', memory: 3Gi }
        limits: { memory: 7Gi }
'''
    }
  }

  options { timeout(time: 45, unit: 'MINUTES'); timestamps() }

  stages {
    stage('Analyze') { steps { sh 'flutter pub get && flutter analyze' } }

    stage('Test') {
      steps { sh 'flutter test --coverage' }
      post { always { archiveArtifacts artifacts: 'coverage/lcov.info', allowEmptyArchive: true } }
    }

    stage('SCA — osv-scanner') {
      steps {
        sh '''
          curl -sSfL -o osv-scanner https://github.com/google/osv-scanner/releases/download/v2.6.0/osv-scanner_linux_amd64
          chmod +x osv-scanner
          ./osv-scanner scan source --lockfile pubspec.lock
        '''
      }
    }

    stage('Debug APK') {
      steps { sh 'flutter build apk --debug' }
      post { success { archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-debug.apk' } }
    }

    stage('Signed release AAB') {
      when { branch 'main' }
      steps {
        withCredentials([file(credentialsId: 'android-keystore', variable: 'KEYSTORE'),
                         string(credentialsId: 'android-store-password', variable: 'STORE_PW'),
                         string(credentialsId: 'android-key-password', variable: 'KEY_PW'),
                         string(credentialsId: 'android-key-alias', variable: 'KEY_ALIAS')]) {
          sh '''
            printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=%s\nstoreFile=%s\n' \
              "$STORE_PW" "$KEY_PW" "$KEY_ALIAS" "$KEYSTORE" > android/key.properties
            flutter build appbundle --release
            jarsigner -verify build/app/outputs/bundle/release/app-release.aab
          '''
        }
      }
      post {
        success { archiveArtifacts artifacts: 'build/app/outputs/bundle/release/app-release.aab' }
        always  { sh 'rm -f android/key.properties' }
      }
    }
  }

  post {
    success { script { notify('SUCCESS') } }
    failure { script { notify('FAILURE') } }
  }
}
