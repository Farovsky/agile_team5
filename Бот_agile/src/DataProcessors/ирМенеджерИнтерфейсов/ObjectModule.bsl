//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;
#Если Клиент Тогда	
	
// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ВосстановитьСписокИнтерфейсов() Экспорт

	лСписокИнтерфейсов = ирОбщий.ВосстановитьЗначениеЛкс("СписокИнтерфейсов");
	Если лСписокИнтерфейсов <> Неопределено Тогда
		СписокИнтерфейсов = лСписокИнтерфейсов;
	КонецЕсли;
	ОбновитьСписокИнтерфейсов();

КонецПроцедуры // ВосстановитьСписокИнтерфейсов()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура СохранитьСписокИнтерфейсов() Экспорт

	ирОбщий.СохранитьЗначениеЛкс("СписокИнтерфейсов", СписокИнтерфейсов);

КонецПроцедуры // СохранитьСписокИнтерфейсов()

Процедура ОбновитьСписокИнтерфейсов() Экспорт
	
	МассивСтарых = Новый Массив;
	Для Каждого ИнтерфейсСписка Из СписокИнтерфейсов Цикл
		Если Метаданные.Интерфейсы.Найти(ИнтерфейсСписка.Значение) = Неопределено Тогда 
			МассивСтарых.Добавить(ИнтерфейсСписка);
		КонецЕсли;
	КонецЦикла;
	Для Каждого СтарыйИнтерфейс Из МассивСтарых Цикл
		СписокИнтерфейсов.Удалить(СтарыйИнтерфейс);
	КонецЦикла;

	Для каждого Интерфейс Из Метаданные.Интерфейсы Цикл
		ЭлементСписка = СписокИнтерфейсов.НайтиПоЗначению(Интерфейс.Имя);
		Если Не ПравоДоступа("Использование", Интерфейс) Тогда 
			Продолжить;
		КонецЕсли; 
		Если ЭлементСписка = Неопределено Тогда
			ЭлементСписка = СписокИнтерфейсов.Добавить(Интерфейс.Имя, Интерфейс.Синоним, ГлавныйИнтерфейс[Интерфейс.Имя].Видимость);
		КонецЕсли;
		Если ЭлементСписка <> Неопределено Тогда
			Если Интерфейс.Переключаемый Тогда 
				ЭлементСписка.Представление = "Переключаемый - " + Интерфейс.Представление();
			Иначе
				ЭлементСписка.Представление = "Общий - "  + Интерфейс.Представление();
			КонецЕсли;
		КонецЕсли;
		ЭлементИнтерфейса = ГлавныйИнтерфейс.Найти(Интерфейс.Имя);
		ЭлементСписка.Пометка = ЭлементИнтерфейса.Видимость;
	КонецЦикла;
	
	СписокИнтерфейсов.СортироватьПоПредставлению();
	
КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ДобавитьИнтерфейс(ИмяИнтерфейса) Экспорт

	ЭлементИнтерфейса = СписокИнтерфейсов.НайтиПоЗначению(ИмяИнтерфейса);
	Если ЭлементИнтерфейса <> Неопределено Тогда
		ЭлементИнтерфейса.Пометка = Истина;
	КонецЕсли;

КонецПроцедуры // ДобавитьИнтерфейс()

Процедура ВыполнитьПереключениеИнтерфейсов() Экспорт
	
	СтрокаИменИнтерфейсов = "";
	
	Для каждого СтрокаСписка Из СписокИнтерфейсов Цикл
		
		Если СтрокаСписка.Пометка Тогда;
			СтрокаИменИнтерфейсов = СтрокаИменИнтерфейсов + ?(СтрокаИменИнтерфейсов = "", "", ",") + СтрокаСписка.Значение;
		КонецЕсли;
		
	КонецЦикла;
	
	ГлавныйИнтерфейс.ПереключитьИнтерфейс(СтрокаИменИнтерфейсов);
	
КонецПроцедуры

//ирПортативный лФайл = Новый Файл(ИспользуемоеИмяФайла);
//ирПортативный ПолноеИмяФайлаБазовогоМодуля = Лев(лФайл.Путь, СтрДлина(лФайл.Путь) - СтрДлина("Модули\")) + "ирПортативный.epf";
//ирПортативный #Если Клиент Тогда
//ирПортативный 	Контейнер = Новый Структура();
//ирПортативный 	Оповестить("ирПолучитьБазовуюФорму", Контейнер);
//ирПортативный 	Если Не Контейнер.Свойство("ирПортативный", ирПортативный) Тогда
//ирПортативный 		ирПортативный = ВнешниеОбработки.ПолучитьФорму(ПолноеИмяФайлаБазовогоМодуля);
//ирПортативный 		ирПортативный.Открыть();
//ирПортативный 	КонецЕсли; 
//ирПортативный #Иначе
//ирПортативный 	ирПортативный = ВнешниеОбработки.Создать(ПолноеИмяФайлаБазовогоМодуля, Ложь); // Это будет второй экземпляр объекта
//ирПортативный #КонецЕсли
//ирПортативный ирОбщий = ирПортативный.ПолучитьОбщийМодульЛкс("ирОбщий");
//ирПортативный ирКэш = ирПортативный.ПолучитьОбщийМодульЛкс("ирКэш");
//ирПортативный ирСервер = ирПортативный.ПолучитьОбщийМодульЛкс("ирСервер");
//ирПортативный ирПривилегированный = ирПортативный.ПолучитьОбщийМодульЛкс("ирПривилегированный");

ВосстановитьСписокИнтерфейсов();

#КонецЕсли

