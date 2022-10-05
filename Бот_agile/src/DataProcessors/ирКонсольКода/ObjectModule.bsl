//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;

Функция РеквизитыДляСервера(Параметры) Экспорт 
	
	Возврат Неопределено;
	
КонецФункции

Функция ВыполнитьАлгоритмВКонтексте(Параметры) Экспорт 
	#Если Сервер И Не Сервер Тогда
		Параметры = Новый Структура;
	#КонецЕсли
	#Если Сервер И Не Клиент Тогда
		КонтекстВыполнения = ирОбщий;
	#Иначе
		Если Параметры.ВыполнятьНаСервере <> Ложь Тогда
			КонтекстВыполнения = ирСервер;
		Иначе
			КонтекстВыполнения = ирОбщий;
		КонецЕсли;
	#КонецЕсли 
	Параметры.Вставить("ВремяНачала", ирОбщий.ТекущееВремяВМиллисекундахЛкс());
	Если Истина
		И Не Параметры.ЛиСинтаксическийКонтроль
		И Параметры.ЧерезВнешнююОбработку 
	Тогда
		КонтекстВыполнения.ВыполнитьАлгоритмЧерезВнешнююОбработкуЛкс(Параметры.ИмяФайлаВнешнейОбработки, Параметры.СтруктураПараметров, Параметры.ВремяНачала, Параметры.ВерсияАлгоритма);
	Иначе
		КонтекстВыполнения.ВыполнитьАлгоритм(Параметры.ТекстДляВыполнения, Параметры.СтруктураПараметров);
	КонецЕсли;
	Возврат Параметры;

КонецФункции

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
