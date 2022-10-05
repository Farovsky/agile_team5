#Область ПрограммныйИнтерфейс

Процедура TelegramGetUpdates() Экспорт

	СтруктураНастроекИнтеграции = СтруктураНастроекИнтеграции();
	
	Токен 					 = СтруктураНастроекИнтеграции.Токен;
	НомерПервогоСообщения    =  ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(СтруктураНастроекИнтеграции,"update_id",0)+1;
	АдресЗапроса = СтрШаблон("/bot%1/getUpdates?timeout=0&offset=%2",Токен, Формат(НомерПервогоСообщения, "ЧГ=0"));
	
	Ответ = КоннекторHTTP.GetJson("api.telegram.org"+АдресЗапроса);
	
	Если Ответ.ok И Ответ.result.Количество()>0 Тогда
		
		// Сначала найду последнее сообщение и запишу его в регистр, только потом приступлю к анализу, 
		//чтобы не конфликтовать со след рег заданием и спокойно обрабатывать свою порцию
		ПоследнееСообщениеРезультата = Ответ.result[Ответ.result.Количество()-1];
		update_id = ПоследнееСообщениеРезультата.update_id;
		ЗаписатьНомерПоследнегоСообщения(СтруктураНастроекИнтеграции.ИмяБота,update_id);
		
		Для Каждого Сообщение Из Ответ.result Цикл
			
			ОбработатьСообщениеБоту(Сообщение, СтруктураНастроекИнтеграции);	
			
		КонецЦикла;
		
	КонецЕсли;

КонецПроцедуры

Процедура ОбработатьСообщениеБоту(Сообщение, СтруктураНастроекИнтеграции = Неопределено) Экспорт

	Если СтруктураНастроекИнтеграции = Неопределено Тогда
		СтруктураНастроекИнтеграции = СтруктураНастроекИнтеграции();
	КонецЕсли;	
	
	ЭтоНажатиеКнопки = Сообщение.Свойство("callback_query");
	
	Если ЭтоНажатиеКнопки Тогда
		Message = Сообщение.callback_query.Message;
	ИначеЕсли  Сообщение.Свойство("Message") Тогда
		Message = Сообщение.Message;
	КонецЕсли;
	
	Chat_id = Формат(Message.chat.id, "ЧГ=0");
	Пользователь = Справочники.Пользователи.НайтиПоРеквизиту("chat_id", Chat_id);
	
	Если Не ЗначениеЗаполнено(Пользователь) Тогда
		Пользователь  = СоздатьПользователя(Chat_id,Message.from);
	КонецЕсли;
	
	Если ЭтоНажатиеКнопки Тогда
		MessageId = Message.message_id;
		ОбработатьНажатиеКнопки(СтруктураНастроекИнтеграции,Сообщение,chat_id,MessageId, Пользователь);
		Возврат;
	КонецЕсли;
	
	ТекущаяЗадача = ТекущаяЗадачаПользователя(Пользователь);
	
	Если ТекущаяЗадача = Неопределено Тогда
		ОтправитьСписокТемДляВзаимодействий(СтруктураНастроекИнтеграции, Chat_id);
	Иначе
		ВыполнитьТекущуюЗадачу(ТекущаяЗадача, Message.text);
	КонецЕсли;

КонецПроцедуры


Процедура TelegramSendMessage(СтруктураНастроекИнтеграции = Неопределено,ТекстСообщения, Chat_id, ДопПараметры = "") Экспорт
	
	Если СтруктураНастроекИнтеграции = Неопределено Тогда
		СтруктураНастроекИнтеграции = СтруктураНастроекИнтеграции();
	КонецЕсли;
	
	Токен = СтруктураНастроекИнтеграции.Токен;
	СоединениеHTTP = Новый HTTPСоединение("api.telegram.org",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	АдресЗапроса = СтрШаблон("bot%1/sendMessage?chat_id=%2&text=%3%4",Токен,Chat_id, ТекстСообщения, ДопПараметры);
				
	ЗапросHTTP = Новый HTTPЗапрос(АдресЗапроса);

	ОтветHTTP = СоединениеHTTP.Получить(ЗапросHTTP);
	
КонецПроцедуры

Процедура ОтправитьНапоминаниеОСтатусМитинге() Экспорт

	Запрос = Новый Запрос;
	//берем разработчиков без активного БП
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Пользователи.Ссылка КАК Ссылка,
		|	Пользователи.chat_id КАК chat_id
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|		ЛЕВОЕ СОЕДИНЕНИЕ БизнесПроцесс.СтатусМитинг КАК СтатусМитинг
		|		ПО Пользователи.Ссылка = СтатусМитинг.Пользователь
		|			И (НАЧАЛОПЕРИОДА(СтатусМитинг.Дата, ДЕНЬ) = &Дата)
		|			И (НЕ СтатусМитинг.ПометкаУдаления)
		|ГДЕ
		|	Пользователи.Роль = ЗНАЧЕНИЕ(Перечисление.РолиПользователей.Разработчик)
		|	И Пользователи.Активен
		|	И СтатусМитинг.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("Дата", НачалоДня(ТекущаяДатаСеанса()));
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ИнтеграцияСМессенджерами.TelegramSendMessage(, "Пришло время Стендап ап митинга.", ВыборкаДетальныеЗаписи.chat_id); 
		БизнесПроцессОбъект = НовыйБизнесПроцессСтатусМитинг(ВыборкаДетальныеЗаписи.Ссылка);
		БизнесПроцессОбъект.Старт();
		 
	КонецЦикла;
	

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИмяБотаПоУмолчанию()

	ИмяБота = "Team5_agile_bot";
	Возврат ИмяБота;

КонецФункции

Функция СтруктураНастроекИнтеграции(ИмяБота = Неопределено)
	
	Если ИмяБота = Неопределено Тогда
		ИмяБота = ИмяБотаПоУмолчанию();
	КонецЕсли;	
	
	Запрос = новый Запрос(
	"ВЫБРАТЬ
	|	НастройкиИнтеграцииTelegram.Настройка,
	|	НастройкиИнтеграцииTelegram.Значение
	|ИЗ
	|	РегистрСведений.НастройкиИнтеграцииTelegram КАК НастройкиИнтеграцииTelegram
	|ГДЕ
	|	НастройкиИнтеграцииTelegram.Бот = &Бот");
	
	Запрос.УстановитьПараметр("Бот", ИмяБота);
	
	СтруктураНастроекИнтеграции = Новый Структура;
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СтруктураНастроекИнтеграции.Вставить(Выборка.Настройка, Выборка.Значение);
	КонецЦикла;
	
	СтруктураНастроекИнтеграции.Вставить("ИмяБота", ИмяБота);
	
	Возврат СтруктураНастроекИнтеграции;
	
КонецФункции

Процедура ЗаписатьНомерПоследнегоСообщения(ИмяБота,update_id)

	РегистрМенеджер = РегистрыСведений.НастройкиИнтеграцииTelegram.СоздатьМенеджерЗаписи();
	РегистрМенеджер.Бот 	  = ИмяБота;
	РегистрМенеджер.Настройка = "update_id";
	РегистрМенеджер.Значение  = update_id;
	РегистрМенеджер.Записать();
	
КонецПроцедуры

Функция СоздатьПользователя(Chat_id,MessageFrom)

	СпрОбъект = Справочники.Пользователи.СоздатьЭлемент();
	СпрОбъект.chat_id = Chat_id;
	СпрОбъект.Наименование = СтрШаблон("%1 %2",MessageFrom.first_name, MessageFrom.last_name);
	СпрОбъект.Роль = Перечисления.РолиПользователей.Разработчик;
	СпрОбъект.Записать();
	
	возврат СпрОбъект.Ссылка;
	
КонецФункции

//Обработка нажатия inline кнопки
//Пример:
//{
//    "ok": true,
//    "result": [
//        {
//            "update_id": 452927286,
//            "callback_query": {
//                "id": "1032902227865237930",
//                "from": {
//                    "id": 240491290,
//                    "is_bot": false,
//                    "first_name": "Leson",
//                    "last_name": "Farovsky",
//                    "username": "Farovsky",
//                    "language_code": "ru"
//                },
//                "message": {
//                    "message_id": 100,
//                    "from": {
//                        "id": 1796512089,
//                        "is_bot": true,
//                        "first_name": "LeoVentoni_retail",
//                        "username": "LeoVentoni_retail_bot"
//                    },
//                    "chat": {
//                        "id": 240491290,
//                        "first_name": "Leson",
//                        "last_name": "Farovsky",
//                        "username": "Farovsky",
//                        "type": "private"
//                    },
//                    "date": 1635430737,
//                    "text": "Напоминаем Вам, что автомобиль C 608 OA 50 записан на ремонт 29.10.2021 в ООО \"Глобал Трак Сервис Чулково\". Просим Вас подтвердить запись",
//                    "reply_markup": {
//                        "inline_keyboard": [
//                            [
//                                {
//                                    "text": "Подтвердить",
//                                    "callback_data": "1:ЗаявкаНаРемонт:d55c0e17-c2b3-11eb-80fb-0cc47ab61a06"
//                                }
//                            ],
//                            [
//                                {
//                                    "text": "Отклонить",
//                                    "callback_data": "2:ЗаявкаНаРемонт:d55c0e17-c2b3-11eb-80fb-0cc47ab61a06"
//                                }
//                            ]
//                        ]
//                    }
//                },
//                "chat_instance": "6744135463728886599",
//                "data": "2:ЗаявкаНаРемонт:d55c0e17-c2b3-11eb-80fb-0cc47ab61a06"
//            }
//        }
//    ]
//}
Процедура ОбработатьНажатиеКнопки(СтруктураНастроекИнтеграции, Сообщение, chat_id, message_id, Пользователь)

	ВыбранноеЗначение = Сообщение.callback_query.data;
	Если ВыбранноеЗначение = "СтатусМитинг" Тогда
		БизнесПроцессОбъект = НовыйБизнесПроцессСтатусМитинг(Пользователь);
	ИначеЕсли ВыбранноеЗначение = "Ретроспектива" Тогда
		Возврат;
	Иначе
		Возврат;		
	КонецЕсли;	
	
	//удалим кнопки после нажатия
	СоединениеHTTP = Новый HTTPСоединение("api.telegram.org",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	АдресЗапроса = СтрШаблон("bot%1/editMessageReplyMarkup?chat_id=%2&message_id=%3",СтруктураНастроекИнтеграции.Токен, chat_id,message_id);
	ЗапросHTTP   = Новый HTTPЗапрос(АдресЗапроса);
	ОтветHTTP    = СоединениеHTTP.Получить(ЗапросHTTP);
	
	БизнесПроцессОбъект.Старт();
	
КонецПроцедуры

Функция НовыйБизнесПроцессСтатусМитинг(Пользователь)

	БизнеспроцессОбъект = БизнесПроцессы.СтатусМитинг.СоздатьБизнесПроцесс();
	БизнеспроцессОбъект.Пользователь = Пользователь; 
	БизнеспроцессОбъект.Дата = ТекущаяДатаСеанса();
	БизнеспроцессОбъект.Записать();
	
	Возврат БизнеспроцессОбъект;

КонецФункции // НовыйБизнесПроцессСтатусМитинг()

Процедура ВыполнитьТекущуюЗадачу(ТекущаяЗадача, Ответ)

	ОбъектТекущаяЗадача = ТекущаяЗадача.ПолучитьОбъект();
	ОбъектТекущаяЗадача.Ответ = Ответ;
	//ОбъектТекущаяЗадача.Записать();
	ОбъектТекущаяЗадача.ВыполнитьЗадачу();

КонецПроцедуры

Функция ТекущаяЗадачаПользователя(Пользователь)
	
	ЗадачаСсылка = Неопределено;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ЗадачиПользователей.Ссылка КАК Ссылка
	|ИЗ
	|	Задача.ЗадачиПользователей КАК ЗадачиПользователей
	|ГДЕ
	|	ЗадачиПользователей.БизнесПроцесс.Пользователь = &Пользователь
	|	И НЕ ЗадачиПользователей.Выполнена");
	
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ЗадачаСсылка = Выборка.Ссылка;
	КонецЦикла;
	
	Возврат ЗадачаСсылка;
	
КонецФункции // ТекущаяЗадачаПользователя()

Процедура ОтправитьСписокТемДляВзаимодействий(СтруктураНастроекИнтеграции, Chat_id)

	СтруктураJSON = Новый Структура;
	СтруктураJSON.Вставить("parse_mode", "Markdown");
	
	МассивКнопок = Новый Массив;
	
	МетаданныеВидовВзаимодействий = Метаданные.Перечисления.ВидыВзаимодействий.ЗначенияПеречисления;
	
	СтруктураКлавиатуры = Новый Структура;
	МассивКнопок = Новый Массив;
	
	Для Каждого ЭлементМетаданных Из МетаданныеВидовВзаимодействий Цикл
		
		МассивКнопки    = Новый Массив;
		СтруктураКнопкиПодтвердить = Новый Структура;
		СтруктураКнопкиПодтвердить.Вставить("text"		   , ЭлементМетаданных.Синоним);
		СтруктураКнопкиПодтвердить.Вставить("callback_data", ЭлементМетаданных.Имя);
		МассивКнопки.добавить(СтруктураКнопкиПодтвердить);
		
		МассивКнопок.Добавить(МассивКнопки);
		
	КонецЦикла;	
	
	СтруктураКлавиатуры.Вставить("inline_keyboard", МассивКнопок);
	
	СтрJSON = КоннекторHTTP.ОбъектВJson(СтруктураКлавиатуры);
	
	ДопПараметры = "&parse_mode=HTML&reply_markup=" + СтрJSON;
	
	TelegramSendMessage(СтруктураНастроекИнтеграции, "Выберите тему для опроса.", Chat_id, ДопПараметры);
	
КонецПроцедуры

#КонецОбласти
