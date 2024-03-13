///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <ЗапретИспользованияПерейти>
//
///////////////////////////////////////////////////////////////////////////////

Перем Лог;

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ЗапретИспользованияПерейти";

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
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		ПроверитьНаОтсутствиеПерейти(АнализируемыйФайл.ПолноеИмя);
		Возврат Истина;
		
	КонецЕсли;
	
	Возврат Ложь;

КонецФункции // ОбработатьФайл()

Процедура ПроверитьНаОтсутствиеПерейти(ПутьКФайлуМодуля) 
	
	ТекстМодуля = ФайловыеОперации.ПрочитатьТекстФайла(ПутьКФайлуМодуля);
	
	ТекстОшибки = "";
	ШаблонПоиска = Новый РегулярноеВыражение("[\s;]+?[^|]Перейти\s+?~[a-zA-ZА-ЯЁа-яё0-9_]+");
	ШаблонПоиска.Многострочный = Истина;
	ШаблонПоиска.ИгнорироватьРегистр = Истина;
	
	Если НЕ ПустаяСтрока(ТекстМодуля) Тогда
		
		Совпадения = ШаблонПоиска.НайтиСовпадения(ТекстМодуля);
		Если Совпадения.Количество() Тогда

			ТекстОшибки = СтрШаблон(
				"В файле '%1' обнаружено использование Перейти (%2)", 
				ПутьКФайлуМодуля, 
				Совпадения.Количество());
			Лог.Ошибка(ТекстОшибки);
			ВызватьИсключение ТекстОшибки;

		КонецЕсли;

	КонецЕсли;

КонецПроцедуры
