# Popis projektu
Cílem řešeného projektu je návrh a implementace relační databáze na zvolené téma.
Je možné pokračovat na projektu z předmětu IUS. Pokud se studenti rozhodnou v projektu z IUS nepokračovat, pak si příslušné téma dvojice vybere ze [https://www.fit.vutbr.cz/study/courses/IDS/private/temata.html seznamu témat].

Zvolené téma není potřeba předem nikde hlásit, avšak všechny výsledky musí obsahovat název zvoleného téma (např. jako komentář v SQL skriptech, či vyznačený v diagramech nebo dokumentaci).

Projekt sestává ze pěti částí, které se odevzdávají ve stanovených termínech do WISu:

*# ''Datový model (ERD) a model případů užití'' &#8211; Datový model (ER diagram) zachycující strukturu dat, resp. požadavky na data v databázi, vyjádřený jako diagram tříd v notaci UML nebo jako ER diagram v tzv. [https://cs.wikipedia.org/wiki/Entity-relationship_model#Crow.27s_Foot Crow's Foot] notaci a model případů užití vyjádřený jako diagram případů užití v notaci UML reprezentující požadavky na poskytovanou funkcionalitu aplikace používající databázi navrženého datového modelu. Datový model musí obsahovat alespoň jeden vztah generalizace/specializace (tedy nějakou entitu/třídu a nějakou její specializovanou entitu/podtřídu spojené vztahem generalizace/specializace; vč. použití správné notace vztahu generalizace/specializace v diagramu).
*# ''SQL skript pro vytvoření základních objektů schématu databáze'' &#8211; SQL skript vytvářející základní objekty schéma databáze, jako jsou tabulky vč. definice integritních omezení (zejména primárních a cizích klíčů), a naplňující vytvořené tabulky ukázkovými daty. Vytvořené schéma databáze musí odpovídat datovému modelu z předchozí části projektu a musí splňovat upřesňující požadavky zadání.
*# ''SQL skript s několika dotazy SELECT'' &#8211; SQL skript, který nejprve vytvoří základní objekty schéma databáze a naplní tabulky ukázkovými daty (stejně jako skript v bodě 2) a poté provede několik dotazů SELECT dle upřesňujících požadavků zadání.
*# ''SQL skript pro vytvoření pokročilých objektů schématu databáze'' &#8211; SQL skript, který nejprve vytvoří základní objekty schéma databáze a naplní tabulky ukázkovými daty (stejně jako skript v bodě 2), a poté zadefinuje či vytvoří pokročilá omezení či objekty databáze dle upřesňujících požadavků zadání. Dále skript bude obsahovat ukázkové příkazy manipulace dat a dotazy demonstrující použití výše zmiňovaných omezení a objektů tohoto skriptu (např. pro demonstraci použití indexů zavolá nejprve skript EXPLAIN PLAN na dotaz bez indexu, poté vytvoří index, a nakonec zavolá EXPLAIN PLAN na dotaz s indexem; pro demostranci databázového triggeru se provede manipulace s daty, která vyvolá daný trigger; atp.).
*# ''Dokumentace popisující finální schéma databáze'' &#8211; Dokumentace popisující řešení ze skriptu v bodě 4 vč. jejich zdůvodnění (např. popisuje výstup příkazu EXPLAIN PLAN bez indexu, důvod vytvoření zvoleného indexu, a výstup EXPLAIN PLAN s indexem, atd.).

Všechny odevzdávané SQL skripty musí být určené pro systém řízení báze dat (SŘBD) Oracle 12c a musí umožňovat opakované volání, tedy odstranění a opětovné vytvoření, nebo rovnou přepsání, objektů v databázi a jejich dat (je v pořádku, když při prvním volání skriptu proběhnou neúspěšné pokusy o odstranění neexistujících databázových objektů).

Část projektu s diagramy a část projektu s dokumentací se odevzdávájí vždy jako jeden PDF soubor. Části projektu s SQL skripty se odevzdávají jednotlivě vždy v jednom souboru s prostým textem v kódování znaků UTF-8.

