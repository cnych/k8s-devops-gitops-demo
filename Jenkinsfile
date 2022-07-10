def label = "slave-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'golang', image: 'golang:1.18.3-alpine3.16', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'docker', image: 'docker:latest', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'cnych/kubectl', command: 'cat', ttyEnabled: true)
], serviceAccount: 'jenkins', envVars: [
  envVar(key: 'DOCKER_HOST', value: 'tcp://docker-dind:2375')  // 环境变量
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH

    // 获取 git commit id 作为镜像标签
    def imageTag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    // 仓库地址
    def registryUrl = "harbor.k8s.local"
    def imageEndpoint = "course/devops-demo"
    // 镜像
    def image = "${registryUrl}/${imageEndpoint}:${imageTag}"

    stage('单元测试') {
      echo "1.测试阶段"
    }
    stage('代码编译打包') {
        try {
            container('golang') {
            echo "2.代码编译打包阶段"
            sh """
                export GOPROXY=https://goproxy.cn
                GOOS=linux GOARCH=amd64 go build -v -o demo-app
                """
            }
        } catch (exc) {
            println "构建失败 - ${currentBuild.fullDisplayName}"
            throw(exc)
        }
    }
    stage('构建 Docker 镜像') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
            credentialsId: 'docker-auth',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASSWORD']]) {
            container('docker') {
                echo "3.构建 Docker 镜像阶段"
                sh """
                docker login ${registryUrl} -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}
                docker build -t ${image} .
                docker push ${image}
                """
            }
        }
    }
    stage('运行 Kubectl') {
        container('kubectl') {
            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                echo "4.查看 K8S 集群 Pod 列表"
                sh "mkdir -p ~/.kube && cp ${KUBECONFIG} ~/.kube/config"
                sh "kubectl get pods"
            }
        }
    }
  }
}