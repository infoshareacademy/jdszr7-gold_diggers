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

#funkcja sortująca
def sorting_values(df_agg, value_by = 'mean', sorting_var = False):
    return df_agg.sort_values(by =value_by, ascending= sorting_var).reset_index()



#funkcja wykres słupkowy - liczebność - jedna zmienna
def f_barplot_1_var(name, var:str, size:tuple = (10,6)):
    name.groupby(var)[var].count().sort_values(ascending = False).plot(kind = 'bar', figsize = size);

#funkcja wykres słupkowy - liczebność - dwie zmienne - col x
def barplot_2var(df, var1:str, var2:str, measure):
    sns.catplot(data = df, col = var1 , x = var2, y = measure , kind = 'bar');

#funkcja wykres słupkowy - średnia - dwie zmienne
# var1 - zmienna grupująca, var2 - zmienna grupowana
def f_barplot_2_var_mean(name, var1:str, var2:str, size:tuple = (10,6)):
    name.groupby(var1)[var2].mean().sort_values(ascending=False).plot(kind='bar', figsize=size);

