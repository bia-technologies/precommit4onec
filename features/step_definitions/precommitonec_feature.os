// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

#Использовать gitrunner
#Использовать tempfiles
#Использовать asserts
#Использовать "../../src"

Перем БДД;

Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;
	ВсеШаги.Добавить("ЯСоздаюВременныйКаталогИЗапоминаюЕгоКак");
	ВсеШаги.Добавить("ЯСоздаюНовыйРепозиторийВКаталогеИЗапоминаюЕгоКак");	
	ВсеШаги.Добавить("ЯПереключаюсьВоВременныйКаталог");
	ВсеШаги.Добавить("ВКаталогеРепозиторияЕстьФайл");
	ВсеШаги.Добавить("ЯКопируюФайлВКаталогРепозитория");
	ВсеШаги.Добавить("ЯФиксируюИзмененияВРепозиторииСКомментарием");
	ВсеШаги.Добавить("УФайлаЕстьМетка");
	ВсеШаги.Добавить("СодержимоеФайлаИФайлаРазное");
	ВсеШаги.Добавить("ЯСоздаюНовыйРепозиторийБезИнициализацииВКаталогеИЗапоминаюЕгоКак");
	ВсеШаги.Добавить("ЯСоздаюФайлВКодировкеСТекстом");
	
	Возврат ВсеШаги;
КонецФункции

// я создаю временный каталог и запоминаю его как "Алиас"
Процедура ЯСоздаюВременныйКаталогИЗапоминаюЕгоКак(Алиас) Экспорт
	
	НовыйВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
	СоздатьКаталог(НовыйВременныйКаталог);

	БДД.СохранитьВКонтекст(Алиас, НовыйВременныйКаталог);

КонецПроцедуры

// я переключаюсь во временный каталог "АлиасКаталога"
Процедура ЯПереключаюсьВоВременныйКаталог(АлиасКаталога)Экспорт
	
	КаталогСкрипта = БДД.ПолучитьИзКонтекста("КаталогПроекта");
	Если НЕ ЗначениеЗаполнено(КаталогСкрипта) Тогда

		БДД.СохранитьВКонтекст("КаталогПроекта", ТекущийКаталог());

	КонецЕсли;

	КаталогРепозиториев = БДД.ПолучитьИзКонтекста(АлиасКаталога);
	УстановитьТекущийКаталог(КаталогРепозиториев);

КонецПроцедуры

// я создаю новый репозиторий "ИмяРепозитория" в каталоге "АлиасКаталога" и запоминаю его как "Алиас"
Процедура ЯСоздаюНовыйРепозиторийВКаталогеИЗапоминаюЕгоКак(ИмяРепозитория, АлиасКаталога, Алиас) Экспорт
	
	РепозиторийGit = Новый ГитРепозиторий();
	КаталогРепозитория = ИнициализироватьРепозиторий(РепозиторийGit, ИмяРепозитория, АлиасКаталога);

	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст("# Репозиторий " + Алиас);
	
	ИмяФайлаreadme = ОбъединитьПути(КаталогРепозитория, "readme.md");
	ТекстовыйДокумент.Записать(ИмяФайлаreadme);
	
	РепозиторийGit.ДобавитьФайлВИндекс(ИмяФайлаreadme);
	РепозиторийGit.Закоммитить("init", Истина);

	БДД.СохранитьВКонтекст(Алиас, КаталогРепозитория);

КонецПроцедуры

// я создаю новый репозиторий без инициализации "ИмяРепозитория" в каталоге "АлиасКаталога" и запоминаю его как "Алиас"
Процедура ЯСоздаюНовыйРепозиторийБезИнициализацииВКаталогеИЗапоминаюЕгоКак(ИмяРепозитория, АлиасКаталога, Алиас) Экспорт
	
	РепозиторийGit = Новый ГитРепозиторий();

	КаталогРепозитория = ИнициализироватьРепозиторий(РепозиторийGit, ИмяРепозитория, АлиасКаталога);
	
	БДД.СохранитьВКонтекст(Алиас, КаталогРепозитория);

КонецПроцедуры

// В каталоге "ИмяКаталога" репозитория "ИмяРепозитория" есть файл "ИмяФайла"
Процедура ВКаталогеРепозиторияЕстьФайл(ИмяКаталога, ИмяРепозитория, ИмяФайла)Экспорт
	
	КаталогРепозитория = БДД.ПолучитьИзКонтекста(ИмяРепозитория);
	ПолноеИмяФайла = ОбъединитьПути(КаталогРепозитория, ИмяКаталога, ИмяФайла);
	Файл = Новый Файл(ПолноеИмяФайла);
	Ожидаем.Что(Файл.Существует(), СтрШаблон("Файл '%1' не существует.", ПолноеИмяФайла)).ЭтоИстина();

КонецПроцедуры

// Я копирую файл "ИмяФайла" в каталог репозитория "АлиасРепозитория"
Процедура ЯКопируюФайлВКаталогРепозитория(ИмяФайла, АлиасРепозитория) Экспорт

	КаталогРепозитория = БДД.ПолучитьИзКонтекста(АлиасРепозитория);
	КаталогСкрипта = БДД.ПолучитьИзКонтекста("КаталогПроекта");
	ПутьКФайлу = ОбъединитьПути(КаталогСкрипта, ИмяФайла);
	Файл = Новый Файл(ПутьКФайлу);
	КопироватьФайл(ПутьКФайлу, ОбъединитьПути(КаталогРепозитория, Файл.Имя));

КонецПроцедуры

// я фиксирую изменения в репозитории "Репозиторий1" с комментарием "demo коммит"
Процедура ЯФиксируюИзмененияВРепозиторииСКомментарием(ИмяРепозитория, ТекстКомментария) Экспорт
	
	КаталогРепозитория = БДД.ПолучитьИзКонтекста(ИмяРепозитория);
	
	РепозиторийGit = Новый ГитРепозиторий();
	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	ПараметрыКоманды = Новый Массив;
	ПараметрыКоманды.Добавить("add --all");
	РепозиторийGit.ВыполнитьКоманду(ПараметрыКоманды);

	РепозиторийGit.Закоммитить(ТекстКомментария, ИСТИНА);

КонецПроцедуры

Функция КлючКоманды(Знач ИмяКоманды)
	Возврат "Команда-" + ИмяКоманды;
КонецФункции

// у файла <Файл> есть метка <Bom>
Процедура УФайлаЕстьМетка(Файл, Метка) Экспорт
	
	КаталогРепозитория	= БДД.ПолучитьИзКонтекста("РабочийКаталог");
	КонечныйФайл		= ОбъединитьПути(КаталогРепозитория, Файл);
	
	Кодировка	= ФайловыеОперации.ОпределитьКодировку(КонечныйФайл);
	ЕстьМетка	= Кодировка = КодировкаТекста.UTF8; 
	
	Ожидаем.Что(ЕстьМетка).Равно(Булево(Метка));

КонецПроцедуры //ОпределитьКодировку

// Содержимое файла "ИсходныйФайл" и файла "КонечныйФайл" разное 
Процедура СодержимоеФайлаИФайлаРазное(ИсходныйФайл, КонечныйФайл) Экспорт
	
	ИсходныйФайл = ОбъединитьПути(БДД.ПолучитьИзКонтекста("КаталогПроекта"), ИсходныйФайл);
	КонечныйФайл = ОбъединитьПути(БДД.ПолучитьИзКонтекста("РабочийКаталог"), КонечныйФайл);
	
	СодержимоеКонечногоФайла = ФайловыеОперации.ПрочитатьТекстФайла(КонечныйФайл);
	СодержимоеИсходногоФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИсходныйФайл);
	
	Ожидаем.Что(СодержимоеИсходногоФайла).Не_().Равно(СодержимоеКонечногоФайла);

КонецПроцедуры


//Я создаю файл "СпециальныйКаталог/ФайлСТекстом.txt" в кодировке "cp866" с текстом "текст178"
Процедура ЯСоздаюФайлВКодировкеСТекстом(Знач ПутьФайла, Знач Кодировка, Знач ТекстФайла) Экспорт
	ПутьФайла = БДД.ПолучитьПутьФайлаСУчетомПеременныхКонтекста(ПутьФайла);
	ЗаписьТекста = Новый ЗаписьТекста(ПутьФайла, Кодировка);
	ЗаписьТекста.ЗаписатьСтроку(ТекстФайла);
	ЗаписьТекста.Закрыть();
КонецПроцедуры

Функция ИнициализироватьРепозиторий(РепозиторийGit, ИмяРепозитория, АлиасКаталога)
	
	КаталогРепозиториев = БДД.ПолучитьИзКонтекста(АлиасКаталога);
	
	КаталогРепозитория = ОбъединитьПути(КаталогРепозиториев, ИмяРепозитория);
	СоздатьКаталог(КаталогРепозитория);

	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	РепозиторийGit.Инициализировать();
	
	Возврат КаталогРепозитория;

КонецФункции