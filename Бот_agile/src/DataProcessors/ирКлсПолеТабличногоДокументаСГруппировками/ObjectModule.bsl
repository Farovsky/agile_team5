//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;

////////////////////////////////////////////////////////////////////////////////
// КОНТЕКСТНОЕ МЕНЮ ПОЛЯ ТАБЛИЧНОГО ДОКУМЕНТА С ГРУППИРОВКАМИ

#Если Клиент Тогда

Перем ИмяКласса Экспорт;
Перем СсылочнаяФормаКласса Экспорт;
Перем МаркерСвернутьДоУровня;

// Инициализирует экземпляр класса.
//
// Параметры:
//  *СтруктураЭкземляров - Структура, *Неопределено - содержит все объекты данного класса для данной формы;
//  пФорма       - Форма;
//  пПолеТабличногоДокумента - ПолеТабличногоДокумента;
//  пКоманднаяПанель - КоманднаяПанель, *Неопределено - в конце которой будут размещены кнопки.
//
Процедура Инициализировать(СтруктураЭкземляров = Неопределено, пФорма, пПолеТабличногоДокумента, пКоманднаяПанель = Неопределено) Экспорт

	ПолеТабличногоДокумента = пПолеТабличногоДокумента;
	КоманднаяПанель = пКоманднаяПанель;
	Имя = ПолеТабличногоДокумента.Имя;
	
	Если КоманднаяПанель = Неопределено Тогда
		КоманднаяПанель = ПолеТабличногоДокумента.КонтекстноеМеню;
		Если КоманднаяПанель = Неопределено Тогда
			ИмяКоманднойПанели = "КоманднаяПанельКонтекстногоМеню" + Имя;
			КоманднаяПанель = пФорма.ЭлементыФормы.Добавить(Тип("КоманднаяПанель"), ИмяКоманднойПанели);
			ПолеТабличногоДокумента.КонтекстноеМеню = КоманднаяПанель;
		КонецЕсли;
	КонецЕсли;
	
    ПерезаполнитьКоманднуюПанельСтатическимиКнопками();
	
	Если СтруктураЭкземляров <> Неопределено Тогда
		СтруктураЭкземляров.Вставить(Имя, ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры // Инициализировать()

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>.
//
Процедура ПерезаполнитьКоманднуюПанельСтатическимиКнопками() Экспорт 

	ФормаКласса = ирКэш.Получить().ПолучитьМакетКомпоненты(ЭтотОбъект);
	ирОбщий.ДобавитьКнопкиКоманднойПанелиКомпонентыЛкс(ЭтотОбъект, ФормаКласса.ЭлементыФормы.КоманднаяПанельОбщая.Кнопки, КоманднаяПанель);

КонецПроцедуры

// Обрабатывает нажатие на кнопки
//
Процедура Нажатие(Кнопка) Экспорт

	Команда = ирОбщий.ПоследнийФрагментЛкс(Кнопка.Имя, "_");
	Если Команда = "Зафиксировать" Тогда
		ПолеТабличногоДокумента.ФиксацияСлева = ПолеТабличногоДокумента.ТекущаяОбласть.Лево - 1;
		ПолеТабличногоДокумента.ФиксацияСверху = ПолеТабличногоДокумента.ТекущаяОбласть.Верх - 1;
	ИначеЕсли Лев(Команда, СтрДлина(МаркерСвернутьДоУровня)) = МаркерСвернутьДоУровня Тогда
	    СвернутьДоУровня(Кнопка.Имя);
	КонецЕсли;
	
КонецПроцедуры // Нажатие()

// Сворачивает группировки до заданного в строке команды уровня.
//
// Параметры:
//  СтрокаКоманды - Строка - специального формата.
//
Процедура СвернутьДоУровня(СтрокаКоманды) Экспорт

	СтрокаУровня = ирОбщий.СтрокаМеждуМаркерамиЛкс(СтрокаКоманды, МаркерСвернутьДоУровня);
	СтрокаНомераУровняСтрок = ирОбщий.СтрокаМеждуМаркерамиЛкс(СтрокаУровня, "Строк", , Ложь);
	Если СтрокаНомераУровняСтрок <> Неопределено Тогда 
		НужныйУровень = Число(СтрокаНомераУровняСтрок) - 1;
		Уровень = ПолеТабличногоДокумента.КоличествоУровнейГруппировокСтрок() - 1;
		Пока Уровень > НужныйУровень Цикл
			ПолеТабличногоДокумента.ПоказатьУровеньГруппировокСтрок(Уровень);
			Уровень = Уровень - 1;
		КонецЦикла;
		ПолеТабличногоДокумента.ПоказатьУровеньГруппировокСтрок(Уровень);
	Иначе
		СтрокаНомераУровняКолонок = ирОбщий.СтрокаМеждуМаркерамиЛкс(СтрокаУровня, "Колонок", , Ложь);
		НужныйУровень = Число(СтрокаНомераУровняКолонок) - 1;
		Уровень = ПолеТабличногоДокумента.КоличествоУровнейГруппировокКолонок() - 1;
		Пока Уровень > НужныйУровень Цикл
			ПолеТабличногоДокумента.ПоказатьУровеньГруппировокКолонок(Уровень);
			Уровень = Уровень - 1;
		КонецЦикла;
		ПолеТабличногоДокумента.ПоказатьУровеньГруппировокКолонок(Уровень);
	КонецЕсли;

КонецПроцедуры // ЛксОткрытьУровеньТабличногоДокументаСГруппировками()

// Формирует подменю для сворачивания снизу вверх всех уровней
// группировок до заданного в пункте.
//
// Параметры:
//  Источник     - ПостроительОтчета, НастройкиКомпоновкиДанных - откуда берем выводимые группировки.
//
Процедура СформироватьМенюГруппировок(Источник) Экспорт 

	ДействиеОткрытьУровень = Новый Действие("Клс" + ИмяКласса + "Нажатие");
	Для Счетчик = 1 По 2 Цикл
		Если Счетчик = 1 Тогда 
			ИмяРодительныйПадеж = "Строк";
			КоличествоГруппировок = ПолеТабличногоДокумента.КоличествоУровнейГруппировокСтрок();
			Если ТипЗнч(Источник) = Тип("ПостроительОтчета") Тогда
				КоллекцияИзмерений = ПолучитьМассивИзмеренийПостроителяПоУровням(Источник.ИзмеренияСтроки);
			ИначеЕсли  ТипЗнч(Источник) = Тип("НастройкиКомпоновкиДанных") Тогда 
				КоллекцияИзмерений = ПолучитьМассивИзмеренийСтрокНастройкиКомпоновкиПоУровням(Источник.Структура);
			КонецЕсли;
			
			//// Фиксация строк заголовка. Задача расчета его высоты видимо довольно сложная.
			//Если Источник.Структура.Количество() = 1 Тогда
			//	ПолеТабличногоДокумента.ФиксацияСверху = КоллекцияИзмерений.Количество() + 0;
			//КонецЕсли;
		Иначе
			ИмяРодительныйПадеж = "Колонок";
			КоличествоГруппировок = ПолеТабличногоДокумента.КоличествоУровнейГруппировокКолонок();
			Если ТипЗнч(Источник) = Тип("ПостроительОтчета") Тогда
				КоллекцияИзмерений = ПолучитьМассивИзмеренийПостроителяПоУровням(Источник.ИзмеренияКолонки);
			ИначеЕсли ТипЗнч(Источник) = Тип("НастройкиКомпоновкиДанных") Тогда
				КоллекцияИзмерений = ПолучитьМассивИзмеренийКолонокНастройкиКомпоновкиПоУровням(Источник.Структура);
			КонецЕсли;
		КонецЕсли;
		
		ИмяКнопкиМеню = МаркерСвернутьДоУровня + ИмяРодительныйПадеж;
		КнопкаУровни = КоманднаяПанель.Кнопки.Найти(ИмяКнопкиМеню);
		Если КнопкаУровни <> Неопределено Тогда
			КоманднаяПанель.Кнопки.Удалить(КнопкаУровни);
		КонецЕсли;
		
		Если КоличествоГруппировок > 1 Тогда
			КнопкаУровни = КоманднаяПанель.Кнопки.Добавить(ИмяКнопкиМеню, ТипКнопкиКоманднойПанели.Подменю,
			"Свернуть до уровня " + НРег(ИмяРодительныйПадеж));
			МассивКнопок = Новый Массив;
			Для Уровень = 1 По КоличествоГруппировок Цикл
				ИмяКнопки = ИмяКнопкиМеню + Строка(Уровень);
				ПредставлениеУровня = "Уровень";
				Если Уровень <= КоллекцияИзмерений.Количество() Тогда 
					ПредставлениеУровня = КоллекцияИзмерений[Уровень - 1];
				КонецЕсли;
				МассивКнопок.Добавить(Новый Структура("Имя, Действие, ТипКнопки, Текст",
					ИмяКнопки, , ТипКнопкиКоманднойПанели.Действие,
					Строка(Уровень) + " " + ПредставлениеУровня, ДействиеОткрытьУровень));
			КонецЦикла;
			ирОбщий.ДобавитьКнопкиКоманднойПанелиКомпонентыЛкс(ЭтотОбъект, МассивКнопок, КнопкаУровни);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры // СформироватьМенюГруппировок()


// Получает массив представлений измерений по уровням компоновки.
//
// Параметры:
//  СтруктураНастройкиКомпоновки - КоллекцияЭлементовСтруктурыНастроекКомпоновкиДанных.
//
// Возвращаемое значение:
//  МассивИзмерений - индекс элемента массива соотвествует уровню, на котором находятся измерения,
//               перечисленные через запятую.
//
Функция ПолучитьМассивИзмеренийСтрокНастройкиКомпоновкиПоУровням(СтруктураНастройкиКомпоновки)
	
#Если Сервер И Не Сервер Тогда
	СтруктураНастройкиКомпоновки = Новый НастройкиКомпоновкиДанных;
	СтруктураНастройкиКомпоновки = СтруктураНастройкиКомпоновки.Структура;
#КонецЕсли
	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("");
	Для Каждого ЭлементСтруктуры Из СтруктураНастройкиКомпоновки Цикл
		СтрокаПоляГруппировки = "";
		НетИерархии = Истина;
		ТипЭлемента = Тип(ЭлементСтруктуры);
		МассивИзмеренийПотомков = Новый Массив;
		Если Ложь
			Или ТипЭлемента = Тип("ГруппировкаДиаграммыКомпоновкиДанных")
			Или ТипЭлемента = Тип("ГруппировкаКомпоновкиДанных")
			Или ТипЭлемента = Тип("ГруппировкаТаблицыКомпоновкиДанных")
		Тогда
			Для Каждого ПолеГруппировки Из ЭлементСтруктуры.ПоляГруппировки.Элементы Цикл
				Если Не ПолеГруппировки.Использование Тогда
					Продолжить;
				КонецЕсли;
				Если ТипЗнч(ПолеГруппировки) = Тип("АвтоПолеГруппировкиКомпоновкиДанных") Тогда 
					ПредставлениеГруппировки = "Автополе групппировки";
				Иначе
					ДоступноеПоле = ЭлементСтруктуры.ПоляГруппировки.ДоступныеПоляПолейГруппировок.НайтиПоле(ПолеГруппировки.Поле);
					Если ДоступноеПоле = Неопределено Тогда
						Продолжить;
					КонецЕсли;
					ПредставлениеГруппировки = ДоступноеПоле.Заголовок;
					Если ПолеГруппировки.ТипГруппировки <> ТипГруппировкиКомпоновкиДанных.Элементы Тогда
						ПредставлениеГруппировки = ПредставлениеГруппировки + " (иерархия)";
						НетИерархии = Ложь;
					КонецЕсли;
				КонецЕсли;
				СтрокаПоляГруппировки = СтрокаПоляГруппировки + ", " + ПредставлениеГруппировки;
			КонецЦикла;
			Если ЭлементСтруктуры.ПоляГруппировки.Элементы.Количество() = 0 Тогда
				ПредставлениеГруппировки = "<Детальные записи>";
				СтрокаПоляГруппировки = СтрокаПоляГруппировки + ", " + ПредставлениеГруппировки;
			КонецЕсли;
			Если НетИерархии Тогда
				МассивИзмеренийПотомков = ПолучитьМассивИзмеренийСтрокНастройкиКомпоновкиПоУровням(ЭлементСтруктуры.Структура);
			КонецЕсли;
			СмещениеГлубины = 1;
		ИначеЕсли ТипЭлемента = Тип("ТаблицаКомпоновкиДанных") Тогда
			МассивИзмеренийПотомков = ПолучитьМассивИзмеренийСтрокНастройкиКомпоновкиПоУровням(ЭлементСтруктуры.Строки);
			СмещениеГлубины = 0;
		Иначе 
			Продолжить;
		КонецЕсли;
		Для Счетчик = СмещениеГлубины По СмещениеГлубины + МассивИзмеренийПотомков.Количество() - 1  Цикл
			Если МассивИзмерений.ВГраница() < Счетчик Тогда
				МассивИзмерений.Добавить("");
			КонецЕсли;
			МассивИзмерений[Счетчик] = МассивИзмерений[Счетчик] + ", " + МассивИзмеренийПотомков[Счетчик - СмещениеГлубины];
		КонецЦикла;
		Если СтрокаПоляГруппировки <> "" Тогда
			МассивИзмерений[0] = МассивИзмерений[0] + ", [" + Сред(СтрокаПоляГруппировки, 3) + "]";
		КонецЕсли;
	КонецЦикла;
	Для Счетчик = 0 По МассивИзмерений.ВГраница() Цикл
		МассивИзмерений[Счетчик] = Сред(МассивИзмерений[Счетчик], 3);
	КонецЦикла;
	Если МассивИзмерений[0] = "" Тогда
		МассивИзмерений.Очистить();
	КонецЕсли;
	Возврат МассивИзмерений;

КонецФункции

// Получает массив представлений измерений по уровням компоновки.
//
// Параметры:
//  СтруктураНастройкиКомпоновки - КоллекцияЭлементовСтруктурыНастроекКомпоновкиДанных.
//
// Возвращаемое значение:
//  МассивИзмерений - индекс элемента массива соотвествует уровню, на котором находятся измерения,
//               перечисленные через запятую.
//
Функция ПолучитьМассивИзмеренийКолонокНастройкиКомпоновкиПоУровням(СтруктураНастройкиКомпоновки)

	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("");
	Для Каждого ЭлементСтруктуры Из СтруктураНастройкиКомпоновки Цикл
		СтрокаПоляГруппировки = "";
		НетИерархии = Истина;
		ТипЭлемента = Тип(ЭлементСтруктуры);
		МассивИзмеренийПотомков = Новый Массив;
		Если ТипЭлемента = Тип("ГруппировкаТаблицыКомпоновкиДанных") Тогда
			Для Каждого ПолеГруппировки Из ЭлементСтруктуры.ПоляГруппировки.Элементы Цикл
				Если Не ПолеГруппировки.Использование Тогда
					Продолжить;
				КонецЕсли;
				ДоступноеПоле = ЭлементСтруктуры.ПоляГруппировки.ДоступныеПоляПолейГруппировок.НайтиПоле(ПолеГруппировки.Поле);
				ПредставлениеГруппировки = ДоступноеПоле.Заголовок;
				Если ПолеГруппировки.ТипГруппировки <> ТипГруппировкиКомпоновкиДанных.Элементы Тогда
					ПредставлениеГруппировки = ПредставлениеГруппировки + " (иерархия)";
					НетИерархии = Ложь;
				КонецЕсли;
				СтрокаПоляГруппировки = СтрокаПоляГруппировки + ", " + ПредставлениеГруппировки;
			КонецЦикла;
			Если НетИерархии Тогда
				МассивИзмеренийПотомков = ПолучитьМассивИзмеренийКолонокНастройкиКомпоновкиПоУровням(ЭлементСтруктуры.Структура);
			КонецЕсли;
			СмещениеГлубины = 1;
		ИначеЕсли ТипЭлемента = Тип("ТаблицаКомпоновкиДанных") Тогда
			МассивИзмеренийПотомков = ПолучитьМассивИзмеренийКолонокНастройкиКомпоновкиПоУровням(ЭлементСтруктуры.Колонки);
			СмещениеГлубины = 0;
		Иначе 
			Продолжить;
		КонецЕсли;
		Для Счетчик = СмещениеГлубины По СмещениеГлубины + МассивИзмеренийПотомков.Количество() - 1  Цикл
			Если МассивИзмерений.ВГраница() < Счетчик Тогда
				МассивИзмерений.Добавить("");
			КонецЕсли;
			МассивИзмерений[Счетчик] = МассивИзмерений[Счетчик] + ", " + МассивИзмеренийПотомков[Счетчик - СмещениеГлубины];
		КонецЦикла;
		Если СтрокаПоляГруппировки <> "" Тогда
			МассивИзмерений[0] = МассивИзмерений[0] + ", [" + Сред(СтрокаПоляГруппировки, 3) + "]";
		КонецЕсли;
	КонецЦикла;
	Для Счетчик = 0 По МассивИзмерений.ВГраница() Цикл
		МассивИзмерений[Счетчик] = Сред(МассивИзмерений[Счетчик], 3);
	КонецЦикла;
	Если МассивИзмерений[0] = "" Тогда
		МассивИзмерений.Очистить();
	КонецЕсли;
	Возврат МассивИзмерений;

КонецФункции // ПолучитьМассивИзмеренийКолонокНастройкиКомпоновкиПоУровням()

// Получает массив представлений измерений по уровням построителя.
//
// Параметры:
//  Измерения - ИзмеренияПостроителяОтчета.
//
// Возвращаемое значение:
//  МассивИзмерений - индекс элемента массива соотвествует уровню.
//
Функция ПолучитьМассивИзмеренийПостроителяПоУровням(Измерения)

	МассивИзмерений = Новый Массив;
	Для Каждого Измерение Из Измерения Цикл
		МассивИзмерений.Добавить(Измерение.Представление);
		Если Измерение.ТипИзмерения <> ТипИзмеренияПостроителяОтчета.Элементы Тогда 
			МассивИзмерений[МассивИзмерений.ВГраница()] = МассивИзмерений[МассивИзмерений.ВГраница()] + " (иерархия)";
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Возврат МассивИзмерений;

КонецФункции // ПолучитьМассивИзмеренийПостроителяПоУровням()

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

// К нему привязаны имена методов-трансляторов событий
ИмяКласса = "ПолеТабличногоДокументаСГруппировками";
СсылочнаяФормаКласса = Ложь;
МаркерСвернутьДоУровня = "СвернутьДоУровня";
#КонецЕсли
