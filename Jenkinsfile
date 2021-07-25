def gitversion = []

podTemplate(containers: [
        containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'pandoc', image: 'tewarid/pandoc:2.14.0.2', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'jq', image: 'badouralix/curl-jq:alpine', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'gitversion', image: 'im5tu/netcore-gitversion:3-alpine', ttyEnabled: true, command: 'cat')],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ]) {
    node(POD_LABEL) {
        stage('Checkout') {
            checkout scm
        }

        container('gitversion') {
            stage('Set version') {
                def output = sh(returnStdout: true, script: "dotnet-gitversion /output json")
                gitversion = readJSON text: output
                currentBuild.displayName = "${gitversion.MajorMinorPatch} (${currentBuild.displayName})"
                echo output
            }
        }

        container('pandoc') {
            stage('Run pandoc for cv in DE') {
                writeFile(file: 'metadata.md', text: "# CV - Thierry Iseli (V. ${gitversion.MajorMinorPatch}) {.unnumbered }")
                sh "tlmgr install adjustbox babel-german background bidi collectbox csquotes everypage filehook footmisc footnotebackref framed fvextra letltxmacro ly1 mdframed mweights needspace pagecolor sourcecodepro sourcesanspro titling ucharcat ulem unicode-math upquote xecjk xurl zref"
                sh "pandoc metadata.md docs/de/index.md -f markdown -o cv-thierryiseli-de.pdf --template ./template.tex -V page-background=background.pdf -V page-background-opacity=1 -N -V margin-top=25mm -V margin-left=20mm -V margin-right=20mm -V margin-bottom=30mm -V version=1.0.0 -V lang=de -V 'caption-justification=centering'"
            }
        }
        
        container('jq') {
            stage('Upload cv in DE') {
                try {
                    withCredentials([usernamePassword(credentialsId: 'b19750e3-fb9d-4d71-b796-566f2c4a9146',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GITHUB_TOKEN')]) {
                        withEnv(["VERSION=${gitversion.MajorMinorPatch}",
                            "RELEASE_NAME=CV V.${gitversion.MajorMinorPatch}",
                            "RELEASE_DESCRIPTION=''",
                            "REPOSITORY_NAME=tyupch/cv-thierryiseli",
                            "UPLOAD_FILE=cv-thierryiseli-de.pdf"]){
                            env.UPLOAD_URL = sh(returnStdout: true, script: "curl -s -H \"Authorization: token ${GITHUB_TOKEN}\" -d '{\"tag_name\": \"${VERSION}\", \"name\": \"${RELEASE_NAME}\", \"body\":\"${RELEASE_DESCRIPTION}\"}' \"https://api.github.com/repos/${REPOSITORY_NAME}/releases\" | jq --raw-output '.assets_url'")
                            env.UPLOAD_URL = env.UPLOAD_URL.replace("\n", "").replace("api.", "uploads.")
                            sh "curl -H \"Authorization: token ${GITHUB_TOKEN}\" -H \"Content-Type: application/octet-stream\" --data-binary @${UPLOAD_FILE} \"${UPLOAD_URL}?name=${UPLOAD_FILE}\""
                        }
                    }                    
                } catch (error) {
                    echo "Release for this version already exists or another error."
                    echo error
                }                               
            }
        }
        
        stage('Archive files in jenkins') {
            archiveArtifacts artifacts: '*.pdf'
        }
    }
}