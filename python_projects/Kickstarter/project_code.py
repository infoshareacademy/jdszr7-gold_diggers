import pandas as pd
import matplotlib as plt
import seaborn as sns

#funkcja import pliku
def f_file_import(name:str):
    return pd.read_csv(name)


#funkcja agregująca dane do nowego DF
def aggregate_fun(df, agg_list:list, measure:str):
    agg_df = df.groupby(agg_list)[measure].agg(['count',sum,'mean']).reset_index()
    return agg_df



#funkcja wykres słupkowy - liczebność - jedna zmienna
def f_barplot_1_var(name, var:str):
    name.groupby(var)[var].count().sort_values(ascending = False).plot(kind = 'bar', figsize = (10,6));

#funkcja wykres słupkowy - liczebność - dwie zmienne - col x
def barplot_2var(df, var1:str, var2:str, measure):
    sns.catplot(data = df, col = var1 , x = var2, y = measure , kind = 'bar');

#funkcja wykres słupkowy - średnia - dwie zmienne
# var1 - zmienna grupująca, var2 - zmienna grupowana
def f_barplot_2_var_mean(name, var1:str, var2:str):
    name.groupby(var1)[var2].mean().sort_values(ascending=False).plot(kind='bar', figsize=(10,8));

