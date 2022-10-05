//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;

#Если Клиент Тогда
////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

Перем мЗапрос Экспорт;
Перем мРезультатыПоиска Экспорт;
Перем мКорневойТипОбъекта Экспорт;
Перем мПутьКДаннымПоляНечеткогоСравнения;
Перем мСтруктураКлючаПоиска;
Перем мСтруктураПредставлений Экспорт;
Перем мСтрокаРеквизитов;
Перем мСписокРеквизитов;

Перем мЗависимыеМетаданные;

Перем мПостроительЗапросаОтбора;
Перем мЗатронутыеЭлементыПВХ  Экспорт;
Перем МассивСтруктурУсекаемыхТипов Экспорт;
Перем СоответствиеИзменяемыхИзмерений;
Перем ПроекцияКолонокВНовые;


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Функция ВыполнитьАвтокорректировку() Экспорт

	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	Попытка
		ВыполнитьАнализ();
		ВыполнитьОчисткуРегистров();
		ВыполнитьКоррекциюПВХ(мЗатронутыеЭлементыПВХ);
	Исключение
		Если ВыполнятьВТранзакции Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки; 
	Если ВыполнятьВТранзакции Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;

	Возврат ВыполнитьАнализ();
	
КонецФункции // ВыполнитьАвтокорректировку()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Функция ВыполнитьАнализ() Экспорт

	ЗатрагиваемыеЭлементыТекущегоПланаВидовХарактеристик = Новый ТаблицаЗначений;
	МассивСтруктурУсекаемыхТипов = Новый Массив;
	МассивТиповКУдалению = Новый Массив;
	Для Каждого УдаляемыйТип Из УдаляемыеТипы.Типы() Цикл
		МетаданныеТипа = Метаданные.НайтиПоТипу(УдаляемыйТип);
		Если МетаданныеТипа = Неопределено Тогда
			ирОбщий.СообщитьЛкс("Примитивный тип """ + УдаляемыйТип + """ не будет учтен");
			МассивТиповКУдалению.Добавить(УдаляемыйТип);
			Продолжить;
		КонецЕсли;
		СтруктураУсекаемогоТипа = Новый Структура;
		СтруктураУсекаемогоТипа.Вставить("Тип", УдаляемыйТип);
		СтруктураУсекаемогоТипа.Вставить("ТипЗапроса", Метаданные.НайтиПоТипу(УдаляемыйТип).ПолноеИмя());
		МассивСтруктурУсекаемыхТипов.Добавить(СтруктураУсекаемогоТипа);
	КонецЦикла;
	УдаляемыеТипы = Новый ОписаниеТипов(УдаляемыеТипы, , МассивТиповКУдалению);
	
	// Регистры сведений
	НайтиПоРавенствуНовыхКлючейЗаписи();
	
	// Планы видов характеристик
	ЗаполнитьТаблицуПВХ();
	
	Результат = Истина
		И Не ПроблемныеПланыВидовХарактеристик.Количество() > 0
		И Не ПроблемныеРегистры.Количество() > 0;
	Возврат Результат;

КонецФункции // ВыполнитьАнализ()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ВыполнитьОчисткуГруппыРегистра(СтрокаРегистра, СтрокаГруппы) Экспорт

	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	МенеджерРегистра = РегистрыСведений[СтрокаРегистра.Имя];
	ТаблицаЗаписей = ПолучитьПроблемныеЗаписиГруппыРегистра(СтрокаРегистра, СтрокаГруппы);
	ПервуюСтрокуПропустили = Ложь;
	ПредставлениеГруппы = СтрокаГруппы.Владелец().Индекс(СтрокаГруппы);
	Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(СтрокаГруппы.КоличествоЭлементовВГруппе - 1, "Элементы группы " + ПредставлениеГруппы);
	Для Каждого СтрокаЗаписи Из ТаблицаЗаписей Цикл
		Если Не ПервуюСтрокуПропустили Тогда
			ПервуюСтрокуПропустили = Истина;
			Продолжить;
		КонецЕсли; 
		ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
		СтруктураНабораЗаписей = ирОбщий.ОбъектБДПоКлючуЛкс("РегистрСведений." + СтрокаРегистра.Имя, СтрокаЗаписи,, Ложь);
		ирОбщий.ЗаписатьОбъектЛкс(СтруктураНабораЗаписей.Методы);
	КонецЦикла; 
	ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
	Если ВыполнятьВТранзакции Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;

КонецПроцедуры

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
// Возвращаемое значение:
//               - <Тип.Вид> - <описание значения>
//                 <продолжение описания значения>;
//  <Значение2>  - <Тип.Вид> - <описание значения>
//                 <продолжение описания значения>.
//
Функция ПолучитьПроблемныеЗаписиГруппыРегистра(СтрокаРегистра, СтрокаГруппы) Экспорт 

	Запрос = Новый Запрос;
	Запрос.Текст = СтрокаРегистра.ЗапросВыборкиСоставаГруппы;
	МетаРегистр = Метаданные.РегистрыСведений[СтрокаРегистра.Имя];
	Для Каждого МетаИзмерение Из МетаРегистр.Измерения Цикл
		Запрос.УстановитьПараметр(МетаИзмерение.Имя, СтрокаГруппы[МетаИзмерение.Имя]);
	КонецЦикла;
	Если МетаРегистр.ПериодичностьРегистраСведений <> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический Тогда
		Запрос.УстановитьПараметр("Период", СтрокаГруппы["Период"]);
	КонецЕсли;
	Если МетаРегистр.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.ПодчинениеРегистратору Тогда
		Запрос.УстановитьПараметр("Регистратор", СтрокаГруппы["Регистратор"]);
	КонецЕсли;
	ТаблицаЗаписей = Запрос.Выполнить().Выгрузить();
	Возврат ТаблицаЗаписей;

КонецФункции // ПолучитьПроблемныеЗаписиГруппыРегистра()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ВыполнитьОчисткуРегистра(СтрокаРегистра) Экспорт    
	
	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	мЗапрос.Текст = "ВЫБРАТЬ * ИЗ " + СтрокаРегистра.Имя;
	ГруппыТекущегоРегистра = мЗапрос.Выполнить().Выгрузить();
	Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(ГруппыТекущегоРегистра.Количество(), "Коррекция регистра " + СтрокаРегистра.Имя);
	Для Каждого СтрокаГруппы Из ГруппыТекущегоРегистра Цикл
		ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
		ВыполнитьОчисткуГруппыРегистра(СтрокаРегистра, СтрокаГруппы);
	КонецЦикла;
	ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
	Если ВыполнятьВТранзакции Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;

КонецПроцедуры // ВыполнитьОчисткуГруппРегистра()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ВыполнитьОчисткуРегистров() Экспорт

	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	Для Каждого СтрокаРегистра Из ПроблемныеРегистры Цикл
		ВыполнитьОчисткуРегистра(СтрокаРегистра);
	КонецЦикла;
	Если ВыполнятьВТранзакции Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;

КонецПроцедуры // ВыполнитьОчисткуРегистров()

Процедура НайтиПоРавенствуНовыхКлючейЗаписи() Экспорт
	
	ПроблемныеРегистры.Очистить();
	ЭлементыТекущейГруппы.Очистить();
	ГруппыТекущегоРегистра.Очистить();
	ГруппыТекущегоРегистра.Колонки.Очистить();
	мТекущаяГруппа = Неопределено;
	
	мСтруктураПредставлений = Новый Структура;
	мСтруктураПредставлений.Вставить("КоличествоЭлементовВГруппе", "Количество элементов");
	мСтруктураПредставлений.Вставить("НомерГруппы", "Номер группы");
	мСтруктураПредставлений.Вставить("ВывестиСостав", "Вывести состав");
	мСтруктураПредставлений.Вставить("Период", "Период");
	мСтруктураПредставлений.Вставить("Регистратор", "Регистратор");
	мСтруктураПредставлений.Вставить("ОткрытьЗапись", "Открыть запись");
	мСтруктураПредставлений.Вставить("НомерСтроки", "Номер строки");
	мСтруктураПредставлений.Вставить("Активность", "Активность");
	
	СоответствиеИзменяемыхИзмерений = Новый Соответствие;
	Для Каждого ИзменяемоеИзмерение Из ИзменяемыеИзмерения Цикл
		Если ирКэш.ОбъектМДПоПолномуИмениЛкс(ИзменяемоеИзмерение.Представление) = Неопределено Тогда
			ирОбщий.СообщитьЛкс("В текущей конфигурации не найдено изменяемое измерение """ + ИзменяемоеИзмерение.Представление + """", СтатусСообщения.Внимание);
		Иначе
			СоответствиеИзменяемыхИзмерений.Вставить(ИзменяемоеИзмерение.Представление, ИзменяемоеИзмерение.Значение);
		КонецЕсли; 
	КонецЦикла;
	
	мЗапрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(Метаданные.РегистрыСведений.Количество(), "Регистры сведений");
	Для Каждого МетаРегистр Из Метаданные.РегистрыСведений Цикл
		ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
		ПолноеИмяТаблицы = МетаРегистр.ПолноеИмя();
		ТекстВЫБРАТЬ = "";
		ТекстСГРУППИРОВАТЬ = "";
		ТекстГДЕ2 = "";
		ВозможныПроблемы = Ложь;
		Для Каждого МетаИзмерение Из МетаРегистр.Измерения Цикл
			ПолноеИмяИзмерения = МетаИзмерение.ПолноеИмя();
			ТекстПоля = ВыражениеПриведенияПоляКОписаниюТипов(ПолноеИмяИзмерения, ВозможныПроблемы);
			ИмяПоля = МетаИзмерение.Имя;
			ТекстВЫБРАТЬ = ТекстВЫБРАТЬ + ", " + ТекстПоля + " КАК " + ИмяПоля; // запрещенные имена например "Соединение" так вызывают ошибку?
			ТекстГДЕ2 = ТекстГДЕ2 + " И " + ТекстПоля + " = &" + ИмяПоля;
			ТекстСГРУППИРОВАТЬ = ТекстСГРУППИРОВАТЬ + ", " + ТекстПоля;
		КонецЦикла;
		
		Если МетаРегистр.ПериодичностьРегистраСведений <> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический Тогда
			ИмяПоля = "Период";
			ТекстПоля = ВыражениеПриведенияПоляКОписаниюТипов(ПолноеИмяТаблицы + ".." + ИмяПоля, ВозможныПроблемы);
			ТекстВЫБРАТЬ = ТекстВЫБРАТЬ + ", " + ТекстПоля + " КАК " + ИмяПоля;
			ТекстГДЕ2 = ТекстГДЕ2 + " И " + ТекстПоля + " = &" + ИмяПоля;
			ТекстСГРУППИРОВАТЬ = ТекстСГРУППИРОВАТЬ + ", " + ТекстПоля;
		КонецЕсли;
		
		Если МетаРегистр.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.ПодчинениеРегистратору Тогда
			ИмяПоля = "Регистратор";
			ТекстПоля = ИмяПоля;
			ТекстВЫБРАТЬ = ТекстВЫБРАТЬ + ", " + ТекстПоля + " КАК " + ИмяПоля;
			ТекстГДЕ2 = ТекстГДЕ2 + " И " + ТекстПоля + " = &" + ИмяПоля;
			ТекстСГРУППИРОВАТЬ = ТекстСГРУППИРОВАТЬ + ", " + ТекстПоля;
		КонецЕсли;
		
		Если Не ВозможныПроблемы Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстСГРУППИРОВАТЬ = Сред(ТекстСГРУППИРОВАТЬ, 2);
		ТекстЗапросаПоиска = "
		|ВЫБРАТЬ
		|	КОЛИЧЕСТВО(*) КАК КоличествоЭлементовВГруппе" + ТекстВЫБРАТЬ + "
		|ПОМЕСТИТЬ " + МетаРегистр.Имя + "
		|ИЗ " + МетаРегистр.ПолноеИмя() + " КАК Регистр
		|СГРУППИРОВАТЬ ПО " + ТекстСГРУППИРОВАТЬ + " 
		|ИМЕЮЩИЕ КОЛИЧЕСТВО(*) > 1
		|";
		
		мЗапрос.Текст = ТекстЗапросаПоиска;
		мЗапрос.Выполнить();
		
		мЗапрос.Текст = "ВЫБРАТЬ КОЛИЧЕСТВО(*) КАК КоличествоГрупп ИЗ " + МетаРегистр.Имя;
		КоличествоГрупп = мЗапрос.Выполнить().Выгрузить()[0].КоличествоГрупп;
		
		Если КоличествоГрупп = 0 Тогда
			Продолжить;
		КонецЕсли;
			
		СтрокаРегистра = ПроблемныеРегистры.Добавить();
		СтрокаРегистра.ЗапросВыборкиСоставаГруппы = "
		|ВЫБРАТЬ *
		|ИЗ " + МетаРегистр.ПолноеИмя() + " КАК Регистр
		|ГДЕ ИСТИНА " + ТекстГДЕ2 + "
		|";
		СтрокаРегистра.Имя = МетаРегистр.Имя;
		СтрокаРегистра.КоличествоГрупп = КоличествоГрупп;
		
	КонецЦикла;
	ирОбщий.ОсвободитьИндикаторПроцессаЛкс();

КонецПроцедуры

Функция ВыражениеПриведенияПоляКОписаниюТипов(Знач ПолноеИмяИзмерения, выхВозможныПроблемы = Ложь)
	
	мПлатформа = ирКэш.Получить();
	#Если Сервер И Не Сервер Тогда
		мПлатформа = Обработки.ирПлатформа.Создать();
	#КонецЕсли
	ИмяПоля = ирОбщий.ПоследнийФрагментЛкс(ПолноеИмяИзмерения);
	ВыражениеНеопределено = "КОГДА ЛОЖЬ";
	ВыражениеСтрока = "";
	ВыражениеЧисло = "";
	ВыражениеДата = "";
	ТипЗначенияТекущий = ирОбщий.ОписаниеПоляТаблицыБДЛкс(ирОбщий.ПолноеИмяКолонкиБДИзМД(ПолноеИмяИзмерения)).ТипЗначения;
	#Если Сервер И Не Сервер Тогда
		ТипЗначенияТекущий = Новый ОписаниеТипов;
	#КонецЕсли
	ТипЗначенияНовый = СоответствиеИзменяемыхИзмерений[ПолноеИмяИзмерения];
	Если ТипЗначенияНовый <> Неопределено Тогда
		#Если Сервер И Не Сервер Тогда
			ТипЗначенияНовый = Новый ОписаниеТипов;
		#КонецЕсли
		Если ТипЗначенияНовый.Типы().Количество() = 0 Тогда
			// Измерение удалено в новой конфигурации
			ТипЗначенияТекущий = Неопределено;
			ВыражениеНеопределено = ВыражениеНеопределено + "
			|		ИЛИ ИСТИНА";
		Иначе
			Для Каждого Тип Из ТипЗначенияТекущий.Типы() Цикл
				Если ирОбщий.ЛиТипСсылкиБДЛкс(Тип, Ложь) Тогда
					Если Не ТипЗначенияНовый.СодержитТип(Тип) Тогда
						ВыражениеНеопределено = ВыражениеНеопределено + "
						|		ИЛИ (" + ИмяПоля + " ССЫЛКА " + Метаданные.НайтиПоТипу(Тип).ПолноеИмя() + ")";
					КонецЕсли; 
				Иначе
					Если ирКэш.НомерВерсииПлатформыЛкс() > 803001 Тогда
						ИмяТипа = мПлатформа.СтруктураТипаИзКонкретногоТипа(Тип).ИмяОбщегоТипа;
						ТекстПроверкиТипа = "ТИПЗНАЧЕНИЯ(" + ИмяПоля + ") = ТИП(" + ИмяТипа + ")";
						Если Не ТипЗначенияНовый.СодержитТип(Тип) Тогда
							ВыражениеНеопределено = ВыражениеНеопределено + "
							|		ИЛИ " + ТекстПроверкиТипа;
						Иначе
							Если Тип = Тип("Число") Тогда
								// TODO ДопустимыйЗнак еще нужно учесть
								ВыражениеЧисло = "КОГДА " + ТекстПроверкиТипа + "
								|		ТОГДА ВЫРАЗИТЬ(" + ИмяПоля + " КАК ЧИСЛО(" + ТипЗначенияНовый.КвалификаторыЧисла.Разрядность + ", " + ТипЗначенияНовый.КвалификаторыЧисла.РазрядностьДробнойЧасти + "))";
							ИначеЕсли Тип = Тип("Строка") Тогда
								ВыражениеСтрока = "КОГДА " + ТекстПроверкиТипа + "
								|		ТОГДА ВЫРАЗИТЬ(" + ИмяПоля + " КАК СТРОКА(" + ТипЗначенияНовый.КвалификаторыСтроки.Длина + "))";
							ИначеЕсли Тип = Тип("Дата") Тогда
								Если ТипЗначенияНовый.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Дата Тогда
									ВыражениеСтрока = "КОГДА " + ТекстПроверкиТипа + "
									|		ТОГДА НачалоПериода(" + ИмяПоля + ", ДЕНЬ)";
								Иначе
									ВыражениеСтрока = "КОГДА " + ТекстПроверкиТипа + "
									|		ТОГДА ДобавитьКДате(ДатаВремя(1,1,1), РазностьДат(НачалоПериода(" + ИмяПоля + ", ДЕНЬ), " + ИмяПоля + ", СЕКУНДА), СЕКУНДА)";
								КонецЕсли; 
							КонецЕсли; 
						КонецЕсли; 
					Иначе
						ирОбщий.СообщитьЛкс("Проверка конфликтов по типу """ + Тип + """ в усеченном измерении " + ПолноеИмяИзмерения + " не может быть выполнена на платформе 8.2");
					КонецЕсли; 
				КонецЕсли; 
			КонецЦикла;
		КонецЕсли; 
		выхВозможныПроблемы = Истина;
	КонецЕсли; 
	Если ТипЗначенияТекущий <> Неопределено Тогда
		Для Каждого СтруктураУсекаемогоТипа Из МассивСтруктурУсекаемыхТипов Цикл
			Если ТипЗначенияТекущий.СодержитТип(СтруктураУсекаемогоТипа.Тип) Тогда
				ВыражениеНеопределено = ВыражениеНеопределено + "
				|	ИЛИ (" + ИмяПоля + " ССЫЛКА " + СтруктураУсекаемогоТипа.ТипЗапроса + ")";
				выхВозможныПроблемы = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли; 
	ВыражениеНеопределено = ВыражениеНеопределено + "
	|	ТОГДА НЕОПРЕДЕЛЕНО";
	Если ЗначениеЗаполнено(ВыражениеСтрока) Тогда
		ВыражениеНеопределено = ВыражениеНеопределено + "
		|	" + ВыражениеСтрока;
	КонецЕсли; 
	Если ЗначениеЗаполнено(ВыражениеЧисло) Тогда
		ВыражениеНеопределено = ВыражениеНеопределено + "
		|	" + ВыражениеЧисло;
	КонецЕсли; 
	Если ЗначениеЗаполнено(ВыражениеДата) Тогда
		ВыражениеНеопределено = ВыражениеНеопределено + "
		|	" + ВыражениеДата;
	КонецЕсли; 
	ТекстПоля = "
	|ВЫБОР
	|	" + ВыражениеНеопределено;
	Если ТипЗначенияТекущий <> Неопределено Тогда
		ТекстПоля = ТекстПоля + "
		|	ИНАЧЕ " + ИмяПоля;
	КонецЕсли; 
	ТекстПоля = ТекстПоля + "
	|КОНЕЦ";
	Возврат ТекстПоля;

КонецФункции

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ЗаполнитьТаблицуПВХ()

	мЗатронутыеЭлементыПВХ = Новый ТаблицаЗначений;
	мЗатронутыеЭлементыПВХ.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка"));
	мЗатронутыеЭлементыПВХ.Колонки.Добавить("Ссылка");
	
	Для Каждого МетаПВХ Из Метаданные.ПланыВидовХарактеристик Цикл
		Выборка = ирОбщий.ПолучитьМенеджерЛкс(МетаПВХ).Выбрать();
		Пока Выборка.Следующий() Цикл
			Затрагивается = Ложь;
			Для Каждого СтруктураУсекаемогоТипа Из МассивСтруктурУсекаемыхТипов Цикл
				Если Выборка.ТипЗначения.СодержитТип(СтруктураУсекаемогоТипа.Тип) Тогда
					Затрагивается = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если Затрагивается Тогда
				СтрокаЭлементаПВХ = мЗатронутыеЭлементыПВХ.Добавить();
				СтрокаЭлементаПВХ.Имя = МетаПВХ.Имя;
				СтрокаЭлементаПВХ.Ссылка = Выборка.Ссылка;
			КонецЕсли;
		КонецЦикла; 
	КонецЦикла;
	
	ИтогоПВХ = мЗатронутыеЭлементыПВХ.Скопировать();
	ИтогоПВХ.Колонки.Добавить("КоличествоЗатрагиваемыхЭлементов");
	ИтогоПВХ.ЗаполнитьЗначения(1, "КоличествоЗатрагиваемыхЭлементов");
	ИтогоПВХ.Свернуть("Имя", "КоличествоЗатрагиваемыхЭлементов");
	ПроблемныеПланыВидовХарактеристик.Загрузить(ИтогоПВХ);

КонецПроцедуры

Процедура ВыполнитьКоррекциюПВХ(ТаблицаСсылокПВХ) Экспорт 

	Если ТаблицаСсылокПВХ = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	ИндикаторПроцесса = ирОбщий.ПолучитьИндикаторПроцессаЛкс(ТаблицаСсылокПВХ.Количество(), "Коррекция элементов ПВХ");
	Для Каждого СтрокаЭлемента Из ТаблицаСсылокПВХ Цикл
		#Если Клиент Тогда
			ирОбщий.ОбработатьИндикаторЛкс(ИндикаторПроцесса);
		#КонецЕсли
		Ссылка = СтрокаЭлемента.Ссылка;
		ОбъектПВХ = ирОбщий.ОбъектБДПоКлючуЛкс(Ссылка.Метаданные().ПолноеИмя(), Ссылка);
		ИсходныйТипЗначения = Новый ОписаниеТипов(ОбъектПВХ.Данные.ТипЗначения);
		ДобавляемыеТипы = Новый Массив;
		//
		НовыйТипЗначения = Новый ОписаниеТипов(ИсходныйТипЗначения, ДобавляемыеТипы, УдаляемыеТипы.Типы());
		Если НовыйТипЗначения.Типы().Количество() = 0 Тогда
			ирОбщий.СообщитьЛкс("Автоматическая модификация типа значения элемента """ + Ссылка + """ невозможна, т.к. он становится пустым",
				СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		ОбъектПВХ.Данные.ТипЗначения = НовыйТипЗначения;
		Попытка
			ирОбщий.ЗаписатьОбъектЛкс(ОбъектПВХ.Методы);
			ирОбщий.СообщитьЛкс("Модифицирован тип значения элемента """ + Ссылка + """", СтатусСообщения.Информация);
			ирОбщий.СообщитьЛкс(Символы.Таб + "Старый: " + ИсходныйТипЗначения);
			ирОбщий.СообщитьЛкс(Символы.Таб + " Новый: " + ОбъектПВХ.Данные.ТипЗначения);
		Исключение
			ирОбщий.СообщитьЛкс("Ошибка при коррекции """ + Ссылка + """: " + ОписаниеОшибки(), СтатусСообщения.Важное);
		КонецПопытки;
	КонецЦикла; 
	ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
	Если ВыполнятьВТранзакции Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;

КонецПроцедуры

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
// Возвращаемое значение:
//               - <Тип.Вид> - <описание значения>
//                 <продолжение описания значения>;
//  <Значение2>  - <Тип.Вид> - <описание значения>
//                 <продолжение описания значения>.
//
Процедура ЗаполнитьПоРазницеМеждуКонфигурациями(ПолноеИмяФайла = "") Экспорт

	ирОбщий.СоздатьCOMОбъект1СЛкс(); // Сразу проверяем частое препятствие
	Если ирКэш.НомерВерсииПлатформыЛкс() >= 803008 Тогда
		ЗаполнитьПоРазницеМеждуКонфигурациямиЧерезОтчетСравнения(ПолноеИмяФайла);
	Иначе
		ирОбщий.СообщитьЛкс("Выполняется на платформе ниже 8.3.8. Переименования измерений не будут обнаружены");
	КонецЕсли; 
	Если Не ЗначениеЗаполнено(ПолноеИмяФайла) Тогда
		ВременныйФайл = Новый ФАйл(ПолучитьИмяВременногоФайла("CF"));
		ПолноеИмяФайла = ВременныйФайл.ПолноеИмя;
		Состояние("Выгружаем основную конфигурацию");
		ЗапуститьСистему("DESIGNER /DumpCfg """ + ПолноеИмяФайла + """", Истина);
		//ВременныйФайл = Новый Файл("C:\TerminalDisk\ИР11.cf"); // для отладки
		Если Не ВременныйФайл.Существует() Тогда
			ирОбщий.СообщитьЛкс("Не удалось выгрузить файл конфигурации. Возможно был занят конфигуратор.", СтатусСообщения.Внимание);
			Возврат;
		КонецЕсли; 
	КонецЕсли; 
	ФайлКонфигурации = Новый Файл(ПолноеИмяФайла);
	ВременныйКаталог = ПолучитьИмяВременногоФайла();
	СтрокаСоединенияВременнойБазы = "File=""" + ВременныйКаталог + """;";
	
	мПлатформа = ирКэш.Получить();
	Состояние("Создаем временную базу");
	// Антибаг платформы 8.2.14 http://partners.v8.1c.ru/forum/thread.jsp?id=952390#952390
	//ЗапуститьСистему("CREATEINFOBASE " + СтрокаСоединенияВременнойБазы + " /UseTemplate " + ФайлКонфигурации.ПолноеИмя, Истина); 
	СтрокаКоманды = """" + ирОбщий.ИмяИсполняемогоФайлаКлиентаПлатформыЛкс() + """ " + "CREATEINFOBASE File=""" + ВременныйКаталог + """;";
	
	// Антибаг платформы http://partners.v8.1c.ru/forum/thread.jsp?id=1076785#1076785
	Если ирКэш.НомерВерсииПлатформыЛкс() < 802018 Тогда
		СтрокаКоманды = СтрокаКоманды + "/";
	КонецЕсли; 
	ИмяФайлаЛога = ПолучитьИмяВременногоФайла("txt");
	СтрокаКоманды = СтрокаКоманды + " /UseTemplate """ + ФайлКонфигурации.ПолноеИмя + """ /Out""" + ИмяФайлаЛога + """";
	РезультатКоманды = мПлатформа.ТекстРезультатаКомандыСистемы(СтрокаКоманды);
	Попытка
	    МассивУдаленныхТипов = ВычислитьРазницуЧерезCOM(СтрокаСоединенияВременнойБазы, ИмяФайлаЛога);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		Если ВременныйФайл <> Неопределено Тогда
			УдалитьФайлы(ВременныйФайл.ПолноеИмя);
		КонецЕсли; 
		УдалитьФайлы(ВременныйКаталог);
		ВызватьИсключение;
	КонецПопытки; 
	Если ВременныйФайл <> Неопределено Тогда
		УдалитьФайлы(ВременныйФайл.ПолноеИмя);
	КонецЕсли; 
	УдалитьФайлы(ВременныйКаталог);
	УдаляемыеТипы = Новый ОписаниеТипов(МассивУдаленныхТипов);

КонецПроцедуры

Функция ВычислитьРазницуЧерезCOM(Знач СтрокаСоединенияВременнойБазы, Знач ИмяФайлаЛога)
	
	КомСоединение = ирОбщий.СоздатьСеансИнфобазы1С8Лкс(СтрокаСоединенияВременнойБазы,,, "COMConnector");
	Если КомСоединение.КонфигурацияИзменена() Тогда
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ИмяФайлаЛога);
		ирОбщий.СообщитьЛкс(ТекстовыйДокумент.ПолучитьТекст());
	Иначе
		МассивУдаленныхТипов = Новый Массив();
		НовыеМетаданные = КомСоединение.Метаданные;
		СсылочныеТипыМетаданных = ирКэш.КорневыеТипыСсылочныеЛкс();
		Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(СсылочныеТипыМетаданных.Количество(), "Поиск удаленных ссылочных метаданных");
		Для Каждого СтрокаКорневогоТипа Из СсылочныеТипыМетаданных Цикл
			ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
			ИмяКоллекции = СтрокаКорневогоТипа.Множественное;
			КоллекцияТекущая = Метаданные[ИмяКоллекции];
			КоллекцияНовая = НовыеМетаданные[ИмяКоллекции];
			Для Каждого МетаобъектТекущий Из КоллекцияТекущая Цикл
				ПолноеИмяРегистра = МетаобъектТекущий.ПолноеИмя();
				ИмяТипаМенеджера = ирОбщий.ИмяТипаИзПолногоИмениМДЛкс(ПолноеИмяРегистра, "Менеджер");
				МенеджерОбъекта = Новый(ИмяТипаМенеджера);
				ИдентификаторМенеджера = ЗначениеВСтрокуВнутр(МенеджерОбъекта);
				НовыйМенеджер = КомСоединение.ЗначениеИзСтрокиВнутр(ИдентификаторМенеджера);
				Если НовыйМенеджер <> Неопределено Тогда
					МетаобъектНовый = НовыйМенеджер.ПустаяСсылка().Метаданные();
				КонецЕсли; 
				Если МетаобъектНовый = Неопределено Тогда
					МетаобъектНовый = КоллекцияНовая.Найти(МетаобъектТекущий.Имя);
				КонецЕсли; 
				Если МетаобъектНовый = Неопределено Тогда 
					МассивУдаленныхТипов.Добавить(Тип(ирОбщий.ИмяТипаИзПолногоИмениТаблицыБДЛкс(ПолноеИмяРегистра)));
				КонецЕсли; 
			КонецЦикла; 
		КонецЦикла;
		ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
		КоллекцияТекущая = Метаданные.РегистрыСведений;
		КоллекцияНовая = НовыеМетаданные.РегистрыСведений;
		ИзменяемыеИзмерения.Очистить();
		Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(КоллекцияТекущая.Количество(), "Поиск изменяемых измерений");
		Для Каждого МетаобъектТекущий Из КоллекцияТекущая Цикл
			ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
			ПолноеИмяРегистра = МетаобъектТекущий.ПолноеИмя();
			ИмяТипаМенеджера = ирОбщий.ИмяТипаИзПолногоИмениМДЛкс(ПолноеИмяРегистра, "Менеджер");
			МенеджерОбъекта = Новый(ИмяТипаМенеджера);
			ИдентификаторМенеджера = ЗначениеВСтрокуВнутр(МенеджерОбъекта);
			МетаобъектНовый = Неопределено;
			Попытка
				НовыйМенеджер = КомСоединение.ЗначениеИзСтрокиВнутр(ИдентификаторМенеджера); // Могут быть ошибки компиляции и подключения обработчиков во внешнем соединении. TODO переделать на запрос
				Если НовыйМенеджер <> Неопределено Тогда
					НаборЗаписейНовыйКОМ = НовыйМенеджер.СоздатьНаборЗаписей(); // Могут быть ошибки компиляции и подключения обработчиков во внешнем соединении. TODO переделать на запрос
					МетаобъектНовый = НаборЗаписейНовыйКОМ.Метаданные();
				КонецЕсли; 
				Если МетаобъектНовый = Неопределено Тогда
					// Если не нашли по внутреннему идентификатору, ищем по имени объекта МД
					МетаобъектНовый = КоллекцияНовая.Найти(МетаобъектТекущий.Имя);
				КонецЕсли;
			Исключение
				ирОбщий.СообщитьЛкс(ОписаниеОшибки());
			КонецПопытки;
			Если МетаобъектНовый = Неопределено Тогда
				ирОбщий.СообщитьЛкс("Для """ + ПолноеИмяРегистра + """ не найдено соответствия в новой конфигурации");
				Продолжить;
			КонецЕсли; 
			ЗаписьXMLКОМ = Неопределено;
			ТаблицаНабораКОМ = НаборЗаписейНовыйКОМ.Выгрузить();
			//ТаблицаНабораТекущая = РегистрыСведений[МетаобъектТекущий.Имя].СоздатьНаборЗаписей().Выгрузить(); // Так будут ошибки толстого клиента https://www.hostedredmine.com/issues/931430
			ТаблицаНабораТекущая = ирОбщий.ПустаяТаблицаЗначенийИзТаблицыБДЛкс(ПолноеИмяРегистра);
			#Если Сервер И Не Сервер Тогда
				ТаблицаНабораКОМ = Новый ТаблицаЗначений;
				ТаблицаНабораТекущая = Новый ТаблицаЗначений;
			#КонецЕсли
			КолонкиНовыеКОМ = ТаблицаНабораКОМ.Колонки;
			Для Каждого КолонкаТекущая Из ТаблицаНабораТекущая.Колонки Цикл
				МетаИзмерение = МетаобъектТекущий.Измерения.Найти(КолонкаТекущая.Имя);
				Если Истина
					И МетаИзмерение = Неопределено
					И Не (КолонкаТекущая.Имя = "Период" И МетаобъектТекущий.ПериодичностьРегистраСведений <> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический)
				Тогда
					Продолжить;
				КонецЕсли; 
				НовоеИмяИзмерения = КолонкаТекущая.Имя;
				РольМетаданных = "";
				Если МетаИзмерение <> Неопределено Тогда
					РольМетаданных = "Измерение";
					Если ПроекцияКолонокВНовые <> Неопределено Тогда
						ПроекцияИмени = ПроекцияКолонокВНовые[ПолноеИмяРегистра + ".Измерение." + КолонкаТекущая.Имя];
						Если ПроекцияИмени <> Неопределено Тогда
							НовоеИмяИзмерения = ПроекцияИмени;
						КонецЕсли; 
					КонецЕсли; 
				КонецЕсли; 
				КолонкаНоваяКОМ = КолонкиНовыеКОМ.Найти(НовоеИмяИзмерения);
				Если КолонкаНоваяКОМ = Неопределено Тогда
					ИзменяемыеИзмерения.Добавить(Новый ОписаниеТипов, ПолноеИмяРегистра + "." + РольМетаданных + "." + КолонкаТекущая.Имя);
					Продолжить;
				КонецЕсли; 
				ТипЗначенияКОМ = КолонкаНоваяКОМ.ТипЗначения;
				ТипыНовые = ЗначениеИзКОМ(ТипЗначенияКОМ.Типы(), КомСоединение, ЗаписьXMLКОМ);
				Если ТипыНовые = Неопределено Тогда
					// https://www.hostedredmine.com/issues/930774
					ирОбщий.СообщитьЛкс("Пропускаем измерение " + ПолноеИмяРегистра + "." + КолонкаТекущая.Имя + " из-за использования новых типов", СтатусСообщения.Внимание);
					Продолжить;
				КонецЕсли;
				КвалификаторыЧислаНовые = ЗначениеИзКОМ(ТипЗначенияКОМ.КвалификаторыЧисла, КомСоединение, ЗаписьXMLКОМ);
				КвалификаторыСтрокиНовые = ЗначениеИзКОМ(ТипЗначенияКОМ.КвалификаторыСтроки, КомСоединение, ЗаписьXMLКОМ);
				КвалификаторыДатыНовые = ЗначениеИзКОМ(ТипЗначенияКОМ.КвалификаторыДаты, КомСоединение, ЗаписьXMLКОМ);
				ТипЗначенияНовый = Новый ОписаниеТипов(ТипыНовые,,, КвалификаторыЧислаНовые, КвалификаторыСтрокиНовые, КвалификаторыДатыНовые);
				Если ирОбщий.ЛиОписаниеТипов1ВходитВОписаниеТипов2Лкс(КолонкаТекущая.ТипЗначения, ТипЗначенияНовый) Тогда 
					Продолжить;
				КонецЕсли; 
				ИзменяемыеИзмерения.Добавить(ТипЗначенияНовый, ПолноеИмяРегистра + "." + РольМетаданных + "." + КолонкаТекущая.Имя);
			КонецЦикла;
		КонецЦикла; 
		ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
	КонецЕсли;
	ИзменяемыеИзмерения.СортироватьПоПредставлению();
	Возврат МассивУдаленныхТипов;

КонецФункции

Функция ЗначениеИзКОМ(КОМЗначение, Знач КомСоединение, ЗаписьXML = Неопределено)
	
	Если ЗаписьXML = Неопределено Тогда
		ЗаписьXML = КомСоединение.NewObject("ЗаписьXML");
	КонецЕсли; 
	ЗаписьXML.УстановитьСтроку();
	КомСоединение.СериализаторXDTO.ЗаписатьXML(ЗаписьXML, КОМЗначение);
	СтрокаХМЛ = ЗаписьXML.Закрыть();
	Результат = ирОбщий.ОбъектИзСтрокиXMLЛкс(СтрокаХМЛ);
	Возврат Результат;

КонецФункции

// 8.3.8+
Процедура ЗаполнитьПоРазницеМеждуКонфигурациямиЧерезОтчетСравнения(ПолноеИмяФайла = "") Экспорт

	КомандаСистемы = "DESIGNER /DisableStartupMessages /DisableStartupDialogs /CompareCfg -FirstConfigurationType DBConfiguration -SecondConfigurationType ";
	Если ЗначениеЗаполнено(ПолноеИмяФайла) Тогда
		КомандаСистемы = КомандаСистемы + "File -SecondConfigurationKey """ + ПолноеИмяФайла + """";
	Иначе
		КомандаСистемы = КомандаСистемы + "MainConfiguration";
	КонецЕсли; 
	ФайлОтчета = Новый ФАйл(ПолучитьИмяВременногоФайла("mxl"));
	ФайлЛога = Новый ФАйл(ПолучитьИмяВременногоФайла("txt"));
	ФайлСпискаОбъектов = ФайлСпискаОбъектовМДДляПакетнойОперацииЛкс(Метаданные.РегистрыСведений);
	КомандаСистемы = КомандаСистемы + " -IncludeChangedObjects -IncludeDeletedObjects -MappingRule ";
	//Если 1=1 Тогда
		КомандаСистемы = КомандаСистемы + "ByObjectIDs";
	//Иначе
	//	КомандаСистемы = КомандаСистемы + "ByObjectNames";
	//КонецЕсли;
	КомандаСистемы = КомандаСистемы + " -ReportType Full -Objects """ + ФайлСпискаОбъектов.ПолноеИмя + """ -ReportFormat mxl -ReportFile """ + ФайлОтчета.ПолноеИмя + """ /Out """ + ФайлЛога.ПолноеИмя + """"; 
	ЗапуститьСистему(КомандаСистемы, Истина);
	Если Не ФайлОтчета.Существует() Тогда
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ФайлЛога.ПолноеИмя);
		ирОбщий.СообщитьЛкс(ТекстовыйДокумент.ПолучитьТекст());
		ирОбщий.СообщитьЛкс("Не удалось сравнить конфигурации конфигуратором базы. Переименования измерений не будут обнаружены.");
		Возврат;
	КонецЕсли;
	//Предупреждение("Можете подключить отладчик"); // для отладки
	РезультатСравнения = Новый ТабличныйДокумент;
	РезультатСравнения.Прочитать(ФайлОтчета.ПолноеИмя);
	УдалитьФайлы(ФайлОтчета.ПолноеИмя);
	УдалитьФайлы(ФайлСпискаОбъектов.ПолноеИмя);
	ЦветУдаления = Новый Цвет(255, 228, 196);
	
	ПроекцияКолонокВНовые = Новый Соответствие;
	Пока Истина Цикл
		НайденнаяЯчейка = РезультатСравнения.НайтиТекст(".Измерение.", НайденнаяЯчейка);
		Если НайденнаяЯчейка = Неопределено Тогда
			Прервать;
		КонецЕсли;
		ПолноеИмяИзмерения = НайденнаяЯчейка.Текст;
		ЯчейкаНиже = РезультатСравнения.Область(НайденнаяЯчейка.Верх + 1, 3);
		Если ЯчейкаНиже.Текст <> "Имя - Различаются значения" Тогда
			Прервать;
		КонецЕсли;  
		ЯчейкаНиже = РезультатСравнения.Область(НайденнаяЯчейка.Верх + 3, 5);
		СтароеИмя = ирОбщий.СтрокаМеждуМаркерамиЛкс(ЯчейкаНиже.Текст, """", """");
		ЯчейкаНиже = РезультатСравнения.Область(НайденнаяЯчейка.Верх + 5, 5);
		НовоеИмя = ирОбщий.СтрокаМеждуМаркерамиЛкс(ЯчейкаНиже.Текст, """", """");
		ПроекцияКолонокВНовые.Вставить(ПолноеИмяИзмерения, НовоеИмя);
	КонецЦикла;
	
	//// Ищем удаленные измерения
	//НайденнаяЯчейка = Неопределено;
	//ОбластьПоиска = РезультатСравнения.Область("C5");
	//Пока Истина Цикл
	//	НайденнаяЯчейка = РезультатСравнения.НайтиТекст(".Измерение.", НайденнаяЯчейка, ОбластьПоиска);
	//	Если НайденнаяЯчейка = Неопределено Тогда
	//		Прервать;
	//	КонецЕсли;
	//	Если НайденнаяЯчейка.ЦветФона = ЦветУдаления Тогда
	//		ИзменяемыеИзмерения.Добавить(Новый ОписаниеТипов, НайденнаяЯчейка.Текст);
	//	КонецЕсли;
	//КонецЦикла;

	//// Ищем удаленные ссылочные типы
	//МассивУдаленныхТипов = Новый Массив();
	//СсылочныеТипыМетаданных = ирКэш.КорневыеТипыСсылочныеЛкс();
	//Для Каждого СтрокаКорневогоТипа Из СсылочныеТипыМетаданных Цикл
	//	ИмяКорневогоТипа = СтрокаКорневогоТипа.Единственное;
	//	НайденнаяЯчейка = Неопределено;
	//	ОбластьПоиска = РезультатСравнения.Область("C4");
	//	Пока Истина Цикл
	//		НайденнаяЯчейка = РезультатСравнения.НайтиТекст(ИмяКорневогоТипа + ".", НайденнаяЯчейка, ОбластьПоиска);
	//		Если НайденнаяЯчейка = Неопределено Тогда
	//			Прервать;
	//		КонецЕсли;
	//		Если НайденнаяЯчейка.ЦветФона = ЦветУдаления Тогда
	//			МассивУдаленныхТипов.Добавить(Тип(ирОбщий.ИмяТипаИзПолногоИмениТаблицыБДЛкс(НайденнаяЯчейка.Текст)));
	//		КонецЕсли;
	//	КонецЦикла;
	//КонецЦикла;
	//УдаляемыеТипы = Новый ОписаниеТипов(МассивУдаленныхТипов);

КонецПроцедуры

Функция ФайлСпискаОбъектовМДДляПакетнойОперацииЛкс(Знач ОбъектыМД) Экспорт 
	
	// https://its.1c.ru/db/v8318doc#bookmark:adm:TI000000698
	//<Objects xmlns="http://v8.1c.ru/8.3/config/objects" version="1.0">
	//	<Object fullName = "Справочник.Товары" includeChildObjects= "true" />
	//</Objects>
	ФайлСпискаОбъектов = Новый Файл(ПолучитьИмяВременногоФайла("xml"));
	ЗаписьХМЛ = Новый ЗаписьXML;
	ЗаписьХМЛ.ОткрытьФайл(ФайлСпискаОбъектов.ПолноеИмя);
	ЗаписьХМЛ.ЗаписатьНачалоЭлемента("Objects", "http://v8.1c.ru/8.3/config/objects");
	ЗаписьХМЛ.ЗаписатьАтрибут("version", "1.0");
	Для Каждого МетаРегистр Из Метаданные.РегистрыСведений Цикл
		ЗаписьХМЛ.ЗаписатьНачалоЭлемента("Object", "http://v8.1c.ru/8.3/config/objects");
		ЗаписьХМЛ.ЗаписатьАтрибут("fullName", МетаРегистр.ПолноеИмя());
		ЗаписьХМЛ.ЗаписатьАтрибут("includeChildObjects", XMLСтрока(Истина));
		ЗаписьХМЛ.ЗаписатьКонецЭлемента();
	КонецЦикла;
	ЗаписьХМЛ.ЗаписатьКонецЭлемента();
	ЗаписьХМЛ.Закрыть();
	Возврат ФайлСпискаОбъектов;

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

мЗапрос = Новый Запрос;
#КонецЕсли 
