# Smart Yard  iOS

## История проекта
Это приложение, которое было изначально заказано операторм связи LanTa (г. Тамбов) у студии мобильной разработки MadBrains (г. Ульяновск) в 2020 году для проекта умных домофонов. Это изначально был MVP, который умел принимать видеозвонки с IP домофонов Beward, открывать двери, калитки, шлагбаумы, принимать оплату от клиентов, подтверждать доступ пользователя к адресу, оставлять заявки на подключение, отображать камеры видеонаблюлюдения с архивом, получать и отображать текстовые уведомления, вести чат с оператором, управлять настройками домофона и управлять доступами для других жителей квартиры.
Позже мы стали развивать этот проект совими силами и дополнять его дополнительными фичами. мы добавили: видовые камеры, журнал событий, настройки функции распознавания лиц, интеграцию с Siri, Быстрыми командами, а также исправляли баги, которые за время работы то там, то тут всплывали.

В октябре 2021 года мы созрели для того, чтобы открыть исходные коды нашего проекта и предлгаем всем, кто заинтересован в построении аналогичных сервисов не "изобретать свой велосипед" с нуля, а вместе с нами развивать данный проект, обмениваясь идеями и наработками. На этот момент приложением пользуется около 15 тысяч пользователей, живущих в домах оборудованных домофонными панелями и системами видеонаблюдения от нашей компании.

## API
Приложение использует наше собственное API. [(ссылка на API)](https://github.com/rosteleset/ApplicationAPI)
Исходный код back-end, реализующий API, на текущий момент неотделим от нашей архитектуры и от всех остальных наших систем, поэтому на текущем этапе мы не можем вам предложить ничего лучше, как реализовать у себя это API своими силами.

## Используемые фреймворки и компоненты (основные)
* [CocoaPods](https://cocoapods.org/) для управления используемыми фреймворками
* [linphone-sdk](https://github.com/BelledonneCommunications/linphone-iphone) для реализации SIP части
* [Flussonic](https://flussonic.ru/) для работы с архивом видеокамер 
* [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) для работы с Push-уведомлениями
* [MapBox](https://www.mapbox.com/) для работы с картами (обязательно нужно на их сайте зарегистрироваться чтобы получить токен для работы с API и установки)
* [Crashlytics](https://firebase.google.com/docs/crashlytics), [Yandex AppMetrika](https://appmetrica.yandex.ru/) для сбора информации и сбоях и аналитике
* Реактивный фреймворк [RxSwift](https://github.com/ReactiveX/RxSwift) и
* [XCoordinator](https://github.com/quickbirdstudios/XCoordinator) для реализации архитектуры MVVM+Coordinator
* Фреймворк [Moya Swift](https://github.com/Moya/Moya) для удобной работы с REST API
