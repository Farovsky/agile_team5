#Область ОбработчикиКомандФормы 

&НаКлиенте
Асинх Процедура ОтправитьСообщение(Команда)
	
	СтрокаСообщения = "";
	СтрокаСообщения = Ждать ВвестиСтрокуАсинх(СтрокаСообщения);
	Если ЗначениеЗаполнено(СтрокаСообщения) Тогда
		ОтправитьСообщениеНаСервере(СтрокаСообщения, Объект.Команда, Объект.chat_id);		
	КонецЕсли;		
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Отправить сообщение на сервере.
// 
// Параметры:
//  СтрокаСообщения - Обещание - Строка сообщения
//  Команда - СправочникСсылка.Команды - Команда
//  chat_id - Строка - Chat id
&НаСервереБезКонтекста
Процедура ОтправитьСообщениеНаСервере(СтрокаСообщения, Команда, chat_id)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	Боты.Токен КАК Токен
	|ИЗ
	|	Справочник.Команды КАК Команды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Боты КАК Боты
	|		ПО Команды.Бот = Боты.Ссылка
	|ГДЕ
	|	Команды.Ссылка = &Команда");
	
	Запрос.УстановитьПараметр("Команда", Команда);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не найден токен бота команды пользователя";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;	
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
		
	ИнтеграцияСМессенджерами.TelegramSendMessage(Выборка.Токен, СтрокаСообщения, chat_id);
КонецПроцедуры

#КонецОбласти

