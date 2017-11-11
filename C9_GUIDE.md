# Cloud 9 AWS Command line interface install guide

이 문서는 C9.io에서 AWS CLI를 설치하는 가이드입니다. 
세미나를 진행할 때 MAC, WINDOWS, LINUX 등 다양한 플랫폼에서 AWS-CLI를 설치하는 것이
문제가 됩니다. 하지만 [C9.io](https://c9.io/)를 사용하면 브라우저에서 가상컨테이너 환경으로
동일하게 작업할 수 있습니다.

## C9.io 계정 생성하기

먼저 [C9.io](https://c9.io/)에 클릭하여 접속합니다.

![c9 main](/images/c9.io_main.png)

---

계정 생성은 3가지 방법으로 가능합니다.

1. email
2. Github
3. Bitbucket

Sign Up 버튼을 눌러 계정을 생성합니다.

![c9 login](/images/c9.io_login.png)

---

카드 정보를 입력합니다.

![c9 credit_card](/images/c9.io_credit_card.png)


## 프로젝트 생성하기

생성한 아이디로 로그인을 하면 다음과 같은 페이지가 나타납니다.

[Create a new workspace](https://c9.io/new) 버튼을 눌러 새로운 프로젝트를 생성합니다.

![c9 projects](/images/c9.io_projects.png)

---

아래와 같이 선택합니다.
1. 프로젝트명: awskrug
2. Private를 선택합니다.(AWS CLI를 다루기 때문에 public으로 두면 보안상 큰 문제가 야기될 수 있습니다)
3. Themplate은 Blank로 선택합니다.
4. Create Workspace 버튼을 클릭합니다.

![c9 create_project](/images/c9.io_create_project.png)


## AWS Command line Interface 설치하기

생성된 프로젝트에 들어가면 아래와 같은 화면을 볼 수 있습니다.

![c9 intro](/images/c9.io_intro.png)

---

아래 부분을 보면 Shell 명령어를 입력할 수 있는 부분이 있습니다. 다음과 같은 순서로 명령어를 입력해 주시기 바랍니다.

```sh
$ sudo apt-get update
$ sudo apt-get install python2.7-dev -y
$ sudo apt-get install awscli -y --upgrade
```

AWS CLI를 사용하기 위해 환경변수를 설정해줍니다.
아래와 같은 명령어를 입력하면 다음 그림과 같이 파일을 open할 수 있습니다.

```sh
$ ls ~/.bashrc -al
```

![c9 open_sh](/images/c9.io_open_sh.png)

.bashrc의 마지막 줄에 환경변수를 설정하는 다음의 값을 붙여넣기해주세요

```sh
export PATH=~/.local/bin:$PATH
```

![c9 env](/images/c9.io_env.png)

입력을 완료한 후에 다시 .bashrc를 불러오는 다음의 명령어를 입력하여주세요

```sh
$ source ~/.bashrc
```

축하드립니다.
AWS CLI 설치가 완료되었습니다!