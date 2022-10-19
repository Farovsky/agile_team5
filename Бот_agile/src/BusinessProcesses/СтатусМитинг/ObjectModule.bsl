#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
Процедура ДействиеЧтоДелалВчераПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)

	СтруктураНастроекМессенджера = ИнтеграцияСМессенджерами.СтруктураНастроекИнтеграции();
	ИнтеграцияСМессенджерами.TelegramSendMessage(СтруктураНастроекМессенджера.Токен , "Что делали вчера?", Пользователь.chat_id);
	
КонецПроцедуры

Процедура ДействиеЧтоБудешьДелатьСегодняПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)
	
	СтруктураНастроекМессенджера = ИнтеграцияСМессенджерами.СтруктураНастроекИнтеграции();
	ИнтеграцияСМессенджерами.TelegramSendMessage(СтруктураНастроекМессенджера.Токен , "Что будете делать сегодня?", Пользователь.chat_id);
	
КонецПроцедуры

Процедура ДействиеКакиеПроблемыПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)

	СтруктураНастроекМессенджера = ИнтеграцияСМессенджерами.СтруктураНастроекИнтеграции();
	ИнтеграцияСМессенджерами.TelegramSendMessage(СтруктураНастроекМессенджера.Токен , "Какие были проблемы?", Пользователь.chat_id);

КонецПроцедуры

Процедура ЗавершениеПриЗавершении(ТочкаМаршрутаБизнесПроцесса, Отказ)

	СтруктураНастроекМессенджера = ИнтеграцияСМессенджерами.СтруктураНастроекИнтеграции();
	ИнтеграцияСМессенджерами.TelegramSendMessage(СтруктураНастроекМессенджера.Токен , "Спасибо, так и запишем.", Пользователь.chat_id);

	ОтправитьРезультатРуководителю();

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОтправитьРезультатРуководителю()

    //надо где-то хранить руководителя
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.chat_id КАК chat_id,
	|	СтатусМитинг.Пользователь КАК Пользователь,
	|	ЗадачиПользователей.Наименование КАК Вопрос,
	|	ЗадачиПользователей.Ответ КАК Ответ,
	|	ЗадачиПользователей.Дата КАК Дата
	|ИЗ
	|	БизнесПроцесс.СтатусМитинг КАК СтатусМитинг
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Задача.ЗадачиПользователей КАК ЗадачиПользователей
	|		ПО СтатусМитинг.Ссылка = ЗадачиПользователей.БизнесПроцесс
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО (Пользователи.Роль в (ЗНАЧЕНИЕ(Перечисление.РолиПользователей.Руководитель),
	|			ЗНАЧЕНИЕ(Перечисление.РолиПользователей.Разработчик)))
	|		И (Пользователи.Активен)
	|		И (НЕ Пользователи.Ссылка = СтатусМитинг.Пользователь)
	|ГДЕ
	|	СтатусМитинг.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	Дата
	|ИТОГИ
	|	МАКСИМУМ(Пользователь)
	|ПО
	|	chat_id";

	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	РезультатЗапроса = Запрос.Выполнить();

	Выборкаchat_id = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);

	СтруктураНастроекМессенджера = ИнтеграцияСМессенджерами.СтруктураНастроекИнтеграции();

	Пока Выборкаchat_id.Следующий() Цикл

		СтрокаСообщения = СтрШаблон("Отчет для Стендап митинга по %1", Выборкаchat_id.Пользователь);
		
		ВыборкаДетальныеЗаписи = Выборкаchat_id.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
			СтрокаСообщения = СтрокаСообщения+Символы.ПС+
				СтрШаблон("%1 %2", ВыборкаДетальныеЗаписи.Вопрос, ВыборкаДетальныеЗаписи.Ответ);
			

		КонецЦикла;
		
		ИнтеграцияСМессенджерами.TelegramSendMessage(СтруктураНастроекМессенджера.Токен , СтрокаСообщения, Выборкаchat_id.chat_id);
		
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#КонецЕсли