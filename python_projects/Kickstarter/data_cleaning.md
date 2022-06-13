# Ustalenia wstępne
1. Nazwa głównego DataFrame'u (pełny plik): df. (Przy łączeniu naszych wyników w całość nie będziemy musieli podmieniać nazw).
2. Nazwa wyczyszczonego pliku, na którym będziemy robić analizy: df_clean. (Przy łączeniu naszych wyników w całość nie będziemy musieli podmieniać nazw).
3. Nie uwzględniamy w analizie kolumn `goal`, `pledged` - one są błędne. Posługujemy się w zamian kolumnami `usd_goal_real`, `usd_pledged_real`, 


# Co jest nie ok
1. Jest 105 rekordów, które jako `country` mają N,0". Dla nich mamy 0 `backers` i `state` sukces. - **REKORDY DO USUNIĘCIA**
2. Do zamiany `main_category` na typ category.
3. Do zamiany `currency` na typ category.
4. Do zamiany `state` na typ category.
5. Do zamiany `country` na typ category.
6. Do zamiany `launched` na typ datetime.
7. Do zamiany `deadline` na typ datetime.


# Co jest ok
1. Nie ma wartości ujemnych w `backers`.
2. Nie ma wartości ujemnych w `usd_pledged_real`.
3. Nie ma wartości ujemnych w `usd_goal_real`.

