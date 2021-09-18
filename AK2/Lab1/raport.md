# 241132
# AK2 Laboratorium 1
## Algorytm ROT13
Jaroński Maciej Mateusz
### Obsługa i działanie programu
Na repozytorium w folderze 'Lab1' umieszczony jest kod programu oraz plik reguł Makefie.
Aby uzyskać wersję uruchomieniową programu ELF należy kod z asemblować, a następnie zkonsolidować.
Do uproszczenia tego procesu zastosowano program **make**, wykonjący automatycznie wymagane cele. 
By uzyskać uruchomieniową wersję programu, wystarczy uruchomić narzedzie poleceniem `make` w terminalu w folderze Lab1.
Program należy uruchomić poleceniem `./rot` w folderze Lab1. W terminalu pojawi się komunikat proszący o podanie zdania do przekonwertowania na rot13. 
Po wpisaniu należy zatwierdzić wybór klawiszem enter a na ekranie pojawi się przetłumaczone zdanie, a program prawidłowo się zakończy. 
Przykładowe uruchomienie programu:
![](https://i.imgur.com/9dmmBUD.png)
### Opis implementacji algorytmu

W sekcji `.data` opisane są etykiety wykorzystywane w programie
 ```
    .data
input: .space input_len
message: .ascii "Podaj zdanie: "
message_len = . - message
```
*input - Bufor pamięci na wejściowy argument. Rozmiar argumentu określony jest przez zdefiniowaną wcześniej wartość input_len
*message: - Zdanie wyświetlane po uruchomieniu programu, proszące użytkownika o wprowadzenie zdania
*message_len - Stała, do której przypisana jest różnica "adres miejsca w którym obecnie znajduje się asember" - "adres pamięci etykiety message". Wynikiem takieog działania będzie   rozmiar "message". Jest to mechanizm mający ominięcie ręcznego liczenia rozmiaru "message"

Następnie w liniach 21-31 wywołana jest najpierw funkcja systemowa **write**, wypisująca na ekranie zawartość z "message" a następnie funkcja **read**, wczytująca do bufora tekst podany przez użytkownika.

Następnie kopiowana jest długość podanego tekstu (długość ta została zwrócona przez funksje **read** do rejestru %eax) do rejestru %edi. 
Na końcu tekstu występuje znak nowej lini, którego nie należy modyfikować, więc zachodzi dekrementacja wartości w rejestrze %edi. 
Następnie zachodzi inicjacja licznika pętli poprzez wpisanie wartości 0 do rejestru %esi.


Za pomocą adresowania pośredniego rejestrowego koleno są uzyskiwane kolejne adresy kolejnych bajtów zapisanych pod etykietą "input". Wartość w rejestrze %esi inkrementowana jest  przy każdym wejściu do sekcji `petlanext` (w ktorym znajduje sie inkrementacja %esi oraz skok warunkowy do poczatku pętli jesli wartosc w rejestrze esi jest < wartość w rejestrze edi). Pętla zatem iteruje kolejno po wszystkich bajtach zadanego tekstu. Dla każdego bajtu argumentu zachodzić będzie następująca procedura:
1. Sprawdzenie czy wartość bajtu jest mniejsza niż zapisana w systemie hex wartość bajtu reprezentującego literę 'A'. Jeśli tak (oznacza to że niest to litera alfabetu łacińskiego) bajt ten jest nie edytowany i następuje skok do następnej iteracji pętli
2. (Jeśli w poprzednim punkcie nie nastąpił skok) Sprawdzenie czy wartość bajtu jest mniejsza niż zapisana w systemie hex wartość bajtu reprezentującego literę 'Z'. Jeśli tak, oznacza że jest to poprawna duża litera, następuje skok do sekcji BigLetter. W tej sekcji sprawdzany jest czy litera znajduje się w przedziale <N,Z>. Jeśli nie, to wartość bajtu zwiększana jest o wartość 13. Jeśli tak, nastepuje skok do sekcji `over` w której wartość bajtu jest zmniejszana o wartość 13 (By uniknąć wyskoczenia poza alfabet). Następnie pętla przechodzi do nowej iteracji
3. (Jeśli nie była to duża litera) sprawdzany jest warunek czy wartość bajtu jest mniejsza niż wartość reprezentująca literę 'a'. Jeśli tak jest, nastepuje skok do nowej iteracji pętli.
4. Jeśli tak nie było, sprawdzane jest czy wartość bajtu jest mniejsza od wartości reprezentującą literę 'z'. Jeśli tak, następuje skok do sekcji `SmallLetter`. Jeśli nie, zachodzi kolejna iteracja pętli. Jeśli tak Ponawiana jest operacja z sekcji BigLetter, tylko dla małych liter (przedział <n,z>)

Po wyjściu z pętli (pętla się kończy gdy nie następuje skok warunkowy w lini 62, czyli gdy wartość w rejestrze %edi będzie rowną wartości w %esi) następuje wywołanie funkcji **write** która wypisuje zmodyfikowany tekst zaczynający się adresem z etykiety "input". Następnie program się kończy
