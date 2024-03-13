///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <УдалениеДублейМетаданных>
//
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "УдалениеДублейМетаданных";
	
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
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образовавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.Настройки.Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() Тогда
		
		Если ТипыФайлов.ЭтоФайлОписанияКонфигурации(АнализируемыйФайл) Тогда
			
			Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
			
			Если УдалитьДублиВМетаданных(АнализируемыйФайл.ПолноеИмя) Тогда
				
				ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
				
			КонецЕсли;
			
			Возврат Истина;
			
		ИначеЕсли ТипыФайлов.ЭтоФайлОписанияКонфигурацииEDT(АнализируемыйФайл) Тогда
			
			Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
			
			Если УдалитьДублиВМетаданныхEDT(АнализируемыйФайл.ПолноеИмя) Тогда
				
				ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
				
			КонецЕсли;
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ЛОЖЬ;
	
КонецФункции // ОбработатьФайл()

Функция УдалитьДублиВМетаданных(Знач ИмяФайла)
	
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	
	Регексп = Новый РегулярноеВыражение("(<ChildObjects>\s+?)([\w\W]+?)(\s+<\/ChildObjects>)");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ПодчиненныеМетаданные = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ПодчиненныеМетаданные.Количество() = 0 Тогда
		
		Возврат Ложь;	
		
	КонецЕсли;
	
	ИсходнаяСтрока = ПодчиненныеМетаданные[0].Группы[2].Значение;
	РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([а-яёa-zA-ZА-ЯЁ0-9_]+)<\/[\w]+>");
	РегекспМетаданные.ИгнорироватьРегистр = ИСТИНА;
	РегекспМетаданные.Многострочный = Истина;
	ОбъектыМетаданныхСтроки = РегекспМетаданные.НайтиСовпадения(ИсходнаяСтрока);
	
	ОбъектыМетаданных = Новый ТаблицаЗначений;
	ОбъектыМетаданных.Колонки.Добавить("ТипМетаданных");
	ОбъектыМетаданных.Колонки.Добавить("ИмяМетаданных");
	ОбъектыМетаданных.Колонки.Добавить("СтрокаФайла");
	ОбъектыМетаданных.Колонки.Добавить("Количество");
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхСтроки Цикл
		
		НоваяЗапись = ОбъектыМетаданных.Добавить();
		НоваяЗапись.ТипМетаданных = ОбъектМетаданных.Группы[1].Значение;
		НоваяЗапись.ИмяМетаданных = ОбъектМетаданных.Группы[2].Значение;
		НоваяЗапись.СтрокаФайла = ОбъектМетаданных.Группы[0].Значение;
		НоваяЗапись.Количество = 1;
		
	КонецЦикла;
	
	ОбъектыМетаданных.Свернуть("ТипМетаданных, ИмяМетаданных, СтрокаФайла", "Количество");
	ОбъектыМетаданных.Сортировать("Количество УБЫВ");

	СтрокаЗамены = ИсходнаяСтрока;
	Пока ОбъектыМетаданных.Количество() Цикл
		
		Если ОбъектыМетаданных[0].Количество = 1 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		ПозНачало = СтрНайти(СтрокаЗамены, ОбъектыМетаданных[0].СтрокаФайла);
		СтрокаЗамены = Лев(СтрокаЗамены, ПозНачало - 1) + Сред(СтрокаЗамены, ПозНачало + СтрДлина(ОбъектыМетаданных[0].СтрокаФайла) + 1);
		
		ОбъектыМетаданных[0].Количество = ОбъектыМетаданных[0].Количество - 1;
		Если ОбъектыМетаданных[0].Количество = 1 Тогда
			
			ОбъектыМетаданных.Удалить(0);
			
		КонецЕсли;

	КонецЦикла;
	
	Если СтрСравнить(ИсходнаяСтрока, СтрокаЗамены) = 0 Тогда
		
		Возврат Ложь;
		
	КонецЕсли;

	СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1" + СтрокаЗамены + "$3");
	ФайловыеОперации.ЗаписатьТекстФайла(ИмяФайла, СодержимоеФайла);
	
	Возврат Истина;
	
КонецФункции

Функция УдалитьДублиВМетаданныхEDT(Знач ИмяФайла)
	Текст = Новый ЧтениеТекста();
	Текст.Открыть(ИмяФайла, КодировкаТекста.UTF8NoBOM);
	СодержимоеФайла = Текст.Прочитать();
	Текст.Закрыть();
	
	Регексп = Новый РегулярноеВыражение("(<\/languages>\s*?)([\w\W]*)(<\/mdclass\:Configuration>)");
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	ПодчиненныеМетаданные = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ПодчиненныеМетаданные.Количество() = 0 Тогда
		
		Возврат Ложь;	
		
	КонецЕсли;
	
	ИсходнаяСтрока = ПодчиненныеМетаданные[0].Группы[2].Значение;
	РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([a-zA-Z]+\.[а-яёa-zA-ZА-ЯЁ0-9_]+)<\/[\w]+>");
	РегекспМетаданные.ИгнорироватьРегистр = Истина;
	РегекспМетаданные.Многострочный = Истина;
	ОбъектыМетаданныхСтроки = РегекспМетаданные.НайтиСовпадения(ИсходнаяСтрока);
	
	ОбъектыМетаданных = Новый ТаблицаЗначений;
	ОбъектыМетаданных.Колонки.Добавить("ТипМетаданных");
	ОбъектыМетаданных.Колонки.Добавить("ИмяМетаданных");
	ОбъектыМетаданных.Колонки.Добавить("СтрокаФайла");
	ОбъектыМетаданных.Колонки.Добавить("Количество");
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхСтроки Цикл
		
		НоваяЗапись = ОбъектыМетаданных.Добавить();
		НоваяЗапись.ТипМетаданных = ОбъектМетаданных.Группы[1].Значение;
		НоваяЗапись.ИмяМетаданных = ОбъектМетаданных.Группы[2].Значение;
		НоваяЗапись.СтрокаФайла = ОбъектМетаданных.Группы[0].Значение;
		НоваяЗапись.Количество = 1;
		
	КонецЦикла;
	
	ОбъектыМетаданных.Свернуть("ТипМетаданных, ИмяМетаданных, СтрокаФайла", "Количество");
	ОбъектыМетаданных.Сортировать("Количество УБЫВ");
	
	СтрокаЗамены = ИсходнаяСтрока;
	Пока ОбъектыМетаданных.Количество() Цикл
		
		Если ОбъектыМетаданных[0].Количество = 1 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		ПозНачало = СтрНайти(СтрокаЗамены, ОбъектыМетаданных[0].СтрокаФайла);
		СтрокаЗамены = Лев(СтрокаЗамены, ПозНачало - 1) + Сред(СтрокаЗамены, ПозНачало + СтрДлина(ОбъектыМетаданных[0].СтрокаФайла) + 1);
		
		ОбъектыМетаданных[0].Количество = ОбъектыМетаданных[0].Количество - 1;
		Если ОбъектыМетаданных[0].Количество = 1 Тогда
			
			ОбъектыМетаданных.Удалить(0);
			
		КонецЕсли;
		
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
