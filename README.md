# 급해 (공중화장실 지도 및 안심 서비스) - iOS

### : '급해'를 사용해서 주변의 화장실 정보를 알아보세요. 화장실에 가기 불안한 경우 위험대비문자를 통해  혹시 모를 위험에 대비할 수 있습니다.

---



 

## * 주요 기능

### 1. 전국의 화장실을 표시

\- 공공데이터를 활용하여 전국의 화장실을 보여줍니다.



 

### 2. 화장실 상세 정보

\- 화장실을 터치하면 상세 정보를 볼 수 있습니다.

\- 상세 정보창을 통해 위험대비문자, 안심문자를 보낼 수 있습니다.

\- 남녀공용여부, 장애인용 갯수, 운영 시간 등을 파악할 수 있습니다.



 

### 3. 비상 연락

\- 위험대비문자를 터치하여 비상연락처에 등록된 사람들에게 문자를 보낼 수 있습니다. 해당 시간 이내에 안심문자를 받지 못 할 경우 수신자가 조치를 취할 수 있습니다.

 



### 4. 다크 모드

\- iOS13 이상 사용 가능

 

---



## * 필수 접근 권한

### 1. 위치

: 현재 위치를 알 수 있습니다.

\- **항상 허용:** 위험대비문자 발송 후 설정한 시간이 되기 5분 전 안심문자를 발송하라는 알림 기능,  앱을 완전이 종료하지 않고 30분이 지나면 GPS 계속 동작 중임을 알려주는 기능

\- **그 외:** 위험대비문자만 발송 가능



 

### 2. 연락처

: 비상연락처에 추가할 수 있습니다.



 

### 3. 알림

: 위치 권한을 항상 허용으로 한 경우 각종 알림을 받을 수 있습니다.



 

\* 주변의 화장실을 좀 더 안전하게 사용합시다

 

---



## * 스크린샷

### 1. Launch Screen

<img src="Assets/Launch Screen.png" width="50%">

### 2. 지도

<img src="Assets/MapView Screen3.png" width="33%"><img src="Assets/MapView Screen.png" width="33%"><img src="Assets/MapView Screen2.png" alt="MapView Screen2" width="33%">

> 지도를 축소하면 해당 지역의 화장실을 숫자로 보여줍니다.
>
> Marker를 Touch 하면 해당 화장실 정보를 보여줍니다.
>
> 아래 상세 정보창을 Touch 하면 더욱 상세한 정보를 볼 수 있습니다. 한번 더 Touch 하면 상세 정보 창이 다시 내려갑니다. 

### 3. 설정

<img src="Assets/Setting Screen.png" width="50%">

> **활성화:** 위함대비문자 전송기능의 사용여부
>
> **설정된 시간:** 사용자가 지정한 화장실의 이용 시간. 위험대비문자에 해당 시간 이후로도 연락이 없다면 조치를 취해달라고 명시합니다.
>
> **비상연락처:** 위험대비문자를 전송할 연락처

### 4. 문자 전송

<img src="Assets/Message Screen.png" width="33%"><img src="Assets/Notice Screen.png" width="33%"><img src="Assets/Message Screen2.png" width="33%">

> 위험대비문자 전송 버튼을 Touch 하면 자동완성된 문자가 나오며 전송 버튼을 누르면 전송합니다.
>
> 문자의 내용은 화장실의 이름, 주소, 위경도, 날짜 및 시간, 요청 사항 등이 나옵니다.

 

---



## * Develop Environment

- Xcode 11
- Swift 5.0

 

---



## * Open Source Library

- GooglePlaces
- GoogleMaps
- GoogleMobileAds

 

---



## [App Store](https://apps.apple.com/kr/app/급해/id1482602320?l=en)