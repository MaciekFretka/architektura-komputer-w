Laboratorium 2
# Wstęp
Zadanie zostało zrealizowane częściowo. Cel który należało osiągnąć  to wyświetlenie poprawnego wyniku w postaci hex, mnożenia dwóch liczb podanych również hex, o długości max 200 znaków. 
Uzyskany efekt, to wypisanie prawidłowego wyniku w systemie hex, jeśli argumenty mają maksymalnie 8 znaków. Gdy znaków jest więcej, wyświetlany wynik jest nieprawidłowy. 
Problem w implementacji zachodi w momencie konwersji wejściowego łańcucha znaków na liczbę w postaci hex. Poprawnie zostaje zapisany tylko słowo 8-bitowe (long)
Np:

wpisanie wartości : 12345678

Poprawnie zostanie zapisane jako : 0x12345678

Natomiast wpisanie : 123456789

Zapisane zostanie jako : 0x123456789, 0x00000009

co jest błędną postacią, gdyż prawidłowy byłby zapis: 0x23456789, 0x01 (Wyświetlane wartości rozumiane jako wyświetlane przez gdb jako : x/2x &liczba , gdzie liczba jest nazwą etykiety przechowującą daną liczbę). Powyższego problemu, mimo wielu prób nie udało się prawidłowo rozwiązać.

## Wytłumaczenie
Daty commitów tego nie udawadniają (brak regularnego nawyku commitowania kodu), ale na zadanie została przeznaczona bardzo znaczna ilość czasu. W trakcie realizacji bardzo dużo rzeczy nieoczywistych sprawiało trudności. Wiele problemów musiało zostać realizowane metodą prób i błędów lub bardzo głębokiej analizy z użyciem debugera, co kosztowało ogromne zasoby czasu. W moim przypadku powodem tego był fakt, iż mimo dokładnej wiedzy teoretycznej dostarczanej nam na wykładzie, bardzo ciężko jest o wiedzę praktyczną opartą o jakieś dobrze wytłumaczone przykłady, czy wskazówki na wszelkie 'pułapki' (np. jak powinno w debuggerze wyglądać poprawnie przekonwertowana wartość do hex). W trakcie zajęć jest dużo czasu na zadanie pytania jednak (co zauważam na każdym laboratorium realizowanym w podobny sposób) większość problemów i niezrozumień pojawia się znacznie później. Dla mnie, tematem który sprawił najwięcej kłopotów były tryby adresowania. Na wykładzie Dr. Tomczak dobrze zaprezentował teorię wszelkich kombinacji trybów adresowania oraz ogólny wzór, jednak trudniej zrozumieć jak to działa w praktyce, który tryb wykorzystać do uzyskania konkretnych komórek pamięci np. przy pracy ze słowami 32-bitowymi. 


# Algorytm mnożenia
Zastosowana implementacja algorytmu mnożenia wynika z poniższych wzorów:

<img src=wzórmul.PNG>

W pierwszym kroku, mnożną A można rozbić na sumę iloczynów kolejnych cyfr przeskalowanych o kolejne pozycje. W algorytmie będziemy posługiwać się słowami `long` więc Beta będzie równe : 2^32. W ten sposób uzyskujemy pierwszą pętle iterującą po x w predziale <0,ilość cyfr liczby A>.

W drugim kroku analogicznie postępujemy dla mnożnika B

W ten sposób finalny wynik można uzyskać za pomocą dwóch pętli, gdzie pętla "po y" będzie zagnieżdżona w w pętli "po y"

# Wczytanie oraz konwersja danych
Za pomocą funkcji systemowej `READ` do pamięci rozpoczynającej się od etykiety `input` wczytany zostaje ciąg znaków ascii. Na jego końcu, występuje znak końca lini `\n`. 
W sekcji programu `rstrip`, znak ten jest usuwany, a program wraca do swojego miejsca w sekcji `back`.
Zwróconą przez funkcje `READ` do rejetru eax długość wczytanego tekstu, umieszczamy do rejestru edi oraz do miejsca w pamięci pod etykietą `liczba1_len`
Następnie zerowane są rejestry esi,eax,ebx.

Rozpoczyna się pętla konwertująca kolejne wczytane bajty reprezentujących znaki 0-9, a-f do faktycznych wartości. 
W pętli iteratorem jest wartość w rejestrze esi, zwiększana po każdej iteracji w sekcji `addbyte`. Jeśli wartość rejestru esi będzie równa wartości w rejestrze edi (ilość wczytanych bajtów), program opuści pętle. W każdej iteracji sprawdzany jest przedział wartości danych bajtów z etykiety `input`. Sprawdzane przedziały to wartości (w notacji hex) : 0x30-0x39 ('0'-'9'), 0x41-0x5A ('A'-'Z'), 0x61-0x7A ('a'-'z'). Wykrycie bajtu o wartościach zpoza tych przedziałów spowoduje skok do sekcji `invaliddata` w której następuje wypisanie komunikatu o nieprawdiłowych danych wejściowych

Jeśli bajt znajduje sie w prawidłowym przedziale, następuje skok do sekcji `digit` lub `SmallLetter` lub `BigLetter`, w zależności od tego czy znak reprezentuje cyfrę, małą czy dużą literę. W tych sekcjach następuję odjęcie odpowiedniej wartości w taki sposób by znak ascii reprezentujący dany symbol miał wartość danego symbolu. Np. od bajtu 'A' (w hex: 0x41) zostaje odjęta wartość 48, co powoduje że bajt ma wartość : 0xA (Decymalnie: 10). Po konwersji danego bajtu, w sekcji `petlanext` następuje sprawdzenie czy nowy bajt zmieści się w aktualnym słowie `long`, czy konieczne jest zwiększenie wartości w rejestrze ebx, służącego później do adresowania do właściwego słowa. Jeśli bajt sie mieści w aktualnym słowie, inkrementowana jest jedynie wartość w rejestrze eax, kontrolująca ilość wpisanych znaków do słowa. 

W sekcji `addbyte`, zachodzi przesunięcie o 4 bity w lewo, dotychczasowej wartości liczby. Wynika to z tego, że odczytany bajt zawiera 8 bitów, a znak hex 0-f 4. Przesunięcie bitowe likwiduje pojawianie się zer pomiędzy wpisanymi wartościami. 

Przekonwertowany znak dodawany jest do rejestru cl, a z rejestru cl do miejsca w pamięci pod etykietą `liczba1`. 

Wczytanie drugiej liczby zachodzi w sposób analogiczny, w sekcji `petla2`. 

Przekonwertowane liczby zapisane są w pamięci pod adresami `liczba1` i `liczba2`. W rejestrach edi oraz edx zawarte są długości wczytanych liczb.

**UWAGA : Tak jak wspomniano we wstępie, w powyższym algorytmie zawarty jest błąd implementacyjny, przez który poprawne są tylko reprezentacje maks 8 znakowe.**

# Implementacja algorytmu mnożenia
Przed wejściem do sekcji `mnozenieb` zerowane są rejestry edx,eax i ebx. Rejestry edx oraz eax będą odpowiadały za przechowywanie aktualnych cyfr, natomiast ebx iteratorem po dużej pętli (pętli "po x"). 

Na początku sekcji-pętli `mnozenieb` następuje sprawdzenie warunku czy licznik ebx dotarł do wartości długości pierwszej liczby. 
Gdy tak nie jest, zerowane są rejestry ecx oraz esi, gdzie rejestr ecx będzie iteratorem po małej pętli (pętli 'po y') a rejestr esi będzie wskazywał na numer pozycji 'o dwie dalej'. 

Sekcja `mnozenies` (pętla wewnętrzna) rozpoczyna się od wyzerowania rejestru edi oraz sprawdzenia warunku wyjscia z wewnętrznej pętli. 

Następnie do rejestrów eax i edx wpisana jest ta sama cyfra z aktualnych pozycji (x/y) liczb. Dalej zachodzi mnożenie : Ax * Bx, czyli pomnożenie liczb z edx i eax. 

8 Bajtowy wynik, umieszczany jest w postaci podwójnego słowa, gdzie wyższe 4 bajty umieszczane są w edx, a niższe 4 bajty w eax. 

Następnie, do rejestru ecx zostaje dodana wartość z ebx, tak aby uzyskać w ecx sume 'x+y'
Do niższych 4 bajtów wyniku mnożenia, zawartych w eax dodany zostaje tymczasowy wynik z pozycji x+y. Uzyskana suma zostaje przekopiowana zpowrotem na pozycję x+y wyniku. 

Zachodzi zwiększenie iteratura w ecx (aktualnie x+y, po inkrementacji x+y+1). Do wyższych 4 bajtów mnożenia w edx zostaje dodany tymczasowy wynik z pozycji x+y+1.

To dodawanie dodawane jest z przeniesieniem, ponieważ mogło one wystąpić w poprzedniej operacji dodawania. 

W tym dodawaniu, również mogło wystąpić przeniesienie. Z tego powodu zastosowano w tym momencie operację zapamiętania przeniesienia na pozycję 'o dwie dalej'. 
Zostało ono (jeśli powstało) zapisane w rejestrze edi.  Dwie iteracje wcześniej zostało wygenerowane przeniesienie na obecną pozycje, to przeniesienie znajduje się w rejestrze esi. Zostaje ono dodane do rejestru edx, a do esi trafia zapamiętane przeniesienie w edi. 

Następnie do wartości wyniku umieszczana jest wynik w edx. Odejmując ebx od ecx przywrócona zostaje właściwa wartość ecx. 

W ten sposób kończy się iteracja mniejszej pętli. Gdy zakończą się wszystkie iteracje mniejszej pętli na danej pozycji x (zapisanej w ebx), zaczyna się następna iteracja dużej pętli dla x+1.

Po zakończeniu dużej pętli, wynik mnożenia znajduje się w pamięci rozpoczynającej się od adresu etykiety `wynik`. Dodając `liczba1_len` oraz `liczba2_len` do eax, uzyskujemy w eax liczbę znaków wyniku mnożenia. 

# Wyświetlenie wyniku

Uzyskaną długość wyniku w rejestrze eax zwiększamy o 1, robiąc miejsce dla znak końca lini. Tą wartość zapisujemy w pamięci pod etykietą `wynik_teks_len`. 

Zapisując wynik, będziemy brać kolejno wszystkie bajty z etykiety `wynik`. Ponieważ w bajcie zawarte są dwie cyfry heksadecymalne z wyniku cyfry będą odczytywane parami, następnie rozdzielane do dwóch osobnych bajtów. Liczba odczytanych 'par' cyfr heksadecymalnych będzie zatem dwukrotnie krótsza od faktycznej ilości cyfr. Uzyskujemy tą liczbę dokonując przesunięcia bitowego o jeden bit w prawo wartości w rejestrze eax, następnie ją dekrementując. Tą wartość zapisujemy do rejestru esi, który będzie iteratorem pętli.

Następnie zerujemy rejest edi, który będzie wskaźnikiem na pozycję w wyjściowym łańcuchu znaków

Na początku sekcji-pętli `petla3` zerujemy rejestry edx oraz ecx. Do nich zostaje zapisana ta sama para cyfr z etykiety `wynik` (iterowanej przez wartość w rejestrze esi, początkowo ustawionej na wartość długości tekstu).

Za pomocą przesunięcia bitowego w prawo o 4 bity rejestru dl, oraz przesunięcia o 4 bity w lewo następnie ponownie w prawo rejestru cl, w rejestrach dl i cl zostaną rozdzielone cyfry do zapisania. 

Następnie zachodzi sprawdzenie czy cyfra należy do znaków czytanych jako cyfra 0-9 czy litera a-f. Podobnie jak w przypadku konwersji danych wejściowych, zawartości w rejestrach konwertowane są w sekcjach `znakA`, `znakB`, `znakC`, `znakD` (w zależności od przedziału i od tego czy konwertujemy prawą czy lewą cyfrę z pary) poprzez dodanie odpowiedniej liczby by uzyskać wartość odpowiadającą czytelnemu znakowi. W tych sekcjach, przekonwertowane znaki zapisywane są do `wynik_tekst`

Pętla  `petla3` działa od wartości długości tekstu do wartości 0 włącznie. Kończy się gdy w porównaniu cmp, przed skokiem do `petla3`, w rejestrze esi znajdzie się wartość równa wartości w rejestrze ecx (do którego wprowadzono wartość -1).

Wynik mógł mieć nieparzystą liczbę cyfr. W takim wypadku, na początku łańcucha z lewej strony dodanie zostane zbędne '0'.
Aby temu zapobiec, w sekcji `petla3koniec` mamy wpisanie wyniku ostatniej cyfry wyniku do rejestru dl (w taki sam sposób jak przy pierwszej iteracji w `petla3`)
Jeśli ten znak jest  równy 0, zachodzi przesunięcie bitowe w prawo o bajt etykiety `wynik_tekst` redukując tym sposobem zbędny znak '0' po lewej stronie.

Następnie, w sekcji `wypiszwynik` dopisywany jest znak końca lini do gotowego już łańcucha znaków w `wynik_tekst`.
Wynik zostaje wypisany za pomocą funkcji systemowej `WRITE`.
