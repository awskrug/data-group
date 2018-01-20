# AWS DeepLens기반 시각인식 ML
---

## 개요
AWS Reinvent 2017에서 발표한 AWS 딥렌즈를 이용하여 미리 만들어진 모델을 이용하여 실제로 객체를 인식하고 분류하는 것을 실습합니다.

이번 실습은 [실제로 Reivent2017에서 진행하였던 핸즈온](https://github.com/aws-samples/reinvent-2017-deeplens-workshop)을 기반으로 합니다.

## 순서

- 1. Face-Detection(Sample Project) 모델 
- 2. Squeezenet을 사용한 Mask 분류 모델 만들기


## 시작하기 전에 주의할 점

진행하는 AWS Console은 N.virginia 리전이어야 합니다.

현재 크롬 웹브라우져 외(ex. 파이어폭스)에는 정상적으로 작동하지 않는 경우를 발견하였습니다. 크롬 웹브라우져로 진행 부탁드립니다.




## 1. Face-Detection(Sample Project) 모델

- [AWS CLOUD 2018 DeepLens](https://www.slideshare.net/awskorea/utilizing-amazon-deeplens-and-computer-version-deep-learning-application-junghee-kang)
33Page부터 참조

- project templates에서 Object Detection이 아니라 Face Detection을 선택합니다.

- output을 확인합니다.

모니터가 있을 경우, AWS DeepLens에 직접 접속하여 터미널에서 다음의 명령어를 실행합니다.

```
mplayer -demuxer lavf -lavfdopts format=mjpeg:probesize=32 /tmp/results.mjpeg
```

모니터가 없을 경우에는, SSH를 사용하여 접속합니다. (현재 Mac만 가능)

[Mac에서 AWS DeepLens Output 보기](https://forums.aws.amazon.com/thread.jspa?messageID=818172&#818172)

[Linux에서 AWS DeepLens Output 보기](http://dveamer.github.io/ubuntu/HowToConnectWIFIOnCommandLine.html)




[AWS 문서(DeepLens) - Sample Project](https://docs.aws.amazon.com/ko_kr/deeplens/latest/dg/deeplens-templated-projects-overview.html)




## 2. Squeezenet을 사용한 Mask 분류 모델 만들기

- AWS DeepLens가 기본으로 탑재하고 있는 Squeezenet 모델을 응용하여 Mask를 분류하도록 만들어 봅시다.

[Fine-tuning 문서](http://gluon.mxnet.io/chapter08_computer-vision/fine-tuning.html)

[Squeezenet 문서](https://arxiv.org/abs/1602.07360)


- 2.1. AWS Lambda 함수 생성하기

1. Lambda 콘솔로 들어갑니다 : https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

2. US East-1 (N.Virginia) 리전인지 확인합니다

3. Create function을 클릭합니다

4. Author from scratch을 클릭합니다.

5. function Name을 deeplens-hotdog-no-hotdog-your-full-name 으로 짓습니다. 이때 full name을 자신의 이름으로 넣습니다. (이때 deeplens-hotdog-not-hotdog 는 반드시 prefix이어야 합니다.) 

6. Choose an existing role 을 선택하여 deeplens_lambda role을 넣습니다. 

7. Create function을 클릭합니다.

- 2.2. AWS Lambda 함수 설정하기

1. Runtime을 python 2.7으로 바꿉니다.

2. handler box의 내용을 greengrassHelloWorld.function_handler 로 바꿉니다.  

3. code entry type을 'Upload a file from Amazon S3'로 바꾸고 다음의 링크를 s3 link로 붙여 넣습니다.

https://s3.amazonaws.com/deeplens-managed-resources/lambdas/hotdog-no-hotdog/new_hot_dog_lambda.zip

4. Save를 클릭하여 lambda를 저장합니다.


- 2.3. AWS Lambda 함수 수정하기

[Imagenet의 Label목록](https://gist.github.com/yrevar/942d3a0ac09ec9e5eb3a#file-imagenet1000_clsid_to_human-txt-L641)

Reinvent의 Workshop에서 진행하였던 Hotdog 대신, Mask를 찾아봅시다.

Imagenet의 Label목록을 확인하면 Mask의 label은 643번 이라는 걸 알 수 있습니다.

lambda code에서 84, 93, 94 번째 line을 다음과 같이 수정합니다.

84번째 Line
```
                if obj['label'] == 643:  
```

93번째 Line
```
            cv2.putText(frame, 'Not Mask', (0,22), font, 1, (225, 225, 225), 1)
```

94번째 Line
```
            cv2.putText(frame, 'Mask', (0,52), font, 1, (225, 225, 225), 1)
```

Save를 클릭하여 저장한 후, Action에서 Publish new version을 클릭하여 최신버젼으로 만듭니다.


- 2.4. Project 생성하기 

1. AWS DeepLens 콘솔로 돌아가 project 항목을 찾습니다.

2. Create a new project를 클릭합니다.

3. Create a new blank project template를 클릭합니다.

4. project의 이름을 지정합니다. : mask-detection-fullname

5. add model 를 클릭하여 the deeplens-squeezenet을 선택합니다.

6. Add function을 클릭하여 방금 수정하였던 deeplens-hotdog-no-hotdog-your-full-name function를 선택합니다.

7. project를 생성합니다.


- 2.5. 자신의 AWS DeepLens 에 Project 배포하기

이 부분은 반드시 크롬으로 진행해야 합니다!!!

1. 방금 생성한 project를 선택합니다.

2. deploy to device를 클릭합니다.

3. 배포할 device를 선택합니다.

4. 배포가 되길 기다리고 정상적으로 이뤄지는지 확인합니다.

- 2.6. output을 확인합니다.

모니터가 있을 경우, AWS DeepLens에 직접 접속하여 터미널에서 다음의 명령어를 실행합니다.

```
mplayer -demuxer lavf -lavfdopts format=mjpeg:probesize=32 /tmp/results.mjpeg
```

모니터가 없을 경우에는, SSH를 사용하여 접속합니다. (현재 Mac만 가능)

[Mac에서 AWS DeepLens Output 보기](https://forums.aws.amazon.com/thread.jspa?messageID=818172&#818172)

[Linux에서 AWS DeepLens Output 보기](http://dveamer.github.io/ubuntu/HowToConnectWIFIOnCommandLine.html)



## References
- [AWS Developer Forums: AWS DeepLens](https://forums.aws.amazon.com/forum.jspa?forumID=275)
- [AWS CLOUD 2018- Amazon DeepLens와 컴퓨터 비전 딥러닝 어플리케이션 활용 (강정희 솔루션즈 아키텍트)](https://www.slideshare.net/awskorea/utilizing-amazon-deeplens-and-computer-version-deep-learning-application-junghee-kang)
- [aws-samples/reinvent-2017-deeplens-workshop](https://github.com/aws-samples/reinvent-2017-deeplens-workshop)
