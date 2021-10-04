Laboratorium 5
# Cel Laboratorium
Celem Laboratorium było utworzenie programu w języku assemblera, nakładający filtr na obraz w formacie .bmp. 

# Wstęp
Zadania nie udało się dobrze zrealizować. Plik wynikowy, zamiast być obrazem przefiltorwanym, ulega zniekształceniu.

Przykładowo:
Plik oryginalny:

<img src=img.bmp>

Plik wyjściowy:

<img src=img2.bmp>

# Funkcjonalność programu
Program wczytuje plik o nazwie "img.bmp". Do wczytywania pliku .bmp oraz uzyskiwania informacji o wymiarach obrazka i dostępu do pikseli wykorzystano metodę napisaną w języku C. 
Dostęp do pikseli obrazka możliwy jest poprzez utworzenie wskaźnika na adres pierwszego składowego bajtu piksela obrazu. Taki wskaźnik wraz z wymiarami obrazka przekazywany jest argumenty do funkcji 'filter' napisanej w języku assemblera. 

## Technika filtrowania.
Do filtrowania obrazka, potrzebna jest macierz: 


<img src=macierz.PNG>

Macierz ta nazywana jest maską. Przechowuje ona wagi wkładu pikseli z otoczenia piksela filtrowanego, na nową wartość piksela. Zawartość tej macierzy, definiuje rodzaj filtru. 
W tym programie podjęto próbę implementacji filtru uśredniającego, gdzie maska jest macierzą 3x3, z wartością 1 na każdej pozycji. Taki filtr "uśrednia" wartość każdego piksela z pikselami do okoła.

Filtracja wymaga wyliczenia nowej wartości dla każdego piksela. Podjęto próbę implemntacji dla obrazów 24-bitowych, co oznacza że piksel zapisany jest w trzech bajtach, każdy odpowiedzialny za inną składową R,G,B. Aby obliczyć nową wartość piksela, należy wylić wartość 's' :

<img src=swzór.PNG>

Parametry f, są kolejnymi wartościami z maski, natomiast parametry a, są wartościami odpowiednich składowych pikseli dookoła aktualnie filtrowanego piksela. 

W celu zapobiedzenia zmiany jasności obrazu, dokonuje się jeszcze normalizacji:

<img src=awzór.PNG>

Tak obliczoną wartość, można wstawić za oryginalną składową piksela.

Problematyczne są piksele na skrajnych krawędziach, ponieważ nie można ich przefiltrować gdyż nie mają sąsiednich pikseli.
Piksele takie traktuje się różnie. Najpopularniejszymi sposobami są zastąpienie je pikselami obok, które udało się przefiltrować, lub obcięcie obrazka ze wszystkich skrajnych pikseli.
W tej realizacji, zastąpiono skrajne piksele pikselami białymi, tworzącą ramkę do okoła obrazu.

# Implementacja funkcji filtrującej

Funkcja rozpoczyna się od zachowania wartości stosu oraz wartości w rejestrze *ebx*. 
Następnie zachodzi odebranie argumentów przekazanych przez stos, czyli kolejno :

- Adresu pamięci pierwszego piksela (zostaje zapisany do eax)
- Szerokości obrazka (zostaje zapisany pod etykietę width)
- Wysokości obrazka (zostaje zapisany pod etykietę height)
- Ilość bajtów przechowujących dane pikseli (zostaje zapisana pod etykietę size)

Szerokość i wysokość obrazka rozumiane są nie jako ilość pikseli lecz ilość bajtów.

Wartości width i height zapisywane są również do etykiet 'x' oraz 'y'. Są to kontrolne iteratory wykorzystywane do oddzielenia skrajnych pikseli.

Uruchamiana jest pętla (sekcja 'loop'), wykorzystująca rejestr esi jako iterator.
Każda iteracja pętli, inkrementuje wartość w rejestrze 'eax'. Dzięki temu w każdej iteracji pętli, pracujemy na kolejnym bajcie składowym pikseli.
Kolejność iteracji pikseli w takiej pętli to przesuwanie się kolejno od lewej krawędzi do prawej, rozpoczynając od lewego górnego rogu obrazka.

Iterator x, początkowo ustawiony na wartość 'width' dekrementuje się przy kolejnej iteracji, aż nie będzie miał wartości '0'. Gdy iterator 'x' osiąga wartość '0', oznacza to że program "przerobił" kolejny wiersz pikseli i następny piksel będzie pierwszym pikselem z lewej, w lini poniżej. Wtedy wartość 'x' ustawiana jest spowrotem na wartość równą 'width'. W ten sposób iterator 'x' zawsze zawiera wartość z przedziału <0,width>, która oznacza aktualną pozycje przerabianego piksej na osi poziomej. 

Przy każdej iteracji sprawdzane jest, czy x nie należy do <width-2,width>  (co by oznaczało że iterowany jest piksel lewej krawędzi) lub do <0,2> (co by oznaczało że iterowany jest piksel prawej krawędzi). Jeśli tak jest, to następuje skok do innej sekcji gdzie aktualnie wybrany bajt z pikseli ustawiany jest na wartość odpowiadającą białej barwie (gdy x jest równe zeru zamiast dekrementacji x zachodzi ponowne ustawienie x jako wartość width).

Dzięki temu pionowe krawędzie są kolorowane na biało i nie przechodzą do algorytmu filtrowania (gdyż po sekcji 'x_r_dec' i 'x_r' następuje skok do kolejnej iteracji).

W podobny sposób zachodzi również wykrywanie krawędzi górnej i dolnej. Iterator y, zaczynając od wartości height, dekrementowany jest przy każdym 'skoku' do nowej lini (czyli przy skoku programu do funkcji 'x_r'). Również jak w przypadku 'x', trzy pierwsze i trzy ostatnie wartości iteratora 'y' oznaczają krawędzie górną lub dolną, zachodzi podejście analogiczne do wykrycia krawędzi prawej i lewej. 

Następnie w pętli 'loop' znajduje się kod algorytmu filtrowania. W tym miejscu kodu mamy pewność że aktualny piksel nie jest pikselem brzegowym - czyli ma wszystkie piksele sąsiednie. 

## Filtrowanie
Na początku filtrowania, dla aktualnego piksela należy wyznaczyć adresy pikseli do okoła (dokładniej składowe pikseli - jeden bajt, gdyż operujemy też na jednej składowej, ten skrót myślowy zostanie zachowany w dalszej części opisu). 
Zrealizowano to w taki sposób, że znając adres aktualnego piksela, arytmetycznie wyliczane są adresy pikseli odpowiadające pierwszej kolumnie z lewej, z macierzy maski.

W rejestrze eax, zapisany jest adres aktualnego piksela, a pod etykietą width - szerokość obrazka. 
Dzięki temu można wyliczyć adresy pikseli odpowiadające pierwszej kolumnie z lewej, z macierzy maski w następujący sposób:

- pierwszy piksel kolumny : eax - width - 4
- drugi piksel kolumny : eax - 3
- trzeci piksel kolumny: eax + width - 2
Tak obliczana wartości uzyskiwane są za pomocą operacji odejmowania, zapisywane do rejestru 'edx' a z niego do etykiet 'mask' , 'mask2', 'mask3'. 

Mając te adresy, uzyskanie adresów kolejnych sąsiednich pikseli można uzyskać poprzez zwiększenie ich o 3 oraz o 6 (gdyż interesują nas bajty odpowiedzialne za te same składowe R,G,B). 

Aby móc korzystać z rejestru 'eax', adres aktualnego piksela zapamiętywany jest chwilowo do etykiety 'pixel_pointer', by potem można było go przywrócić.

Następnie występuje szereg dziewięciu operacji wyliczania wartości 's'. 
Zaczynając od piksela sąsiadujacego przy lewym górnym rogu, do rejestru 'dl' przesyłany jest bajt z adresu wskazywanego przez obliczone wcześniej adresy sąsiednich pikseli.
Do rejestru 'eax' przesyłana jest wartość '1', będąca wagą z danej pozycji maski. W przypadku tego filtru, wartośc ta będzie stale 1. Mimo tego, wykonujemy następny krok (chociaż w tym przypadku zbędny) - mnożymy wartość w rejestrze 'edx' przez wartośc w 'eax', wynik trafia do 'eax'. 
Wartość z 'eax' dodawana jest do 'ebx'.

Ta operacja zostaje powtórzona 9 razy, wykorzystując wszystkie 9 adresów sąsiednich pikseli wraz z aktualnym pikselem.

Wartość 's' zapisana jest w rejestrze 'ebx'.
Nasepnym krokiem jest uśrednienie wartości. 
Wartości sąsiednich pikseli sumowane są do rejestru 'edx'. Najpierw bajt przesyłany jest z danego adresu do rejestru 'al' a następnie dodawany do 'edx'.
Następnie, wartość z rejestru 'ebx' (s) zapisywana jest do rejestru 'eax' a wartość z rejestru 'edx' do 'ebx'.
Wykonywana jest operacja 

```
divl %ebx
```
która dzieli podwójne słowo zapisane w rejestrach 'edx:eax' przez wartośc w rejestrze 'ebx'. Wynik trafia do rejestru 'eax' a reszta to 'edx'. Tak uzyskaną wartość, przesyłamy pod adres aktualnego piksela. 

