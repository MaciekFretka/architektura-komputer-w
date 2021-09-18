Laboratorium 3
# Cel Laboratorium
Celem laboratorium było utworzenie programu w języku assemblera działającym jako kalkulator zmiennoprzecinkowy.
# Opis programu
Program pyta użytkownika o dwie liczby w formacie zmiennoprzecinkowym w systemie dziesiętnym.
Po ich wprowadzeniu, użytkownik wybiera operację arytmetyczną do wykonania poprzez wprowadzenie znaku wg schematu:
1. "+" Dodawanie
2. "-" Odejmowanie
3. "*" Mnożenie
4.  "/" Dzielenie
5.  ":" Dzielenie

(4 i 5 jest tą samą operacją)
Użytkownik wybiera również opcję zaokrąglania wyniku wg schematu: 
1. "n" Nearest
2. "d" Down 
3. "u" Up
4.  "z" To Zero

Następnie program wypisuje wynik operacji w formacie dziesiętnym.
# Implementacja
W sekcji '.data' zainicjowane są miejsca w pamięci dla wyświetlanych komunikatów oraz dla ciągów formatujących funkcji 'printf' oraz 'scanf' W sekcji .bss znajduje się rezerwacja przestrzeni pamięci dla zmiennych wprowadzonych argumentów.
Na początku programu trzykrotnie są wprowadzane dane wejściowe z klawiatury, za pomocą funkcji z języka C 'scanf'. Żeby zadziałała ona poprawnie należało umieścić na stosie jej argumenty (w odwrotnej kolejności) czyli: adres pamięci do której wczytany ma być dana liczba, ciąg formatujący dla liczby float czy: "%f".
Znak operatora operacji arytmetycznej oraz trybu zaokrąglania są wczytywane za pomocą funkcji write.

Ustawienie trybu zaokrąglania w FPU polega na ustawieniu odpowiedniej flagi w 16 bitowym słowie sterującym. bity odpowiadające za tryb zaokrąglania znajdują się na pozycjach 11-10. Przygotowane słowa ładowane są zapomocą instrukcji 'fldcw'. Słowa przygotowane są odpowiednio wg wybranej opcji zaokrąglania.


Sprawdzana jest wartość pierwszego bajtu z wczytanego tekstu (jako znak operatora), pod kątem reprezentacji znaku ascii.
Wykrycie że wpisano którychś z poprawnych operatorów, wywołuje skok do sekcji wykonania operacji arytmetycznej. W przeciwnym wypadku następuje skok do sekcji w której następuje wypisanie komunikatu błędu. 

Sekcja operacji arytmetycznej rozpoczyna się od załadowania na stos FPU wprowadzonych liczb poleceniem **fld**. Liczby trafiają do rejestrów st(0) oraz st(1). Stos FPU również posiada swojego rodzaju 'wskaźnik', będący polem **TOP**. Każda operacja umieszczenia wartości na stosie fpu, powoduje umieszczenie wartości w jednym z ośmiu 80-bitowych rejestrów st, oraz zwiększenie wskaźnika **TOP**. 

Następnym krokiem jest wykonanie operacji arytmetycznej. W zależności od wybranej sekcji może to być:
1. fubp - odejmowanie
2. faddp - dodawanie
3. fmulp - mnożenie
4. fdivp - dzielenie
Argumentami funkcji są wartości z rejestrów st i st(1). Instrukcje są wprowadzone wraz z sufiksem 'p'. Oznacza to że kaza instrukcja wykonana operacje arytmetyczną, po czym zdejmie ze stosu wartość (w tym przypadku z st(1)) a wynik umieści w st(0). Następuje skok do sekcji 'koniec'

W sekcji 'koniec', następuje rezerwacja miejsca na stosie zwykłym za pomocą dwukrotnej operacji push. Następnie ze stosu fpu, ściągana jest wartość wyniku, do stosu zwykłego. Drugą wartością umieszczona na stosie jest cią formatujący funkcje printf, tak by wyświetliła wynik jako liczbę  zmiennoprzecinkową. Następuje wywołanie funkcji printf, a następnie zakończenie procesu.

