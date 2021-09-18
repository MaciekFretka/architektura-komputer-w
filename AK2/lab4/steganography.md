Laboratorium 4
# Cel Laboratorium
Celem Laboratorium było utworzenie programu w języku assemblera, ukrywającego za pomocą techniki steganografii w pliku .BMP ukrytą wiadomość. 
Program mial również umożliwić odczytanie takie wiadomości ukrytej w pliku .BMP
# Opis Programu

Zrealizowany program działa na ustawionych "na sztywno" plikach "img.bmp" oraz "img2.bmp" które muszą być w katalogu razem z programem. 

Program na początku pyta użytkownika o tryb działania. Użytkownik wybiera opcję 1 - Odczyt wiadomości z pliku .BMP lub 2 - Ukrycie wiadomości w pliku .BMP

Po wybraniu opcji 1, użytkownik zostaje zapytany o ilość znaków do odczytania (zakładamy że użytkownik nie wie jaka wiadomość ukryta jestw pliku - więc nie wie również jak długa ona może być).
Jeśli użytkownik wprowadzi zbyt dużą liczbę, zostanie poinformowany o tym fakcie i program się zakończy. Dozwolona liczba odczytu znaków jest równa liczbie bajtów przeznaczonych na zapis pikseli w obrazie. 
Obraz ma rozmiary 100 x 100, a ponieważ jest zapisany z głębią 24 bitową, co oznacza że każdy piksel zapisany jest za pomocą3 bajtów. Daje to razem maksymalny rozmiar buffora: 100 * 100 * 3 = 30000.

Następnie użytkownikowi zostaje wyświetlona ukryta wiadomość, oraz możliwe znaki niedrukowalne (jeśli podał rozmiar buffora dłuższy niż długość ukrytej wiadomości).


Po wybraniu opcji 2, użytkownik zostaje zapytany o wiadomość do ukrycia. Podobnie jak w przypadku opcji 1, nie może ona przekroczyć określonej liczby.

Po tym, zostanie utworzony (bądź podmieniony) plik "img2.bmp", w którym została ukryta wprowadzona wiadomość. 

# Utworzony algorytm steganografii 

Utworzona implementacja realizuje algorytm steganografii poprzez ukrywanie wiadomości w 4 najmłodszych bitach bajtów pikseli. 
Każdy bajt z wprowadzonego tekstu do zaszyfrowania zostaje podzielony na dwie grupy 4 bitów, a następnie te grupy zastępują cztery najmłodszy bity w  dwóch kolejnych bajtach w sekcji pikseli pliku bmp.

Odczyt wiadomości jest operacją odwrotną. Brane są kolejne pary bajtów z pikseli pliku bmp. Z nich wyodrębniane są 4 najmłodsze bity, które są łączone w cały bajt. Tak utworzony bajt zostaje dodany do tekstu wyjściowego. 

# Wczytanie nagłówka pliku .bmp oraz danych pikseli

Do wczytania i obsługi formatu bmp skorzystano ze znalezionych przykładów. Dzięki nim uzyskano dwie funkcje : 'ReadImage()' oraz 'WriteImage'.
'ReadImage' przyjmuje jako argumenty:

- Nazwę pliku do odczytu
- Referencje na miejsce w pamięci do której mają być wczytanie dane bajtów pikseli
- Referencje do liczby typu Integer która ma przeechowywać szerokość danego obrazu
- Referencje do liczby typu Integer która ma przeechowywać wysokość danego obrazu
- Referencje do liczby typu Integer która ma przeechowywać liczbę w ilu bajtach zapisany jest jeden piksel

'WriteImage; przyjmuje jako argumenty:
- Nazwę pliku wyjściowego
- Dane pikseli wyjściowego obrazu
- Szerokość wyjściowego obrazu
- Wysokość wyjściowego obrazu
- Liczbę bajtów w jakich ma być zapisany pisel w wyjściowym obrazie

# Algorytm szyfrowania wiadomości

W pliku 'steganography.s' zapisana została funkcja 'steganography' odpowiedzialna za szyfrowanie wiadomości.
Funkcja ta przyjmuje dwa argumenty - adres do pamięci gdzie zapisane są piksele obrazu (począwszy od piksela pierwszego piksela z lewego górnego rogu), oraz rozmiar obszaru gdzie zapisane są bajty pikseli. 

Funkcja rozpoczyna się od przypisania tych argumentów (przekazanych poprzez stos) do rejestrów eax oraz edx. 

Natępnia ustawiany jest rejestr esi jako iterator pętli. 

Iteracja pętli rozpoczyna się od wyzerowania rejestru ecx. Następnie, do etykiety 'b' wpisany jest bajt "00001111", a do rejestru 'cl' - bajt z szyfrowanej wiadomości. 
Następnie dokonując operacji logicznej 'and' na rejetrze 'cl' i etykiecie 'b', w 'b' zostają zapisany bajt w którym 4 młodsze bity to 4 młodsze bity odczytanego bajtu z wiadomości, a 4 starsze to zera.

Następnie zachodzi wyzerowanie rejestru ecx oraz przekazanie do niego bajtu z adresu (%eax), gdzie w eax znajduje się wskaźnik na obszar bajtów pikseli. 
Wykonywana jest operacja logiczna 'and' z argumentem '11110000' oraz zapisanym wcześniej bajcie w ecx, dzięki czemuw cl uzyskujemy bajt gdzie 4 młodsze bity są zerami a cztery starsze zawierają odpowiednie bity ze swoich pozycji z bajtu z piksela. 

Mając przygotowane dwa takie bajty, operacją xor zapisujemy w 'b' bajt w którym 4 młodsze bity są z zaszyfrowanej wiadomości, a 4 starsze zostały z bajtu piksela. 
Takim bajtem zastępujemy bajt pod adresem (%eax).

Następnie zachodzi inkrementacja wskaźnika w eax oraz dokonanie operacji bardzo podobnych do powyższych. Jednak tym razem w kolejnym bajcie chcemy zapisać 4 starsze bity z bajtu szyfrowanej wiadomości, więc uzyskując bajt w którym chcemy mieć formę <0000+4bity z bajtu teksty>, musimy operacji and dokonać na wartości '11110000' a następnie dokonać przesunięcia bitowego w prawo o 4 bity. 

Tak działająca pętla działa aż zostaną zapisane wszystkie bajty z podanej wiadomości.


# Algorytm odczytu wiadomości

W pliku 'read.s' zapisana została funkcja 'read' odpowiedzialna za odczyt ukrytej wiadomości w danym pliku bmp.
Funkcja ta przyjmuje dwa argumenty - tablicę bajtów pikseli z wejściowego obrazu oraz ilość znaków do odczytania.

Na początku funkcji argumenty te (przekazane przez stos) przypisywane są do rejestrów eax i edx.

Ustawiany jest iterator pętli w rejestrze 'esi' i program przechodzi do wykonywania pętli.

Na początku iteracji pętli pobierany jest bajt (z piksela obrazu) z adresu (eax) do rejestru 'ecx'. Inkrementowany jest wskaźnik w rejestrze 'eax'.
Następnie ustwiany jest bajt (zapisany bitowo)  '00001111' do etykiety 'by', a następnie wykonywana jest operacja logiczna 'and' na rejestrze 'cl' oraz zapisanym bajcie w 'by'.
Wynikiem tej operacji jest uzyskanie w 'by' bajtu w którym 4 młodsze bity są bitami z odczytanego bajtu z piksela a reszta jest zerami. 

Następnie pobierany jest kolejny bajt z bajtów pikseli do rejetru 'cl'. W bajcie pod etykietą 'by2' ustawiana jest wartość '00001111'. 
Następnie, ponownie za pomocą operacji and na 'by2' i przechowywanym bajcie w 'cl', w 'by2' uzyskujemy bajt z zerami na 4 starszych bitach i z bitami z odczytanego bajtu na młodszych pozycjach. 

Ponieważ w 'by2', cztery młodsze bity to są tak naprawdę 4 starsze bity bajtu który chcemy uzyskać, dokonujemy przesunięcia bitowego o 4 pozycje w lewo na bajcie w 'by2'.
W ten sposób, dokonując operacji xor na 'by' (pośrednio poprzez rejestr 'cl' gdyż nie jest możliwe wykonanie operacji na dwóch argumentach będących adresami pamięci) i 'by2' w 'by2' uzyskujemy prawidłowy bajt który reprezentuje poprawny bajt zaszyfrowanej wiadomości. Tak odszyfrowany dołączany jest pod etykietę 'input' (nazwa etykiety 'input' jest dobrana omyłkowo niewłaściwie) wg. iteratora 'esi'. 

Tak zorganizowana pętla taką ilość iteracji jaką podał użytkownik, nawet jeśli przypiswyane bajty już nie należą do zaszyfrowanej wiadomości. 
Warto by zaimplementować pętlę tak by zamiast zadanej ilości iteracji, działała tak długo jak bajty są w przedziałach znaków drukowalnych (0-9,a-z,A-Z,). 
Niestety nie starczyło czasu by zmodyfikować implementację petli.

Na końcu funkcji wywoływana jest funkcja systemowa 'WRITE' wypisująca daną wiadomość.
Następnie kod assemblera wywołuje kod zakończenia procesu. 

Nie uważam tego za rozwiązanie dokońca prawidłowe - gdyż program powinien się zakończyć z poziomu C tak jak się rozpoczął. Powodem dla którego zostano przy tym rozwiązaniu były błędy które wynikały po powrocie do poziomu c. Wywołując funckję 'WRITE' konieczne było użycie rejestrów eax,ebx,ecx,edx, a ponieważ rejestr ebx zachowuje wartość z poziomu wywoływanego funkcję (ang. called-saved), nadpisanie tej wartości kończyło się po powrocie do C segmentation faultem. Z braku czasu na naprawę tego błędu, pozostano przy takim rozwiązaniu.


