///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <СортировкаДереваМетаданных>
//
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "СортировкаДереваМетаданных";
	
КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образоавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.УправлениеНастройками.Настройка("Precommt4onecСценарии\НастройкиСценариев").Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() Тогда
		
		Если ТипыФайлов.ЭтоФайлОписанияКонфигурации(АнализируемыйФайл) Тогда
		
			Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
			
			Если ОтсортироватьДеревоМетаданных(АнализируемыйФайл.ПолноеИмя) Тогда
				
				ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
				
			КонецЕсли;
			
			Возврат Истина;
			
		ИначеЕсли ТипыФайлов.ЭтоФайлОписанияКонфигурацииEDT(АнализируемыйФайл) Тогда
			
			Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
			
			Если ОтсортироватьДеревоМетаданныхEDT(АнализируемыйФайл.ПолноеИмя) Тогда
				
				ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
				
			КонецЕсли;
			
			Возврат Истина;

		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ЛОЖЬ;
	
КонецФункции // ОбработатьФайл()

Функция ОтсортироватьДеревоМетаданных(Знач ИмяФайла)
	
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	
	Регексп = Новый РегулярноеВыражение("(<ChildObjects>\s+?)([\w\W]+?)(\s+<\/ChildObjects>)");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ПодчиненныеМетаданные = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ПодчиненныеМетаданные.Количество() = 0 Тогда
		
		Возврат Ложь;	
		
	КонецЕсли;
	
	ИсходнаяСтрока = ПодчиненныеМетаданные[0].Группы[2].Значение;
	РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([а-яa-zA-ZА-Я0-9_]+)<\/[\w]+>");
	РегекспМетаданные.ИгнорироватьРегистр = ИСТИНА;
	РегекспМетаданные.Многострочный = Истина;
	ОбъектыМетаданныхСтроки = РегекспМетаданные.НайтиСовпадения(ИсходнаяСтрока);
	
	ОбъектыМетаданных = Новый СписокЗначений;
	ПоследнийТип = "";
	ОбъектыТипа = Новый СписокЗначений;
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхСтроки Цикл
		
		Если ПоследнийТип <> ОбъектМетаданных.Группы[1].Значение Тогда
			
			Если ПоследнийТип <> "" Тогда

				ОбъектыМетаданных.Добавить(ОбъектыТипа);
				ОбъектыТипа = Новый СписокЗначений;

			КонецЕсли;

			ПоследнийТип = ОбъектМетаданных.Группы[1].Значение;
			
		КонецЕсли;
		
		ОбъектыТипа.Добавить(ОбъектМетаданных.Группы[0].Значение, ОбъектМетаданных.Группы[2].Значение);
		
	КонецЦикла;

	ОбъектыМетаданных.Добавить(ОбъектыТипа);
	
	СтрокаЗамены = "";
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданных Цикл
		
		Если НЕ СтрЗаканчиваетсяНа(ОбъектМетаданных.Значение[0].Значение, "Subsystem>") Тогда
			
			ОбъектМетаданных.Значение.СортироватьПоПредставлению(НаправлениеСортировки.Возр);

		КонецЕсли;
		
		СтрокаЗамены = СтрокаЗамены + ?(ПустаяСтрока(СтрокаЗамены), "", Символы.ПС) 
						+ СтрСоединить(ОбъектМетаданных.Значение.ВыгрузитьЗначения(), Символы.ПС);
		
	КонецЦикла;
	
	Если СтрСравнить(ИсходнаяСтрока, СтрокаЗамены) = 0 Тогда
		
		Возврат Ложь;
		
	КонецЕсли;

	ФайловыеОперации.ЗаписатьТекстФайла(ИмяФайла, СодержимоеФайла);
	
	Возврат Истина;
	
КонецФункции

Функция ОтсортироватьДеревоМетаданныхEDT(Знач ИмяФайла)
	
	Текст = Новый ЧтениеТекста();
	Текст.Открыть(ИмяФайла, КодировкаТекста.UTF8NoBOM);
	СодержимоеФайла = Текст.Прочитать();
	Текст.Закрыть();
	
	Регексп = Новый РегулярноеВыражение("(<\/languages>\s*?)([\w\W]*)(<\/mdclass\:Configuration>)");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ПодчиненныеМетаданные = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ПодчиненныеМетаданные.Количество() = 0 Тогда
		
		Возврат Ложь;	
		
	КонецЕсли;
	
	ИсходнаяСтрока = ПодчиненныеМетаданные[0].Группы[2].Значение;
	РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([a-zA-Z]+\.[а-яa-zA-ZА-Я0-9_]+)<\/[\w]+>");
	РегекспМетаданные.ИгнорироватьРегистр = ИСТИНА;
	РегекспМетаданные.Многострочный = Истина;
	ОбъектыМетаданныхСтроки = РегекспМетаданные.НайтиСовпадения(ИсходнаяСтрока);
	
	ОбъектыМетаданных = Новый СписокЗначений;
	ПоследнийТип = "";
	ОбъектыТипа = Новый СписокЗначений;
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхСтроки Цикл
		
		Если ПоследнийТип <> ОбъектМетаданных.Группы[1].Значение Тогда
			
			Если ПоследнийТип <> "" Тогда

				ОбъектыМетаданных.Добавить(ОбъектыТипа);
				ОбъектыТипа = Новый СписокЗначений;

			КонецЕсли;

			ПоследнийТип = ОбъектМетаданных.Группы[1].Значение;
			
		КонецЕсли;
		
		ОбъектыТипа.Добавить(ОбъектМетаданных.Группы[0].Значение, ОбъектМетаданных.Группы[2].Значение);
		
	КонецЦикла;

	ОбъектыМетаданных.Добавить(ОбъектыТипа);
	
	СтрокаЗамены = "";
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданных Цикл
		
		Если НЕ СтрЗаканчиваетсяНа(ОбъектМетаданных.Значение[0].Значение, "subsystems>") Тогда
			
			ОбъектМетаданных.Значение.СортироватьПоПредставлению(НаправлениеСортировки.Возр);

		КонецЕсли;
		
		СтрокаЗамены = СтрокаЗамены + ?(ПустаяСтрока(СтрокаЗамены), "", Символы.ПС) 
						+ СтрСоединить(ОбъектМетаданных.Значение.ВыгрузитьЗначения(), Символы.ПС);
		
	КонецЦикла;
	
	Если СтрСравнить(ИсходнаяСтрока, СтрокаЗамены) = 0 Тогда
		
		Возврат Ложь;
		
	КонецЕсли;

	СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1" + СокрЛП(СтрокаЗамены) + Символы.ПС + "$3");
	ЗаписьТекста = Новый ЗаписьТекста;
	ЗаписьТекста.Открыть(ИмяФайла, КодировкаТекста.UTF8NoBOM);
	ЗаписьТекста.Записать(СодержимоеФайла);
	ЗаписьТекста.Закрыть();
	
	Возврат Истина;
	
КонецФункции
