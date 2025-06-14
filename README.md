# (Swift 6, iOS 15+): MVC, UIKit, PinLayout, RxSwift, XCTest, Realm, Core Graphic

<br>

<img src="https://github.com/user-attachments/assets/e3a6e676-e3b4-497e-b425-c01b1b00e63e" width="250">!
<img src="https://github.com/user-attachments/assets/c8907ce2-6c1e-4f07-b97c-168dabb3cee9" width="250">!
<img src="https://github.com/user-attachments/assets/cfb0704d-f26c-45de-9f96-c94dfcb9f474" width="250">!

<br>

<h1>Тестовое задание в Рик мастерс</h1>
<p>В целом я доволен реализацией. Простое приложение, моментами может показаться, что из пушки по воробьям стрелял))</p> <p>Но Ведь цель тестового - показать что умеешь, а не сделать экономно)</p>

<h2>Из интересного:</h2>
<ul>
  <li>Работа с сетью + бизнес логика вынесены в отдельный модуль</li>
  <li>Кэширование данных в Realm</li>
  <li>Высокий уровень абстракции. Всё что инкапсулируется - инкапсулировано</li>
  <li>Вёрстка на чистом UIKit + PinLayout без StoryBoard</li>
  <li>Полностью написанные с 0 компоненты UI (ChartKit - тоже моя библиотека, есть на гите)</li>
  <li>Обмен данными с помощью RXSwift</li>
</ul>

<h1>Структура</h1>

<h2>Координатор</h2>
  <p>Не бигтеховский координатор - его младщий брат) Но свою задачу - инкапсуляцию навигации выполняет</p>
  <p>На данном этапе он, конечно, излишен, но мы же делаем как-будто на будущее)</p>
  
  <h3>Coordinatable</h3>
    <ul>
      <li type="cirlce">Может быть подписан только под UIViewController'ом</li>
      <li type="cirlce">Имеет ссылку на координатор, чтобы управлять навигацией</li>
    </ul>

  <h3>Coordinator</h3>
    <ul>
      <li type="cirlce">Методы собственно для отображения контроллеров</li>
      <li type="cirlce">ViewControllersFactory - фабрика, с которой берутся сами контроллеры</li>
    </ul>
  
<h2>Фабрика контроллеров</h2>
  <p>Фабрика для контроллеров, чтобы все знали, что они создаются, но никто не знал как🤫</p>
  <p>Тоже пока не необходима, "Задел на будущее"</p>
  
  <h3>ViewControllersFabric</h3>
    <ul>
      <li type="cirlce">Методы для создания контроллеров</li>
    </ul>
  
<h2>RikAPI</h2>
  <p>Отедльный модуль? ДА!</p>
    <h3>APInetwork</h3>
    <ul>
      <li type="cirlce">Протокол с методами для обращения к API</li>
      <li type="cirlce">Реализован посредством Swift Concurrency -> не тормозит UI при обращении🎉</li>
    </ul>
    <h3>NetowrkCacher</h3>
    <ul>
      <li type="cirlce">Протокол для кэширования данных из сети😯</li>
      <li type="cirlce">Является "наследником" APINetwork, что позволяет ему быть использованным как api</li>
    </ul>
    <h3>CashingNetworkFacade</h3>
    <ul>
      <li type="cirlce">Реализация APINetwork</li>
      <li type="cirlce">Содержит в себе "активную" сеть и кэшер. Если данных нет, то они подгружаются из сети и кэшируются, если есть - берутся из кэша</li>
    </ul>


<h2>API в приложении</h2>
    <h3>StatisticsAPI</h3>
    <ul>
      <li type="cirlce">Протокол, с набором методов для работы с API. Чтобы абстрагироваться от прямой работы с API🙂‍↕️</li>
      <li type="cirlce">RikStatisticsApiAdapter - адаптер, работает с RikAPI😯</li>
    </ul>


 <h2>Главный экран статистики</h2>
  <p>Первый(последний) экран</p>
    <h3>MainStatisticsModel</h3>
    <ul>
      <li type="cirlce">Можно назвать Rx адаптером для API</li>
      <li type="cirlce">Принимает входные потоки, выдает выходные через метод transform</li>
      <li type="cirlce">2 доп enum DateIntervalForVisitors и DateIntervalForSexAndAge для удобной работы с промежутками дат</li>
    </ul>
    <h3>TaskEditingViewController</h3>
    <ul>
      <li type="cirlce">Простой котнроллер с скролящимся StackView</li>
      <li type="cirlce">Весь экран разбит на несколько секций, которые группируются между собой другими UIStackView</li>
      <li type="cirlce">Просто и со вкусом>li>
    </ul>
    <h3>Кастомные View</h3>
    <ul>
      <li type="cirlce">График - написан полностью с 0</li>
      <li type="cirlce">PieChart - взят из написанной мной ранее библиотеки ChartKit</li>
      <li type="cirlce">ActionsLineView - стак с кнопками, обернутый в UIScrollView</li>
    </ul>

<h1>Заключение</h1>
<p>Вот и всё. На самом деле, влил свою джунплюсовскую архитекторскую душу в это)</p>
<p>Буду рад любой адекватной(опционально) критике</p>
<p>Места, которые разумно тестировать - покрыл тестам конечно же))</p>
<p>Я считаю, что получилось довольно хорошо, модульный и слабосвязный код с композицией вместо наследования - это ли не счастье?</p>
  
