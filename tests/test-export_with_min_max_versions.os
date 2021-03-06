#Использовать tempfiles
#Использовать logos
#Использовать strings

#Использовать ".."

Перем юТест;
Перем Распаковщик;
Перем Лог;

Процедура Инициализация()
	
	Распаковщик = Новый МенеджерСинхронизации();
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync");
	Лог.УстановитьУровень(УровниЛога.Отладка);
	
КонецПроцедуры

Функция ПолучитьСписокТестов(Знач Контекст) Экспорт
	
	юТест = Контекст;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьНачинаяСВерсии3");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьМаксимумВерсию5");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьВерсииС3По7");
	
	Возврат ВсеТесты;
	
КонецФункции

Процедура ПослеЗапускаТеста() Экспорт
	ВременныеФайлы.Удалить();
КонецПроцедуры

Функция ПолучитьФайлКонфигурацииИзМакета(Знач ИмяМакета = "")
	
	Если ИмяМакета = "" Тогда
		ИмяМакета = "TestStoreVer8";
	КонецЕсли;
	
	
	ФайлТестовойКонфигурации = Новый Файл(ОбъединитьПути(КаталогFixtures(), ИмяМакета + ".cf"));
	
	юТест.Проверить(ФайлТестовойКонфигурации.Существует(), "Файл тестовой конфигурации <"+ФайлТестовойКонфигурации.ПолноеИмя+"> должен существовать");
	
	Возврат ФайлТестовойКонфигурации.ПолноеИмя;
	
КонецФункции

Функция ПолучитьПутьКВременномуФайлуХранилища1С()
	
	ПутьКФайлуХранилища1С = ОбъединитьПути(КаталогFixtures(), "TestStoreVer8.1CD");
	юТест.ПроверитьИстину(ПроверитьСуществованиеФайлаКаталога(ПутьКФайлуХранилища1С, "Тест_ДолженПолучитьФайлВерсийХранилища - ПутьКФайлуХранилища1С"));
	
	Возврат ПутьКФайлуХранилища1С;
	
КонецФункции

Функция ПроверитьСуществованиеФайлаКаталога(парамПуть, допСообщениеОшибки = "")
	Если Не ЗначениеЗаполнено(парамПуть) Тогда
		Сообщить("Не указан путь <"+допСообщениеОшибки+">");
		Возврат Ложь;
	КонецЕсли;
	
	лфайл = Новый Файл(парамПуть);
	Если Не лфайл.Существует() Тогда
		Сообщить("Не существует файл <"+допСообщениеОшибки+">");
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Функция КаталогFixtures()
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "fixtures");
КонецФункции

Процедура Тест_ДолженЭкспортироватьНачинаяСВерсии3() Экспорт
	
	ПутьКФайлуХранилища1С = ПутьКВременномуФайлуХранилища1С();
	
	КаталогРепо = ВременныеФайлы.СоздатьКаталог();
	КаталогИсходников = ОбъединитьПути(КаталогРепо, "src");
	СоздатьКаталог(КаталогИсходников);
	
	РезультатИнициализацииГитЧисло = ИнициализироватьТестовоеХранилищеГит(КаталогРепо);
	юТест.ПроверитьИстину(РезультатИнициализацииГитЧисло=0, "Инициализация git-хранилища в каталоге: "+КаталогРепо);
	
	СоздатьФайлАвторовГит_ДляТестов(КаталогИсходников);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"AUTHORS"));
	Распаковщик.ЗаписатьФайлВерсийГит(КаталогИсходников,0);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"VERSION"));
	
	Распаковщик.СинхронизироватьХранилищеКонфигурацийСГит(КаталогИсходников, ПутьКФайлуХранилища1С, 3);
	
	ИмяФайлаЛогаГит = ВременныеФайлы.НовоеИмяФайла("txt");
	
	ФайлКоманды = ВременныеФайлы.НовоеИмяФайла("cmd");
	ЗаписьФайла = Новый ЗаписьТекста(ФайлКоманды, "cp866");
	ЗаписьФайла.ЗаписатьСтроку("cd /d " + ОбернутьВКавычки(КаталогИсходников));
	ЗаписьФайла.ЗаписатьСтроку("git log --pretty=oneline >"+ОбернутьВКавычки(ИмяФайлаЛогаГит));
	ЗаписьФайла.Закрыть();
	
	КодВозврата = 0;
	ЗапуститьПриложение("cmd.exe /C " + ОбернутьВКавычки(ФайлКоманды), , Истина, КодВозврата);
	юТест.ПроверитьРавенство(0, КодВозврата, "Получение краткого лога хранилища git");
	
	ЛогГит = Новый ЧтениеТекста;
	ЛогГит.Открыть(ИмяФайлаЛогаГит);
	КоличествоКоммитов = 0;
	Пока ЛогГит.ПрочитатьСтроку() <> Неопределено Цикл
		КоличествоКоммитов = КоличествоКоммитов + 1;
	КонецЦикла;
	ЛогГит.Закрыть();
	юТест.ПроверитьРавенство(КоличествоКоммитов, 6, "Количество коммитов в git-хранилище");
	
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьМаксимумВерсию5() Экспорт
	
	ПутьКФайлуХранилища1С = ПутьКВременномуФайлуХранилища1С();
	
	КаталогРепо = ВременныеФайлы.СоздатьКаталог();
	КаталогИсходников = ОбъединитьПути(КаталогРепо, "src");
	СоздатьКаталог(КаталогИсходников);
	
	РезультатИнициализацииГитЧисло = ИнициализироватьТестовоеХранилищеГит(КаталогРепо);
	юТест.ПроверитьИстину(РезультатИнициализацииГитЧисло=0, "Инициализация git-хранилища в каталоге: "+КаталогРепо);
	
	СоздатьФайлАвторовГит_ДляТестов(КаталогИсходников);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"AUTHORS"));
	Распаковщик.ЗаписатьФайлВерсийГит(КаталогИсходников,0);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"VERSION"));
	
	Распаковщик.СинхронизироватьХранилищеКонфигурацийСГит(КаталогИсходников, ПутьКФайлуХранилища1С,,5);
	
	ИмяФайлаЛогаГит = ВременныеФайлы.НовоеИмяФайла("txt");
	
	ФайлКоманды = ВременныеФайлы.НовоеИмяФайла("cmd");
	ЗаписьФайла = Новый ЗаписьТекста(ФайлКоманды, "cp866");
	ЗаписьФайла.ЗаписатьСтроку("cd /d " + ОбернутьВКавычки(КаталогИсходников));
	ЗаписьФайла.ЗаписатьСтроку("git log --pretty=oneline >"+ОбернутьВКавычки(ИмяФайлаЛогаГит));
	ЗаписьФайла.Закрыть();
	
	КодВозврата = 0;
	ЗапуститьПриложение("cmd.exe /C " + ОбернутьВКавычки(ФайлКоманды), , Истина, КодВозврата);
	юТест.ПроверитьРавенство(0, КодВозврата, "Получение краткого лога хранилища git");
	
	ЛогГит = Новый ЧтениеТекста;
	ЛогГит.Открыть(ИмяФайлаЛогаГит);
	КоличествоКоммитов = 0;
	Пока ЛогГит.ПрочитатьСтроку() <> Неопределено Цикл
		КоличествоКоммитов = КоличествоКоммитов + 1;
	КонецЦикла;
	ЛогГит.Закрыть();
	юТест.ПроверитьРавенство(КоличествоКоммитов, 5 , "Количество коммитов в git-хранилище");
	
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьВерсииС3По7() Экспорт
	
	ПутьКФайлуХранилища1С = ПутьКВременномуФайлуХранилища1С();
	
	КаталогРепо = ВременныеФайлы.СоздатьКаталог();
	КаталогИсходников = ОбъединитьПути(КаталогРепо, "src");
	СоздатьКаталог(КаталогИсходников);
	
	РезультатИнициализацииГитЧисло = ИнициализироватьТестовоеХранилищеГит(КаталогРепо);
	юТест.ПроверитьИстину(РезультатИнициализацииГитЧисло=0, "Инициализация git-хранилища в каталоге: "+КаталогРепо);
	
	СоздатьФайлАвторовГит_ДляТестов(КаталогИсходников);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"AUTHORS"));
	Распаковщик.ЗаписатьФайлВерсийГит(КаталогИсходников,0);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"VERSION"));
	
	Распаковщик.СинхронизироватьХранилищеКонфигурацийСГит(КаталогИсходников, ПутьКФайлуХранилища1С,,5);
	
	ИмяФайлаЛогаГит = ВременныеФайлы.НовоеИмяФайла("txt");
	
	ФайлКоманды = ВременныеФайлы.НовоеИмяФайла("cmd");
	ЗаписьФайла = Новый ЗаписьТекста(ФайлКоманды, "cp866");
	ЗаписьФайла.ЗаписатьСтроку("cd /d " + ОбернутьВКавычки(КаталогИсходников));
	ЗаписьФайла.ЗаписатьСтроку("git log --pretty=oneline >"+ОбернутьВКавычки(ИмяФайлаЛогаГит));
	ЗаписьФайла.Закрыть();
	
	КодВозврата = 0;
	ЗапуститьПриложение("cmd.exe /C " + ОбернутьВКавычки(ФайлКоманды), , Истина, КодВозврата);
	юТест.ПроверитьРавенство(0, КодВозврата, "Получение краткого лога хранилища git");
	
	ЛогГит = Новый ЧтениеТекста;
	ЛогГит.Открыть(ИмяФайлаЛогаГит);
	КоличествоКоммитов = 0;
	Пока ЛогГит.ПрочитатьСтроку() <> Неопределено Цикл
		КоличествоКоммитов = КоличествоКоммитов + 1;
	КонецЦикла;
	ЛогГит.Закрыть();
	юТест.ПроверитьРавенство(КоличествоКоммитов, 5 , "Количество коммитов в git-хранилище");
	
КонецПроцедуры


Функция ОбернутьВКавычки(Знач Строка);
	Возврат """" + Строка + """";
КонецФункции

Функция ИнициализироватьТестовоеХранилищеГит(Знач КаталогРепозитория, Знач КакЧистое = Ложь)

	КодВозврата = Неопределено;
	ЗапуститьПриложение("git init" + ?(КакЧистое, " --bare", ""), КаталогРепозитория, Истина, КодВозврата);
	
	Возврат КодВозврата;
	
КонецФункции

Функция ПутьКВременномуФайлуХранилища1С()
	
	Возврат ОбъединитьПути(КаталогFixtures(), "TestStoreVer8.1CD");
	
КонецФункции

Процедура СоздатьФайлАвторовГит_ДляТестов(Знач Каталог)

	ФайлАвторов = Новый ЗаписьТекста;
	ФайлАвторов.Открыть(ОбъединитьПути(Каталог, "AUTHORS"), "utf-8");
	ФайлАвторов.ЗаписатьСтроку("Администратор=Администратор <admin@localhost>");
	ФайлАвторов.ЗаписатьСтроку("Отладка=Отладка <debug@localhost>");
	ФайлАвторов.Закрыть();

КонецПроцедуры

Функция ВыполнитьКлонированиеТестовогоРепо()
	
	БазовыйКаталог = ВременныеФайлы.СоздатьКаталог();
	УдаленныйКаталог = ОбъединитьПути(БазовыйКаталог, "remote");
	ЛокальныйКаталог = ОбъединитьПути(БазовыйКаталог, "local");
	СоздатьКаталог(УдаленныйКаталог);
	СоздатьКаталог(ЛокальныйКаталог);
	
	URLРепозитария = УдаленныйКаталог;
	
	Лог.Отладка("Инициализация репо в каталоге " + URLРепозитария);
	Если ИнициализироватьТестовоеХранилищеГит(URLРепозитария, Истина) <> 0 Тогда
		ВызватьИсключение "Не удалось инициализировать удаленный репо";
	КонецЕсли;
	
	ИмяВетки = "master";
	
	ФайлЛога = ВременныеФайлы.СоздатьФайл("log");
	Батник = СоздатьКомандныйФайл();
	ДобавитьВКомандныйФайл(Батник, "chcp 1251 > nul");
	ДобавитьВКомандныйФайл(Батник, СтроковыеФункции.ПодставитьПараметрыВСтроку("cd /d ""%1""", ЛокальныйКаталог));
	
	ПараметрыКоманды = Новый Массив;
	ПараметрыКоманды.Добавить("git clone");
	ПараметрыКоманды.Добавить(URLРепозитария);
	ПараметрыКоманды.Добавить(ОбернутьВКавычки("%CD%"));
	ПараметрыКоманды.Добавить(СуффиксПеренаправленияВывода(ФайлЛога, Истина));
	
	КоманднаяСтрока = СобратьКоманднуюСтроку(ПараметрыКоманды);
	Лог.Отладка("Командная строка git clone:" + Символы.ПС + КоманднаяСтрока);
	ДобавитьВКомандныйФайл(Батник, КоманднаяСтрока);
	ДобавитьВКомандныйФайл(Батник, "exit /b %ERRORLEVEL%");
	
	РезультатКлонирования = ВыполнитьКомандныйФайл(Батник);
	// вывод всех сообщений от Git
	ВывестиТекстФайла(ФайлЛога);
	юТест.ПроверитьРавенство(РезультатКлонирования, 0, "git clone должен отработать успешно");
	
	Ответ = Новый Структура;
	Ответ.Вставить("ЛокальныйРепозиторий", ЛокальныйКаталог);
	Ответ.Вставить("URLРепозитария", URLРепозитария);
	Ответ.Вставить("ИмяВетки", ИмяВетки);
	
	Возврат Ответ;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////
// Работа с командными файлами

Функция СоздатьКомандныйФайл(Знач Путь = "")

	Файл = Новый КомандныйФайл();
	Файл.Открыть(Путь);
	
	Возврат Файл;
	
КонецФункции

Процедура ДобавитьВКомандныйФайл(Знач ДескрипторКомандногоФайла, Знач Команда)
	ДескрипторКомандногоФайла.Добавить(Команда);
КонецПроцедуры

Функция ВыполнитьКомандныйФайл(Знач ДескрипторКомандногоФайла)
	Возврат ДескрипторКомандногоФайла.Выполнить();
КонецФункции

Функция ЗакрытьКомандныйФайл(Знач ДескрипторКомандногоФайла)
	
	Возврат ДескрипторКомандногоФайла.Закрыть();
	
КонецФункции

Функция СуффиксПеренаправленияВывода(Знач ИмяФайлаПриемника, Знач УчитыватьStdErr = Истина)
	Возврат "> " + ИмяФайлаПриемника + ?(УчитыватьStdErr, " 2>&1", "");
КонецФункции

Функция СобратьКоманднуюСтроку(Знач ПереченьПараметров)
	
	СтрокаЗапуска = "";
	Для Каждого Параметр Из ПереченьПараметров Цикл
	
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		
	КонецЦикла;
	
	Возврат СтрокаЗапуска;
	
КонецФункции

Процедура ВывестиТекстФайла(Знач ИмяФайла, Знач Кодировка = Неопределено)

	Файл = Новый Файл(ИмяФайла);
	Если НЕ Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	
	Если Кодировка = Неопределено Тогда
		Кодировка = "utf-8";
	КонецЕсли;
	
	ЧТ = Новый ЧтениеТекста(ИмяФайла, Кодировка);
	СтрокаФайла = ЧТ.Прочитать();
	ЧТ.Закрыть();
	
	Лог.Информация(СтрокаФайла);

КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////

Инициализация();